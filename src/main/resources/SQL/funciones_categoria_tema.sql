-- Función para obtener todas las categorías de exámenes
CREATE OR REPLACE FUNCTION obtener_categorias_examenes
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_categoria, nombre_categoria, descripcion
        FROM categorias_examenes
        ORDER BY nombre_categoria;
    
    RETURN v_cursor;
END obtener_categorias_examenes;
/

-- Función para obtener todos los temas
CREATE OR REPLACE FUNCTION obtener_temas
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_tema, nombre_tema, descripcion
        FROM tema
        ORDER BY nombre_tema;
    
    RETURN v_cursor;
END obtener_temas;
/

-- Función para obtener un tema específico por ID
CREATE OR REPLACE FUNCTION obtener_tema_por_id(
    p_id_tema IN NUMBER
)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_tema, nombre_tema, descripcion
        FROM tema
        WHERE id_tema = p_id_tema;
    
    RETURN v_cursor;
END obtener_tema_por_id;
/

-- Función para obtener una categoría de examen específica por ID
CREATE OR REPLACE FUNCTION obtener_categoria_examen_por_id(
    p_id_categoria IN NUMBER
)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_categoria, nombre_categoria, descripcion
        FROM categorias_examenes
        WHERE id_categoria = p_id_categoria;
    
    RETURN v_cursor;
END obtener_categoria_examen_por_id;
/ 