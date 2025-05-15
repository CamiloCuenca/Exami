package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "PRESENTACION_EXAMEN")
public class PresentacionExaman {
    @Id
    @Column(name = "ID_PRESENTACION", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_EXAMEN", nullable = false)
    private Examan idExamen;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTUDIANTE", nullable = false)
    private edu.uniquindio.exami.Entity.Usuario idEstudiante;

    @ColumnDefault("SYSTIMESTAMP")
    @Column(name = "FECHA_INICIO")
    private Instant fechaInicio;

    @Column(name = "FECHA_FIN")
    private Instant fechaFin;

    @Column(name = "PUNTAJE_OBTENIDO", precision = 5, scale = 2)
    private BigDecimal puntajeObtenido;

    @Column(name = "TIEMPO_UTILIZADO")
    private Short tiempoUtilizado;

    @Column(name = "IP_ACCESO", length = 15)
    private String ipAcceso;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO", nullable = false)
    private EstadoGeneral idEstado;

}