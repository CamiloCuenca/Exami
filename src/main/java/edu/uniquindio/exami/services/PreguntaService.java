package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.OpcionRespuestaDisponibleDTO;
import edu.uniquindio.exami.dto.PreguntaDisponibleDTO;
import edu.uniquindio.exami.dto.PreguntaRequestDTO;
import edu.uniquindio.exami.dto.PreguntaResponseDTO;
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

import java.sql.*;
import java.util.*;
import java.util.logging.Logger;
import oracle.jdbc.OracleTypes;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;

import javax.sql.DataSource;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
@Transactional
@Slf4j
public class PreguntaService {

    private static final Logger logger = Logger.getLogger(PreguntaService.class.getName());
    
    private final JdbcTemplate jdbcTemplate;
    @Autowired
    private DataSource dataSource;
    private SimpleJdbcCall agregarPreguntaCall;

    // Códigos de resultado del procedimiento almacenado
    private static final int COD_EXITO = 0;
    private static final int COD_ERROR_PARAMETROS = 1;
    private static final int COD_DOCENTE_NO_EXISTE = 2;
    private static final int COD_TEMA_NO_EXISTE = 3;
    private static final int COD_NIVEL_NO_EXISTE = 4;
    private static final int COD_TIPO_NO_EXISTE = 5;
    private static final int COD_PREGUNTA_PADRE_NO_EXISTE = 6;
    private static final int COD_ERROR_OPCIONES = 7;
    private static final int COD_ERROR_REGISTRO = 8;
    private static final int COD_ERROR_SECUENCIA = 9;

