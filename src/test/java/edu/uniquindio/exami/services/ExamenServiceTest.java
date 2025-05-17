package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.ExamenRequestDTO;
import edu.uniquindio.exami.dto.ExamenResponseDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class ExamenServiceTest {

    @Autowired
    private ExamenService service;

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
} 