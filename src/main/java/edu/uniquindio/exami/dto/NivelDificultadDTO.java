package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NivelDificultadDTO {
    private Long idNivelDificultad;
    private String nombre;
    private String descripcion;
} 