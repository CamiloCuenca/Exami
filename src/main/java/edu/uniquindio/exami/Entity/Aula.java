package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@Setter
@Entity
@Table(name = "AULA")
public class Aula {
    @Id
    @Column(name = "ID_AULA", nullable = false)
    private Long id;

    @Column(name = "NOMBRE", nullable = false, length = 50)
    private String nombre;

    @Column(name = "BLOQUE", nullable = false, length = 50)
    private String bloque;

    @Column(name = "CAPACIDAD")
    private Short capacidad;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_ESTADO")
    private edu.uniquindio.exami.Entity.EstadoGeneral idEstado;

}