package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.RegistroRequestDTO;
import edu.uniquindio.exami.dto.RegistroResponseDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct; // Importante para @PostConstruct
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

@Service
public class AutenticacionService {

    private final JdbcTemplate jdbcTemplate;
    private SimpleJdbcCall registrarUsuarioCompletoCall;

    @Autowired
    public AutenticacionService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void init() {
        // Configuración para SP_REGISTRAR_USUARIO_COMPLETO
        registrarUsuarioCompletoCall = new SimpleJdbcCall(jdbcTemplate)
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
        // Creamos un mapa para todos los parámetros
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

        Long idUsuarioCreado = null;
        if (result.get("p_id_usuario_creado") != null) {
            // Oracle NUMERIC puede venir como BigDecimal
            idUsuarioCreado = ((Number) result.get("p_id_usuario_creado")).longValue();
        }
        
        int codigoResultado = ((Number) result.get("p_codigo_resultado")).intValue();
        String mensajeResultado = (String) result.get("p_mensaje_resultado");

        return new RegistroResponseDTO(idUsuarioCreado, codigoResultado, mensajeResultado);
    }


   
} 