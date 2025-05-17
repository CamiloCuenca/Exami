package edu.uniquindio.exami.dto;

import lombok.Data;
import java.util.List;

@Data
public class PreguntaRequestDTO {
    // Datos básicos de la pregunta
    private Long idDocente;
    private Long idTema;
    private Long idNivelDificultad;
    private Long idTipoPregunta;
    private String textoPregunta;
    private Integer esPublica; // 0=privada, 1=pública
    private Integer tiempoMaximo; // En segundos, opcional
    private Double porcentaje; // Opcional, porcentaje de la pregunta
    private Long idPreguntaPadre; // Opcional, para subpreguntas
    
    // Listas para opciones de respuesta
    private List<String> textosOpciones; // Textos de las opciones
    private List<Integer> sonCorrectas; // 1=correcta, 0=incorrecta
    private List<Integer> ordenes; // Orden de presentación
} 