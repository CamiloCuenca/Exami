package edu.uniquindio.exami.dto;

public record ExamenCardDTO(
        Long idExamen,
        String nombre,
        String descripcion,
        String fechaInicio,
        String fechaFin,
        String estado,
        String nombreTema,
        String nombreCurso
) {}