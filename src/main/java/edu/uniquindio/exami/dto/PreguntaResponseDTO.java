package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PreguntaResponseDTO {
    private Long idPreguntaCreada;
    private Integer codigoResultado;
    private String mensajeResultado;
} 