package edu.uniquindio.exami.Controllers;

import edu.uniquindio.exami.dto.NotaResponseDTO;
import edu.uniquindio.exami.services.ExamenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/nota")
public class NotaController {

    private static final int COD_EXITO = 0;

    @Autowired
    private ExamenService examenService;

    @GetMapping("/calcular/{idPresentacion}")
    public ResponseEntity<NotaResponseDTO> calcularNota(@PathVariable Long idPresentacion) {
        NotaResponseDTO response = examenService.calcularNotaEstudiante(idPresentacion);

        if (response.getCodigoResultado() == COD_EXITO) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }
}
