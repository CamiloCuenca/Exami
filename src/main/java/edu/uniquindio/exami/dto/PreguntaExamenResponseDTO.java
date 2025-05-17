package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para la respuesta de asignación de preguntas a un examen.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PreguntaExamenResponseDTO {
    
    private Long idExamen;
    private Integer cantidadAsignadas;
    private Integer codigoResultado;
    private String mensajeResultado;
} 