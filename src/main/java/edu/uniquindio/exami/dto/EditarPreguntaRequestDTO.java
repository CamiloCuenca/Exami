package edu.uniquindio.exami.dto;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class EditarPreguntaRequestDTO {
    private Long idPregunta;
    private String textoPregunta;
    private Long idTema;
    private Long idNivelDificultad;
    private Long idTipoPregunta;

}
