CREATE OR REPLACE FUNCTION OBTENER_EXAMENES_ESTUDIANTE(
    p_id_estudiante NUMBER
) RETURN SYS_REFCURSOR
IS
    v_resultado SYS_REFCURSOR;
BEGIN
    OPEN v_resultado FOR
        SELECT
            e.ID_EXAMEN,
            e.NOMBRE,
            e.DESCRIPCION,
            TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') AS FECHA_INICIO_FORMATEADA,
            TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') AS FECHA_FIN_FORMATEADA,
            CASE
                WHEN CURRENT_TIMESTAMP < e.FECHA_INICIO THEN 'Pendiente'
                WHEN CURRENT_TIMESTAMP BETWEEN e.FECHA_INICIO AND e.FECHA_FIN THEN 'Disponible'
                ELSE 'Finalizado'
            END AS ESTADO,
            t.NOMBRE AS NOMBRE_TEMA,
            c.NOMBRE AS NOMBRE_CURSO
        FROM PROYECTO_FINAL.EXAMEN e
        JOIN PROYECTO_FINAL.TEMA t ON e.ID_TEMA = t.ID_TEMA
        JOIN PROYECTO_FINAL.CURSO c ON t.ID_CURSO = c.ID_CURSO
        JOIN PROYECTO_FINAL.GRUPO g ON c.ID_CURSO = g.ID_CURSO
        JOIN PROYECTO_FINAL.MATRICULA m ON g.ID_GRUPO = m.ID_GRUPO
        WHERE m.ID_ESTUDIANTE = p_id_estudiante
        ORDER BY e.FECHA_INICIO;

    RETURN v_resultado;
END;
/

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION OBTENER_EXAMENES_DOCENTE(
    p_id_docente NUMBER
) RETURN SYS_REFCURSOR
IS
    v_resultado SYS_REFCURSOR;
BEGIN
    OPEN v_resultado FOR
        SELECT
            e.ID_EXAMEN,
            e.NOMBRE,
            e.DESCRIPCION,
            TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') AS FECHA_INICIO_FORMATEADA,
            TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') AS FECHA_FIN_FORMATEADA,
            CASE
                WHEN CURRENT_TIMESTAMP < e.FECHA_INICIO THEN 'Pendiente'
                WHEN CURRENT_TIMESTAMP BETWEEN e.FECHA_INICIO AND e.FECHA_FIN THEN 'Disponible'
                ELSE 'Finalizado'
            END AS ESTADO,
            t.NOMBRE AS NOMBRE_TEMA,
            c.NOMBRE AS NOMBRE_CURSO,
            e.CANTIDAD_PREGUNTAS_TOTAL,
            e.CANTIDAD_PREGUNTAS_PRESENTAR,
            e.TIEMPO_LIMITE,
            e.PESO_CURSO,
            e.UMBRAL_APROBACION,
            e.INTENTOS_PERMITIDOS,
            e.MOSTRAR_RESULTADOS,
            e.PERMITIR_RETROALIMENTACION
        FROM PROYECTO_FINAL.EXAMEN e
        JOIN PROYECTO_FINAL.TEMA t ON e.ID_TEMA = t.ID_TEMA
        JOIN PROYECTO_FINAL.CURSO c ON t.ID_CURSO = c.ID_CURSO
        WHERE e.ID_DOCENTE = p_id_docente
        ORDER BY e.FECHA_INICIO DESC;

    RETURN v_resultado;
END;
/

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Obtener examenes disponibles  de  un estudainte
CREATE OR REPLACE FUNCTION OBT_EXA_PROGRESO_EST(
    p_id_estudiante NUMBER
) RETURN SYS_REFCURSOR
IS
    v_resultado SYS_REFCURSOR;
BEGIN
OPEN v_resultado FOR
SELECT
    e.ID_EXAMEN,
    e.NOMBRE,
    e.DESCRIPCION,
    TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') AS FECHA_INICIO_FORMATEADA,
    TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') AS FECHA_FIN_FORMATEADA,
    'Disponible' AS ESTADO,
    t.NOMBRE AS NOMBRE_TEMA,
    c.NOMBRE AS NOMBRE_CURSO
FROM PROYECTO_FINAL.EXAMEN e
         JOIN PROYECTO_FINAL.TEMA t ON e.ID_TEMA = t.ID_TEMA
         JOIN PROYECTO_FINAL.CURSO c ON t.ID_CURSO = c.ID_CURSO
         JOIN PROYECTO_FINAL.GRUPO g ON c.ID_CURSO = g.ID_CURSO
         JOIN PROYECTO_FINAL.MATRICULA m ON g.ID_GRUPO = m.ID_GRUPO
