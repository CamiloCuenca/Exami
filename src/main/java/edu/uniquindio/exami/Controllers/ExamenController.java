package edu.uniquindio.exami.Controllers;

import edu.uniquindio.exami.dto.ExamenCardDTO;
import edu.uniquindio.exami.dto.ExamenRequestDTO;
import edu.uniquindio.exami.dto.ExamenResponseDTO;
import edu.uniquindio.exami.dto.PreguntaExamenRequestDTO;
import edu.uniquindio.exami.dto.PreguntaExamenResponseDTO;
import edu.uniquindio.exami.services.ExamenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/examen")
public class ExamenController {

    @Autowired
    private ExamenService examenService;

    @GetMapping("/mis-examenes/{idEstudiante}")
    public ResponseEntity<?> listarExamenesPorEstudiante(@PathVariable Long idEstudiante) {
        try {
            List<ExamenCardDTO> examenes = examenService.listarExamenesEstudiante(idEstudiante);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", examenes,
                "message", "Exámenes obtenidos exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener los exámenes: " + e.getMessage()
                ));
        }
    }

    @PostMapping
    public ResponseEntity<?> crearExamen(@RequestBody ExamenRequestDTO request) {
        try {
            ExamenResponseDTO response = examenService.crearExamen(request);
            if (response.getCodigoResultado() == 0) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response,
                    "message", "Examen creado exitosamente"
                ));
            } else {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", response.getMensajeResultado()
                ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al crear el examen: " + e.getMessage()
                ));
        }
    }

    @PostMapping("/{idExamen}/preguntas")
    public ResponseEntity<?> asignarPreguntasExamen(
            @PathVariable Long idExamen,
            @RequestBody PreguntaExamenRequestDTO request) {
        try {
            request.setIdExamen(idExamen);
            PreguntaExamenResponseDTO response = examenService.asignarPreguntasExamen(request);
            if (response.getCodigoResultado() == 0) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response,
                    "message", "Preguntas asignadas exitosamente"
                ));
            } else {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", response.getMensajeResultado()
                ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al asignar preguntas: " + e.getMessage()
                ));
        }
    }
}
