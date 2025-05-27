package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RespuestaEstudianteDTO {
    private Long idPregunta;
    private Long idOpcionSeleccionada;
    private String respuestaTexto; // Para preguntas abiertas
} 