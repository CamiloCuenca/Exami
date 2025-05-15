package edu.uniquindio.exami.dto;

public record LoginResponseDTO(
        Long idUsuario,
        String nombreCompleto,
        String tipoUsuario,
        int codigoResultado,
        String mensajeResultado
) {
}
