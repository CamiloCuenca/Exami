package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;

@Getter
@Setter
@Entity
@Table(name = "RESPUESTA_ESTUDIANTE")
public class RespuestaEstudiante {
    @Id
    @Column(name = "ID_RESPUESTA", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_PRESENTACION", nullable = false)
    private PresentacionExaman idPresentacion;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_PREGUNTA", nullable = false)
    private Pregunta idPregunta;

    @Column(name = "RESPUESTA_DADA", length = 1000)
    private String respuestaDada;

    @Column(name = "ES_CORRECTA")
    private Boolean esCorrecta;

    @Column(name = "PUNTAJE_OBTENIDO", precision = 5, scale = 2)
    private BigDecimal puntajeObtenido;

    @Column(name = "TIEMPO_UTILIZADO")
    private Short tiempoUtilizado;

}