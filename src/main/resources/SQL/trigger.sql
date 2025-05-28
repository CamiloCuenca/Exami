-- Creamos una tabla temporal para almacenar los IDs de usuarios que deben ser bloqueados
CREATE GLOBAL TEMPORARY TABLE TEMP_USUARIOS_A_BLOQUEAR (
    ID_USUARIO NUMBER PRIMARY KEY
) ON COMMIT DELETE ROWS;

-- Creamos un trigger compuesto para resolver el problema de tabla mutante
CREATE OR REPLACE TRIGGER TRG_BLOQUEO_CUENTA_COMPUESTO
FOR UPDATE OF INTENTOS_FALLIDOS ON USUARIO
COMPOUND TRIGGER

    -- Sección que se ejecuta antes del procesamiento de cada fila
    BEFORE EACH ROW IS
    BEGIN
        -- Verificar si se alcanzaron los 3 intentos fallidos
        IF :NEW.INTENTOS_FALLIDOS >= 3 AND (:OLD.INTENTOS_FALLIDOS < 3 OR :OLD.FECHA_BLOQUEO IS NULL) THEN
            -- Insertar en la tabla temporal para procesar después
            INSERT INTO TEMP_USUARIOS_A_BLOQUEAR (ID_USUARIO)
            VALUES (:NEW.ID_USUARIO);
        END IF;
    END BEFORE EACH ROW;

    -- Sección que se ejecuta después de que se han procesado todas las filas
    AFTER STATEMENT IS
        CURSOR c_usuarios_a_bloquear IS
            SELECT ID_USUARIO FROM TEMP_USUARIOS_A_BLOQUEAR;
        v_id_usuario NUMBER;
    BEGIN
        -- Procesar cada usuario que debe ser bloqueado
        OPEN c_usuarios_a_bloquear;
        LOOP
            FETCH c_usuarios_a_bloquear INTO v_id_usuario;
            EXIT WHEN c_usuarios_a_bloquear%NOTFOUND;

            -- Actualizar la fecha de bloqueo y el estado
            UPDATE USUARIO
            SET FECHA_BLOQUEO = SYSTIMESTAMP,
                ID_ESTADO = 3  -- Estado "Bloqueado"
            WHERE ID_USUARIO = v_id_usuario;
        END LOOP;
        CLOSE c_usuarios_a_bloquear;

        -- La tabla temporal se limpiará automáticamente (ON COMMIT DELETE ROWS)
    END AFTER STATEMENT;

END TRG_BLOQUEO_CUENTA_COMPUESTO;
/

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Tabla donde se guardan los estudiantes que termianan un examen
CREATE TABLE ESTUDIANTES_EXAMEN_FINALIZADO (
                                               ID_REGISTRO NUMBER PRIMARY KEY,
                                               ID_PRESENTACION NUMBER NOT NULL,
                                               ID_EXAMEN NUMBER NOT NULL,
                                               ID_ESTUDIANTE NUMBER NOT NULL,
                                               FECHA_FINALIZACION TIMESTAMP NOT NULL,
                                               PUNTAJE_OBTENIDO NUMBER(5,2),
                                               TIEMPO_UTILIZADO NUMBER(4),
                                               FECHA_REGISTRO TIMESTAMP DEFAULT SYSTIMESTAMP
);


--Trigger que se activa cuando el examen se envia
CREATE OR REPLACE TRIGGER TRG_ESTUDIANTE_FINALIZA_EXAMEN
AFTER UPDATE OF FECHA_FIN ON PRESENTACION_EXAMEN
    FOR EACH ROW
    WHEN (NEW.FECHA_FIN IS NOT NULL AND OLD.FECHA_FIN IS NULL)
BEGIN
INSERT INTO ESTUDIANTES_EXAMEN_FINALIZADO (
    ID_REGISTRO,
    ID_PRESENTACION,
    ID_EXAMEN,
    ID_ESTUDIANTE,
    FECHA_FINALIZACION,
    PUNTAJE_OBTENIDO,
    TIEMPO_UTILIZADO
)
VALUES (
           SEQ_EXAMEN_FINALIZADO.NEXTVAL,
           :NEW.ID_PRESENTACION,
           :NEW.ID_EXAMEN,
           :NEW.ID_ESTUDIANTE,
           :NEW.FECHA_FIN,
           :NEW.PUNTAJE_OBTENIDO,
           :NEW.TIEMPO_UTILIZADO
       );
