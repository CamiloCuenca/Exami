package edu.uniquindio.exami.services;


import edu.uniquindio.exami.dto.LoginRequestDTO;
import edu.uniquindio.exami.dto.LoginResponseDTO;
import edu.uniquindio.exami.dto.RegistroRequestDTO;
import edu.uniquindio.exami.dto.RegistroResponseDTO;
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
public class AutenticacionService {

    private static final Logger logger = Logger.getLogger(AutenticacionService.class.getName());
    
    private final JdbcTemplate jdbcTemplate;
    private SimpleJdbcCall registrarUsuarioCompletoCall;
    private SimpleJdbcCall loginUsuarioCall;

    // Códigos de resultado del procedimiento almacenado
    private static final int COD_EXITO = 0;
    private static final int COD_EMAIL_YA_EXISTE = 1;
    private static final int COD_ERROR_PARAMETROS = 2;
    private static final int COD_ERROR_REGISTRO = 3;
    private static final int COD_TIPO_USUARIO_INVALIDO = 4;
    private static final int COD_ESTADO_INVALIDO = 5;
    private static final int COD_ERROR_SECUENCIA = 6;

    // Códigos de resultado para login
    private static final int LOGIN_EXITOSO = 1;
    private static final int LOGIN_USUARIO_NO_ENCONTRADO = -1;
    private static final int LOGIN_CUENTA_INACTIVA = -2;
    private static final int LOGIN_CUENTA_BLOQUEADA = -3;
    private static final int LOGIN_CONTRASENA_INCORRECTA = -4;
    private static final int LOGIN_ERROR_INESPERADO = -99;

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
        // Configuración para login
        this.loginUsuarioCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("LOGIN_USUARIO")
                .declareParameters(
                        new SqlParameter("p_correo", Types.VARCHAR),
                        new SqlParameter("p_contrasena", Types.VARCHAR),
                        new SqlOutParameter("p_id_usuario", Types.NUMERIC),
                        new SqlOutParameter("p_nombre_completo", Types.VARCHAR),
                        new SqlOutParameter("p_tipo_usuario", Types.VARCHAR),
                        new SqlOutParameter("p_resultado", Types.NUMERIC),
                        new SqlOutParameter("p_mensaje", Types.VARCHAR)
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

    public LoginResponseDTO loginUsuario(LoginRequestDTO request) {
        try {
            logger.info("Intentando inicio de sesión para: " + request.email()); // Cambiado para loggear el email

            // Validación básica
            if (request.email() == null || request.email().isEmpty() ||
                    request.contrasena() == null || request.contrasena().isEmpty()) {
                return new LoginResponseDTO(null, null, null,
                        LOGIN_CONTRASENA_INCORRECTA, "Email y contraseña son requeridos");
            }

            Map<String, Object> inParams = new HashMap<>();
            inParams.put("p_correo", request.email()); // CORRECCIÓN: Usar request.email()
            inParams.put("p_contrasena", request.contrasena());

            Map<String, Object> result = loginUsuarioCall.execute(inParams);

            Long idUsuario = result.get("p_id_usuario") != null ?
                    ((Number) result.get("p_id_usuario")).longValue() : null;
            String nombreCompleto = (String) result.get("p_nombre_completo");
            String tipoUsuario = (String) result.get("p_tipo_usuario");
            int codigoResultado = ((Number) result.get("p_resultado")).intValue();
            String mensajeResultado = (String) result.get("p_mensaje");

            logger.info("Resultado del login - Código: " + codigoResultado +
                    ", Mensaje: " + mensajeResultado);

            return new LoginResponseDTO(idUsuario, nombreCompleto, tipoUsuario,
                    codigoResultado, mensajeResultado);

        } catch (DataAccessException dae) {
            logger.severe("Error de acceso a datos al iniciar sesión: " + dae.getMessage());
            return new LoginResponseDTO(null, null, null,
                    LOGIN_ERROR_INESPERADO, "Error técnico al iniciar sesión");
        } catch (Exception e) {
            logger.severe("Error inesperado al iniciar sesión: " + e.getMessage());
            return new LoginResponseDTO(null, null, null,
                    LOGIN_ERROR_INESPERADO, "Error inesperado al iniciar sesión");
        }
    }
}