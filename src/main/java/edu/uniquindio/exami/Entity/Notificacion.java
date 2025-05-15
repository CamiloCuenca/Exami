package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "NOTIFICACION")
public class Notificacion {
    @Id
    @Column(name = "ID_NOTIFICACION", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_USUARIO", nullable = false)
    private edu.uniquindio.exami.Entity.Usuario idUsuario;

    @Column(name = "TITULO", nullable = false, length = 100)
    private String titulo;

    @Column(name = "MENSAJE", nullable = false, length = 1000)
    private String mensaje;

    @Column(name = "TIPO_NOTIFICACION", nullable = false, length = 50)
    private String tipoNotificacion;

    @ColumnDefault("SYSTIMESTAMP")
    @Column(name = "FECHA_CREACION")
    private Instant fechaCreacion;

    @Column(name = "FECHA_LECTURA")
    private Instant fechaLectura;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO", nullable = false)
    private EstadoGeneral idEstado;

}