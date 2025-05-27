package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
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
import org.springframework.jdbc.core.RowMapper;

@Service
@Transactional
@Slf4j
public class ExamenService {


    private static final int COD_ERROR = -1;
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

            // Validación de fechas
            if (request.getFechaInicio() == null || request.getFechaFin() == null) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "Las fechas de inicio y fin son obligatorias");
            }

            if (request.getFechaInicio().isAfter(request.getFechaFin())) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "La fecha de inicio debe ser anterior a la fecha de fin");
            }

            // Validación de tiempo límite
            if (request.getTiempoLimite() == null || request.getTiempoLimite() <= 0) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "El tiempo límite debe ser mayor a 0");
            }

            // Validación de peso del curso
            if (request.getPesoCurso() == null || request.getPesoCurso() <= 0 || request.getPesoCurso() > 100) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "El peso del curso debe estar entre 1 y 100");
            }

            // Validación de umbral de aprobación
            if (request.getUmbralAprobacion() == null || request.getUmbralAprobacion() < 0 || request.getUmbralAprobacion() > 100) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "El umbral de aprobación debe estar entre 0 y 100");
            }

            // Validación de cantidad de preguntas
            if (request.getCantidadPreguntasTotal() == null || request.getCantidadPreguntasTotal() <= 0) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "La cantidad total de preguntas debe ser mayor a 0");
            }

            if (request.getCantidadPreguntasPresentar() == null || request.getCantidadPreguntasPresentar() <= 0) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "La cantidad de preguntas a presentar debe ser mayor a 0");
            }

            if (request.getCantidadPreguntasPresentar() > request.getCantidadPreguntasTotal()) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "La cantidad de preguntas a presentar no puede ser mayor a la cantidad total de preguntas");
            }

            // Validación de intentos permitidos
            if (request.getIntentosPermitidos() != null && request.getIntentosPermitidos() <= 0) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "Los intentos permitidos deben ser mayores a 0");
            }

            // Validación de longitud del nombre
            if (request.getNombre().length() > 100) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "El nombre del examen no puede exceder los 100 caracteres");
            }

            // Validación de longitud de la descripción
            if (request.getDescripcion() != null && request.getDescripcion().length() > 500) {
                return new ExamenResponseDTO(null, COD_ERROR_PARAMETROS,
                    "La descripción del examen no puede exceder los 500 caracteres");
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

    /**
     * Obtiene la lista de exámenes de un estudiante para mostrar en cards
     * @param idEstudiante ID del estudiante
     * @return Lista de DTOs con información para las cards
     */
    public List<ExamenCardDTO> listarExamenesEstudiante(Long idEstudiante) {
        List<ExamenCardDTO> examenes = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             CallableStatement stmt = conn.prepareCall("{? = call OBTENER_EXAMENES_ESTUDIANTE(?)}")) {

            // Registrar parámetros
            stmt.registerOutParameter(1, Types.REF_CURSOR);
            stmt.setLong(2, idEstudiante);

            // Ejecutar función
            stmt.execute();

            // Obtener el cursor de resultados
            try (ResultSet rs = (ResultSet) stmt.getObject(1)) {
                while (rs.next()) {
                    ExamenCardDTO card = new ExamenCardDTO(
                            rs.getLong("ID_EXAMEN"),
                            rs.getString("NOMBRE"),
                            rs.getString("DESCRIPCION"),
                            rs.getString("FECHA_INICIO_FORMATEADA"),
                            rs.getString("FECHA_FIN_FORMATEADA"),
                            rs.getString("ESTADO"),
                            rs.getString("NOMBRE_TEMA"),
                            rs.getString("NOMBRE_CURSO")
                    );
                    examenes.add(card);
                }
            }

        } catch (SQLException e) {
            logger.severe("Error al listar exámenes del estudiante: " + e.getMessage());
            throw new RuntimeException("Error al obtener exámenes", e);
        }

        return examenes;
    }

    /**
     * Obtiene la lista de exámenes creados por un docente
     * @param idDocente ID del docente
     * @return Lista de DTOs con información detallada de los exámenes
     */
    public List<ExamenDocenteDTO> listarExamenesDocente(Long idDocente) {
        List<ExamenDocenteDTO> examenes = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             CallableStatement stmt = conn.prepareCall("{? = call OBTENER_EXAMENES_DOCENTE(?)}")) {

            // Registrar parámetros
            stmt.registerOutParameter(1, Types.REF_CURSOR);
            stmt.setLong(2, idDocente);

            // Ejecutar función
            stmt.execute();

            // Obtener el cursor de resultados
            try (ResultSet rs = (ResultSet) stmt.getObject(1)) {
                while (rs.next()) {
                    ExamenDocenteDTO examen = new ExamenDocenteDTO(
                            rs.getLong("ID_EXAMEN"),
                            rs.getString("NOMBRE"),
                            rs.getString("DESCRIPCION"),
                            rs.getString("FECHA_INICIO_FORMATEADA"),
                            rs.getString("FECHA_FIN_FORMATEADA"),
                            rs.getString("ESTADO"),
                            rs.getString("NOMBRE_TEMA"),
                            rs.getString("NOMBRE_CURSO"),
                            rs.getInt("CANTIDAD_PREGUNTAS_TOTAL"),
                            rs.getInt("CANTIDAD_PREGUNTAS_PRESENTAR"),
                            rs.getInt("TIEMPO_LIMITE"),
                            rs.getInt("PESO_CURSO"),
                            rs.getInt("UMBRAL_APROBACION"),
                            rs.getInt("INTENTOS_PERMITIDOS"),
                            rs.getInt("MOSTRAR_RESULTADOS"),
                            rs.getInt("PERMITIR_RETROALIMENTACION")
                    );
                    examenes.add(examen);
                }
            }

        } catch (SQLException e) {
            logger.severe("Error al listar exámenes del docente: " + e.getMessage());
            throw new RuntimeException("Error al obtener exámenes del docente", e);
        }

        return examenes;
    }


    @Transactional
    public PreguntaResponseDTO agregarPregunta(PreguntaRequestDTO request) {
        Connection connection = null;
        try {
            log.info("Intentando agregar pregunta con texto: {}", request.getTextoPregunta());

            // Validaciones básicas
            if (!validarRequest(request)) {
                return new PreguntaResponseDTO(null, COD_ERROR_PARAMETROS,
                        "Error en los parámetros de entrada");
            }

            connection = dataSource.getConnection();
            OracleConnection oracleConn = connection.unwrap(OracleConnection.class);

            // Convertir listas a arrays Oracle
            Array textosArray = oracleConn.createARRAY("SYS.ODCIVARCHAR2LIST",
                    request.getTextosOpciones().toArray());

            Array correctasArray = oracleConn.createARRAY("SYS.ODCINUMBERLIST",
                    request.getSonCorrectas().toArray());

            Array ordenesArray = oracleConn.createARRAY("SYS.ODCINUMBERLIST",
                    request.getOrdenes().toArray());

            // Llamar al procedimiento almacenado
            CallableStatement stmt = connection.prepareCall(
                    "{ call SP_AGREGAR_PREGUNTA(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) }");

            // Parámetros de entrada
            stmt.setLong(1, request.getIdDocente());
            stmt.setLong(2, request.getIdTema());
            stmt.setLong(3, request.getIdNivelDificultad());
            stmt.setLong(4, request.getIdTipoPregunta());
            stmt.setString(5, request.getTextoPregunta());
            stmt.setInt(6, request.getEsPublica());
            stmt.setObject(7, request.getTiempoMaximo());
            stmt.setDouble(8, request.getPorcentaje() != null ? request.getPorcentaje() : 100.0);
            stmt.setObject(9, request.getIdPreguntaPadre());
            stmt.setArray(10, textosArray);
            stmt.setArray(11, correctasArray);
            stmt.setArray(12, ordenesArray);

            // Parámetros de salida
            stmt.registerOutParameter(13, java.sql.Types.NUMERIC); // p_id_pregunta_creada
            stmt.registerOutParameter(14, java.sql.Types.NUMERIC); // p_codigo_resultado
            stmt.registerOutParameter(15, java.sql.Types.VARCHAR); // p_mensaje_resultado

            // Ejecutar
            stmt.execute();

            // Obtener resultados
            Long idPreguntaCreada = stmt.getLong(13);
            Integer codigoResultado = stmt.getInt(14);
            String mensajeResultado = stmt.getString(15);

            return new PreguntaResponseDTO(
                    idPreguntaCreada,
                    codigoResultado,
                    mensajeResultado
            );

        } catch (SQLException e) {
            log.error("Error SQL al agregar pregunta: {}", e.getMessage());
            return new PreguntaResponseDTO(null, COD_ERROR_REGISTRO,
                    "Error técnico al agregar la pregunta: " + e.getMessage());
        } catch (DataAccessException e) {
            log.error("Error de acceso a datos al agregar pregunta: {}", e.getMessage());
            return new PreguntaResponseDTO(null, COD_ERROR_REGISTRO,
                    "Error de acceso a datos: " + e.getMessage());
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    log.error("Error al cerrar conexión: {}", e.getMessage());
                }
            }
        }
    }

    private boolean validarRequest(PreguntaRequestDTO request) {
        // Validar campos obligatorios
        if (request.getIdDocente() == null ||
                request.getIdTema() == null ||
                request.getIdNivelDificultad() == null ||
                request.getIdTipoPregunta() == null ||
                request.getTextoPregunta() == null ||
                request.getEsPublica() == null) {
            log.warn("Faltan campos obligatorios en la solicitud");
            return false;
        }

        // Validar opciones de respuesta
        if (request.getTextosOpciones() == null || request.getTextosOpciones().isEmpty() ||
                request.getSonCorrectas() == null || request.getSonCorrectas().isEmpty() ||
                request.getOrdenes() == null || request.getOrdenes().isEmpty()) {
            log.warn("Debe haber al menos una opción de respuesta");
            return false;
        }

        // Validar que las listas tengan la misma longitud
        if (request.getTextosOpciones().size() != request.getSonCorrectas().size() ||
                request.getTextosOpciones().size() != request.getOrdenes().size()) {
            log.warn("Las listas de opciones deben tener la misma longitud");
            return false;
        }

        // Validar longitud del texto de la pregunta
        if (request.getTextoPregunta().length() > 1000) {
            log.warn("El texto de la pregunta excede los 1000 caracteres");
            return false;
        }

        // Validar valores de las opciones correctas
        for (Integer esCorrecta : request.getSonCorrectas()) {
            if (esCorrecta != 0 && esCorrecta != 1) {
                log.warn("Valores incorrectos en sonCorrectas (deben ser 0 o 1)");
                return false;
            }
        }

        return true;
    }


    /**
     * Obtiene la lista de exámenes pendientes para un estudiante.
     * @param idEstudiante ID del estudiante
     * @return Lista de DTOs con información de los exámenes pendientes
     */
    public List<ExamenCardDTO> listarExamenesPendientesEstudiante(Long idEstudiante) {
        List<ExamenCardDTO> examenesPendientes = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             CallableStatement stmt = conn.prepareCall("{? = call EXAMENES_PENDIENTES_EST(?)}")) {

            // Registrar parámetros
            stmt.registerOutParameter(1, Types.REF_CURSOR);
            stmt.setLong(2, idEstudiante);

            // Ejecutar función
            stmt.execute();

            // Obtener el cursor de resultados
            try (ResultSet rs = (ResultSet) stmt.getObject(1)) {
                while (rs.next()) {
                    ExamenCardDTO examen = new ExamenCardDTO(
                            rs.getLong("ID_EXAMEN"),
                            rs.getString("NOMBRE"),
                            rs.getString("DESCRIPCION"),
                            rs.getString("FECHA_INICIO_FORMATEADA"),
                            rs.getString("FECHA_FIN_FORMATEADA"),
                            rs.getString("ESTADO"),
                            rs.getString("NOMBRE_TEMA"),
                            rs.getString("NOMBRE_CURSO")
                    );
                    examenesPendientes.add(examen);
                }
            }

        } catch (SQLException e) {
            logger.severe("Error al listar exámenes pendientes del estudiante: " + e.getMessage());
            throw new RuntimeException("Error al obtener exámenes pendientes", e);
        }

        return examenesPendientes;
    }

