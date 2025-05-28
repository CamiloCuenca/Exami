package edu.uniquindio.exami.Controllers;

import edu.uniquindio.exami.dto.*;
import edu.uniquindio.exami.services.ExamenService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;

@RestController
@RequestMapping("/api/examen")
@Slf4j
public class ExamenController {

    private static final Integer COD_EXITO = 0;
    private static final Integer COD_ERROR_PARAMETROS = -1;
    private static final Integer COD_ERROR_REGISTRO = -2;

    private final ExamenService examenService;

    @Autowired
    public ExamenController(ExamenService examenService) {
        this.examenService = examenService;
    }

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

    @PostMapping("/asignar-preguntas-examen/{idExamen}")
    public ResponseEntity<?> asignarPreguntasExamen(
            @PathVariable Long idExamen,
            @RequestBody PreguntaExamenRequestDTO request) {
        try {
            // Validar que las listas tengan la misma longitud
            if (request.getIdsPreguntas().size() != request.getPorcentajes().size() || 
                request.getIdsPreguntas().size() != request.getOrdenes().size()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Las listas de preguntas, porcentajes y órdenes deben tener la misma longitud"
                ));
            }

            // Validar el umbral de aprobación
            if (request.getUmbralAprobacion() == null || request.getUmbralAprobacion() < 0 || request.getUmbralAprobacion() > 100) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "El umbral de aprobación debe estar entre 0 y 100"
                ));
            }

            // Validar que no haya preguntas duplicadas
            Set<Long> preguntasUnicas = new HashSet<>(request.getIdsPreguntas());
            if (preguntasUnicas.size() != request.getIdsPreguntas().size()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "No se permiten preguntas duplicadas"
                ));
            }

            // Validar que los porcentajes estén entre 0 y 100
            for (Double porcentaje : request.getPorcentajes()) {
                if (porcentaje < 0 || porcentaje > 100) {
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Los porcentajes deben estar entre 0 y 100"
                    ));
                }
            }

            request.setIdExamen(idExamen);
            PreguntaExamenResponseDTO response = examenService.asignarPreguntasExamen(request);
            
            // Mapear códigos de resultado a mensajes específicos
            String mensaje = switch (response.getCodigoResultado()) {
                case 0 -> "Preguntas asignadas exitosamente";
                case 1 -> "Error en los parámetros proporcionados";
                case 2 -> "El examen especificado no existe o no está activo";
                case 3 -> "El docente no está autorizado a modificar este examen";
                case 4 -> "No se pueden modificar las preguntas de un examen ya iniciado";
                case 5 -> "Una o más preguntas no existen o no están activas";
                case 6 -> "Una o más preguntas ya están asignadas al examen";
                case 7 -> "Error en la suma de porcentajes";
                case 8 -> "Error al registrar las preguntas";
                case 9 -> "Error en la secuencia de IDs";
                case 10 -> "Error en la cantidad de preguntas";
                case 11 -> "Error en el umbral de aprobación";
                default -> response.getMensajeResultado();
            };

            if (response.getCodigoResultado() == 0) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response,
                    "message", mensaje
                ));
            } else {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", mensaje
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

    /**
     * Endpoint para crear una nueva pregunta en el sistema.
     * 
     * @param request DTO con la información de la pregunta a crear
     * @return ResponseEntity con el resultado de la operación
     */
    @PostMapping("/crear-pregunta")
    public ResponseEntity<?> agregarPregunta(@RequestBody PreguntaRequestDTO request) {
        log.info("Recibida solicitud para crear pregunta: {}", request.getTextoPregunta());
        
        try {
            // Validar que el tema exista
            if (!validarTema(request.getIdTema())) {
                log.warn("Intento de crear pregunta con tema no válido: {}", request.getIdTema());
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "El tema especificado no existe"
                ));
            }

            // Validación específica para preguntas Verdadero/Falso
            if (request.getIdTipoPregunta() == 3) {
                if (request.getTextosOpciones() == null || request.getTextosOpciones().size() != 2) {
                    log.warn("Intento de crear pregunta Verdadero/Falso con número incorrecto de opciones");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Las preguntas Verdadero/Falso deben tener exactamente dos opciones"
                    ));
                }

                // Validar que las opciones sean "Verdadero" y "Falso"
                String opcion1 = request.getTextosOpciones().get(0).trim();
                String opcion2 = request.getTextosOpciones().get(1).trim();
                
                if (!opcion1.equalsIgnoreCase("Verdadero") || !opcion2.equalsIgnoreCase("Falso")) {
                    log.warn("Intento de crear pregunta Verdadero/Falso con opciones incorrectas");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Las opciones deben ser 'Verdadero' y 'Falso' en ese orden"
                    ));
                }

                // Validar que haya exactamente una opción correcta
                long opcionesCorrectas = request.getSonCorrectas().stream()
                    .filter(correcta -> correcta == 1)
                    .count();
                
                if (opcionesCorrectas != 1) {
                    log.warn("Intento de crear pregunta Verdadero/Falso con número incorrecto de opciones correctas");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Debe haber exactamente una opción correcta en preguntas Verdadero/Falso"
                    ));
                }
            }
            // Validación específica para preguntas de selección múltiple
            else if (request.getIdTipoPregunta() == 2) {
                if (request.getTextosOpciones() == null || request.getTextosOpciones().size() < 2) {
                    log.warn("Intento de crear pregunta de selección múltiple con menos de dos opciones");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Las preguntas de selección múltiple deben tener al menos dos opciones"
                    ));
                }

                // Validar que haya al menos una opción correcta
                long opcionesCorrectas = request.getSonCorrectas().stream()
                    .filter(correcta -> correcta == 1)
                    .count();
                
                if (opcionesCorrectas < 1) {
                    log.warn("Intento de crear pregunta de selección múltiple sin opciones correctas");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Debe haber al menos una opción correcta en preguntas de selección múltiple"
                    ));
                }
            }
            // Validación para preguntas de selección única
            else if (request.getIdTipoPregunta() == 1) {
                if (request.getTextosOpciones() == null || request.getTextosOpciones().size() < 2) {
                    log.warn("Intento de crear pregunta de selección única con menos de dos opciones");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Las preguntas de selección única deben tener al menos dos opciones"
                    ));
                }

                // Validar que haya exactamente una opción correcta
                long opcionesCorrectas = request.getSonCorrectas().stream()
                    .filter(correcta -> correcta == 1)
                    .count();
                
                if (opcionesCorrectas != 1) {
                    log.warn("Intento de crear pregunta de selección única con número incorrecto de opciones correctas");
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Debe haber exactamente una opción correcta en preguntas de selección única"
                    ));
                }
            }

            PreguntaResponseDTO response = examenService.agregarPregunta(request);

            if (response.getCodigoResultado() == COD_EXITO) {
                log.info("Pregunta creada exitosamente con ID: {}", response.getIdPreguntaCreada());
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response,
                    "message", "Pregunta creada exitosamente"
                ));
            } else {
                log.warn("Error al crear pregunta. Código: {}, Mensaje: {}", 
                    response.getCodigoResultado(), response.getMensajeResultado());
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", response.getMensajeResultado()
                ));
            }
        } catch (Exception e) {
            log.error("Error inesperado al crear pregunta: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error interno del servidor al procesar la solicitud"
                ));
        }
    }

    /**
     * Valida que el tema exista
     * @param idTema ID del tema a validar
     * @return true si el tema existe, false en caso contrario
     */
    private boolean validarTema(Long idTema) {
        try {
            return examenService.obtenerTemaPorId(idTema) != null;
        } catch (Exception e) {
            log.error("Error al validar tema: {}", e.getMessage());
            return false;
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

    @GetMapping("/categorias")
    public ResponseEntity<?> obtenerCategoriasExamenes() {
        try {
            List<CategoriaDTO> categorias = examenService.obtenerCategoriasExamenes();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", categorias,
                "message", "Categorías obtenidas exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener las categorías: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/categorias/{idCategoria}")
    public ResponseEntity<?> obtenerCategoriaExamenPorId(@PathVariable Long idCategoria) {
        try {
            CategoriaDTO categoria = examenService.obtenerCategoriaExamenPorId(idCategoria);
            if (categoria != null) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", categoria,
                    "message", "Categoría obtenida exitosamente"
                ));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of(
                        "success", false,
                        "message", "Categoría no encontrada"
                    ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener la categoría: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/temas")
    public ResponseEntity<?> obtenerTemas() {
        try {
            List<TemaDTO> temas = examenService.obtenerTemas();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", temas,
                "message", "Temas obtenidos exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener los temas: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/temas/{idTema}")
    public ResponseEntity<?> obtenerTemaPorId(@PathVariable Long idTema) {
        try {
            TemaDTO tema = examenService.obtenerTemaPorId(idTema);
            if (tema != null) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", tema,
                    "message", "Tema obtenido exitosamente"
                ));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of(
                        "success", false,
                        "message", "Tema no encontrado"
                    ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener el tema: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/niveles-dificultad")
    public ResponseEntity<?> obtenerNivelesDificultad() {
        try {
            List<NivelDificultadDTO> niveles = examenService.obtenerNivelesDificultad();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", niveles,
                "message", "Niveles de dificultad obtenidos exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener los niveles de dificultad: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/niveles-dificultad/{idNivelDificultad}")
    public ResponseEntity<?> obtenerNivelDificultadPorId(@PathVariable Long idNivelDificultad) {
        try {
            NivelDificultadDTO nivel = examenService.obtenerNivelDificultadPorId(idNivelDificultad);
            if (nivel != null) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", nivel,
                    "message", "Nivel de dificultad obtenido exitosamente"
                ));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of(
                        "success", false,
                        "message", "Nivel de dificultad no encontrado"
                    ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener el nivel de dificultad: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/tipos-pregunta")
    public ResponseEntity<?> obtenerTiposPregunta() {
        try {
            List<TipoPreguntaDTO> tipos = examenService.obtenerTiposPregunta();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", tipos,
                "message", "Tipos de pregunta obtenidos exitosamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener los tipos de pregunta: " + e.getMessage()
                ));
        }
    }

    @GetMapping("/tipos-pregunta/{idTipoPregunta}")
    public ResponseEntity<?> obtenerTipoPreguntaPorId(@PathVariable Long idTipoPregunta) {
        try {
            TipoPreguntaDTO tipo = examenService.obtenerTipoPreguntaPorId(idTipoPregunta);
            if (tipo != null) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", tipo,
                    "message", "Tipo de pregunta obtenido exitosamente"
                ));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of(
                        "success", false,
                        "message", "Tipo de pregunta no encontrado"
                    ));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "success", false,
                    "message", "Error al obtener el tipo de pregunta: " + e.getMessage()
                ));
        }
    }
}

