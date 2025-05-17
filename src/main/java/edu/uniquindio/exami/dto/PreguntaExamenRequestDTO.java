package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO para la solicitud de asignación de preguntas a un examen.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PreguntaExamenRequestDTO {
    
    private Long idExamen;
    private Long idDocente;
    private List<Long> idsPreguntas;
    private List<Integer> porcentajes;
    private List<Integer> ordenes;
} 