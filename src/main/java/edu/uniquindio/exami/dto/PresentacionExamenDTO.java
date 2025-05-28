package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PresentacionExamenDTO {
    private Long idPresentacion;
    private Long idExamen;
    private Long idEstudiante;
    private Instant fechaInicio;
    private Instant fechaFin;
    private Integer tiempoLimite;
    private Integer tiempoUtilizado;
    private String estado;
} 