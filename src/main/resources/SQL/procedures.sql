CREATE SEQUENCE SEQ_ID_USUARIO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
SELECT sequence_name FROM user_sequences;

-- PROCEDURE para registrar un nuevo usuario
create or replace PROCEDURE SP_REGISTRAR_USUARIO_COMPLETO (
    p_nombre             IN  VARCHAR2,
    p_apellido           IN  VARCHAR2,
    p_email              IN  VARCHAR2,
    p_contrasena         IN  VARCHAR2,
    p_id_tipo_usuario    IN  NUMBER,
    p_id_estado          IN  NUMBER,
    p_telefono           IN  VARCHAR2 DEFAULT NULL,
    p_direccion          IN  VARCHAR2 DEFAULT NULL,
    p_id_usuario_creado  OUT NUMBER,
    p_codigo_resultado   OUT NUMBER,
    p_mensaje_resultado  OUT VARCHAR2
)
IS
    v_email_existe      NUMBER := 0;
    v_tipo_usuario_valido NUMBER := 0;
    v_estado_valido     NUMBER := 0;
    v_secuencia_valida NUMBER := 0;

    -- Códigos de resultado
    COD_EXITO               CONSTANT NUMBER := 0;
    COD_EMAIL_YA_EXISTE     CONSTANT NUMBER := 1;
    COD_ERROR_PARAMETROS    CONSTANT NUMBER := 2;
    COD_ERROR_REGISTRO      CONSTANT NUMBER := 3;
    COD_TIPO_USUARIO_INVALIDO CONSTANT NUMBER := 4;
    COD_ESTADO_INVALIDO     CONSTANT NUMBER := 5;
    COD_ERROR_SECUENCIA     CONSTANT NUMBER := 6;
BEGIN
    -- Inicializar valores de salida
    p_id_usuario_creado := NULL;
    p_codigo_resultado  := COD_ERROR_REGISTRO;
    p_mensaje_resultado := 'Error en el proceso de registro';

    -- 1. Validación de parámetros obligatorios
    IF p_nombre IS NULL OR p_apellido IS NULL OR p_email IS NULL
       OR p_contrasena IS NULL OR p_id_tipo_usuario IS NULL OR p_id_estado IS NULL THEN
        p_codigo_resultado  := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Todos los campos obligatorios son requeridos';
        RETURN;
END IF;

    -- 2. Validación de longitudes máximas
    IF LENGTH(p_nombre) > 100 OR LENGTH(p_apellido) > 100
       OR LENGTH(p_email) > 100 OR LENGTH(p_contrasena) > 100 THEN
        p_codigo_resultado  := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Uno o más campos exceden la longitud máxima permitida (100 caracteres)';
        RETURN;
END IF;

    -- 3. Validar tipo de usuario (más eficiente)
BEGIN
SELECT 1 INTO v_tipo_usuario_valido
FROM TIPO_USUARIO
WHERE ID_TIPO_USUARIO = p_id_tipo_usuario
  AND ROWNUM = 1;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado  := COD_TIPO_USUARIO_INVALIDO;
            p_mensaje_resultado := 'Error: Tipo de usuario no válido (ID: '||p_id_tipo_usuario||')';
            RETURN;
END;

    -- 4. Validar estado (más eficiente)
BEGIN
SELECT 1 INTO v_estado_valido
FROM ESTADO_GENERAL
WHERE ID_ESTADO = p_id_estado
  AND ROWNUM = 1;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado  := COD_ESTADO_INVALIDO;
            p_mensaje_resultado := 'Error: Estado no válido (ID: '||p_id_estado||')';
            RETURN;
END;

-- 5. Verificar email único (corrección)
BEGIN
    SELECT COUNT(*) INTO v_email_existe
    FROM USUARIO
    WHERE EMAIL = p_email;
    
    IF v_email_existe > 0 THEN
        p_codigo_resultado  := COD_EMAIL_YA_EXISTE;
        p_mensaje_resultado := 'Error: El email '||p_email||' ya está registrado';
        RETURN;
    END IF;
