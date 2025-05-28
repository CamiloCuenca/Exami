package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PreguntaExamenDTO {
    private Long idPregunta;
    private String textoPregunta;
    private Integer porcentaje;
    private Integer orden;
    private List<OpcionRespuestaDTO> opciones;
} 