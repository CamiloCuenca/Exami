package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TipoPreguntaDTO {
    private Long idTipoPregunta;
    private String nombre;
    private String descripcion;
} 