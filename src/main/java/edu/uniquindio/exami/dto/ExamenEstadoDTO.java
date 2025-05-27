package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class ExamenEstadoDTO {
    private Long idExamen;
    private String nombre;
    private String descripcion;
    private String fechaInicio;
    private String fechaFin;
    private Integer tiempoLimite;
    private Integer pesoCurso;
    private Integer umbralAprobacion;
    private String nombreTema;
    private String nombreCurso;
    private String nombreEstado;
    private Long idPresentacion;
    private Double puntajeObtenido;
    private Integer tiempoUtilizado;
} 