END;

    -- 6. Validar secuencia
BEGIN
SELECT 1 INTO v_secuencia_valida
FROM USER_SEQUENCES
WHERE SEQUENCE_NAME = 'SEQ_ID_USUARIO';
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado  := COD_ERROR_SECUENCIA;
            p_mensaje_resultado := 'Error: Secuencia SEQ_ID_USUARIO no existe';
            RETURN;
END;

    -- 7. Obtener ID y registrar usuario
BEGIN
SELECT SEQ_ID_USUARIO.NEXTVAL INTO p_id_usuario_creado FROM DUAL;

INSERT INTO USUARIO (
    ID_USUARIO, ID_TIPO_USUARIO, NOMBRE, APELLIDO,
    EMAIL, CONTRASENA, ID_ESTADO, FECHA_REGISTRO,
    INTENTOS_FALLIDOS, TELEFONO, DIRECCION
) VALUES (
             p_id_usuario_creado, p_id_tipo_usuario, p_nombre, p_apellido,
             p_email, p_contrasena, p_id_estado, SYSDATE,
             0, p_telefono, p_direccion
         );

COMMIT;
p_codigo_resultado := COD_EXITO;
        p_mensaje_resultado := 'Usuario registrado exitosamente. ID: '||p_id_usuario_creado;

EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            p_codigo_resultado := COD_EMAIL_YA_EXISTE;
            p_mensaje_resultado := 'Error: El email ya existe (violación de índice único)';

WHEN OTHERS THEN
            ROLLBACK;
            p_codigo_resultado := COD_ERROR_REGISTRO;
            p_mensaje_resultado := 'Error técnico al registrar usuario: '||SUBSTR(SQLERRM,1,200);
END;
END SP_REGISTRAR_USUARIO_COMPLETO;


-- PROCEDURE para iniciar sesión

CREATE OR REPLACE PROCEDURE LOGIN_USUARIO (
    p_correo IN VARCHAR2,
    p_contrasena IN VARCHAR2,
    p_id_usuario OUT NUMBER,
    p_nombre_completo OUT VARCHAR2,
    p_tipo_usuario OUT VARCHAR2,
    p_resultado OUT NUMBER,
    p_mensaje OUT VARCHAR2
) AS
    v_usuario USUARIO%ROWTYPE;
    v_contrasena_db VARCHAR2(100);
    v_estado_usuario NUMBER;
    v_intentos_actuales NUMBER;
    v_next_audit_id NUMBER;
BEGIN
    -- Inicializar parámetros de salida
    p_id_usuario := NULL;
    p_nombre_completo := NULL;
    p_tipo_usuario := NULL;
    p_resultado := 0;
    p_mensaje := NULL;

    -- Buscar usuario por correo electrónico
BEGIN
SELECT * INTO v_usuario
FROM USUARIO
WHERE EMAIL = p_correo;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_resultado := -1; -- Usuario no encontrado
            p_mensaje := 'Correo electrónico no registrado';
            RETURN;
END;

    -- Verificar estado del usuario
    IF v_usuario.ID_ESTADO != 1 THEN -- 1 = Activo en tu tabla ESTADO_GENERAL
        p_resultado := -2; -- Usuario inactivo/bloqueado
        p_mensaje := 'Tu cuenta está inactiva o bloqueada';
        RETURN;
END IF;

    -- Verificar si la cuenta está bloqueada temporalmente por intentos fallidos
    IF v_usuario.FECHA_BLOQUEO IS NOT NULL AND
       v_usuario.FECHA_BLOQUEO > SYSTIMESTAMP - INTERVAL '30' MINUTE THEN
        p_resultado := -3; -- Cuenta bloqueada temporalmente
        p_mensaje := 'Cuenta bloqueada por múltiples intentos fallidos. Intenta nuevamente en 30 minutos.';
        RETURN;
