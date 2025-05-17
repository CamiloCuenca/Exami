package edu.uniquindio.exami.services;
import edu.uniquindio.exami.dto.LoginRequestDTO;
import edu.uniquindio.exami.dto.LoginResponseDTO;
import edu.uniquindio.exami.dto.RegistroRequestDTO;
import edu.uniquindio.exami.dto.RegistroResponseDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ActiveProfiles; // Opcional, para perfiles de prueba

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class AutenticacionServiceTest {

    @Autowired
    private AutenticacionService service;

    @Test
    @Rollback(false)  // Esto evita que se haga rollback de la transacción
    void registrarUsuario() {
        // Genera un email único con timestamp
        String uniqueEmail = "test." + System.currentTimeMillis() + "@uqvirtual.edu.co";
        
        RegistroRequestDTO request = new RegistroRequestDTO();
        request.setNombre("Test");
        request.setApellido("User");
        request.setEmail(uniqueEmail);  // Email único garantizado
        request.setContrasena("Password123!");
        request.setIdTipoUsuario(1L);  // Asegúrate que exista
        request.setIdEstado(1L);       // Asegúrate que exista
        request.setTelefono("3001234567");
        request.setDireccion("Test Address");

        RegistroResponseDTO response = service.registrarUsuario(request);
        
        // Verificar resultado
        System.out.println("===================================");
        System.out.println("Resultado del registro:");
        System.out.println("Código: " + response.getCodigoResultado());
        System.out.println("Mensaje: " + response.getMensajeResultado());
        System.out.println("ID Usuario: " + response.getIdUsuarioCreado());
        System.out.println("Email: " + request.getEmail());
        System.out.println("===================================");
        
        // Verificar que el registro fue exitoso
        assertEquals(0, response.getCodigoResultado(), "El código de resultado debería ser 0 (éxito)");
        assertNotNull(response.getIdUsuarioCreado(), "El ID de usuario no debería ser nulo");
        
        /* 
         * SQL para consultar el usuario en la base de datos:
         * 
         * SELECT * FROM USUARIO WHERE ID_USUARIO = [ID_USUARIO_CREADO];
         *
         * O para ver el usuario por email:
         * 
         * SELECT * FROM USUARIO WHERE EMAIL = '[EMAIL]';
         */
    }

    @Test
    void loginUsuarioBasico() {
        // Usar credenciales de un usuario que ya existe en tu BD de prueba
        LoginRequestDTO request = new LoginRequestDTO("juan.perez@uni.edu", "JuanP3rez#2024");
        LoginResponseDTO response = service.loginUsuario(request);

        assertEquals(1, response.codigoResultado());


    }

} 