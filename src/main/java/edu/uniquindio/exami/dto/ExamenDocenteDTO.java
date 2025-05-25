package edu.uniquindio.exami.dto;

public record ExamenDocenteDTO(
    Long idExamen,
    String nombre,
    String descripcion,
    String fechaInicioFormateada,
    String fechaFinFormateada,
    String estado,
    String nombreTema,
    String nombreCurso,
    Integer cantidadPreguntasTotal,
    Integer cantidadPreguntasPresentar,
    Integer tiempoLimite,
    Integer pesoCurso,
    Integer umbralAprobacion,
    Integer intentosPermitidos,
    Integer mostrarResultados,
    Integer permitirRetroalimentacion
) {} 