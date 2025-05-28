-- Bloque de prueba para el flujo completo de presentación de examen
DECLARE
    -- Variables para el estudiante y examen
    v_id_estudiante NUMBER;
    v_id_examen NUMBER;
    v_id_presentacion NUMBER;
    v_id_docente NUMBER;
    
    -- Variables para las preguntas
    v_ids_preguntas SYS.ODCINUMBERLIST;
    v_porcentajes SYS.ODCINUMBERLIST;
    v_ordenes SYS.ODCINUMBERLIST;
    
    -- Variables para el cursor de preguntas
    v_cursor_preguntas SYS_REFCURSOR;
    v_pregunta_id NUMBER;
    v_pregunta_texto VARCHAR2(500);
    v_porcentaje NUMBER;
    v_orden NUMBER;
    
    -- Variables para respuestas
    v_respuestas_correctas NUMBER := 0;
    v_total_preguntas NUMBER := 0;
    
    -- Variables para resultados
    v_codigo_resultado NUMBER;
    v_mensaje_resultado VARCHAR2(200);
    v_cantidad_asignadas NUMBER;
    
    -- Variables para diagnóstico
    v_count_examenes NUMBER;
    v_count_preguntas NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE PRUEBA DE PRESENTACIÓN DE EXAMEN ===');
    
    -- 1. Obtener un estudiante activo
    BEGIN
        SELECT ID_USUARIO INTO v_id_estudiante
        FROM USUARIO
        WHERE ID_TIPO_USUARIO = 3  -- Tipo estudiante
        AND ID_ESTADO = 1  -- Activo
        AND ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('Estudiante encontrado con ID: ' || v_id_estudiante);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró ningún estudiante activo');
            RETURN;
    END;
    
    -- 2. Obtener un docente activo
    BEGIN
        SELECT ID_USUARIO INTO v_id_docente
        FROM USUARIO
        WHERE ID_TIPO_USUARIO = 2  -- Tipo docente
        AND ID_ESTADO = 1  -- Activo
        AND ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('Docente encontrado con ID: ' || v_id_docente);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró ningún docente activo');
            RETURN;
    END;
    
    -- 3. Crear un nuevo examen
    DBMS_OUTPUT.PUT_LINE('=== Creando nuevo examen ===');
    
    SP_CREAR_EXAMEN(
        p_id_docente => v_id_docente,
        p_id_tema => 1,  -- Asumiendo que existe un tema con ID 1
        p_nombre => 'Examen de Prueba',
        p_descripcion => 'Examen creado para pruebas',
        p_fecha_inicio => SYSTIMESTAMP,
        p_fecha_fin => SYSTIMESTAMP + INTERVAL '1' HOUR,
        p_tiempo_limite => 60,
        p_peso_curso => 20,
        p_umbral_aprobacion => 60,
        p_total_preguntas => 5,
        p_mostrar_resultados => 1,
        p_mostrar_retroalimentacion => 1,
        p_mostrar_respuestas_correctas => 1,
        p_mostrar_puntos_obtenidos => 1,
        p_mostrar_tiempo_utilizado => 1,
        p_mostrar_intentos_restantes => 1,
        p_id_examen_creado => v_id_examen,
        p_codigo_resultado => v_codigo_resultado,
        p_mensaje_resultado => v_mensaje_resultado
    );
    
    DBMS_OUTPUT.PUT_LINE('Examen creado con ID: ' || v_id_examen);
    DBMS_OUTPUT.PUT_LINE('Código resultado: ' || v_codigo_resultado);
    DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje_resultado);
    
    -- 4. Obtener preguntas activas para asignar
    BEGIN
        SELECT ID_PREGUNTA BULK COLLECT INTO v_ids_preguntas
        FROM PREGUNTA
        WHERE ID_ESTADO = 1  -- Activas
        AND ROWNUM <= 5;  -- Tomamos hasta 5 preguntas
        
        IF v_ids_preguntas.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontraron preguntas activas para asignar');
            RETURN;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Preguntas encontradas: ' || v_ids_preguntas.COUNT);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al obtener preguntas: ' || SQLERRM);
            RETURN;
    END;
    
    -- 5. Configurar porcentajes y órdenes
    v_porcentajes := SYS.ODCINUMBERLIST();
    v_ordenes := SYS.ODCINUMBERLIST();
    
    FOR i IN 1..v_ids_preguntas.COUNT LOOP
        v_porcentajes.EXTEND;
        v_ordenes.EXTEND;
        v_porcentajes(i) := 100 / v_ids_preguntas.COUNT;  -- Distribuir porcentajes equitativamente
        v_ordenes(i) := i;  -- Orden secuencial
    END LOOP;
    
    -- 6. Asignar preguntas al examen
    DBMS_OUTPUT.PUT_LINE('=== Asignando preguntas al examen ===');
    
    SP_ASIGNAR_PREGUNTAS_EXAMEN(
        p_id_examen => v_id_examen,
        p_id_docente => v_id_docente,
        p_ids_preguntas => v_ids_preguntas,
        p_porcentajes => v_porcentajes,
        p_ordenes => v_ordenes,
        p_cantidad_asignadas => v_cantidad_asignadas,
        p_codigo_resultado => v_codigo_resultado,
        p_mensaje_resultado => v_mensaje_resultado
    );
    
    DBMS_OUTPUT.PUT_LINE('Resultados de la asignación:');
    DBMS_OUTPUT.PUT_LINE('Cantidad asignada: ' || v_cantidad_asignadas);
    DBMS_OUTPUT.PUT_LINE('Código resultado: ' || v_codigo_resultado);
    DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje_resultado);
    
    -- 7. Iniciar el examen
    DBMS_OUTPUT.PUT_LINE('=== Iniciando examen ===');
    
    INICIAR_EXAMEN(
        p_id_examen => v_id_examen,
        p_id_estudiante => v_id_estudiante,
        p_cursor => v_cursor_preguntas
    );
    
    -- 8. Obtener y mostrar preguntas
    DBMS_OUTPUT.PUT_LINE('=== Preguntas del examen ===');
    
    LOOP
        FETCH v_cursor_preguntas INTO v_pregunta_id, v_pregunta_texto, v_porcentaje, v_orden;
        EXIT WHEN v_cursor_preguntas%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Pregunta ' || v_orden || ':');
        DBMS_OUTPUT.PUT_LINE('  ID: ' || v_pregunta_id);
        DBMS_OUTPUT.PUT_LINE('  Texto: ' || v_pregunta_texto);
        DBMS_OUTPUT.PUT_LINE('  Porcentaje: ' || v_porcentaje || '%');
        DBMS_OUTPUT.PUT_LINE('---');
        
        v_total_preguntas := v_total_preguntas + 1;
    END LOOP;
    
    CLOSE v_cursor_preguntas;
    
    -- 9. Verificar estado de la presentación
    BEGIN
        SELECT ID_PRESENTACION INTO v_id_presentacion
        FROM PRESENTACION_EXAMEN
        WHERE ID_EXAMEN = v_id_examen
        AND ID_ESTUDIANTE = v_id_estudiante
        AND ID_ESTADO = 6  -- EN_PROCESO
        AND ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('Presentación activa encontrada con ID: ' || v_id_presentacion);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró la presentación del examen');
            RETURN;
    END;
    
    -- 10. Mostrar resumen
    DBMS_OUTPUT.PUT_LINE('=== Resumen de la presentación ===');
    DBMS_OUTPUT.PUT_LINE('Total de preguntas: ' || v_total_preguntas);
    DBMS_OUTPUT.PUT_LINE('ID Presentación: ' || v_id_presentacion);
    
    DBMS_OUTPUT.PUT_LINE('=== FIN DE PRUEBA DE PRESENTACIÓN DE EXAMEN ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/ 