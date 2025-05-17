package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.ExamenRequestDTO;
import edu.uniquindio.exami.dto.ExamenResponseDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@Service
@Transactional
@Slf4j
public class ExamenService {

    private static final Logger logger = Logger.getLogger(ExamenService.class.getName());
    
    private final JdbcTemplate jdbcTemplate;
    private SimpleJdbcCall crearExamenCall;

    // Códigos de resultado del procedimiento almacenado
    private static final int COD_EXITO = 0;
    private static final int COD_ERROR_PARAMETROS = 1;
    private static final int COD_DOCENTE_NO_EXISTE = 2;
    private static final int COD_TEMA_NO_EXISTE = 3;
    private static final int COD_CATEGORIA_NO_EXISTE = 4;
    private static final int COD_ERROR_FECHAS = 5;
    private static final int COD_ERROR_CANTIDADES = 6;
    private static final int COD_ERROR_REGISTRO = 7;
    private static final int COD_ERROR_SECUENCIA = 8;

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
} 