WHERE m.ID_ESTUDIANTE = p_id_estudiante
  AND CURRENT_TIMESTAMP BETWEEN e.FECHA_INICIO AND e.FECHA_FIN
ORDER BY e.FECHA_INICIO;

RETURN v_resultado;
END;
/

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION EXAMENES_EXPIRADOS_EST(
    p_id_estudiante NUMBER
) RETURN SYS_REFCURSOR
IS
    v_resultado SYS_REFCURSOR;
BEGIN
OPEN v_resultado FOR
SELECT
    e.ID_EXAMEN,
    e.NOMBRE,
    e.DESCRIPCION,
    TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') AS FECHA_INICIO_FORMATEADA,
    TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') AS FECHA_FIN_FORMATEADA,
    'Finalizado' AS ESTADO,
    t.NOMBRE AS NOMBRE_TEMA,
    c.NOMBRE AS NOMBRE_CURSO
FROM PROYECTO_FINAL.EXAMEN e
         JOIN PROYECTO_FINAL.TEMA t ON e.ID_TEMA = t.ID_TEMA
         JOIN PROYECTO_FINAL.CURSO c ON t.ID_CURSO = c.ID_CURSO
         JOIN PROYECTO_FINAL.GRUPO g ON c.ID_CURSO = g.ID_CURSO
         JOIN PROYECTO_FINAL.MATRICULA m ON g.ID_GRUPO = m.ID_GRUPO
WHERE m.ID_ESTUDIANTE = p_id_estudiante
  AND e.FECHA_FIN < CURRENT_TIMESTAMP
ORDER BY e.FECHA_FIN DESC;

RETURN v_resultado;
END;
/

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION EXAMENES_PENDIENTES_EST(
    p_id_estudiante NUMBER
) RETURN SYS_REFCURSOR
IS
    v_resultado SYS_REFCURSOR;
BEGIN
OPEN v_resultado FOR
SELECT
    e.ID_EXAMEN,
    e.NOMBRE,
    e.DESCRIPCION,
    TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') AS FECHA_INICIO_FORMATEADA,
    TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') AS FECHA_FIN_FORMATEADA,
    'Pendiente' AS ESTADO,
    t.NOMBRE AS NOMBRE_TEMA,
    c.NOMBRE AS NOMBRE_CURSO
FROM PROYECTO_FINAL.EXAMEN e
         JOIN PROYECTO_FINAL.TEMA t ON e.ID_TEMA = t.ID_TEMA
         JOIN PROYECTO_FINAL.CURSO c ON t.ID_CURSO = c.ID_CURSO
         JOIN PROYECTO_FINAL.GRUPO g ON c.ID_CURSO = g.ID_CURSO
         JOIN PROYECTO_FINAL.MATRICULA m ON g.ID_GRUPO = m.ID_GRUPO
WHERE m.ID_ESTUDIANTE = p_id_estudiante
  AND CURRENT_TIMESTAMP < e.FECHA_INICIO
ORDER BY e.FECHA_INICIO;

RETURN v_resultado;
END;
/

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*Funcion para Calcular la nota total obtenida por un estudiante en una presentación de
examen específica, sumando el puntaje de cada respuesta correcta.*/
CREATE OR REPLACE FUNCTION CALCULAR_NOTA_ESTUDIANTE (
    P_ID_PRESENTACION IN NUMBER
) RETURN NUMBER
IS
    V_TOTAL NUMBER := 0;
BEGIN
SELECT NVL(SUM(PUNTAJE_OBTENIDO), 0)
INTO V_TOTAL
FROM RESPUESTA_ESTUDIANTE
WHERE ID_PRESENTACION = P_ID_PRESENTACION;

RETURN V_TOTAL;
END;
/

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Funcion para Calcular el porcentaje de preguntas respondidas correctamente por un estudiante en una presentación.*/
CREATE OR REPLACE FUNCTION PORCENTAJE_PREGUNTAS_CORRECTAS (
    P_ID_PRESENTACION IN NUMBER
) RETURN NUMBER
IS
    V_CORRECTAS NUMBER := 0;
    V_TOTAL     NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO V_TOTAL
FROM RESPUESTA_ESTUDIANTE
WHERE ID_PRESENTACION = P_ID_PRESENTACION;

SELECT COUNT(*) INTO V_CORRECTAS
FROM RESPUESTA_ESTUDIANTE
WHERE ID_PRESENTACION = P_ID_PRESENTACION
  AND ES_CORRECTA = 1;

IF V_TOTAL = 0 THEN
        RETURN 0;
ELSE
        RETURN ROUND((V_CORRECTAS / V_TOTAL) * 100, 2);
END IF;
END;
/