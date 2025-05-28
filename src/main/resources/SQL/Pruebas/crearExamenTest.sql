-- Bloque de prueba para SP_CREAR_EXAMEN
DECLARE
    -- Variables para el docente
    v_id_docente NUMBER;
    
    -- Variables para el examen
    v_id_examen_creado NUMBER;
    v_codigo_resultado NUMBER;
    v_mensaje_resultado VARCHAR2(200);
    
    -- Variables para verificación
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE PRUEBA DE CREACIÓN DE EXAMEN ===');
    
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
    
    -- 2. Verificar temas disponibles
    SELECT COUNT(1) INTO v_count
    FROM TEMA;  -- Verificar todos los temas disponibles
    
    DBMS_OUTPUT.PUT_LINE('Temas disponibles: ' || v_count);
    
    -- 3. Crear examen de prueba
    DBMS_OUTPUT.PUT_LINE('=== Creando examen de prueba ===');
    
    SP_CREAR_EXAMEN(
        p_id_docente => v_id_docente,
        p_id_tema => 1,  -- Asumiendo que existe un tema con ID 1
        p_nombre => 'Examen de Prueba',
        p_descripcion => 'Examen creado para pruebas del sistema',
        p_fecha_inicio => SYSTIMESTAMP + INTERVAL '1' DAY,  -- Mañana
        p_fecha_fin => SYSTIMESTAMP + INTERVAL '2' DAY,     -- Pasado mañana
        p_tiempo_limite => 60,  -- 60 minutos
        p_peso_curso => 100,
        p_umbral_aprobacion => 60,
        p_cantidad_preguntas_total => 5,
        p_cantidad_preguntas_presentar => 5,
        p_id_categoria => 1,
        p_intentos_permitidos => 1,
        p_mostrar_resultados => 1,
        p_permitir_retroalimentacion => 1,
        p_id_examen_creado => v_id_examen_creado,
        p_codigo_resultado => v_codigo_resultado,
        p_mensaje_resultado => v_mensaje_resultado
    );
    
    -- 4. Mostrar resultados
    DBMS_OUTPUT.PUT_LINE('=== Resultados de la creación ===');
    DBMS_OUTPUT.PUT_LINE('ID Examen creado: ' || v_id_examen_creado);
    DBMS_OUTPUT.PUT_LINE('Código resultado: ' || v_codigo_resultado);
    DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje_resultado);
    
    -- 5. Verificar que el examen se creó correctamente
    IF v_codigo_resultado = 0 THEN
        DBMS_OUTPUT.PUT_LINE('=== Verificando examen creado ===');
        
        SELECT COUNT(1) INTO v_count
        FROM EXAMEN
        WHERE ID_EXAMEN = v_id_examen_creado;
        
        DBMS_OUTPUT.PUT_LINE('Examen encontrado en la base de datos: ' || 
            CASE WHEN v_count > 0 THEN 'SÍ' ELSE 'NO' END);
            
        -- Mostrar detalles del examen creado
        FOR r IN (
            SELECT 
                e.ID_EXAMEN,
                e.NOMBRE,
                e.DESCRIPCION,
                TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') as FECHA_INICIO,
                TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') as FECHA_FIN,
                e.TIEMPO_LIMITE,
                e.PESO_CURSO,
                e.UMBRAL_APROBACION,
                t.NOMBRE as NOMBRE_TEMA,
                eg.NOMBRE as NOMBRE_ESTADO
            FROM EXAMEN e
            INNER JOIN TEMA t ON e.ID_TEMA = t.ID_TEMA
            INNER JOIN ESTADO_GENERAL eg ON e.ID_ESTADO = eg.ID_ESTADO
            WHERE e.ID_EXAMEN = v_id_examen_creado
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Detalles del examen:');
            DBMS_OUTPUT.PUT_LINE('  Nombre: ' || r.NOMBRE);
            DBMS_OUTPUT.PUT_LINE('  Descripción: ' || r.DESCRIPCION);
            DBMS_OUTPUT.PUT_LINE('  Fecha Inicio: ' || r.FECHA_INICIO);
            DBMS_OUTPUT.PUT_LINE('  Fecha Fin: ' || r.FECHA_FIN);
            DBMS_OUTPUT.PUT_LINE('  Tiempo Límite: ' || r.TIEMPO_LIMITE || ' minutos');
            DBMS_OUTPUT.PUT_LINE('  Peso Curso: ' || r.PESO_CURSO);
            DBMS_OUTPUT.PUT_LINE('  Umbral Aprobación: ' || r.UMBRAL_APROBACION);
            DBMS_OUTPUT.PUT_LINE('  Tema: ' || r.NOMBRE_TEMA);
            DBMS_OUTPUT.PUT_LINE('  Estado: ' || r.NOMBRE_ESTADO);
        END LOOP;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('=== FIN DE PRUEBA DE CREACIÓN DE EXAMEN ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/ 