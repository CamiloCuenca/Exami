package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OpcionRespuestaDTO {
    private Long idOpcion;
    private String texto;
    private Integer orden;
} 