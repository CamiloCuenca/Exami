package edu.uniquindio.exami.Controllers;

import edu.uniquindio.exami.dto.*;
import edu.uniquindio.exami.services.ExamenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/examen")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:5173")
public class ExamenController {

    private static final Integer COD_EXITO = 0;

    private final ExamenService examenService;

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

    @PostMapping("/crear-examen")
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

    @GetMapping("/mis-examenes-docente/{idDocente}")
    public ResponseEntity<?> listarExamenesPorDocente(@PathVariable Long idDocente) {
        try {
            List<ExamenDocenteDTO> examenes = examenService.listarExamenesDocente(idDocente);
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

    @PostMapping("/Crear")
    public ResponseEntity<PreguntaResponseDTO> agregarPregunta(@RequestBody PreguntaRequestDTO request) {
        PreguntaResponseDTO response = examenService.agregarPregunta(request);

        if (response.getCodigoResultado() == COD_EXITO) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }



    @GetMapping("/en-progreso/{idEstudiante}")
        public ResponseEntity<?> listarExamenesEnProgresoEstudiante(@PathVariable Long idEstudiante) {
            try {
                List<ExamenCardDTO> examenesEnProgreso = examenService.listarExamenesEnProgresoEstudiante(idEstudiante);
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", examenesEnProgreso,
                    "message", "Exámenes en progreso obtenidos exitosamente"
                ));
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                        "success", false,
                        "message", "Error al obtener los exámenes en progreso: " + e.getMessage()
                    ));
            }
        }

    @GetMapping("/expirados/{idEstudiante}")
        public ResponseEntity<?> listarExamenesExpiradosEstudiante(@PathVariable Long idEstudiante) {
            try {
                List<ExamenCardDTO> examenesExpirados = examenService.listarExamenesExpiradosEstudiante(idEstudiante);
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", examenesExpirados,
                    "message", "Exámenes expirados obtenidos exitosamente"
                ));
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                        "success", false,
                        "message", "Error al obtener los exámenes expirados: " + e.getMessage()
                    ));
            }
        }


        @GetMapping("/estudiante-ui/{idEstudiante}")
    public ResponseEntity<?> obtenerExamenesEstudianteUI(@PathVariable Long idEstudiante) {
        try {
            List<ExamenEstudianteDetalleDTO> examenes = examenService.obtenerExamenesEstudianteUI(idEstudiante);
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

    @PostMapping("/iniciar/{idExamen}/{idEstudiante}")
    public ResponseEntity<?> iniciarExamen(
            @PathVariable Long idExamen,
            @PathVariable Long idEstudiante) {
        try {
            PresentacionExamenDTO presentacion = examenService.iniciarExamen(idExamen, idEstudiante);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", presentacion,
                "message", "Examen iniciado exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al iniciar el examen: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/preguntas/{idPresentacion}")
    public ResponseEntity<?> obtenerPreguntasExamen(@PathVariable Long idPresentacion) {
        try {
            List<PreguntaExamenDTO> preguntas = examenService.obtenerPreguntasExamen(idPresentacion);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", preguntas,
                "message", "Preguntas obtenidas exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener las preguntas: " + e.getMessage()
                ));
        }
    }

    @PostMapping("/responder/{idPresentacion}")
    public ResponseEntity<?> responderPregunta(
            @PathVariable Long idPresentacion,
            @RequestBody RespuestaEstudianteDTO respuesta) {
        try {
            RespuestaResponseDTO response = examenService.responderPregunta(idPresentacion, respuesta);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", response,
                "message", "Respuesta registrada exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al registrar la respuesta: " + e.getMessage()
                ));
        }
    }

    @PostMapping("/finalizar/{idPresentacion}")
    public ResponseEntity<?> finalizarExamen(@PathVariable Long idPresentacion) {
        try {
            PresentacionExamenDTO presentacion = examenService.finalizarExamen(idPresentacion);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", presentacion,
                "message", "Examen finalizado exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al finalizar el examen: " + e.getMessage()
                ));
        }
    }
}

