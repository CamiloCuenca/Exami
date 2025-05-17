package edu.uniquindio.exami.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ExamenRequestDTO {
    private Long idDocente;
    private Long idTema;
    private String nombre;
    private String descripcion;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;
    private Integer tiempoLimite;
    private Double pesoCurso;
    private Double umbralAprobacion;
    private Integer cantidadPreguntasTotal;
    private Integer cantidadPreguntasPresentar;
    private Long idCategoria;
    private Integer intentosPermitidos;
    private Integer mostrarResultados;
    private Integer permitirRetroalimentacion;
} 