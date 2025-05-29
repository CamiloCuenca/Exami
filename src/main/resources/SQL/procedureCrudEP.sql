CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PREGUNTA(
    P_ID_PREGUNTA IN PREGUNTA.ID_PREGUNTA%TYPE,
    P_CODIGO_RESULTADO OUT NUMBER,
    P_MENSAJE_RESULTADO OUT VARCHAR2
) AS
BEGIN
    -- Primero eliminamos las respuestas de estudiantes asociadas a la pregunta
    DELETE FROM RESPUESTA_ESTUDIANTE WHERE ID_PREGUNTA = P_ID_PREGUNTA;
    
    -- Luego eliminamos las opciones asociadas a la pregunta
    DELETE FROM OPCION_RESPUESTA WHERE ID_PREGUNTA = P_ID_PREGUNTA;
    
    -- Eliminamos las referencias en EXAMEN_PREGUNTA
    DELETE FROM EXAMEN_PREGUNTA WHERE ID_PREGUNTA = P_ID_PREGUNTA;
    
    -- Finalmente eliminamos la pregunta
    DELETE FROM PREGUNTA WHERE ID_PREGUNTA = P_ID_PREGUNTA;
    
    -- Si llegamos aquí, la eliminación fue exitosa
    P_CODIGO_RESULTADO := 1;
    P_MENSAJE_RESULTADO := 'Pregunta eliminada exitosamente';
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        P_CODIGO_RESULTADO := 0;
        P_MENSAJE_RESULTADO := 'Error al eliminar la pregunta: ' || SQLERRM;
        ROLLBACK;
END SP_ELIMINAR_PREGUNTA;



CREATE OR REPLACE PROCEDURE SP_ELIMINAR_EXAMEN (
    p_id_examen IN NUMBER,
    p_codigo_resultado OUT NUMBER,
    p_mensaje_resultado OUT VARCHAR2
) AS
    v_dummy NUMBER;
BEGIN
    -- Validar existencia
    BEGIN
        SELECT 1 INTO v_dummy FROM EXAMEN WHERE ID_EXAMEN = p_id_examen;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := -1;
            p_mensaje_resultado := 'El examen no existe';
            RETURN;
    END;

    -- Primero eliminamos las respuestas de estudiantes asociadas a las presentaciones
    DELETE FROM RESPUESTA_ESTUDIANTE 
    WHERE ID_PRESENTACION IN (SELECT ID_PRESENTACION FROM PRESENTACION_EXAMEN WHERE ID_EXAMEN = p_id_examen);
    
    -- Luego eliminamos las presentaciones del examen
    DELETE FROM PRESENTACION_EXAMEN WHERE ID_EXAMEN = p_id_examen;
    
    -- Eliminamos las preguntas asociadas al examen
    DELETE FROM EXAMEN_PREGUNTA WHERE ID_EXAMEN = p_id_examen;
    
    -- Finalmente eliminamos el examen
    DELETE FROM EXAMEN WHERE ID_EXAMEN = p_id_examen;

    p_codigo_resultado := 0;
    p_mensaje_resultado := 'Examen eliminado correctamente';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := -2;
        p_mensaje_resultado := 'Error al eliminar el examen: ' || SQLERRM;
        ROLLBACK;
END;
/








CREATE OR REPLACE PROCEDURE SP_EDITAR_PREGUNTA (
    p_id_pregunta IN NUMBER,
    p_texto_pregunta IN VARCHAR2,
    p_id_tema IN NUMBER,
    p_id_nivel_dificultad IN NUMBER,
    p_id_tipo_pregunta IN NUMBER,
    p_codigo_resultado OUT NUMBER,
    p_mensaje_resultado OUT VARCHAR2
) AS
    v_dummy NUMBER;
