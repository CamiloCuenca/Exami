package edu.uniquindio.exami.Controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import edu.uniquindio.exami.services.PreguntaService;

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


}
