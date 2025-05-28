package edu.uniquindio.exami.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TemaDTO {
    private Long id_tema;        // Se mapeará a IDTEMA
    private String nombre;  // Se mapeará a NOMBRETEMA
    private String descripcion; // Se mapeará a DESCRIPCION
} 