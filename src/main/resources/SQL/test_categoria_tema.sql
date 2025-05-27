-- Script de pruebas para las funciones de categorías y temas

-- Configuración del entorno de pruebas
SET SERVEROUTPUT ON;
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id_categoria NUMBER;
    v_nombre_categoria VARCHAR2(100);
    v_descripcion VARCHAR2(500);
    v_id_tema NUMBER;
    v_nombre_tema VARCHAR2(100);
    v_count NUMBER;
BEGIN
    -- Prueba 1: Obtener todas las categorías
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA 1: Obtener todas las categorías ===');
    v_cursor := obtener_categorias_examenes();
    v_count := 0;
    
    LOOP
        FETCH v_cursor INTO v_id_categoria, v_nombre_categoria, v_descripcion;
        EXIT WHEN v_cursor%NOTFOUND;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Categoría encontrada:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_categoria);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_categoria);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
        DBMS_OUTPUT.PUT_LINE('-------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de categorías encontradas: ' || v_count);
    CLOSE v_cursor;
    
    -- Prueba 2: Obtener todas las temas
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 2: Obtener todos los temas ===');
    v_cursor := obtener_temas();
    v_count := 0;
    
    LOOP
        FETCH v_cursor INTO v_id_tema, v_nombre_tema, v_descripcion;
        EXIT WHEN v_cursor%NOTFOUND;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Tema encontrado:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_tema);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_tema);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
        DBMS_OUTPUT.PUT_LINE('-------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de temas encontrados: ' || v_count);
    CLOSE v_cursor;
    
    -- Prueba 3: Obtener categoría por ID (usando un ID existente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 3: Obtener categoría por ID ===');
    v_cursor := obtener_categoria_examen_por_id(1); -- Asumiendo que existe una categoría con ID 1
    
    FETCH v_cursor INTO v_id_categoria, v_nombre_categoria, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Categoría encontrada:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_categoria);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_categoria);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontró la categoría con ID 1');
    END IF;
    CLOSE v_cursor;
    
    -- Prueba 4: Obtener tema por ID (usando un ID existente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 4: Obtener tema por ID ===');
    v_cursor := obtener_tema_por_id(1); -- Asumiendo que existe un tema con ID 1
    
    FETCH v_cursor INTO v_id_tema, v_nombre_tema, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Tema encontrado:');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_tema);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_tema);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontró el tema con ID 1');
    END IF;
    CLOSE v_cursor;
    
    -- Prueba 5: Obtener categoría por ID (usando un ID inexistente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 5: Obtener categoría por ID inexistente ===');
    v_cursor := obtener_categoria_examen_por_id(999999); -- ID que no debería existir
    
    FETCH v_cursor INTO v_id_categoria, v_nombre_categoria, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Categoría encontrada (esto no debería ocurrir):');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_categoria);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_categoria);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Correcto: No se encontró la categoría con ID 999999');
    END IF;
    CLOSE v_cursor;
    
    -- Prueba 6: Obtener tema por ID (usando un ID inexistente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PRUEBA 6: Obtener tema por ID inexistente ===');
    v_cursor := obtener_tema_por_id(999999); -- ID que no debería existir
    
    FETCH v_cursor INTO v_id_tema, v_nombre_tema, v_descripcion;
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Tema encontrado (esto no debería ocurrir):');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id_tema);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_tema);
        DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_descripcion);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Correcto: No se encontró el tema con ID 999999');
    END IF;
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en las pruebas: ' || SQLERRM);
END;
/ 