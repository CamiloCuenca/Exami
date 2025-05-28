-- Función para obtener todos los niveles de dificultad
CREATE OR REPLACE FUNCTION obtener_niveles_dificultad
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_nivel_dificultad, nombre, descripcion
        FROM nivel_dificultad
        WHERE estado = 1
        ORDER BY nombre;
    
    RETURN v_cursor;
END obtener_niveles_dificultad;
/

-- Función para obtener un nivel de dificultad específico por ID
CREATE OR REPLACE FUNCTION obtener_nivel_dificultad_por_id(
    p_id_nivel_dificultad IN NUMBER
)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_nivel_dificultad, nombre, descripcion
        FROM nivel_dificultad
        WHERE id_nivel_dificultad = p_id_nivel_dificultad
        AND estado = 1;
    
    RETURN v_cursor;
END obtener_nivel_dificultad_por_id;
/

-- Función para obtener todos los tipos de pregunta
CREATE OR REPLACE FUNCTION obtener_tipos_pregunta
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_tipo_pregunta, nombre, descripcion
        FROM tipo_pregunta
        WHERE estado = 1
        ORDER BY nombre;
    
    RETURN v_cursor;
END obtener_tipos_pregunta;
/

-- Función para obtener un tipo de pregunta específico por ID
CREATE OR REPLACE FUNCTION obtener_tipo_pregunta_por_id(
    p_id_tipo_pregunta IN NUMBER
)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id_tipo_pregunta, nombre, descripcion
        FROM tipo_pregunta
        WHERE id_tipo_pregunta = p_id_tipo_pregunta
        AND estado = 1;
    
    RETURN v_cursor;
END obtener_tipo_pregunta_por_id;
/ 