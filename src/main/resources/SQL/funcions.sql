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

--Datos para probarlo en la BD
SET SERVEROUTPUT on;
DECLARE
v_cursor SYS_REFCURSOR;
    v_id_examen PROYECTO_FINAL.EXAMEN.ID_EXAMEN%TYPE;
    v_nombre PROYECTO_FINAL.EXAMEN.NOMBRE%TYPE;
    v_descripcion PROYECTO_FINAL.EXAMEN.DESCRIPCION%TYPE;
    v_fecha_inicio VARCHAR2(20);
    v_fecha_fin VARCHAR2(20);
    v_estado VARCHAR2(20);
    v_nombre_tema PROYECTO_FINAL.TEMA.NOMBRE%TYPE;
    v_nombre_curso PROYECTO_FINAL.CURSO.NOMBRE%TYPE;
BEGIN
    -- Llama a la función y obtiene el cursor
    v_cursor := OBTENER_EXAMENES_ESTUDIANTE(p_id_estudiante => 4); -- reemplaza 123 con un ID válido

    -- Itera sobre los resultados del cursor
    LOOP
FETCH v_cursor INTO v_id_examen, v_nombre, v_descripcion, v_fecha_inicio, v_fecha_fin, v_estado, v_nombre_tema, v_nombre_curso;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Examen: ' || v_id_examen || ' - ' || v_nombre || ', Estado: ' || v_estado);
END LOOP;

CLOSE v_cursor;
END;


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

-- Datos para probarlo en la BD
SET SERVEROUTPUT ON;
DECLARE
v_cursor SYS_REFCURSOR;

    -- Variables para almacenar los datos del cursor
    v_id_examen                  PROYECTO_FINAL.EXAMEN.ID_EXAMEN%TYPE;
    v_nombre                    PROYECTO_FINAL.EXAMEN.NOMBRE%TYPE;
    v_descripcion               PROYECTO_FINAL.EXAMEN.DESCRIPCION%TYPE;
    v_fecha_inicio              VARCHAR2(20);
    v_fecha_fin                 VARCHAR2(20);
    v_estado                    VARCHAR2(20);
    v_nombre_tema               PROYECTO_FINAL.TEMA.NOMBRE%TYPE;
    v_nombre_curso              PROYECTO_FINAL.CURSO.NOMBRE%TYPE;
    v_cant_preg_total           NUMBER;
    v_cant_preg_presentar       NUMBER;
    v_tiempo_limite             NUMBER;
    v_peso_curso                NUMBER;
    v_umbral_aprobacion         NUMBER;
    v_intentos_permitidos       NUMBER;
    v_mostrar_resultados        VARCHAR2(1);
    v_permitir_retroalimentacion VARCHAR2(1);
BEGIN
    -- Llamada a la función
    v_cursor := OBTENER_EXAMENES_DOCENTE(1); -- Cambia 123 por un ID de docente válido

    -- Iterar los resultados
    LOOP
FETCH v_cursor INTO
            v_id_examen, v_nombre, v_descripcion, v_fecha_inicio, v_fecha_fin, v_estado,
            v_nombre_tema, v_nombre_curso,
            v_cant_preg_total, v_cant_preg_presentar, v_tiempo_limite,
            v_peso_curso, v_umbral_aprobacion, v_intentos_permitidos,
            v_mostrar_resultados, v_permitir_retroalimentacion;

        EXIT WHEN v_cursor%NOTFOUND;

        -- Mostrar en consola
        DBMS_OUTPUT.PUT_LINE('Examen: ' || v_id_examen || ' - ' || v_nombre || ' (' || v_estado || ')');
        DBMS_OUTPUT.PUT_LINE('Tema: ' || v_nombre_tema || ', Curso: ' || v_nombre_curso);
        DBMS_OUTPUT.PUT_LINE('Fecha: ' || v_fecha_inicio || ' a ' || v_fecha_fin);
        DBMS_OUTPUT.PUT_LINE('Preguntas: ' || v_cant_preg_presentar || '/' || v_cant_preg_total ||
                             ', Intentos: ' || v_intentos_permitidos ||
                             ', Tiempo: ' || v_tiempo_limite || ' min');
        DBMS_OUTPUT.PUT_LINE('Aprobación: ' || v_umbral_aprobacion || '%, Peso: ' || v_peso_curso);
        DBMS_OUTPUT.PUT_LINE('Resultados: ' || v_mostrar_resultados || ', Retroalimentación: ' || v_permitir_retroalimentacion);
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
END LOOP;

CLOSE v_cursor;
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

-- Datos para probarlo en la BD
SET SERVEROUTPUT ON;
DECLARE
v_cursor SYS_REFCURSOR;

    v_id_examen        PROYECTO_FINAL.EXAMEN.ID_EXAMEN%TYPE;
    v_nombre           PROYECTO_FINAL.EXAMEN.NOMBRE%TYPE;
    v_descripcion      PROYECTO_FINAL.EXAMEN.DESCRIPCION%TYPE;
    v_fecha_inicio     VARCHAR2(20);
    v_fecha_fin        VARCHAR2(20);
    v_estado           VARCHAR2(20);
    v_nombre_tema      PROYECTO_FINAL.TEMA.NOMBRE%TYPE;
    v_nombre_curso     PROYECTO_FINAL.CURSO.NOMBRE%TYPE;