BEGIN
    -- Validar existencia
    BEGIN
        SELECT 1 INTO v_dummy FROM PREGUNTA WHERE ID_PREGUNTA = p_id_pregunta;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := -1;
            p_mensaje_resultado := 'La pregunta no existe';
            RETURN;
    END;

    UPDATE PREGUNTA
    SET TEXTO_PREGUNTA = p_texto_pregunta,
        ID_TEMA = p_id_tema,
        ID_NIVEL_DIFICULTAD = p_id_nivel_dificultad,
        ID_TIPO_PREGUNTA = p_id_tipo_pregunta
    WHERE ID_PREGUNTA = p_id_pregunta;

    p_codigo_resultado := 0;
    p_mensaje_resultado := 'Pregunta actualizada correctamente';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := -2;
        p_mensaje_resultado := 'Error al editar la pregunta: ' || SQLERRM;
        ROLLBACK;
END;
/




CREATE OR REPLACE FUNCTION FN_DETALLE_PREGUNTA (
    p_id_pregunta IN NUMBER
) RETURN SYS_REFCURSOR AS
    cur SYS_REFCURSOR;
BEGIN
    OPEN cur FOR
        SELECT * FROM PREGUNTA WHERE ID_PREGUNTA = p_id_pregunta;
    RETURN cur;
END;
/



CREATE OR REPLACE PROCEDURE SP_ELIMINAR_EXAMEN (
    p_id_examen IN NUMBER,
    p_codigo_resultado OUT NUMBER,
    p_mensaje_resultado OUT VARCHAR2
) AS
    v_dummy NUMBER;
BEGIN
    -- Validar existencia
    BEGIN
        SELECT 1 INTO v_dummy FROM EXAMEN WHERE ID_EXAMEN = p_id_examen;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := -1;
            p_mensaje_resultado := 'El examen no existe';
            RETURN;
    END;

    -- Primero eliminamos las respuestas de estudiantes asociadas a las presentaciones
    DELETE FROM RESPUESTA_ESTUDIANTE 
    WHERE ID_PRESENTACION IN (SELECT ID_PRESENTACION FROM PRESENTACION_EXAMEN WHERE ID_EXAMEN = p_id_examen);
    
    -- Luego eliminamos las presentaciones del examen
    DELETE FROM PRESENTACION_EXAMEN WHERE ID_EXAMEN = p_id_examen;
    
    -- Eliminamos las preguntas asociadas al examen
    DELETE FROM EXAMEN_PREGUNTA WHERE ID_EXAMEN = p_id_examen;
    
    -- Finalmente eliminamos el examen
    DELETE FROM EXAMEN WHERE ID_EXAMEN = p_id_examen;

    p_codigo_resultado := 0;
    p_mensaje_resultado := 'Examen eliminado correctamente';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := -2;
        p_mensaje_resultado := 'Error al eliminar el examen: ' || SQLERRM;
        ROLLBACK;
END;
/




CREATE OR REPLACE PROCEDURE SP_EDITAR_EXAMEN (
    p_id_examen IN NUMBER,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE,
    p_tiempo_limite IN NUMBER,
    p_codigo_resultado OUT NUMBER,
    p_mensaje_resultado OUT VARCHAR2
) AS
    v_dummy NUMBER;
BEGIN
    -- Validar existencia
    BEGIN
        SELECT 1 INTO v_dummy FROM EXAMEN WHERE ID_EXAMEN = p_id_examen;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := -1;
            p_mensaje_resultado := 'El examen no existe';
            RETURN;
    END;

    UPDATE EXAMEN
    SET NOMBRE = p_nombre,
        DESCRIPCION = p_descripcion,
        FECHA_INICIO = p_fecha_inicio,
        FECHA_FIN = p_fecha_fin,
        TIEMPO_LIMITE = p_tiempo_limite
    WHERE ID_EXAMEN = p_id_examen;

    p_codigo_resultado := 0;
    p_mensaje_resultado := 'Examen actualizado correctamente';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := -2;
        p_mensaje_resultado := 'Error al editar el examen: ' || SQLERRM;
        ROLLBACK;
END;
/





CREATE OR REPLACE FUNCTION FN_DETALLE_EXAMEN (
    p_id_examen IN NUMBER
) RETURN SYS_REFCURSOR AS
    cur SYS_REFCURSOR;
BEGIN
    OPEN cur FOR
        SELECT * FROM EXAMEN WHERE ID_EXAMEN = p_id_examen;
    RETURN cur;
END;
/