END;
/

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Crear la tabla para guardar todos los exmanes creaos
CREATE TABLE HISTORIAL_EXAMENES_CREADOS (
                                            ID NUMBER PRIMARY KEY,
                                            ID_EXAMEN NUMBER,
                                            ID_DOCENTE NUMBER,
                                            FECHA_CREACION TIMESTAMP DEFAULT SYSTIMESTAMP
);

--Trigger para guardar los examenes en la tabla
CREATE OR REPLACE TRIGGER TRG_REGISTRO_EXAMEN_DOCENTE
AFTER INSERT ON EXAMEN
FOR EACH ROW
BEGIN
INSERT INTO HISTORIAL_EXAMENES_CREADOS (
    ID,
    ID_EXAMEN,
    ID_DOCENTE
) VALUES (
             SEQ_HIST_EXAMEN_CREADO.NEXTVAL,
             :NEW.ID_EXAMEN,
             :NEW.ID_DOCENTE
         );
END;
/

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Tabla para guardar las preguntas con bajo rendimiento
CREATE TABLE PREGUNTAS_CON_BAJO_RENDIMIENTO (
    ID NUMBER PRIMARY KEY,
    ID_PREGUNTA NUMBER,
    PORCENTAJE_CORRECTAS NUMBER(5,2),
    TOTAL_ESTUDIANTES NUMBER,
    FECHA_DETECCION TIMESTAMP DEFAULT SYSTIMESTAMP
);

--Crear paquete para almacenar temporalmente los IDs de preguntas afectadas
CREATE OR REPLACE PACKAGE PREGUNTAS_MUTANTES AS
    TYPE T_ID_LIST IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    IDS T_ID_LIST;
    CONTADOR PLS_INTEGER := 0;
END PREGUNTAS_MUTANTES;
/

--Trigger BEFORE INSERT fila: guarda solo el ID_PREGUNTA
CREATE OR REPLACE TRIGGER TRG_PREGUNTA_BAJO_RENDIMIENTO
BEFORE INSERT ON RESPUESTA_ESTUDIANTE
FOR EACH ROW
BEGIN
    PREGUNTAS_MUTANTES.CONTADOR := PREGUNTAS_MUTANTES.CONTADOR + 1;
    PREGUNTAS_MUTANTES.IDS(PREGUNTAS_MUTANTES.CONTADOR) := :NEW.ID_PREGUNTA;
END;
/

--Trigger AFTER STATEMENT: hace el análisis real
CREATE OR REPLACE TRIGGER TRG_PREGUNTA_BA_REND_STATEMENT
AFTER INSERT ON RESPUESTA_ESTUDIANTE
DECLARE
V_ID NUMBER;
    V_TOTAL INT;
    V_CORRECTAS INT;
    V_PORCENTAJE NUMBER(5,2);
BEGIN
FOR I IN 1 .. PREGUNTAS_MUTANTES.CONTADOR LOOP
        V_ID := PREGUNTAS_MUTANTES.IDS(I);

SELECT COUNT(*) INTO V_TOTAL
FROM RESPUESTA_ESTUDIANTE
WHERE ID_PREGUNTA = V_ID;

SELECT COUNT(*) INTO V_CORRECTAS
FROM RESPUESTA_ESTUDIANTE
WHERE ID_PREGUNTA = V_ID AND ES_CORRECTA = 1;

V_PORCENTAJE := (V_CORRECTAS / V_TOTAL) * 100;

        IF V_TOTAL >= 5 AND V_PORCENTAJE < 40 THEN
            INSERT INTO PREGUNTAS_CON_BAJO_RENDIMIENTO (
                ID,
                ID_PREGUNTA,
                PORCENTAJE_CORRECTAS,
                TOTAL_ESTUDIANTES
            )
SELECT SEQ_PREGUNTA_BAJO_REND.NEXTVAL, V_ID, V_PORCENTAJE, V_TOTAL
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM PREGUNTAS_CON_BAJO_RENDIMIENTO WHERE ID_PREGUNTA = V_ID
);
END IF;
END LOOP;

    -- Reset
    PREGUNTAS_MUTANTES.CONTADOR := 0;
END;
/

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Tabla de las preguntas modificadas
CREATE TABLE MODIFICACION_PREGUNTAS (
                                        ID NUMBER PRIMARY KEY,
                                        ID_PREGUNTA NUMBER,
                                        ID_DOCENTE NUMBER,
                                        FECHA_MODIFICACION TIMESTAMP DEFAULT SYSTIMESTAMP,
                                        TEXTO_ANTERIOR VARCHAR2(1000),
                                        TEXTO_NUEVO VARCHAR2(1000)
);

