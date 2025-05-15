package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.Instant;
import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "USUARIO")
public class Usuario {
    @Id
    @Column(name = "ID_USUARIO", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_TIPO_USUARIO", nullable = false)
    private TipoUsuario idTipoUsuario;

    @Column(name = "NOMBRE", nullable = false, length = 100)
    private String nombre;

    @Column(name = "APELLIDO", nullable = false, length = 100)
    private String apellido;

    @Column(name = "EMAIL", nullable = false, length = 100)
    private String email;

    @Column(name = "CONTRASENA", nullable = false, length = 100)
    private String contrasena;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO", nullable = false)
    private EstadoGeneral idEstado;

    @ColumnDefault("SYSDATE")
    @Column(name = "FECHA_REGISTRO")
    private LocalDate fechaRegistro;

    @Column(name = "FECHA_ULTIMO_ACCESO")
    private Instant fechaUltimoAcceso;

    @ColumnDefault("0")
    @Column(name = "INTENTOS_FALLIDOS")
    private Short intentosFallidos;

    @Column(name = "FECHA_BLOQUEO")
    private Instant fechaBloqueo;

    @Column(name = "TELEFONO", length = 20)
    private String telefono;

    @Column(name = "DIRECCION", length = 200)
    private String direccion;

}