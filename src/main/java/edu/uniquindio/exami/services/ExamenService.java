package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.ExamenRequestDTO;
import edu.uniquindio.exami.dto.ExamenResponseDTO;
import edu.uniquindio.exami.dto.PreguntaExamenRequestDTO;
import edu.uniquindio.exami.dto.PreguntaExamenResponseDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import jakarta.annotation.PostConstruct;
import java.sql.Connection;
import java.sql.Types;
import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;
import oracle.jdbc.OracleConnection;

@Service
@Transactional
@Slf4j
public class ExamenService {

    private static final Logger logger = Logger.getLogger(ExamenService.class.getName());
    
    private final JdbcTemplate jdbcTemplate;
    private SimpleJdbcCall crearExamenCall;

    // Códigos de resultado para respuesta al cliente
    private static final Integer COD_EXITO = 0;
    private static final Integer COD_ERROR_PARAMETROS = 1;
    private static final Integer COD_EXAMEN_NO_EXISTE = 2;
    private static final Integer COD_DOCENTE_NO_AUTORIZADO = 3;
    private static final Integer COD_EXAMEN_YA_INICIADO = 4;
    private static final Integer COD_PREGUNTA_NO_EXISTE = 5;
    private static final Integer COD_PREGUNTA_YA_ASIGNADA = 6;
    private static final Integer COD_ERROR_PORCENTAJES = 7;
    private static final Integer COD_ERROR_REGISTRO = 8;
    private static final Integer COD_ERROR_SECUENCIA = 9;
    
    @Autowired
    private DataSource dataSource;

