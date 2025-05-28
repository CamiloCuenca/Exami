package edu.uniquindio.exami.dto;

import lombok.Data;
import java.util.List;

@Data
public class PreguntaDisponibleDTO {
    private Long idPregunta;
    private String textoPregunta;
    private Long idTipoPregunta;
    private String nombreTipoPregunta;
    private Long idNivelDificultad;
    private String nombreNivelDificultad;
    private Long idTema;
    private String nombreTema;
    private Boolean esPublica;
    private Integer tiempoMaximo;
    private Double porcentaje;
    private Long idEstado;
    private String nombreEstado;
    private List<OpcionRespuestaDisponibleDTO> opciones;
} 