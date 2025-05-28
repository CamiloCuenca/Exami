-- Bloque de prueba para SP_AGREGAR_PREGUNTA
DECLARE
    -- Variables para el docente
    v_id_docente NUMBER;
    
    -- Variables para la pregunta
    v_id_pregunta_creada NUMBER;
    v_codigo_resultado NUMBER;
    v_mensaje_resultado VARCHAR2(200);
    
    -- Variables para las opciones
    v_textos_opciones SYS.ODCIVARCHAR2LIST;
    v_son_correctas SYS.ODCINUMBERLIST;
    v_ordenes SYS.ODCINUMBERLIST;
    
    -- Variables para verificación
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE PRUEBA DE CREACIÓN DE PREGUNTAS ===');
    
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
    
    -- 2. Crear pregunta de opción múltiple
    DBMS_OUTPUT.PUT_LINE('=== Creando pregunta de opción múltiple ===');
    
    -- Configurar opciones para pregunta de opción múltiple
    v_textos_opciones := SYS.ODCIVARCHAR2LIST(
        'Opción A - Correcta',
        'Opción B',
        'Opción C',
        'Opción D'
    );
    v_son_correctas := SYS.ODCINUMBERLIST(1, 0, 0, 0);  -- Solo la primera es correcta
    v_ordenes := SYS.ODCINUMBERLIST(1, 2, 3, 4);
    
    SP_AGREGAR_PREGUNTA(
        p_id_docente => v_id_docente,
        p_id_tema => 1,  -- Asumiendo que existe un tema con ID 1
        p_id_nivel_dificultad => 1,  -- Nivel básico
        p_id_tipo_pregunta => 1,     -- Opción múltiple
        p_texto_pregunta => '¿Cuál es la capital de Francia?',
        p_es_publica => 1,
        p_tiempo_maximo => 60,
        p_porcentaje => 20,
        p_textos_opciones => v_textos_opciones,
        p_son_correctas => v_son_correctas,
        p_ordenes => v_ordenes,
        p_id_pregunta_creada => v_id_pregunta_creada,
        p_codigo_resultado => v_codigo_resultado,
        p_mensaje_resultado => v_mensaje_resultado
    );
    
    DBMS_OUTPUT.PUT_LINE('Resultados pregunta opción múltiple:');
    DBMS_OUTPUT.PUT_LINE('ID Pregunta creada: ' || v_id_pregunta_creada);
    DBMS_OUTPUT.PUT_LINE('Código resultado: ' || v_codigo_resultado);
    DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje_resultado);
    
    -- 3. Crear pregunta de verdadero/falso
    DBMS_OUTPUT.PUT_LINE('=== Creando pregunta de verdadero/falso ===');
    
    -- Configurar opciones para pregunta de verdadero/falso
    v_textos_opciones := SYS.ODCIVARCHAR2LIST('Verdadero', 'Falso');
    v_son_correctas := SYS.ODCINUMBERLIST(1, 0);  -- Verdadero es correcto
    v_ordenes := SYS.ODCINUMBERLIST(1, 2);
    
    SP_AGREGAR_PREGUNTA(
        p_id_docente => v_id_docente,
        p_id_tema => 1,
        p_id_nivel_dificultad => 1,
        p_id_tipo_pregunta => 3,     -- Verdadero/Falso
        p_texto_pregunta => 'El sol es una estrella',
        p_es_publica => 1,
        p_tiempo_maximo => 30,
        p_porcentaje => 20,
        p_textos_opciones => v_textos_opciones,
        p_son_correctas => v_son_correctas,
        p_ordenes => v_ordenes,
        p_id_pregunta_creada => v_id_pregunta_creada,
        p_codigo_resultado => v_codigo_resultado,
        p_mensaje_resultado => v_mensaje_resultado
    );
    
    DBMS_OUTPUT.PUT_LINE('Resultados pregunta verdadero/falso:');
    DBMS_OUTPUT.PUT_LINE('ID Pregunta creada: ' || v_id_pregunta_creada);
    DBMS_OUTPUT.PUT_LINE('Código resultado: ' || v_codigo_resultado);
    DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje_resultado);
    
    -- 4. Verificar preguntas creadas
    IF v_codigo_resultado = 0 THEN
        DBMS_OUTPUT.PUT_LINE('=== Verificando preguntas creadas ===');
        
        -- Verificar pregunta de opción múltiple
        FOR r IN (
            SELECT 
                p.ID_PREGUNTA,
                p.TEXTO_PREGUNTA,
                tp.NOMBRE as TIPO_PREGUNTA,
                nd.NOMBRE as NIVEL_DIFICULTAD,
                t.NOMBRE as NOMBRE_TEMA,
                p.ES_PUBLICA,
                p.TIEMPO_MAXIMO,
                p.PORCENTAJE
            FROM PREGUNTA p
            INNER JOIN TIPO_PREGUNTA tp ON p.ID_TIPO_PREGUNTA = tp.ID_TIPO_PREGUNTA
            INNER JOIN NIVEL_DIFICULTAD nd ON p.ID_NIVEL_DIFICULTAD = nd.ID_NIVEL_DIFICULTAD
            INNER JOIN TEMA t ON p.ID_TEMA = t.ID_TEMA
            WHERE p.ID_DOCENTE = v_id_docente
            ORDER BY p.ID_PREGUNTA DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Detalles de la pregunta:');
            DBMS_OUTPUT.PUT_LINE('  ID: ' || r.ID_PREGUNTA);
            DBMS_OUTPUT.PUT_LINE('  Texto: ' || r.TEXTO_PREGUNTA);
            DBMS_OUTPUT.PUT_LINE('  Tipo: ' || r.TIPO_PREGUNTA);
            DBMS_OUTPUT.PUT_LINE('  Nivel: ' || r.NIVEL_DIFICULTAD);
            DBMS_OUTPUT.PUT_LINE('  Tema: ' || r.NOMBRE_TEMA);
            DBMS_OUTPUT.PUT_LINE('  Pública: ' || CASE WHEN r.ES_PUBLICA = 1 THEN 'SÍ' ELSE 'NO' END);
            DBMS_OUTPUT.PUT_LINE('  Tiempo máximo: ' || r.TIEMPO_MAXIMO || ' segundos');
            DBMS_OUTPUT.PUT_LINE('  Porcentaje: ' || r.PORCENTAJE || '%');
            
            -- Mostrar opciones de respuesta
            DBMS_OUTPUT.PUT_LINE('  Opciones de respuesta:');
            FOR o IN (
                SELECT 
                    TEXTO_OPCION,
                    ES_CORRECTA,
                    ORDEN
                FROM OPCION_RESPUESTA
                WHERE ID_PREGUNTA = r.ID_PREGUNTA
                ORDER BY ORDEN
            ) LOOP
                DBMS_OUTPUT.PUT_LINE('    ' || o.ORDEN || '. ' || o.TEXTO_OPCION || 
                    CASE WHEN o.ES_CORRECTA = 1 THEN ' (Correcta)' ELSE '' END);
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('---');
        END LOOP;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('=== FIN DE PRUEBA DE CREACIÓN DE PREGUNTAS ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/ 