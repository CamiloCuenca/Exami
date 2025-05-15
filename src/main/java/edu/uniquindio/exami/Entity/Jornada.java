package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "JORNADA")
public class Jornada {
    @Id
    @Column(name = "ID_JORNADA", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_GRUPO", nullable = false)
    private Grupo idGrupo;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_AULA", nullable = false)
    private Aula idAula;

    @Column(name = "DIA_SEMANA", nullable = false, length = 20)
    private String diaSemana;

    @Column(name = "HORA_INICIO", nullable = false)
    private Instant horaInicio;

    @Column(name = "HORA_FIN", nullable = false)
    private Instant horaFin;

}