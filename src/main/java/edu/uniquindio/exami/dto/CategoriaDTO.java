package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CategoriaDTO {
    private Long id_categoria;    // Se mapeará a IDCATEGORIA
    private String nombre; // Se mapeará a NOMBRECATEGORIA
    private String descripcion;  // Se mapeará a DESCRIPCION
}