--Tigger para guardar las peguntas modificadas
CREATE OR REPLACE TRIGGER TRG_LOG_MODIFICACION_PREGUNTA
BEFORE UPDATE ON PREGUNTA
                  FOR EACH ROW
BEGIN
    IF :OLD.ID_DOCENTE IS NOT NULL THEN
        INSERT INTO MODIFICACION_PREGUNTAS (
            ID,
            ID_PREGUNTA,
            ID_DOCENTE,
            TEXTO_ANTERIOR,
            TEXTO_NUEVO
        ) VALUES (
            SEQ_MODIF_PREGUNTA.NEXTVAL,
            :OLD.ID_PREGUNTA,
            :OLD.ID_DOCENTE,
            :OLD.TEXTO_PREGUNTA,
            :NEW.TEXTO_PREGUNTA
        );
END IF;
END;
/

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Tabla de rpesentaciones de examens
CREATE TABLE HISTORIAL_PRESENTACIONES (
                                          ID NUMBER PRIMARY KEY,
                                          ID_ESTUDIANTE NUMBER,
                                          ID_EXAMEN NUMBER,
                                          FECHA_INICIO TIMESTAMP,
                                          IP_ACCESO VARCHAR2(15)
);

--Trigger para agregar los datos de la tabla de presentacion de examenes
CREATE OR REPLACE TRIGGER TRG_LOG_PRESENTACION_EXAMEN
AFTER INSERT ON PRESENTACION_EXAMEN
FOR EACH ROW
BEGIN
INSERT INTO HISTORIAL_PRESENTACIONES (
    ID,
    ID_ESTUDIANTE,
    ID_EXAMEN,
    FECHA_INICIO,
    IP_ACCESO
) VALUES (
             SEQ_HIST_PRESENTACION.NEXTVAL,
             :NEW.ID_ESTUDIANTE,
             :NEW.ID_EXAMEN,
             :NEW.FECHA_INICIO,
             :NEW.IP_ACCESO
         );
END;
/

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Tabla para guardar los resultados de los estudantes
CREATE TABLE RESULTADO_EXAMEN_ESTUDIANTE (
                                             ID_RESULTADO NUMBER PRIMARY KEY,
                                             ID_PRESENTACION NUMBER NOT NULL,
                                             ID_ESTUDIANTE NUMBER NOT NULL,
                                             ID_EXAMEN NUMBER NOT NULL,
                                             PUNTAJE_OBTENIDO NUMBER(5,2),
                                             UMBRAL_APROBACION NUMBER(5,2),
                                             RESULTADO VARCHAR2(10), -- 'APROBADO' o 'REPROBADO'
                                             FECHA_REGISTRO TIMESTAMP DEFAULT SYSTIMESTAMP
);

--Trigger para guardar el puntaje de los estudiantes
CREATE OR REPLACE TRIGGER TRG_RESULTADO_PRESENTACION
AFTER UPDATE OF PUNTAJE_OBTENIDO ON PRESENTACION_EXAMEN
    FOR EACH ROW
DECLARE
V_UMBRAL NUMBER(5,2);
BEGIN
    -- Obtener el umbral de aprobación desde la tabla EXAMEN
SELECT UMBRAL_APROBACION
INTO V_UMBRAL
FROM EXAMEN
WHERE ID_EXAMEN = :NEW.ID_EXAMEN;

-- Insertar resultado
INSERT INTO RESULTADO_EXAMEN_ESTUDIANTE (
    ID_RESULTADO,
    ID_PRESENTACION,
    ID_ESTUDIANTE,
    ID_EXAMEN,
    PUNTAJE_OBTENIDO,
    UMBRAL_APROBACION,
    RESULTADO
) VALUES (
             SEQ_RESULTADO_EXAMEN.NEXTVAL,
             :NEW.ID_PRESENTACION,
             :NEW.ID_ESTUDIANTE,
             :NEW.ID_EXAMEN,
             :NEW.PUNTAJE_OBTENIDO,
             V_UMBRAL,
             CASE
                 WHEN :NEW.PUNTAJE_OBTENIDO >= V_UMBRAL THEN 'APROBADO'
                 ELSE 'REPROBADO'
                 END
         );
END;
/