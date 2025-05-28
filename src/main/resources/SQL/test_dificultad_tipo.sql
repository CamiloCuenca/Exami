-- Script de pruebas para las funciones de niveles de dificultad y tipos de pregunta

-- Configuración del entorno de pruebas
SET SERVEROUTPUT ON;
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id_nivel_dificultad NUMBER;
    v_nombre VARCHAR2(50);
    v_descripcion VARCHAR2(200);
    v_id_tipo_pregunta NUMBER;
    v_count NUMBER;
BEGIN
    -- Prueba 1: Obtener todos los niveles de dificultad
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA 1: Obtener todos los niveles de dificultad ===');
    v_cursor := obtener_niveles_dificultad();
    v_count := 0;
    
    LOOP
        FETCH v_cursor INTO v_id_nivel_dificultad, v_nombre, v_descripcion;
        EXIT WHEN v_cursor%NOTFOUND;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Nivel de dificultad encontrado:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_nivel_dificultad);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
        DBMS_OUTPUT.PUT_LINE('-------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de niveles de dificultad encontrados: ' || v_count);
    CLOSE v_cursor;
    
    -- Prueba 2: Obtener todos los tipos de pregunta
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 2: Obtener todos los tipos de pregunta ===');
    v_cursor := obtener_tipos_pregunta();
    v_count := 0;
    
    LOOP
        FETCH v_cursor INTO v_id_tipo_pregunta, v_nombre, v_descripcion;
        EXIT WHEN v_cursor%NOTFOUND;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Tipo de pregunta encontrado:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_tipo_pregunta);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
        DBMS_OUTPUT.PUT_LINE('-------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de tipos de pregunta encontrados: ' || v_count);
    CLOSE v_cursor;
    
    -- Prueba 3: Obtener nivel de dificultad por ID (usando un ID existente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 3: Obtener nivel de dificultad por ID ===');
    v_cursor := obtener_nivel_dificultad_por_id(1); -- Asumiendo que existe un nivel con ID 1
    
    FETCH v_cursor INTO v_id_nivel_dificultad, v_nombre, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nivel de dificultad encontrado:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_nivel_dificultad);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontró el nivel de dificultad con ID 1');
    END IF;
    CLOSE v_cursor;
    
    -- Prueba 4: Obtener tipo de pregunta por ID (usando un ID existente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 4: Obtener tipo de pregunta por ID ===');
    v_cursor := obtener_tipo_pregunta_por_id(1); -- Asumiendo que existe un tipo con ID 1
    
    FETCH v_cursor INTO v_id_tipo_pregunta, v_nombre, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Tipo de pregunta encontrado:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_tipo_pregunta);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontró el tipo de pregunta con ID 1');
    END IF;
    CLOSE v_cursor;
    
    -- Prueba 5: Obtener nivel de dificultad por ID (usando un ID inexistente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 5: Obtener nivel de dificultad por ID inexistente ===');
    v_cursor := obtener_nivel_dificultad_por_id(999999); -- ID que no debería existir
    
    FETCH v_cursor INTO v_id_nivel_dificultad, v_nombre, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nivel de dificultad encontrado (esto no debería ocurrir):');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_nivel_dificultad);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Correcto: No se encontró el nivel de dificultad con ID 999999');
    END IF;
    CLOSE v_cursor;
    
    -- Prueba 6: Obtener tipo de pregunta por ID (usando un ID inexistente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 6: Obtener tipo de pregunta por ID inexistente ===');
    v_cursor := obtener_tipo_pregunta_por_id(999999); -- ID que no debería existir
    
    FETCH v_cursor INTO v_id_tipo_pregunta, v_nombre, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Tipo de pregunta encontrado (esto no debería ocurrir):');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_tipo_pregunta);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Correcto: No se encontró el tipo de pregunta con ID 999999');
    END IF;
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en las pruebas: ' || SQLERRM);
END;
/ 