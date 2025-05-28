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
@Table(name = "EXAMEN_PREGUNTA")
public class ExamenPregunta {
    @Id
    @Column(name = "ID_EXAMEN_PREGUNTA", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_EXAMEN", nullable = false)
    private Examen idExamen;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_PREGUNTA", nullable = false)
    private edu.uniquindio.exami.Entity.Pregunta idPregunta;

    @Column(name = "PORCENTAJE", nullable = false, precision = 5, scale = 2)
    private BigDecimal porcentaje;

    @Column(name = "ORDEN")
    private Short orden;

}