/**
 * Obtiene la lista de exámenes en progreso para un estudiante.
 * @param idEstudiante ID del estudiante
 * @return Lista de DTOs con información de los exámenes en progreso
 */
public List<ExamenCardDTO> listarExamenesEnProgresoEstudiante(Long idEstudiante) {
    List<ExamenCardDTO> examenesEnProgreso = new ArrayList<>();

    try (Connection conn = dataSource.getConnection();
         CallableStatement stmt = conn.prepareCall("{? = call OBT_EXA_PROGRESO_EST(?)}")) {

        // Registrar parámetros
        stmt.registerOutParameter(1, Types.REF_CURSOR);
        stmt.setLong(2, idEstudiante);

        // Ejecutar función
        stmt.execute();

        // Obtener el cursor de resultados
        try (ResultSet rs = (ResultSet) stmt.getObject(1)) {
            while (rs.next()) {
                ExamenCardDTO examen = new ExamenCardDTO(
                        rs.getLong("ID_EXAMEN"),
                        rs.getString("NOMBRE"),
                        rs.getString("DESCRIPCION"),
                        rs.getString("FECHA_INICIO_FORMATEADA"),
                        rs.getString("FECHA_FIN_FORMATEADA"),
                        rs.getString("ESTADO"),
                        rs.getString("NOMBRE_TEMA"),
                        rs.getString("NOMBRE_CURSO")
                );
                examenesEnProgreso.add(examen);
            }
        }

    } catch (SQLException e) {
        logger.severe("Error al listar exámenes en progreso del estudiante: " + e.getMessage());
        throw new RuntimeException("Error al obtener exámenes en progreso", e);
    }

    return examenesEnProgreso;
}

