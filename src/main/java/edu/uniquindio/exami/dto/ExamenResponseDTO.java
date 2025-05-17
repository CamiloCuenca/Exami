package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ExamenResponseDTO {
    private Long idExamenCreado;
    private Integer codigoResultado;
    private String mensajeResultado;
} 