END IF;

    -- Comparar contraseñas (en producción debería ser con hash)
    IF v_usuario.CONTRASENA = p_contrasena THEN
        -- Credenciales correctas
        p_resultado := 1; -- Éxito
        p_mensaje := 'Inicio de sesión exitoso';
        p_id_usuario := v_usuario.ID_USUARIO;
        p_nombre_completo := v_usuario.NOMBRE || ' ' || v_usuario.APELLIDO;

        -- Obtener nombre del tipo de usuario
SELECT NOMBRE INTO p_tipo_usuario
FROM TIPO_USUARIO
WHERE ID_TIPO_USUARIO = v_usuario.ID_TIPO_USUARIO;

-- Reiniciar contador de intentos fallidos
UPDATE USUARIO
SET INTENTOS_FALLIDOS = 0,
    FECHA_BLOQUEO = NULL,
    FECHA_ULTIMO_ACCESO = SYSTIMESTAMP
WHERE ID_USUARIO = v_usuario.ID_USUARIO;

-- Obtener próximo ID de auditoría (alternativa si no hay secuencia)
SELECT NVL(MAX(ID_AUDITORIA), 0) + 1 INTO v_next_audit_id FROM AUDITORIA;

-- Registrar acceso en auditoría
INSERT INTO AUDITORIA (
    ID_AUDITORIA, ID_USUARIO, TABLA_AFECTADA, ID_REGISTRO,
    TIPO_OPERACION, FECHA_OPERACION, IP_ACCESO
) VALUES (
             v_next_audit_id, v_usuario.ID_USUARIO, 'USUARIO', v_usuario.ID_USUARIO,
             'LOGIN_EXITOSO', SYSTIMESTAMP, NULL -- Aquí podrías pasar la IP si la tienes
         );
ELSE
        -- Credenciales incorrectas
        v_intentos_actuales := v_usuario.INTENTOS_FALLIDOS + 1;

        -- Actualizar intentos fallidos
UPDATE USUARIO
SET INTENTOS_FALLIDOS = v_intentos_actuales,
    FECHA_ULTIMO_ACCESO = SYSTIMESTAMP,
    FECHA_BLOQUEO = CASE
                        WHEN v_intentos_actuales >= 3 THEN SYSTIMESTAMP
                        ELSE FECHA_BLOQUEO
        END
WHERE ID_USUARIO = v_usuario.ID_USUARIO;

-- Determinar mensaje según intentos
IF v_intentos_actuales >= 3 THEN
            p_resultado := -3; -- Cuenta bloqueada
            p_mensaje := 'Contraseña incorrecta. Cuenta bloqueada por 30 minutos.';
ELSE
            p_resultado := -4; -- Contraseña incorrecta
            p_mensaje := 'Contraseña incorrecta. Intentos restantes: ' || (3 - v_intentos_actuales);
END IF;

        -- Obtener próximo ID de auditoría (alternativa si no hay secuencia)
SELECT NVL(MAX(ID_AUDITORIA), 0) + 1 INTO v_next_audit_id FROM AUDITORIA;

-- Registrar intento fallido en auditoría
INSERT INTO AUDITORIA (
    ID_AUDITORIA, ID_USUARIO, TABLA_AFECTADA, ID_REGISTRO,
    TIPO_OPERACION, FECHA_OPERACION, DATOS_ANTERIORES,
    DATOS_NUEVOS, IP_ACCESO
) VALUES (
             v_next_audit_id, v_usuario.ID_USUARIO, 'USUARIO', v_usuario.ID_USUARIO,
             'LOGIN_FALLIDO', SYSTIMESTAMP,
             'Intentos fallidos: ' || v_usuario.INTENTOS_FALLIDOS,
             'Intentos fallidos: ' || v_intentos_actuales,
             NULL -- IP si está disponible
         );
END IF;

COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -99; -- Error inesperado
        p_mensaje := 'Error durante el inicio de sesión: ' || SUBSTR(SQLERRM, 1, 200);
END LOGIN_USUARIO;

-- PROCEDURE para crear un nuevo examen

