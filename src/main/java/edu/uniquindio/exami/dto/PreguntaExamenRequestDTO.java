package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Size;
import java.util.List;

/**
 * DTO para la solicitud de asignación de preguntas a un examen.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PreguntaExamenRequestDTO {
    
    @NotNull(message = "El ID del examen es obligatorio")
    private Long idExamen;
    
    @NotNull(message = "El ID del docente es obligatorio")
    private Long idDocente;
    
    @NotNull(message = "La lista de preguntas no puede ser nula")
    @Size(min = 1, message = "Debe haber al menos una pregunta")
    private List<Long> idsPreguntas;
    
    @NotNull(message = "La lista de porcentajes no puede ser nula")
    @Size(min = 1, message = "Debe haber al menos un porcentaje")
    private List<Double> porcentajes;
    
    @NotNull(message = "La lista de órdenes no puede ser nula")
    @Size(min = 1, message = "Debe haber al menos un orden")
    private List<Integer> ordenes;

    @NotNull(message = "El umbral de aprobación es obligatorio")
    @Min(value = 0, message = "El umbral de aprobación debe ser mayor o igual a 0")
    @Max(value = 100, message = "El umbral de aprobación debe ser menor o igual a 100")
    private Double umbralAprobacion;

    @NotNull(message = "La cantidad total de preguntas es obligatoria")
    @Min(value = 1, message = "La cantidad total de preguntas debe ser mayor a 0")
    private Integer cantidadPreguntasTotal;

    @NotNull(message = "La cantidad de preguntas a presentar es obligatoria")
    @Min(value = 1, message = "La cantidad de preguntas a presentar debe ser mayor a 0")
    private Integer cantidadPreguntasPresentar;
} 