package edu.uniquindio.exami.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@Setter
@Entity
@Table(name = "OPCION_RESPUESTA")
public class OpcionRespuesta {
    @Id
    @Column(name = "ID_OPCION", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "ID_PREGUNTA", nullable = false)
    private edu.uniquindio.exami.Entity.Pregunta idPregunta;

    @Column(name = "TEXTO_OPCION", nullable = false, length = 500)
    private String textoOpcion;

    @ColumnDefault("0")
    @Column(name = "ES_CORRECTA")
    private Boolean esCorrecta;

    @Column(name = "ORDEN")
    private Short orden;

}