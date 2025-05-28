package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RespuestaResponseDTO {
    private boolean correcta;
    private String retroalimentacion;
    private BigDecimal puntajeObtenido;
} 