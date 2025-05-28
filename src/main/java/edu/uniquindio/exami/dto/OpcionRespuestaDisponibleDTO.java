package edu.uniquindio.exami.dto;

import lombok.Data;

@Data
public class OpcionRespuestaDisponibleDTO {
    private Long idOpcion;
    private String textoOpcion;
    private Boolean esCorrecta;
    private Integer orden;
} 