BEGIN
    -- Llamada a la función con un ID de estudiante (reemplaza 456 con uno real)
    v_cursor := OBT_EXA_PROGRESO_EST(4);

    -- Iterar los resultados
    LOOP
FETCH v_cursor INTO
            v_id_examen, v_nombre, v_descripcion,
            v_fecha_inicio, v_fecha_fin, v_estado,
            v_nombre_tema, v_nombre_curso;

        EXIT WHEN v_cursor%NOTFOUND;

        -- Mostrar datos
        DBMS_OUTPUT.PUT_LINE('Examen ID: ' || v_id_examen || ' - ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Curso: ' || v_nombre_curso || ' | Tema: ' || v_nombre_tema);
        DBMS_OUTPUT.PUT_LINE('Fecha: ' || v_fecha_inicio || ' a ' || v_fecha_fin);
        DBMS_OUTPUT.PUT_LINE('Estado: ' || v_estado);
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
END LOOP;

CLOSE v_cursor;
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

-- Datos para probarlo en la BD
SET SERVEROUTPUT ON;
DECLARE
v_cursor SYS_REFCURSOR;

    v_id_examen      PROYECTO_FINAL.EXAMEN.ID_EXAMEN%TYPE;
    v_nombre         PROYECTO_FINAL.EXAMEN.NOMBRE%TYPE;
    v_descripcion    PROYECTO_FINAL.EXAMEN.DESCRIPCION%TYPE;
    v_fecha_inicio   VARCHAR2(20);
    v_fecha_fin      VARCHAR2(20);
    v_estado         VARCHAR2(20);
    v_nombre_tema    PROYECTO_FINAL.TEMA.NOMBRE%TYPE;
    v_nombre_curso   PROYECTO_FINAL.CURSO.NOMBRE%TYPE;

BEGIN
    -- Llama la función con un ID de estudiante real (reemplaza 456)
    v_cursor := EXAMENES_EXPIRADOS_EST(4);

    LOOP
FETCH v_cursor INTO
            v_id_examen, v_nombre, v_descripcion,
            v_fecha_inicio, v_fecha_fin, v_estado,
            v_nombre_tema, v_nombre_curso;

        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Examen ID: ' || v_id_examen || ' - ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Curso: ' || v_nombre_curso || ' | Tema: ' || v_nombre_tema);
        DBMS_OUTPUT.PUT_LINE('Fecha: ' || v_fecha_inicio || ' a ' || v_fecha_fin);
        DBMS_OUTPUT.PUT_LINE('Estado: ' || v_estado);
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
END LOOP;

CLOSE v_cursor;
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

-- Datos para probarlo en la BD
SET SERVEROUTPUT ON;
DECLARE
v_cursor SYS_REFCURSOR;

    v_id_examen      PROYECTO_FINAL.EXAMEN.ID_EXAMEN%TYPE;
    v_nombre         PROYECTO_FINAL.EXAMEN.NOMBRE%TYPE;
    v_descripcion    PROYECTO_FINAL.EXAMEN.DESCRIPCION%TYPE;
    v_fecha_inicio   VARCHAR2(20);
    v_fecha_fin      VARCHAR2(20);
    v_estado         VARCHAR2(20);
    v_nombre_tema    PROYECTO_FINAL.TEMA.NOMBRE%TYPE;
    v_nombre_curso   PROYECTO_FINAL.CURSO.NOMBRE%TYPE;

BEGIN
    -- Reemplaza 456 con un ID de estudiante real
    v_cursor := EXAMENES_PENDIENTES_EST(4);

    LOOP
FETCH v_cursor INTO
            v_id_examen, v_nombre, v_descripcion,
            v_fecha_inicio, v_fecha_fin, v_estado,
            v_nombre_tema, v_nombre_curso;

        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Examen ID: ' || v_id_examen || ' - ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Curso: ' || v_nombre_curso || ' | Tema: ' || v_nombre_tema);
        DBMS_OUTPUT.PUT_LINE('Fecha: ' || v_fecha_inicio || ' a ' || v_fecha_fin);
        DBMS_OUTPUT.PUT_LINE('Estado: ' || v_estado);
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
END LOOP;

CLOSE v_cursor;
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

--Datos para probar la BD
SET SERVEROUTPUT ON;
DECLARE
v_nota NUMBER;
BEGIN
    v_nota := CALCULAR_NOTA_ESTUDIANTE(3);
    DBMS_OUTPUT.PUT_LINE('Nota total: ' || v_nota);
END;

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

SET SERVEROUTPUT ON;
DECLARE
v_porcentaje NUMBER;
BEGIN
    v_porcentaje := PORCENTAJE_PREGUNTAS_CORRECTAS(4);
    DBMS_OUTPUT.PUT_LINE('Porcentaje de respuestas correctas: ' || v_porcentaje || '%');
END;