    @Autowired
    public PreguntaService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        this.agregarPreguntaCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_AGREGAR_PREGUNTA")
                .declareParameters(
                        // Parámetros básicos de la pregunta
                        new SqlParameter("p_id_docente", Types.NUMERIC),
                        new SqlParameter("p_id_tema", Types.NUMERIC),
                        new SqlParameter("p_id_nivel_dificultad", Types.NUMERIC),
                        new SqlParameter("p_id_tipo_pregunta", Types.NUMERIC),
                        new SqlParameter("p_texto_pregunta", Types.VARCHAR),
                        new SqlParameter("p_es_publica", Types.NUMERIC),
                        new SqlParameter("p_tiempo_maximo", Types.NUMERIC),
                        new SqlParameter("p_porcentaje", Types.NUMERIC),
                        new SqlParameter("p_id_pregunta_padre", Types.NUMERIC),
                        // Parámetros para las opciones de respuesta (arrays)
                        new SqlParameter("p_textos_opciones", OracleTypes.ARRAY),
                        new SqlParameter("p_son_correctas", OracleTypes.ARRAY),
                        new SqlParameter("p_ordenes", OracleTypes.ARRAY),
                        // Parámetros de salida
                        new SqlOutParameter("p_id_pregunta_creada", Types.NUMERIC),
                        new SqlOutParameter("p_codigo_resultado", Types.NUMERIC),
                        new SqlOutParameter("p_mensaje_resultado", Types.VARCHAR)
                );
    }

    public PreguntaResponseDTO agregarPregunta(PreguntaRequestDTO request) {
        Connection connection = null;
        try {
            logger.info("Intentando crear pregunta para el tema: " + request.getIdTema());
            
            // Validación básica de datos requeridos
            if (request.getIdDocente() == null || request.getIdTema() == null || 
                request.getIdNivelDificultad() == null || request.getIdTipoPregunta() == null || 
                request.getTextoPregunta() == null || request.getTextosOpciones() == null ||
                request.getSonCorrectas() == null || request.getOrdenes() == null) {
                return new PreguntaResponseDTO(null, COD_ERROR_PARAMETROS, 
                    "Los campos obligatorios (docente, tema, nivel, tipo, texto y opciones) son requeridos");
            }

            // Validar que las listas tengan la misma longitud
            if (request.getTextosOpciones().size() != request.getSonCorrectas().size() || 
                request.getTextosOpciones().size() != request.getOrdenes().size()) {
                return new PreguntaResponseDTO(null, COD_ERROR_OPCIONES, 
                    "Las listas de textos, corrección y ordenes deben tener la misma longitud");
            }

            // Preparar los arrays para Oracle
            connection = jdbcTemplate.getDataSource().getConnection();
            
            // Obtener la conexión real de Oracle desde la conexión proxy de HikariCP
            oracle.jdbc.OracleConnection oracleConnection = null;
            if (connection.isWrapperFor(oracle.jdbc.OracleConnection.class)) {
                oracleConnection = connection.unwrap(oracle.jdbc.OracleConnection.class);
                logger.info("Conexión Oracle obtenida correctamente");
            } else {
                throw new SQLException("No se pudo obtener la conexión Oracle original");
            }
            
            // Crear descriptores de array
            ArrayDescriptor textosDescriptor = ArrayDescriptor.createDescriptor("SYS.ODCIVARCHAR2LIST", oracleConnection);
            ArrayDescriptor numerosDescriptor = ArrayDescriptor.createDescriptor("SYS.ODCINUMBERLIST", oracleConnection);
            
            // Preparar los arrays
            String[] textosArray = request.getTextosOpciones().toArray(new String[0]);
            Integer[] sonCorrectasArray = request.getSonCorrectas().toArray(new Integer[0]);
            Integer[] ordenesArray = request.getOrdenes().toArray(new Integer[0]);
            
            // Crear objetos ARRAY de Oracle
            ARRAY textosOracle = new ARRAY(textosDescriptor, oracleConnection, textosArray);
            ARRAY sonCorrectasOracle = new ARRAY(numerosDescriptor, oracleConnection, sonCorrectasArray);
            ARRAY ordenesOracle = new ARRAY(numerosDescriptor, oracleConnection, ordenesArray);

            // Preparar los parámetros
            Map<String, Object> inParams = new HashMap<>();
            inParams.put("p_id_docente", request.getIdDocente());
            inParams.put("p_id_tema", request.getIdTema());
            inParams.put("p_id_nivel_dificultad", request.getIdNivelDificultad());
            inParams.put("p_id_tipo_pregunta", request.getIdTipoPregunta());
            inParams.put("p_texto_pregunta", request.getTextoPregunta());
            inParams.put("p_es_publica", request.getEsPublica() != null ? request.getEsPublica() : 0);
            inParams.put("p_tiempo_maximo", request.getTiempoMaximo());
            inParams.put("p_porcentaje", request.getPorcentaje() != null ? request.getPorcentaje() : 100.0);
            inParams.put("p_id_pregunta_padre", request.getIdPreguntaPadre());
            inParams.put("p_textos_opciones", textosOracle);
            inParams.put("p_son_correctas", sonCorrectasOracle);
            inParams.put("p_ordenes", ordenesOracle);

            // Imprimir los parámetros para depuración
            logger.info("Parámetros enviados a SP_AGREGAR_PREGUNTA: " + inParams.toString());

            // Ejecutar el procedimiento
            Map<String, Object> result = agregarPreguntaCall.execute(inParams);
            
            // Procesar el resultado
            Long idPreguntaCreada = result.get("p_id_pregunta_creada") != null ? 
                ((Number) result.get("p_id_pregunta_creada")).longValue() : null;
            
            int codigoResultado = ((Number) result.get("p_codigo_resultado")).intValue();
            String mensajeResultado = (String) result.get("p_mensaje_resultado");

            logger.info("Resultado de crear pregunta - Código: " + codigoResultado + 
                       ", Mensaje: " + mensajeResultado);
            
            return new PreguntaResponseDTO(idPreguntaCreada, codigoResultado, mensajeResultado);

        } catch (SQLException sqle) {
            logger.severe("Error SQL al crear pregunta: " + sqle.getMessage());
            sqle.printStackTrace(); // Imprimir stack trace para depuración
            
            // Obtener causa raíz del error SQL
            Throwable rootCause = sqle;
            while (rootCause.getCause() != null) {
                rootCause = rootCause.getCause();
            }
            
            return new PreguntaResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error SQL al crear la pregunta: " + rootCause.getMessage());
        } catch (DataAccessException dae) {
            logger.severe("Error de acceso a datos al crear pregunta: " + dae.getMessage());
            dae.printStackTrace(); // Imprimir stack trace para depuración
            
            // Obtener causa raíz del error de acceso a datos
            Throwable rootCause = dae;
            while (rootCause.getCause() != null) {
                rootCause = rootCause.getCause();
            }
            
            return new PreguntaResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error técnico al crear la pregunta: " + rootCause.getMessage());
        } catch (Exception e) {
            logger.severe("Error inesperado al crear pregunta: " + e.getMessage());
            e.printStackTrace(); // Imprimir stack trace para depuración
            return new PreguntaResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error inesperado al crear la pregunta: " + e.getMessage());
        } finally {
            // Cerrar la conexión utilizada para los arrays
            if (connection != null) {
                try {
                    if (!connection.isClosed()) {
                        connection.close();
                    }
                } catch (SQLException e) {
                    logger.severe("Error al cerrar la conexión: " + e.getMessage());
                }
            }
        }
    }

    public Double obtenerPorcentajeCorrectas(Long idPresentacion) {
        Connection connection = null;
        try {
            connection = dataSource.getConnection();
            CallableStatement stmt = connection.prepareCall("{ ? = call PORCENTAJE_PREGUNTAS_CORRECTAS(?) }");

            stmt.registerOutParameter(1, Types.NUMERIC);
            stmt.setLong(2, idPresentacion);

            stmt.execute();

            return stmt.getDouble(1);

        } catch (SQLException e) {
            log.error("Error al obtener el porcentaje de respuestas correctas: {}", e.getMessage());
            return null;
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    log.error("Error al cerrar la conexión: {}", e.getMessage());
                }
            }
        }
    }


    public List<Map<String, Object>> obtenerExamenesYPocentajesPorEstudiante(Long idUsuario) {
        Connection connection = null;
        try {
            connection = dataSource.getConnection();
            CallableStatement stmt = connection.prepareCall("{ call EXA_Y_PORC_POR_ESTUE(?, ?) }");

            stmt.setLong(1, idUsuario);
            stmt.registerOutParameter(2, OracleTypes.CURSOR);

            stmt.execute();

            ResultSet resultSet = (ResultSet) stmt.getObject(2);
            List<Map<String, Object>> resultados = new ArrayList<>();

            while (resultSet.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("ID_PRESENTACION", resultSet.getLong("ID_PRESENTACION"));
                fila.put("NOMBRE_EXAMEN", resultSet.getString("NOMBRE_EXAMEN"));
                fila.put("PORCENTAJE", resultSet.getDouble("PORCENTAJE"));
                resultados.add(fila);
            }

            return resultados;

        } catch (SQLException e) {
            log.error("Error al ejecutar el procedimiento EXA_Y_PORC_POR_ESTUE: {}", e.getMessage());
            return Collections.emptyList();
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    log.error("Error al cerrar la conexión: {}", e.getMessage());
                }
            }
        }
    }

    public List<PreguntaDisponibleDTO> obtenerPreguntasDisponibles(Long idDocente, Long idTema, Long idTipoPregunta, Long idNivelDificultad) {
        Connection connection = null;
        try {
            connection = dataSource.getConnection();
            CallableStatement stmt = connection.prepareCall("{ call OBTENER_PREGUNTAS_DISPONIBLES(?, ?, ?, ?, ?) }");

            stmt.setLong(1, idDocente);
            stmt.setObject(2, idTema);
            stmt.setObject(3, idTipoPregunta);
            stmt.setObject(4, idNivelDificultad);
            stmt.registerOutParameter(5, OracleTypes.CURSOR);

            stmt.execute();

            ResultSet resultSet = (ResultSet) stmt.getObject(5);
            List<PreguntaDisponibleDTO> preguntas = new ArrayList<>();
            ObjectMapper objectMapper = new ObjectMapper();

            while (resultSet.next()) {
                PreguntaDisponibleDTO pregunta = new PreguntaDisponibleDTO();
                pregunta.setIdPregunta(resultSet.getLong("ID_PREGUNTA"));
                pregunta.setTextoPregunta(resultSet.getString("TEXTO_PREGUNTA"));
                pregunta.setIdTipoPregunta(resultSet.getLong("ID_TIPO_PREGUNTA"));
                pregunta.setNombreTipoPregunta(resultSet.getString("NOMBRE_TIPO_PREGUNTA"));
                pregunta.setIdNivelDificultad(resultSet.getLong("ID_NIVEL_DIFICULTAD"));
                pregunta.setNombreNivelDificultad(resultSet.getString("NOMBRE_NIVEL_DIFICULTAD"));
                pregunta.setIdTema(resultSet.getLong("ID_TEMA"));
                pregunta.setNombreTema(resultSet.getString("NOMBRE_TEMA"));
                pregunta.setEsPublica(resultSet.getBoolean("ES_PUBLICA"));
                pregunta.setTiempoMaximo(resultSet.getInt("TIEMPO_MAXIMO"));
                pregunta.setPorcentaje(resultSet.getDouble("PORCENTAJE"));
                pregunta.setIdEstado(resultSet.getLong("ID_ESTADO"));
                pregunta.setNombreEstado(resultSet.getString("NOMBRE_ESTADO"));

                // Procesar el JSON de opciones
                String opcionesJson = resultSet.getString("OPCIONES");
                if (opcionesJson != null) {
                    List<OpcionRespuestaDisponibleDTO> opciones = objectMapper.readValue(
                        opcionesJson,
                        objectMapper.getTypeFactory().constructCollectionType(
                            List.class, OpcionRespuestaDisponibleDTO.class
                        )
                    );
                    pregunta.setOpciones(opciones);
                }

                preguntas.add(pregunta);
            }

            return preguntas;

        } catch (Exception e) {
            log.error("Error al obtener preguntas disponibles: {}", e.getMessage());
            return Collections.emptyList();
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    log.error("Error al cerrar la conexión: {}", e.getMessage());
                }
            }
        }
    }

} 