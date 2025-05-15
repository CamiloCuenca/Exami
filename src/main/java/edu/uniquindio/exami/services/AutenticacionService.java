package edu.uniquindio.exami.services;


import edu.uniquindio.exami.dto.RegistroRequestDTO;
import edu.uniquindio.exami.dto.RegistroResponseDTO;
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
public class AutenticacionService {

    private static final Logger logger = Logger.getLogger(AutenticacionService.class.getName());
    
    private final JdbcTemplate jdbcTemplate;
    private SimpleJdbcCall registrarUsuarioCompletoCall;

    // Códigos de resultado del procedimiento almacenado
    private static final int COD_EXITO = 0;
    private static final int COD_EMAIL_YA_EXISTE = 1;
    private static final int COD_ERROR_PARAMETROS = 2;
    private static final int COD_ERROR_REGISTRO = 3;
    private static final int COD_TIPO_USUARIO_INVALIDO = 4;
    private static final int COD_ESTADO_INVALIDO = 5;
    private static final int COD_ERROR_SECUENCIA = 6;

    @Autowired
    public AutenticacionService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        this.registrarUsuarioCompletoCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_REGISTRAR_USUARIO_COMPLETO")
                .declareParameters(
                        new SqlParameter("p_nombre", Types.VARCHAR),
                        new SqlParameter("p_apellido", Types.VARCHAR),
                        new SqlParameter("p_email", Types.VARCHAR),
                        new SqlParameter("p_contrasena", Types.VARCHAR),
                        new SqlParameter("p_id_tipo_usuario", Types.NUMERIC),
                        new SqlParameter("p_id_estado", Types.NUMERIC),
                        new SqlParameter("p_telefono", Types.VARCHAR),
                        new SqlParameter("p_direccion", Types.VARCHAR),
                        new SqlOutParameter("p_id_usuario_creado", Types.NUMERIC),
                        new SqlOutParameter("p_codigo_resultado", Types.NUMERIC),
                        new SqlOutParameter("p_mensaje_resultado", Types.VARCHAR)
                );
    }

    public RegistroResponseDTO registrarUsuario(RegistroRequestDTO request) {
        try {
            logger.info("Intentando registrar usuario: " + request.getEmail());
            
            // Validación básica de datos requeridos
            if (request.getNombre() == null || request.getApellido() == null || 
                request.getEmail() == null || request.getContrasena() == null ||
                request.getIdTipoUsuario() == null || request.getIdEstado() == null) {
                return new RegistroResponseDTO(null, COD_ERROR_PARAMETROS, 
                    "Todos los campos obligatorios deben tener valor");
            }

            Map<String, Object> inParams = new HashMap<>();
            inParams.put("p_nombre", request.getNombre());
            inParams.put("p_apellido", request.getApellido());
            inParams.put("p_email", request.getEmail());
            inParams.put("p_contrasena", request.getContrasena());
            inParams.put("p_id_tipo_usuario", request.getIdTipoUsuario());
            inParams.put("p_id_estado", request.getIdEstado());
            inParams.put("p_telefono", request.getTelefono());
            inParams.put("p_direccion", request.getDireccion());

            Map<String, Object> result = registrarUsuarioCompletoCall.execute(inParams);

            Long idUsuarioCreado = result.get("p_id_usuario_creado") != null ? 
                ((Number) result.get("p_id_usuario_creado")).longValue() : null;
            
            int codigoResultado = ((Number) result.get("p_codigo_resultado")).intValue();
            String mensajeResultado = (String) result.get("p_mensaje_resultado");

            logger.info("Resultado del registro - Código: " + codigoResultado + 
                       ", Mensaje: " + mensajeResultado);
            
            return new RegistroResponseDTO(idUsuarioCreado, codigoResultado, mensajeResultado);

        } catch (DataAccessException dae) {
            logger.severe("Error de acceso a datos al registrar usuario: " + dae.getMessage());
            return new RegistroResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error técnico al registrar el usuario");
        } catch (Exception e) {
            logger.severe("Error inesperado al registrar usuario: " + e.getMessage());
            return new RegistroResponseDTO(null, COD_ERROR_REGISTRO, 
                "Error inesperado al registrar el usuario");
        }
    }
}