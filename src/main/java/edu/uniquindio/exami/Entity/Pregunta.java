package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;

@Getter
@Setter
@Entity
@Table(name = "PREGUNTA")
public class Pregunta {
    @Id
    @Column(name = "ID_PREGUNTA", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_DOCENTE", nullable = false)
    private edu.uniquindio.exami.Entity.Usuario idDocente;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_TEMA", nullable = false)
    private edu.uniquindio.exami.Entity.Tema idTema;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_NIVEL_DIFICULTAD", nullable = false)
    private NivelDificultad idNivelDificultad;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_TIPO_PREGUNTA", nullable = false)
    private edu.uniquindio.exami.Entity.TipoPregunta idTipoPregunta;

    @Column(name = "TEXTO_PREGUNTA", nullable = false, length = 1000)
    private String textoPregunta;

    @ColumnDefault("0")
    @Column(name = "ES_PUBLICA")
    private Boolean esPublica;

    @Column(name = "TIEMPO_MAXIMO")
    private Short tiempoMaximo;

    @Column(name = "PORCENTAJE", precision = 5, scale = 2)
    private BigDecimal porcentaje;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_PREGUNTA_PADRE")
    private Pregunta idPreguntaPadre;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO", nullable = false)
    private EstadoGeneral idEstado;

}