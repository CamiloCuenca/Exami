package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@Setter
@Entity
@Table(name = "GRUPO")
public class Grupo {
    @Id
    @Column(name = "ID_GRUPO", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_CURSO", nullable = false)
    private Curso idCurso;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_DOCENTE", nullable = false)
    private edu.uniquindio.exami.Entity.Usuario idDocente;

    @Column(name = "PERIODO", nullable = false, length = 20)
    private String periodo;

    @Column(name = "ANIO", nullable = false)
    private Short anio;

    @Column(name = "CAPACIDAD")
    private Short capacidad;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO")
    private EstadoGeneral idEstado;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_PERIODO")
    private edu.uniquindio.exami.Entity.PeriodoAcademico idPeriodo;

}