/**
 * Obtiene la lista de exámenes expirados para un estudiante.
 * @param idEstudiante ID del estudiante
 * @return Lista de DTOs con información de los exámenes expirados
 */
public List<ExamenCardDTO> listarExamenesExpiradosEstudiante(Long idEstudiante) {
    List<ExamenCardDTO> examenesExpirados = new ArrayList<>();

    try (Connection conn = dataSource.getConnection();
         CallableStatement stmt = conn.prepareCall("{? = call EXAMENES_EXPIRADOS_EST(?)}")) {

        // Registrar parámetros
        stmt.registerOutParameter(1, Types.REF_CURSOR);
        stmt.setLong(2, idEstudiante);

        // Ejecutar función
        stmt.execute();

        // Obtener el cursor de resultados
        try (ResultSet rs = (ResultSet) stmt.getObject(1)) {
            while (rs.next()) {
                ExamenCardDTO examen = new ExamenCardDTO(
                        rs.getLong("ID_EXAMEN"),
                        rs.getString("NOMBRE"),
                        rs.getString("DESCRIPCION"),
                        rs.getString("FECHA_INICIO_FORMATEADA"),
                        rs.getString("FECHA_FIN_FORMATEADA"),
                        rs.getString("ESTADO"),
                        rs.getString("NOMBRE_TEMA"),
                        rs.getString("NOMBRE_CURSO")
                );
                examenesExpirados.add(examen);
            }
        }

    } catch (SQLException e) {
        logger.severe("Error al listar exámenes expirados del estudiante: " + e.getMessage());
        throw new RuntimeException("Error al obtener exámenes expirados", e);
    }

    return examenesExpirados;
}

    public NotaResponseDTO calcularNotaEstudiante(Long idPresentacion) {
        Connection connection = null;
        try {
            log.info("Calculando nota para la presentación ID: {}", idPresentacion);

            connection = dataSource.getConnection();

            // Preparar llamada a la función PL/SQL
            CallableStatement stmt = connection.prepareCall("{ ? = call CALCULAR_NOTA_ESTUDIANTE(?) }");

            // Registrar tipo de retorno (el primer parámetro es el return)
            stmt.registerOutParameter(1, Types.NUMERIC);

            // Setear parámetro de entrada
            stmt.setLong(2, idPresentacion);

            // Ejecutar
            stmt.execute();

            // Obtener resultado
            Double notaTotal = stmt.getDouble(1);

            return new NotaResponseDTO(notaTotal, COD_EXITO, "Cálculo exitoso");

        } catch (SQLException e) {
            log.error("Error SQL al calcular nota: {}", e.getMessage());
            return new NotaResponseDTO(null, COD_ERROR, "Error técnico: " + e.getMessage());
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    log.error("Error cerrando conexión: {}", e.getMessage());
                }
            }
        }
    }

    
    public List<ExamenEstadoDTO> obtenerExamenesPorEstadoYEstudiante(Integer idEstado, Integer idEstudiante) {
        try (Connection conn = dataSource.getConnection();
             CallableStatement stmt = conn.prepareCall("{call OBTENER_EXAMENES_POR_ESTADO_Y_ESTUDIANTE(?, ?, ?)}")) {
    
            // Registrar parámetros
            stmt.setInt(1, idEstado);
            stmt.setInt(2, idEstudiante);
            stmt.registerOutParameter(3, Types.REF_CURSOR);
    
            // Ejecutar función
            stmt.execute();
    
            // Obtener el cursor de resultados
            try (ResultSet rs = (ResultSet) stmt.getObject(3)) {
                List<ExamenEstadoDTO> examenes = new ArrayList<>();
                while (rs.next()) {
                    examenes.add(new ExamenEstadoDTO(
                        rs.getLong("ID_EXAMEN"),
                        rs.getString("NOMBRE"),
                        rs.getString("DESCRIPCION"),
                        rs.getString("FECHA_INICIO"),
                        rs.getString("FECHA_FIN"),
                        rs.getInt("TIEMPO_LIMITE"),
                        rs.getInt("PESO_CURSO"),
                        rs.getInt("UMBRAL_APROBACION"),
                        rs.getString("NOMBRE_TEMA"),
                        rs.getString("NOMBRE_CURSO"),
                        rs.getString("NOMBRE_ESTADO"),
                        rs.getLong("ID_PRESENTACION"),
                        rs.getDouble("PUNTAJE_OBTENIDO"),
                        rs.getInt("TIEMPO_UTILIZADO")
                    ));
                }
                return examenes;
            }
        } catch (SQLException e) {
            logger.severe("Error al obtener exámenes por estado y estudiante: " + e.getMessage());
            throw new RuntimeException("Error al obtener los exámenes: " + e.getMessage());
        }
    }
}