CREATE SEQUENCE SEQ_ID_EXAMEN START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE PROCEDURE SP_CREAR_EXAMEN (
    -- Parámetros de entrada básicos
    p_id_docente                   IN  NUMBER,
    p_id_tema                      IN  NUMBER,
    p_nombre                       IN  VARCHAR2,
    p_descripcion                  IN  VARCHAR2,
    -- Parámetros de configuración
    p_fecha_inicio                 IN  TIMESTAMP,
    p_fecha_fin                    IN  TIMESTAMP,
    p_tiempo_limite                IN  NUMBER,
    p_peso_curso                   IN  NUMBER,
    p_umbral_aprobacion            IN  NUMBER,
    p_cantidad_preguntas_total     IN  NUMBER,
    p_cantidad_preguntas_presentar IN  NUMBER,
    p_id_categoria                 IN  NUMBER,
    p_intentos_permitidos          IN  NUMBER DEFAULT 1,
    p_mostrar_resultados           IN  NUMBER DEFAULT 1,
    p_permitir_retroalimentacion   IN  NUMBER DEFAULT 1,
    -- Parámetros de salida
    p_id_examen_creado             OUT NUMBER,
    p_codigo_resultado             OUT NUMBER,
    p_mensaje_resultado            OUT VARCHAR2
)
IS
    -- Variables locales
    v_id_examen            NUMBER;
    v_tema_existe          NUMBER := 0;
    v_docente_existe       NUMBER := 0;
    v_categoria_existe     NUMBER := 0;
    v_secuencia_existe     NUMBER := 0;
    v_id_estado            NUMBER := 1; -- Por defecto activo
    
    -- Códigos de resultado
    COD_EXITO                   CONSTANT NUMBER := 0;
    COD_ERROR_PARAMETROS        CONSTANT NUMBER := 1;
    COD_DOCENTE_NO_EXISTE       CONSTANT NUMBER := 2;
    COD_TEMA_NO_EXISTE          CONSTANT NUMBER := 3;
    COD_CATEGORIA_NO_EXISTE     CONSTANT NUMBER := 4;
    COD_ERROR_FECHAS            CONSTANT NUMBER := 5;
    COD_ERROR_CANTIDADES        CONSTANT NUMBER := 6;
    COD_ERROR_REGISTRO          CONSTANT NUMBER := 7;
    COD_ERROR_SECUENCIA         CONSTANT NUMBER := 8;