    @Autowired
    public ExamenService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        this.crearExamenCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_CREAR_EXAMEN")
                .declareParameters(
                        new SqlParameter("p_id_docente", Types.NUMERIC),
                        new SqlParameter("p_id_tema", Types.NUMERIC),
                        new SqlParameter("p_nombre", Types.VARCHAR),
                        new SqlParameter("p_descripcion", Types.VARCHAR),
                        new SqlParameter("p_fecha_inicio", Types.TIMESTAMP),
                        new SqlParameter("p_fecha_fin", Types.TIMESTAMP),
                        new SqlParameter("p_tiempo_limite", Types.NUMERIC),
                        new SqlParameter("p_peso_curso", Types.NUMERIC),
                        new SqlParameter("p_umbral_aprobacion", Types.NUMERIC),
                        new SqlParameter("p_cantidad_preguntas_total", Types.NUMERIC),
                        new SqlParameter("p_cantidad_preguntas_presentar", Types.NUMERIC),
                        new SqlParameter("p_id_categoria", Types.NUMERIC),
                        new SqlParameter("p_intentos_permitidos", Types.NUMERIC),
                        new SqlParameter("p_mostrar_resultados", Types.NUMERIC),
                        new SqlParameter("p_permitir_retroalimentacion", Types.NUMERIC),
                        new SqlOutParameter("p_id_examen_creado", Types.NUMERIC),
                        new SqlOutParameter("p_codigo_resultado", Types.NUMERIC),
                        new SqlOutParameter("p_mensaje_resultado", Types.VARCHAR)
                );
    }

    public ExamenResponseDTO crearExamen(ExamenRequestDTO request) {
        try {
            logger.info("Intentando crear examen: " + request.getNombre());
            
            // Validación básica de datos requeridos
            if (request.getIdDocente() == null || request.getIdTema() == null || 
                request.getNombre() == null) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS, 
                    "Los campos id_docente, id_tema y nombre son obligatorios");
            }

            Map<String, Object> inParams = new HashMap<>();
            inParams.put("p_id_docente", request.getIdDocente());
            inParams.put("p_id_tema", request.getIdTema());
            inParams.put("p_nombre", request.getNombre());
            inParams.put("p_descripcion", request.getDescripcion());
            inParams.put("p_fecha_inicio", request.getFechaInicio());
            inParams.put("p_fecha_fin", request.getFechaFin());
            inParams.put("p_tiempo_limite", request.getTiempoLimite());
            inParams.put("p_peso_curso", request.getPesoCurso());
            inParams.put("p_umbral_aprobacion", request.getUmbralAprobacion());
            inParams.put("p_cantidad_preguntas_total", request.getCantidadPreguntasTotal());
            inParams.put("p_cantidad_preguntas_presentar", request.getCantidadPreguntasPresentar());
            inParams.put("p_id_categoria", request.getIdCategoria());
            inParams.put("p_intentos_permitidos", request.getIntentosPermitidos() != null ? request.getIntentosPermitidos() : 1);
            inParams.put("p_mostrar_resultados", request.getMostrarResultados() != null ? request.getMostrarResultados() : 1);
            inParams.put("p_permitir_retroalimentacion", request.getPermitirRetroalimentacion() != null ? request.getPermitirRetroalimentacion() : 1);

            Map<String, Object> result = crearExamenCall.execute(inParams);

            Long idExamenCreado = result.get("p_id_examen_creado") != null ? 
                ((Number) result.get("p_id_examen_creado")).longValue() : null;
            
            int codigoResultado = ((Number) result.get("p_codigo_resultado")).intValue();
            String mensajeResultado = (String) result.get("p_mensaje_resultado");

            logger.info("Resultado de crear examen - Código: " + codigoResultado + 
                       ", Mensaje: " + mensajeResultado);
            
            return new ExamenResponseDTO(idExamenCreado, codigoResultado, mensajeResultado);

        } catch (DataAccessException dae) {
            logger.severe("Error de acceso a datos al crear examen: " + dae.getMessage());
            return new ExamenResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error técnico al crear el examen: " + dae.getMessage());
        } catch (Exception e) {
            logger.severe("Error inesperado al crear examen: " + e.getMessage());
            return new ExamenResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error inesperado al crear el examen: " + e.getMessage());
        }
    }

    /**
     * Asigna preguntas a un examen existente.
     * Las preguntas se guardan en la tabla EXAMEN_PREGUNTA.
     * 
     * @param request DTO con la información de las preguntas a asignar
     * @return DTO con el resultado de la operación
     */
    public PreguntaExamenResponseDTO asignarPreguntasExamen(PreguntaExamenRequestDTO request) {
        Connection connection = null;
        try {
            logger.info("Intentando asignar preguntas al examen: " + request.getIdExamen());
            
            // Validación básica de datos requeridos
            if (request.getIdExamen() == null || request.getIdDocente() == null || 
                request.getIdsPreguntas() == null || request.getIdsPreguntas().isEmpty() ||
                request.getPorcentajes() == null || request.getPorcentajes().isEmpty() ||
                request.getOrdenes() == null || request.getOrdenes().isEmpty()) {
                return new PreguntaExamenResponseDTO(request.getIdExamen(), 0, COD_ERROR_PARAMETROS, 
                    "Los campos obligatorios (examen, docente, preguntas, porcentajes y órdenes) son requeridos");
            }
            
            // Validar que las listas tengan la misma longitud
            if (request.getIdsPreguntas().size() != request.getPorcentajes().size() || 
                request.getIdsPreguntas().size() != request.getOrdenes().size()) {
                return new PreguntaExamenResponseDTO(request.getIdExamen(), 0, COD_ERROR_PARAMETROS, 
                    "Las listas de preguntas, porcentajes y órdenes deben tener la misma longitud");
            }
            
            connection = dataSource.getConnection();
            
            // Convertir listas de Java a arrays de Oracle
            Array idsPreguntas = connection.unwrap(OracleConnection.class).createARRAY("SYS.ODCINUMBERLIST", 
                request.getIdsPreguntas().toArray());
            
            Array porcentajes = connection.unwrap(OracleConnection.class).createARRAY("SYS.ODCINUMBERLIST", 
                request.getPorcentajes().toArray());
            
            Array ordenes = connection.unwrap(OracleConnection.class).createARRAY("SYS.ODCINUMBERLIST", 
                request.getOrdenes().toArray());
            
            // Preparar la llamada al procedimiento almacenado
            CallableStatement stmt = connection.prepareCall(
                "{ call SP_ASIGNAR_PREGUNTAS_EXAMEN(?, ?, ?, ?, ?, ?, ?, ?) }");
            
            // Parámetros de entrada
            stmt.setLong(1, request.getIdExamen());
            stmt.setLong(2, request.getIdDocente());
            stmt.setArray(3, idsPreguntas);
            stmt.setArray(4, porcentajes);
            stmt.setArray(5, ordenes);
            
            // Parámetros de salida
            stmt.registerOutParameter(6, Types.INTEGER); // cantidad_asignadas
            stmt.registerOutParameter(7, Types.INTEGER); // codigo_resultado
            stmt.registerOutParameter(8, Types.VARCHAR); // mensaje_resultado
            
            // Ejecutar el procedimiento
            stmt.execute();
            
            // Obtener los resultados
            Integer cantidadAsignadas = stmt.getInt(6);
            Integer codigoResultado = stmt.getInt(7);
            String mensajeResultado = stmt.getString(8);
            
            // Cerrar recursos
            stmt.close();
            
            // Crear y devolver la respuesta
            return new PreguntaExamenResponseDTO(
                request.getIdExamen(),
                cantidadAsignadas,
                codigoResultado,
                mensajeResultado
            );
        } catch (SQLException e) {
            logger.severe("Error al asignar preguntas al examen: " + e.getMessage());
            return new PreguntaExamenResponseDTO(
                request.getIdExamen(),
                0, 
                COD_ERROR_REGISTRO,
                "Error al asignar preguntas al examen: " + e.getMessage()
            );
        } finally {
            // Cerrar la conexión
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    logger.severe("Error al cerrar la conexión: " + e.getMessage());
                }
            }
        }
    }
} 