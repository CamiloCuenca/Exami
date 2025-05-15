package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.LoginRequestDTO;
import edu.uniquindio.exami.dto.LoginResponseDTO;
import edu.uniquindio.exami.dto.RegistroRequestDTO;
import edu.uniquindio.exami.dto.RegistroResponseDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles; // Opcional, para perfiles de prueba

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
// @ActiveProfiles("test") // Descomenta si tienes un application-test.properties
public class AutenticacionServiceTest {

    @Autowired
    private AutenticacionService autenticacionService;

    // IDs para TipoUsuario y Estado (ajústalos a los que tengas en tu BD de prueba)
    private final Long ID_TIPO_USUARIO_PRUEBA = 1L; // Ejemplo
    private final Long ID_ESTADO_ACTIVO_PRUEBA = 1L;   // Ejemplo

    @Test
    void testRegistroYLoginExitoso() {
        // Generar un email único para cada ejecución de prueba para evitar conflictos
        String emailUnico = "testuser_" + System.currentTimeMillis() + "@example.com";
        
        // 1. Probar Registro Exitoso
        RegistroRequestDTO registroRequest = new RegistroRequestDTO(
                "Usuario",
                "Prueba",
                emailUnico,
                "claveSegura123", // Recuerda que es texto plano en este ejemplo
                ID_TIPO_USUARIO_PRUEBA,
                ID_ESTADO_ACTIVO_PRUEBA
        );

        RegistroResponseDTO registroResponse = autenticacionService.registrarUsuario(registroRequest);

        assertNotNull(registroResponse, "La respuesta de registro no debería ser nula.");
        assertEquals(0, registroResponse.getCodigoResultado(), "El código de resultado del registro debería ser 0 (éxito). Mensaje: " + registroResponse.getMensajeResultado());
        assertNotNull(registroResponse.getIdUsuarioCreado(), "El ID del usuario creado no debería ser nulo.");
        assertTrue(registroResponse.fueExitoso(), "El registro debería haber sido exitoso. Mensaje: " + registroResponse.getMensajeResultado());
        System.out.println("Registro exitoso: " + registroResponse.getMensajeResultado() + ", ID Usuario: " + registroResponse.getIdUsuarioCreado());


        // 2. Probar Login Exitoso con el usuario recién registrado
        LoginRequestDTO loginRequest = new LoginRequestDTO(emailUnico, "claveSegura123");
        LoginResponseDTO loginResponse = autenticacionService.loginUsuario(loginRequest);

        assertNotNull(loginResponse, "La respuesta de login no debería ser nula.");
        assertEquals(0, loginResponse.getCodigoResultado(), "El código de resultado del login debería ser 0 (éxito). Mensaje: " + loginResponse.getMensajeResultado());
        assertTrue(loginResponse.fueExitoso(), "El login debería haber sido exitoso. Mensaje: " + loginResponse.getMensajeResultado());
        assertNotNull(loginResponse.getIdUsuario(), "El ID de usuario en login no debería ser nulo.");
        assertEquals(registroResponse.getIdUsuarioCreado(), loginResponse.getIdUsuario(), "El ID de usuario del login debe coincidir con el del registro.");
        assertNotNull(loginResponse.getNombreCompleto(), "El nombre completo no debería ser nulo.");
        System.out.println("Login exitoso: " + loginResponse.getMensajeResultado() + ", Nombre: " + loginResponse.getNombreCompleto());
    }

    @Test
    void testRegistroEmailExistente() {
        // Primero, registra un usuario
        String emailExistente = "usuario_existente_" + System.currentTimeMillis() + "@example.com";
        RegistroRequestDTO primerRegistro = new RegistroRequestDTO("Test", "Existente", emailExistente, "password", ID_TIPO_USUARIO_PRUEBA, ID_ESTADO_ACTIVO_PRUEBA);
        RegistroResponseDTO primeraRespuesta = autenticacionService.registrarUsuario(primerRegistro);
        assertTrue(primeraRespuesta.fueExitoso(), "El primer registro debería ser exitoso para esta prueba.");

        // Intenta registrarlo de nuevo con el mismo email
        RegistroRequestDTO segundoRegistroRequest = new RegistroRequestDTO("Otro", "Usuario", emailExistente, "otraClave", ID_TIPO_USUARIO_PRUEBA, ID_ESTADO_ACTIVO_PRUEBA);
        RegistroResponseDTO segundaRespuesta = autenticacionService.registrarUsuario(segundoRegistroRequest);

        assertNotNull(segundaRespuesta, "La respuesta del segundo registro no debería ser nula.");
        assertEquals(1, segundaRespuesta.getCodigoResultado(), "El código de resultado debería ser 1 (Email ya existe)."); // Ajusta el código si es diferente
        assertFalse(segundaRespuesta.fueExitoso(), "El segundo registro no debería ser exitoso.");
        System.out.println("Prueba Email Existente: " + segundaRespuesta.getMensajeResultado());
    }
    
    @Test
    void testLoginUsuarioNoExistente() {
        LoginRequestDTO loginRequest = new LoginRequestDTO("noexiste@example.com", "cualquiercosa");
        LoginResponseDTO loginResponse = autenticacionService.loginUsuario(loginRequest);

        assertNotNull(loginResponse);
        assertEquals(1, loginResponse.getCodigoResultado()); // Asumiendo que 1 es CREDENCIALES_INVALIDAS
        assertFalse(loginResponse.fueExitoso());
        System.out.println("Prueba Login Usuario No Existente: " + loginResponse.getMensajeResultado());
    }

    @Test
    void testLoginContrasenaIncorrecta() {
        // Primero, registra un usuario
        String emailParaLoginFallido = "login_fallido_" + System.currentTimeMillis() + "@example.com";
        RegistroRequestDTO registro = new RegistroRequestDTO("Usuario", "LoginFallido", emailParaLoginFallido, "claveCorrecta", ID_TIPO_USUARIO_PRUEBA, ID_ESTADO_ACTIVO_PRUEBA);
        autenticacionService.registrarUsuario(registro); // Asumimos que es exitoso

        // Intenta login con contraseña incorrecta
        LoginRequestDTO loginRequest = new LoginRequestDTO(emailParaLoginFallido, "claveIncorrecta");
        LoginResponseDTO loginResponse = autenticacionService.loginUsuario(loginRequest);

        assertNotNull(loginResponse);
        assertEquals(1, loginResponse.getCodigoResultado()); // Asumiendo que 1 es CREDENCIALES_INVALIDAS
        assertFalse(loginResponse.fueExitoso());
        System.out.println("Prueba Login Contraseña Incorrecta: " + loginResponse.getMensajeResultado());
    }

    // Podrías añadir más pruebas:
    // - Login con cuenta no activa (necesitarías poder crear un usuario con estado no activo)
    // - Pruebas de valores nulos o inválidos en los DTOs de entrada (aunque los procedimientos PL/SQL deberían manejarlos también)
} 