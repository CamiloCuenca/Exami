package edu.uniquindio.exami.services;

import edu.uniquindio.exami.dto.PreguntaRequestDTO;
import edu.uniquindio.exami.dto.PreguntaResponseDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class PreguntaServiceTest {

    @Autowired
    private PreguntaService service;

    @Test
    @Rollback(false) // Evita que se haga rollback para poder ver la pregunta en la base de datos
    void crearPreguntaSeleccionUnica() {
        PreguntaRequestDTO request = new PreguntaRequestDTO();
        
        // Datos básicos obligatorios
        request.setIdDocente(1L);           // Docente existente (Juan Pérez)
        request.setIdTema(1L);              // Tema existente (Modelo Relacional)
        request.setIdNivelDificultad(1L);   // Nivel fácil
        request.setIdTipoPregunta(1L);      // Selección única
        
        // Añadir un texto aleatorio para forzar que el test siempre sea diferente y se ejecute
        String textoAleatorio = "¿Cuál es la principal característica de una clave primaria en una base de datos relacional? " + 
                               System.currentTimeMillis();
        request.setTextoPregunta(textoAleatorio);
        
        // Configuración adicional
        request.setEsPublica(1);            // 1=pública, 0=privada
        request.setTiempoMaximo(60);        // 60 segundos para responder
        request.setPorcentaje(100.0);       // 100% de la nota

        // Opciones de respuesta (la primera es correcta)
        List<String> textosOpciones = Arrays.asList(
            "Debe ser única para cada registro",
            "Puede contener valores nulos",
            "No puede ser modificada nunca",
            "Debe ser siempre de tipo texto"
        );
        
        List<Integer> sonCorrectas = Arrays.asList(1, 0, 0, 0); // Solo la primera es correcta
        List<Integer> ordenes = Arrays.asList(1, 2, 3, 4);      // Orden de presentación
        
        request.setTextosOpciones(textosOpciones);
        request.setSonCorrectas(sonCorrectas);
        request.setOrdenes(ordenes);
        
        // Ejecutar el servicio
        PreguntaResponseDTO response = service.agregarPregunta(request);
        
        // Imprimir información completa para depuración
        System.out.println("\n===================================");
        System.out.println("RESULTADO DE LA PRUEBA:");
        System.out.println("Pregunta creada con ID: " + response.getIdPreguntaCreada());
        System.out.println("Código de resultado: " + response.getCodigoResultado());
        System.out.println("Mensaje de resultado: " + response.getMensajeResultado());
        System.out.println("===================================\n");
        
        // Verificar que se obtuvo el mensaje (sin importar el código de resultado)
        assertNotNull(response.getMensajeResultado(), "Debe haber un mensaje de resultado");
        
        // Verificar el código de resultado
        assertEquals(0, response.getCodigoResultado(), 
            "El código de resultado debería ser 0 (éxito), pero fue " + 
            response.getCodigoResultado() + ": " + response.getMensajeResultado());
        
        /* 
         * SQL para consultar la pregunta en la base de datos:
         * 
         * SELECT * FROM PREGUNTA WHERE ID_PREGUNTA = [ID_PREGUNTA_CREADA];
         *
         * SQL para consultar las opciones de respuesta:
         * 
         * SELECT * FROM OPCION_RESPUESTA WHERE ID_PREGUNTA = [ID_PREGUNTA_CREADA] ORDER BY ORDEN;
         */
    }
    
    @Test
    @Rollback(false)
    void crearPreguntaSeleccionMultiple() {
        PreguntaRequestDTO request = new PreguntaRequestDTO();
        
        // Datos básicos obligatorios
        request.setIdDocente(2L);           // Otro docente (María López)
        request.setIdTema(1L);              // Tema existente (Modelo Relacional)
        request.setIdNivelDificultad(2L);   // Nivel medio
        request.setIdTipoPregunta(2L);      // Selección múltiple
        request.setTextoPregunta("Seleccione las características de las bases de datos NoSQL:");
        
        // Configuración adicional
        request.setEsPublica(1);            // Pública
        request.setPorcentaje(100.0);       // 100% de la nota

        // Opciones de respuesta (varias correctas)
        List<String> textosOpciones = Arrays.asList(
            "Escalabilidad horizontal",
            "Esquemas flexibles",
            "Soporte ACID completo",
            "Optimizadas para joins complejos"
        );
        
        List<Integer> sonCorrectas = Arrays.asList(1, 1, 0, 0); // Las dos primeras son correctas
        List<Integer> ordenes = Arrays.asList(1, 2, 3, 4);
        
        request.setTextosOpciones(textosOpciones);
        request.setSonCorrectas(sonCorrectas);
        request.setOrdenes(ordenes);
        
        // Ejecutar el servicio
        PreguntaResponseDTO response = service.agregarPregunta(request);
        
        // Verificar resultado
        System.out.println("===================================");
        System.out.println("Pregunta de selección múltiple creada con ID: " + response.getIdPreguntaCreada());
        System.out.println("Código: " + response.getCodigoResultado());
        System.out.println("Mensaje: " + response.getMensajeResultado());
        System.out.println("===================================");
        
        // Verificar que la operación fue exitosa
        assertEquals(0, response.getCodigoResultado());
        assertNotNull(response.getIdPreguntaCreada());
    }
    
    @Test
    @Rollback(false)
    void crearPreguntaVerdaderoFalso() {
        PreguntaRequestDTO request = new PreguntaRequestDTO();
        
        // Datos básicos obligatorios
        request.setIdDocente(3L);           // Otro docente (Carlos Ramírez)
        request.setIdTema(1L);              // Tema existente (Modelo Relacional)
        request.setIdNivelDificultad(1L);   // Nivel fácil
        request.setIdTipoPregunta(3L);      // Verdadero/Falso
        request.setTextoPregunta("Los índices en una base de datos relacional mejoran el rendimiento de las consultas:");
        
        // Configuración adicional
        request.setEsPublica(1);            // Pública

        // Opciones para verdadero/falso
        List<String> textosOpciones = Arrays.asList("Verdadero", "Falso");
        List<Integer> sonCorrectas = Arrays.asList(1, 0); // Verdadero es correcto
        List<Integer> ordenes = Arrays.asList(1, 2);
        
        request.setTextosOpciones(textosOpciones);
        request.setSonCorrectas(sonCorrectas);
        request.setOrdenes(ordenes);
        
        // Ejecutar el servicio
        PreguntaResponseDTO response = service.agregarPregunta(request);
        
        // Verificar resultado
        System.out.println("===================================");
        System.out.println("Pregunta Verdadero/Falso creada con ID: " + response.getIdPreguntaCreada());
        System.out.println("Código: " + response.getCodigoResultado());
        System.out.println("Mensaje: " + response.getMensajeResultado());
        System.out.println("===================================");
        
        // Verificar que la operación fue exitosa
        assertEquals(0, response.getCodigoResultado());
        assertNotNull(response.getIdPreguntaCreada());
    }
} 