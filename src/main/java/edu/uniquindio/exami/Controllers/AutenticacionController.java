package edu.uniquindio.exami.Controllers;

import edu.uniquindio.exami.dto.LoginRequestDTO;
import edu.uniquindio.exami.dto.LoginResponseDTO;
import edu.uniquindio.exami.dto.RegistroRequestDTO;
import edu.uniquindio.exami.dto.RegistroResponseDTO;
import edu.uniquindio.exami.services.AutenticacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/auth")
public class AutenticacionController {

    private final AutenticacionService autenticacionService;

    @Autowired
    public AutenticacionController(AutenticacionService autenticacionService) {
        this.autenticacionService = autenticacionService;
    }

    @PostMapping("/registro")
    public ResponseEntity<RegistroResponseDTO> registrarUsuario(@RequestBody RegistroRequestDTO request) {
        RegistroResponseDTO response = autenticacionService.registrarUsuario(request);
        
        // Manejar diferentes casos según el código de resultado
        switch (response.getCodigoResultado()) {
            case 0: // Éxito
                return ResponseEntity.status(HttpStatus.CREATED).body(response);
            case 1: // Email ya existe
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            case 2: // Error en parámetros
            case 4: // Tipo de usuario inválido
            case 5: // Estado inválido
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            default: // Otros errores
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> loginUsuario(@RequestBody LoginRequestDTO request) {
        LoginResponseDTO response = autenticacionService.loginUsuario(request);

        // Manejar diferentes casos según el código de resultado
        switch (response.codigoResultado()) {
            case 1: // LOGIN_EXITOSO
                return ResponseEntity.ok(response);
            case -1: // LOGIN_USUARIO_NO_ENCONTRADO
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            case -2: // LOGIN_CUENTA_INACTIVA
            case -3: // LOGIN_CUENTA_BLOQUEADA
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            case -4: // LOGIN_CONTRASENA_INCORRECTA
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            default: // LOGIN_ERROR_INESPERADO (-99)
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }


    
}
