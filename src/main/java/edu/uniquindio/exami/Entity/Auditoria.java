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
@Table(name = "AUDITORIA")
public class Auditoria {
    @Id
    @Column(name = "ID_AUDITORIA", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_USUARIO")
    private edu.uniquindio.exami.Entity.Usuario idUsuario;

    @Column(name = "TABLA_AFECTADA", nullable = false, length = 50)
    private String tablaAfectada;

    @Column(name = "ID_REGISTRO", nullable = false)
    private Long idRegistro;

    @Column(name = "TIPO_OPERACION", nullable = false, length = 20)
    private String tipoOperacion;

    @ColumnDefault("SYSTIMESTAMP")
    @Column(name = "FECHA_OPERACION")
    private Instant fechaOperacion;

    @Lob
    @Column(name = "DATOS_ANTERIORES")
    private String datosAnteriores;

    @Lob
    @Column(name = "DATOS_NUEVOS")
    private String datosNuevos;

    @Column(name = "IP_ACCESO", length = 15)
    private String ipAcceso;

}