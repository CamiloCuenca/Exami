-- Bloque de prueba para SP_ASIGNAR_PREGUNTAS_EXAMEN
DECLARE
    -- Variables para el docente y examen
    v_id_docente NUMBER;
    v_id_examen NUMBER;
    
    -- Variables para las preguntas
    v_ids_preguntas SYS.ODCINUMBERLIST;
    v_porcentajes SYS.ODCINUMBERLIST;
    v_ordenes SYS.ODCINUMBERLIST;
    
    -- Variables de salida
    v_cantidad_asignadas NUMBER;
    v_codigo_resultado NUMBER;
    v_mensaje_resultado VARCHAR2(200);
    
    -- Variables para verificación
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE PRUEBA DE ASIGNACIÓN DE PREGUNTAS ===');
    
    -- 1. Obtener un docente activo
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
    
    -- 2. Obtener un examen activo del docente
    BEGIN
        SELECT ID_EXAMEN INTO v_id_examen
        FROM EXAMEN
        WHERE ID_DOCENTE = v_id_docente
        AND ID_ESTADO = 1  -- Activo
        AND FECHA_INICIO > SYSTIMESTAMP  -- Que no haya iniciado
        AND ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('Examen encontrado con ID: ' || v_id_examen);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró ningún examen activo del docente');
            RETURN;
    END;
    
    -- 3. Obtener preguntas activas para asignar
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
    
    -- 4. Configurar porcentajes y órdenes
    v_porcentajes := SYS.ODCINUMBERLIST();
    v_ordenes := SYS.ODCINUMBERLIST();
    
    FOR i IN 1..v_ids_preguntas.COUNT LOOP
        v_porcentajes.EXTEND;
        v_ordenes.EXTEND;
        v_porcentajes(i) := 100 / v_ids_preguntas.COUNT;  -- Distribuir porcentajes equitativamente
        v_ordenes(i) := i;  -- Orden secuencial
    END LOOP;
    
    -- 5. Asignar preguntas al examen
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
    
    -- 6. Mostrar resultados
    DBMS_OUTPUT.PUT_LINE('Resultados de la asignación:');
    DBMS_OUTPUT.PUT_LINE('Cantidad asignada: ' || v_cantidad_asignadas);
    DBMS_OUTPUT.PUT_LINE('Código resultado: ' || v_codigo_resultado);
    DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje_resultado);
    
    -- 7. Verificar asignaciones realizadas
    IF v_codigo_resultado = 0 THEN
        DBMS_OUTPUT.PUT_LINE('=== Verificando asignaciones realizadas ===');
        
        FOR r IN (
            SELECT 
                ep.ID_EXAMEN_PREGUNTA,
                ep.ID_PREGUNTA,
                p.TEXTO_PREGUNTA,
                ep.PORCENTAJE,
                ep.ORDEN
            FROM EXAMEN_PREGUNTA ep
            INNER JOIN PREGUNTA p ON ep.ID_PREGUNTA = p.ID_PREGUNTA
            WHERE ep.ID_EXAMEN = v_id_examen
            ORDER BY ep.ORDEN
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Pregunta asignada:');
            DBMS_OUTPUT.PUT_LINE('  ID Asignación: ' || r.ID_EXAMEN_PREGUNTA);
            DBMS_OUTPUT.PUT_LINE('  ID Pregunta: ' || r.ID_PREGUNTA);
            DBMS_OUTPUT.PUT_LINE('  Texto: ' || r.TEXTO_PREGUNTA);
            DBMS_OUTPUT.PUT_LINE('  Porcentaje: ' || r.PORCENTAJE || '%');
            DBMS_OUTPUT.PUT_LINE('  Orden: ' || r.ORDEN);
            DBMS_OUTPUT.PUT_LINE('---');
        END LOOP;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('=== FIN DE PRUEBA DE ASIGNACIÓN DE PREGUNTAS ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/ 