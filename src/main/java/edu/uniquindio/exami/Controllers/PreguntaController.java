package edu.uniquindio.exami.Controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import edu.uniquindio.exami.services.PreguntaService;
import edu.uniquindio.exami.dto.PreguntaDisponibleDTO;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/pregunta")
public class PreguntaController {
    @Autowired
    private PreguntaService preguntaService;

    @GetMapping("/porcentaje-correctas/{idPresentacion}")
    public ResponseEntity<Double> obtenerPorcentajeCorrectas(@PathVariable Long idPresentacion) {
        Double porcentaje = preguntaService.obtenerPorcentajeCorrectas(idPresentacion);
        if (porcentaje != null) {
            return ResponseEntity.ok(porcentaje);
        } else {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/examenes-porcentajes/{idUsuario}")
        public ResponseEntity<List<Map<String, Object>>> obtenerExamenesYPocentajesPorEstudiante(@PathVariable Long idUsuario) {
            List<Map<String, Object>> resultados = preguntaService.obtenerExamenesYPocentajesPorEstudiante(idUsuario);
            if (!resultados.isEmpty()) {
                return ResponseEntity.ok(resultados);
            } else {
                return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
            }
        }

    @GetMapping("/disponibles/{idDocente}")
    public ResponseEntity<List<PreguntaDisponibleDTO>> obtenerPreguntasDisponibles(
            @PathVariable Long idDocente,
            @RequestParam(required = false) Long idTema,
            @RequestParam(required = false) Long idTipoPregunta,
            @RequestParam(required = false) Long idNivelDificultad) {
        
        List<PreguntaDisponibleDTO> preguntas = preguntaService.obtenerPreguntasDisponibles(
            idDocente, idTema, idTipoPregunta, idNivelDificultad);
        
        if (!preguntas.isEmpty()) {
            return ResponseEntity.ok(preguntas);
        } else {
            return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
        }
    }

}
