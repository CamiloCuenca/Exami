package edu.uniquindio.exami.services;
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
    @Rollback
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

        service.registrarUsuario(request);
   
    }

  
} 