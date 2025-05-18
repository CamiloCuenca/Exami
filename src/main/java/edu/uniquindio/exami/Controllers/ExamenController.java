package edu.uniquindio.exami.Controllers;

import edu.uniquindio.exami.dto.ExamenCardDTO;
import edu.uniquindio.exami.services.ExamenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/quiz")
public class ExamenController {

    @Autowired
    private ExamenService examenService;


    @GetMapping("/estudiante/{idEstudiante}/examenes")
    public ResponseEntity<List<ExamenCardDTO>> listarExamenesPorEstudiante(
            @PathVariable Long idEstudiante) {

        try {
            List<ExamenCardDTO> examenes = examenService.listarExamenesEstudiante(idEstudiante);
            return ResponseEntity.ok(examenes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
