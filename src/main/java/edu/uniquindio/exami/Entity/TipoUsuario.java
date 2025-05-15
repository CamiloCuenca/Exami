package edu.uniquindio.exami.Entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

@Getter
@Setter
@Entity
@Table(name = "TIPO_USUARIO")
public class TipoUsuario {
    @Id
    @Column(name = "ID_TIPO_USUARIO", nullable = false)
    private Long id;

    @Column(name = "NOMBRE", nullable = false, length = 50)
    private String nombre;

    @Column(name = "DESCRIPCION", length = 200)
    private String descripcion;

    @ColumnDefault("1")
    @Column(name = "ESTADO")
    private Boolean estado;

}