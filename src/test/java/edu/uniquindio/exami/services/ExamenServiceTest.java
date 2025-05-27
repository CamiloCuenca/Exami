package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.ExamenEstadoDTO;
import edu.uniquindio.exami.dto.ExamenRequestDTO;
import edu.uniquindio.exami.dto.ExamenResponseDTO;
import edu.uniquindio.exami.dto.PreguntaExamenRequestDTO;
import edu.uniquindio.exami.dto.PreguntaExamenResponseDTO;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Random;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class ExamenServiceTest {

    @Autowired
    private ExamenService service;

    @Autowired
    private PreguntaService preguntaService;

    @Test
    @Rollback(false)  // Esto evita que se haga rollback de la transacción
    void crearExamenBasico() {
        ExamenRequestDTO request = new ExamenRequestDTO();
        
        // Datos básicos obligatorios
        request.setIdDocente(1L);           // Docente existente (Juan Pérez)
        request.setIdTema(1L);              // Tema existente (Modelo Relacional)
        request.setNombre("Examen de Prueba " + System.currentTimeMillis());
        request.setDescripcion("Examen creado para pruebas");
        
        // Configuración del examen
        request.setFechaInicio(LocalDateTime.now().plusDays(1));
        request.setFechaFin(LocalDateTime.now().plusDays(1).plusHours(2));
        request.setTiempoLimite(120);       // 120 minutos
        request.setPesoCurso(20.0);         // 20% del curso
        request.setUmbralAprobacion(60.0);  // 60% para aprobar
        request.setCantidadPreguntasTotal(10);
        request.setCantidadPreguntasPresentar(5);
        request.setIdCategoria(1L);         // Categoría Parcial
        request.setIntentosPermitidos(1);
        request.setMostrarResultados(1);
        request.setPermitirRetroalimentacion(1);
        
        ExamenResponseDTO response = service.crearExamen(request);
        
        // Verificar resultado
        assertEquals(0, response.getCodigoResultado());
        assertNotNull(response.getIdExamenCreado());
        
        // Información detallada para verificar en consola
        System.out.println("===================================");
        System.out.println("Examen creado exitosamente con ID: " + response.getIdExamenCreado());
        System.out.println("Mensaje: " + response.getMensajeResultado());
        System.out.println("Nombre: " + request.getNombre());
        System.out.println("Fecha inicio: " + request.getFechaInicio());
        System.out.println("Fecha fin: " + request.getFechaFin());
        System.out.println("===================================");
        
        /* 
         * SQL para consultar el examen en la base de datos:
         * 
         * SELECT * FROM EXAMEN WHERE ID_EXAMEN = [ID_EXAMEN_CREADO];
         *
         * O para ver todos los exámenes:
         * 
         * SELECT * FROM EXAMEN ORDER BY ID_EXAMEN DESC;
         */
    }

    @Test
    @Rollback(false) // Evita que se haga rollback para poder ver el resultado en la base de datos
    void asignarPreguntasExamen() {
        // Primero crear un nuevo examen para la prueba
        ExamenRequestDTO examenRequest = new ExamenRequestDTO();
        
        // Datos básicos obligatorios del examen
        examenRequest.setIdDocente(1L);           // Docente existente
        examenRequest.setIdTema(1L);              // Tema existente
        examenRequest.setNombre("Examen para asignación de preguntas " + System.currentTimeMillis());
        examenRequest.setDescripcion("Examen creado para prueba de asignación de preguntas");
        
        // Configuración del examen - importante usar fechas futuras
        examenRequest.setFechaInicio(LocalDateTime.now().plusDays(1));  // Fecha futura
        examenRequest.setFechaFin(LocalDateTime.now().plusDays(1).plusHours(2));
        examenRequest.setTiempoLimite(120);
        examenRequest.setPesoCurso(20.0);
        examenRequest.setUmbralAprobacion(60.0);
        examenRequest.setCantidadPreguntasTotal(10);
        examenRequest.setCantidadPreguntasPresentar(5);
        examenRequest.setIdCategoria(1L);
        
        // Crear el examen
        ExamenResponseDTO examenResponse = service.crearExamen(examenRequest);
        
        // Verificar que el examen se haya creado correctamente
        assertEquals(0, examenResponse.getCodigoResultado(), 
            "Error al crear el examen: " + examenResponse.getMensajeResultado());
        assertNotNull(examenResponse.getIdExamenCreado(), "El ID del examen no puede ser nulo");
        
        System.out.println("Examen creado con ID: " + examenResponse.getIdExamenCreado());
        
        // Ahora asignar preguntas al examen recién creado
        PreguntaExamenRequestDTO request = new PreguntaExamenRequestDTO();
        
        // Configurar los datos básicos usando el ID del examen recién creado
        request.setIdExamen(examenResponse.getIdExamenCreado());
        request.setIdDocente(1L);       // ID del docente que creó el examen
        
        // Configurar las listas de preguntas, porcentajes y órdenes
        request.setIdsPreguntas(Arrays.asList(1L, 2L, 3L));
        request.setPorcentajes(Arrays.asList(30, 30, 40)); // Deben sumar 100
        request.setOrdenes(Arrays.asList(1, 2, 3));
        
        // Ejecutar el servicio
        PreguntaExamenResponseDTO response = service.asignarPreguntasExamen(request);
        
        // Imprimir resultados para depuración
        System.out.println("===================================");
        System.out.println("Asignación de preguntas al examen");
        System.out.println("===================================");
        System.out.println("Código de resultado: " + response.getCodigoResultado());
        System.out.println("Mensaje: " + response.getMensajeResultado());
        System.out.println("Cantidad de preguntas asignadas: " + response.getCantidadAsignadas());
        System.out.println("ID del examen: " + response.getIdExamen());
        System.out.println("===================================");
        System.out.println("SQL para verificar:");
        System.out.println("SELECT * FROM EXAMEN_PREGUNTA WHERE ID_EXAMEN = " + response.getIdExamen() + ";");
        System.out.println("===================================");
        
        // Validar el resultado
        assertEquals(0, response.getCodigoResultado(), 
            "El código de resultado debe ser 0 (éxito). Error: " + response.getMensajeResultado());
        assertEquals(3, response.getCantidadAsignadas(), 
            "Se deben haber asignado 3 preguntas al examen");
        assertNotNull(response.getMensajeResultado(), 
            "El mensaje de resultado no debe ser nulo");
    }

    @Test
    @Rollback(false)
    void obtenerExamenesPorEstadoYEstudiante() {
        // ID del estudiante de prueba (Ana Gómez)
        Integer idEstudiante = 4;
        Integer idEstado = 4; // Estado activo/disponible
        
        // Obtener exámenes disponibles para el estudiante
        List<ExamenEstadoDTO> examenesEstudiante = service.obtenerExamenesPorEstadoYEstudiante(idEstado, idEstudiante);
        
        // Verificar que la lista no sea nula
        assertNotNull(examenesEstudiante, "La lista de exámenes no debe ser nula");
        
        // Imprimir resultados para depuración
        System.out.println("===================================");
        System.out.println("Exámenes Disponibles para Estudiante " + idEstudiante);
        System.out.println("===================================");
        System.out.println("Cantidad de exámenes: " + examenesEstudiante.size());
        
        // Verificar cada examen
        for (ExamenEstadoDTO examen : examenesEstudiante) {
            // Verificar campos obligatorios
            assertNotNull(examen.getIdExamen(), "El ID del examen no debe ser nulo");
            assertNotNull(examen.getNombre(), "El nombre del examen no debe ser nulo");
            assertNotNull(examen.getDescripcion(), "La descripción no debe ser nula");
            assertNotNull(examen.getFechaInicio(), "La fecha de inicio no debe ser nula");
            assertNotNull(examen.getFechaFin(), "La fecha de fin no debe ser nula");
            assertNotNull(examen.getTiempoLimite(), "El tiempo límite no debe ser nulo");
            assertNotNull(examen.getPesoCurso(), "El peso del curso no debe ser nulo");
            assertNotNull(examen.getUmbralAprobacion(), "El umbral de aprobación no debe ser nulo");
            assertNotNull(examen.getNombreTema(), "El nombre del tema no debe ser nulo");
            assertNotNull(examen.getNombreCurso(), "El nombre del curso no debe ser nulo");
            assertNotNull(examen.getNombreEstado(), "El nombre del estado no debe ser nulo");
            
            // Imprimir información detallada
            System.out.println("Examen ID: " + examen.getIdExamen());
            System.out.println("Nombre: " + examen.getNombre());
            System.out.println("Descripción: " + examen.getDescripcion());
            System.out.println("Tema: " + examen.getNombreTema());
            System.out.println("Curso: " + examen.getNombreCurso());
            System.out.println("Fecha Inicio: " + examen.getFechaInicio());
            System.out.println("Fecha Fin: " + examen.getFechaFin());
            System.out.println("Tiempo Límite: " + examen.getTiempoLimite());
            System.out.println("Peso Curso: " + examen.getPesoCurso());
            System.out.println("Umbral Aprobación: " + examen.getUmbralAprobacion());
            System.out.println("Estado: " + examen.getNombreEstado());
            
            // Campos de presentación (pueden ser nulos si el estudiante no ha presentado el examen)
            System.out.println("ID Presentación: " + examen.getIdPresentacion());
            System.out.println("Puntaje Obtenido: " + examen.getPuntajeObtenido());
            System.out.println("Tiempo Utilizado: " + examen.getTiempoUtilizado());
            System.out.println("-----------------------------------");
        }
    }
} 