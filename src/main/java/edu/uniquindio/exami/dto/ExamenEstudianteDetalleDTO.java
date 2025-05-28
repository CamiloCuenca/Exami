package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ExamenEstudianteDetalleDTO {
    // Campos del Examen
    private Long idExamen;
    private String nombreExamen;
    private String descripcion;
    private String fechaInicioExamenFormateada;
    private String fechaFinExamenFormateada;
    private Integer tiempoLimite;
    private BigDecimal pesoCurso; // Usar BigDecimal para precisión
    private BigDecimal umbralAprobacion; // Usar BigDecimal
    private Integer cantidadPreguntasTotal;
    private Integer cantidadPreguntasPresentar;
    private Integer intentosPermitidos;
    private Integer mostrarResultados; // Podría mapearse a Boolean si quieres
    private Integer permitirRetroalimentacion; // Podría mapearse a Boolean

    // Campos de Tablas Relacionadas
    private String nombreTema;
    private String nombreCurso;
    private String nombreEstadoExamen; // Estado general del Examen

    // Información de la Presentación (puede ser null)
    private Long idPresentacion; // Nullable
    private BigDecimal puntajeObtenido; // Nullable, usar BigDecimal
    private Integer tiempoUtilizado; // Nullable
    private Timestamp fechaInicioPresentacion; // Nullable, usar Timestamp
    private Timestamp fechaFinPresentacion; // Nullable, usar Timestamp
    private Integer idEstadoPresentacion; // Nullable
    private String nombreEstadoPresentacion; // Nullable

    // Campo Calculado para la UI
    private String estadoUI; // Campo crucial para la interfaz
} 