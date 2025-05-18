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