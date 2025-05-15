package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RegistroResponseDTO {
    private Long idUsuarioCreado;
    private int codigoResultado;
    private String mensajeResultado;
} 