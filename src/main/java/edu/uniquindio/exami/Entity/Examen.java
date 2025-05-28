package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "EXAMEN")
public class Examen {
    @Id
    @Column(name = "ID_EXAMEN", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_DOCENTE", nullable = false)
    private edu.uniquindio.exami.Entity.Usuario idDocente;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_TEMA", nullable = false)
    private edu.uniquindio.exami.Entity.Tema idTema;

    @Column(name = "NOMBRE", nullable = false, length = 100)
    private String nombre;

    @Column(name = "DESCRIPCION", length = 500)
    private String descripcion;

    @ColumnDefault("SYSDATE")
    @Column(name = "FECHA_CREACION")
    private LocalDate fechaCreacion;

    @Column(name = "FECHA_INICIO")
    private Instant fechaInicio;

    @Column(name = "FECHA_FIN")
    private Instant fechaFin;

    @Column(name = "TIEMPO_LIMITE")
    private Short tiempoLimite;

    @Column(name = "PESO_CURSO", precision = 5, scale = 2)
    private BigDecimal pesoCurso;

    @Column(name = "UMBRAL_APROBACION", precision = 5, scale = 2)
    private BigDecimal umbralAprobacion;

    @Column(name = "CANTIDAD_PREGUNTAS_TOTAL")
    private Short cantidadPreguntasTotal;

    @Column(name = "CANTIDAD_PREGUNTAS_PRESENTAR")
    private Short cantidadPreguntasPresentar;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO", nullable = false)
    private EstadoGeneral idEstado;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_CATEGORIA")
    private CategoriaExaman idCategoria;

    @ColumnDefault("1")
    @Column(name = "INTENTOS_PERMITIDOS")
    private Short intentosPermitidos;

    @ColumnDefault("1")
    @Column(name = "MOSTRAR_RESULTADOS")
    private Boolean mostrarResultados;

    @ColumnDefault("1")
    @Column(name = "PERMITIR_RETROALIMENTACION")
    private Boolean permitirRetroalimentacion;

    @Column(name = "FECHA_ULTIMA_MODIFICACION")
    private Instant fechaUltimaModificacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_USUARIO_ULTIMA_MODIFICACION")
    private edu.uniquindio.exami.Entity.Usuario idUsuarioUltimaModificacion;

}