BEGIN
    -- Inicializar parámetros de salida
    p_id_examen_creado := NULL;
    p_codigo_resultado := COD_ERROR_REGISTRO;
    p_mensaje_resultado := 'Error en el proceso de creación del examen';

    -- 1. Validación de parámetros obligatorios
    IF p_id_docente IS NULL OR p_id_tema IS NULL OR p_nombre IS NULL THEN
        p_codigo_resultado := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Los campos id_docente, id_tema y nombre son obligatorios';
        RETURN;
    END IF;

    -- 2. Validación de longitudes máximas
    IF LENGTH(p_nombre) > 100 OR (p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 500) THEN
        p_codigo_resultado := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Nombre o descripción exceden la longitud permitida';
        RETURN;
    END IF;

    -- 3. Validar que el docente exista
    BEGIN
        SELECT 1 INTO v_docente_existe
        FROM USUARIO
        WHERE ID_USUARIO = p_id_docente
          AND ID_TIPO_USUARIO = 2 -- Tipo docente
          AND ID_ESTADO = 1       -- Activo
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := COD_DOCENTE_NO_EXISTE;
            p_mensaje_resultado := 'Error: El docente especificado no existe o no está activo';
            RETURN;
    END;

    -- 4. Validar que el tema exista
    BEGIN
        SELECT 1 INTO v_tema_existe
        FROM TEMA
        WHERE ID_TEMA = p_id_tema
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := COD_TEMA_NO_EXISTE;
            p_mensaje_resultado := 'Error: El tema especificado no existe';
            RETURN;
    END;

    -- 5. Validar categoría si se proporciona
    IF p_id_categoria IS NOT NULL THEN
        BEGIN
            SELECT 1 INTO v_categoria_existe
            FROM CATEGORIA_EXAMEN
            WHERE ID_CATEGORIA = p_id_categoria
              AND ESTADO = 1
              AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_codigo_resultado := COD_CATEGORIA_NO_EXISTE;
                p_mensaje_resultado := 'Error: La categoría especificada no existe o no está activa';
                RETURN;
        END;
    END IF;

    -- 6. Validar fechas si se proporcionan
    IF p_fecha_inicio IS NOT NULL AND p_fecha_fin IS NOT NULL THEN
        IF p_fecha_inicio >= p_fecha_fin THEN
            p_codigo_resultado := COD_ERROR_FECHAS;
            p_mensaje_resultado := 'Error: La fecha de inicio debe ser anterior a la fecha de fin';
            RETURN;
        END IF;
    END IF;

    -- 7. Validar cantidades de preguntas
    IF p_cantidad_preguntas_total IS NOT NULL AND p_cantidad_preguntas_presentar IS NOT NULL THEN
        IF p_cantidad_preguntas_presentar > p_cantidad_preguntas_total THEN
            p_codigo_resultado := COD_ERROR_CANTIDADES;
            p_mensaje_resultado := 'Error: El número de preguntas a presentar no puede ser mayor al total';
            RETURN;
        END IF;
    END IF;

    -- 8. Verificar existencia de secuencia
    BEGIN
        SELECT 1 INTO v_secuencia_existe
        FROM USER_SEQUENCES
        WHERE SEQUENCE_NAME = 'SEQ_ID_EXAMEN';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Crear secuencia si no existe
            EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ID_EXAMEN START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
            v_secuencia_existe := 1;
    END;

    -- 9. Generar ID para el examen
    BEGIN
        SELECT SEQ_ID_EXAMEN.NEXTVAL INTO v_id_examen FROM DUAL;
    EXCEPTION
        WHEN OTHERS THEN
            p_codigo_resultado := COD_ERROR_SECUENCIA;
            p_mensaje_resultado := 'Error al generar ID para el examen: ' || SQLERRM;
            RETURN;
    END;

    -- 10. Insertar el examen
    BEGIN
        INSERT INTO EXAMEN (
            ID_EXAMEN, ID_DOCENTE, ID_TEMA, NOMBRE, DESCRIPCION,
            FECHA_CREACION, FECHA_INICIO, FECHA_FIN, TIEMPO_LIMITE,
            PESO_CURSO, UMBRAL_APROBACION, CANTIDAD_PREGUNTAS_TOTAL,
            CANTIDAD_PREGUNTAS_PRESENTAR, ID_ESTADO, ID_CATEGORIA,
            INTENTOS_PERMITIDOS, MOSTRAR_RESULTADOS, PERMITIR_RETROALIMENTACION,
            FECHA_ULTIMA_MODIFICACION, ID_USUARIO_ULTIMA_MODIFICACION
        ) VALUES (
            v_id_examen, p_id_docente, p_id_tema, p_nombre, p_descripcion,
            SYSDATE, p_fecha_inicio, p_fecha_fin, p_tiempo_limite,
            p_peso_curso, p_umbral_aprobacion, p_cantidad_preguntas_total,
            p_cantidad_preguntas_presentar, v_id_estado, p_id_categoria,
            p_intentos_permitidos, p_mostrar_resultados, p_permitir_retroalimentacion,
            SYSDATE, p_id_docente
        );

        -- Asignar valores de salida
        p_id_examen_creado := v_id_examen;
        p_codigo_resultado := COD_EXITO;
        p_mensaje_resultado := 'Examen creado exitosamente. ID: ' || v_id_examen;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_codigo_resultado := COD_ERROR_REGISTRO;
            p_mensaje_resultado := 'Error al registrar el examen: ' || SUBSTR(SQLERRM, 1, 200);
    END;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := COD_ERROR_REGISTRO;
        p_mensaje_resultado := 'Error inesperado: ' || SUBSTR(SQLERRM, 1, 200);
END SP_CREAR_EXAMEN;