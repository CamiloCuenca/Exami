package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RegistroRequestDTO {
    private String nombre;
    private String apellido;
    private String email;
    private String contrasena;
    private Long idTipoUsuario;
    private Long idEstado;
    private String telefono;  // Campo nuevo, opcional
    private String direccion; // Campo nuevo, opcional
} 