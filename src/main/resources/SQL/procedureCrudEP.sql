CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PREGUNTA (
    p_id_pregunta IN NUMBER,
    p_codigo_resultado OUT NUMBER,
    p_mensaje_resultado OUT VARCHAR2
) AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE ID_PREGUNTA = p_id_pregunta) THEN
        p_codigo_resultado := -1;
        p_mensaje_resultado := 'La pregunta no existe';
        RETURN;
    END IF;

    -- Eliminar (puedes cambiar por un UPDATE para borrado lógico)
    DELETE FROM PREGUNTA WHERE ID_PREGUNTA = p_id_pregunta;

    p_codigo_resultado := 0;
    p_mensaje_resultado := 'Pregunta eliminada correctamente';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := -2;
        p_mensaje_resultado := 'Error al eliminar la pregunta: ' || SQLERRM;
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
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM PREGUNTA WHERE ID_PREGUNTA = p_id_pregunta) THEN
        p_codigo_resultado := -1;
        p_mensaje_resultado := 'La pregunta no existe';
        RETURN;
    END IF;

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
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EXAMEN WHERE ID_EXAMEN = p_id_examen) THEN
        p_codigo_resultado := -1;
        p_mensaje_resultado := 'El examen no existe';
        RETURN;
    END IF;

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
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EXAMEN WHERE ID_EXAMEN = p_id_examen) THEN
        p_codigo_resultado := -1;
        p_mensaje_resultado := 'El examen no existe';
        RETURN;
    END IF;

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