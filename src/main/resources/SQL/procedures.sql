-- Crear secuencias necesarias
CREATE SEQUENCE SEQ_ID_USUARIO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EXAMEN_PREGUNTA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

--PROCEDURE PARA REGISTRAR USUARIO
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
        WHERE UPPER(EMAIL) = UPPER(p_email);

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

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- PROCEDURE para iniciar sesión con lógica simplificada (la lógica de bloqueo está en el trigger)
CREATE OR REPLACE PROCEDURE LOGIN_USUARIO (
    p_correo            IN VARCHAR2,
    p_contrasena        IN VARCHAR2,
    p_id_usuario        OUT NUMBER,
    p_nombre_completo   OUT VARCHAR2,
    p_tipo_usuario      OUT VARCHAR2,
    p_resultado         OUT NUMBER,
    p_mensaje           OUT VARCHAR2,
    p_ip_acceso         IN VARCHAR2 DEFAULT NULL
) AS
    v_usuario           USUARIO%ROWTYPE;
    v_intentos_actuales NUMBER;
    v_fecha_actual      TIMESTAMP := SYSTIMESTAMP;
    v_estado_nombre     VARCHAR2(100);

    -- Códigos de resultado estandarizados
    COD_EXITO                   CONSTANT NUMBER := 1;   -- Mantener 1 para éxito para compatibilidad
    COD_USUARIO_NO_ENCONTRADO   CONSTANT NUMBER := -1;
    COD_USUARIO_INACTIVO        CONSTANT NUMBER := -2;
    COD_CUENTA_BLOQUEADA        CONSTANT NUMBER := -3;
    COD_CONTRASENA_INCORRECTA   CONSTANT NUMBER := -4;
    COD_ERROR_DESCONOCIDO       CONSTANT NUMBER := -99;
BEGIN
    -- Inicializar parámetros de salida
    p_id_usuario := NULL;
    p_nombre_completo := NULL;
    p_tipo_usuario := NULL;
    p_resultado := COD_ERROR_DESCONOCIDO;
    p_mensaje := 'Error durante el inicio de sesión';

    -- Validación de parámetros de entrada
    IF p_correo IS NULL OR LENGTH(TRIM(p_correo)) = 0 THEN
        p_resultado := COD_USUARIO_NO_ENCONTRADO;
        p_mensaje := 'El correo electrónico es obligatorio';
        RETURN;
    END IF;

    IF p_contrasena IS NULL THEN
        p_resultado := COD_CONTRASENA_INCORRECTA;
        p_mensaje := 'La contraseña es obligatoria';
        RETURN;
    END IF;

    -- Buscar usuario por correo electrónico
    BEGIN
        SELECT * INTO v_usuario
        FROM USUARIO
        WHERE EMAIL = p_correo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_resultado := COD_USUARIO_NO_ENCONTRADO;
            p_mensaje := 'Correo electrónico no registrado';
            RETURN;
    END;

    -- Verificar estado del usuario (Activo, Inactivo, Bloqueado)
    BEGIN
        SELECT NOMBRE INTO v_estado_nombre
        FROM ESTADO_GENERAL
        WHERE ID_ESTADO = v_usuario.ID_ESTADO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_estado_nombre := 'Desconocido';
    END;

    -- Verificar si la cuenta está bloqueada (estado 3) o inactiva (estado 2)
    IF v_usuario.ID_ESTADO = 3 THEN
        p_resultado := COD_CUENTA_BLOQUEADA;
        p_mensaje := 'Tu cuenta está bloqueada. Contacta a soporte técnico o espera 30 minutos.';
        RETURN;
    ELSIF v_usuario.ID_ESTADO != 1 THEN
        p_resultado := COD_USUARIO_INACTIVO;
        p_mensaje := 'Tu cuenta está inactiva o suspendida. Estado: ' || v_estado_nombre;
        RETURN;
    END IF;

    -- Verificar bloqueo temporal por intentos fallidos (incluso si el estado sigue siendo Activo)
    IF v_usuario.FECHA_BLOQUEO IS NOT NULL AND
       v_usuario.FECHA_BLOQUEO > v_fecha_actual - INTERVAL '30' MINUTE THEN
        -- Asegurar que el estado sea coherente con el bloqueo temporal
        UPDATE USUARIO
        SET ID_ESTADO = 3
        WHERE ID_USUARIO = v_usuario.ID_USUARIO
        AND ID_ESTADO = 1;
        
        p_resultado := COD_CUENTA_BLOQUEADA;
        p_mensaje := 'Cuenta bloqueada por múltiples intentos fallidos. Intenta nuevamente en 30 minutos.';
        RETURN;
    END IF;

    -- Si la cuenta estuvo bloqueada pero pasaron los 30 minutos, desbloquearla automáticamente
    IF v_usuario.FECHA_BLOQUEO IS NOT NULL AND
       v_usuario.FECHA_BLOQUEO <= v_fecha_actual - INTERVAL '30' MINUTE AND
       v_usuario.ID_ESTADO = 3 THEN
        UPDATE USUARIO
        SET ID_ESTADO = 1,
            FECHA_BLOQUEO = NULL,
            INTENTOS_FALLIDOS = 0
        WHERE ID_USUARIO = v_usuario.ID_USUARIO;
    END IF;

    -- Comparar contraseñas (mantenido en texto plano según solicitud)
    IF v_usuario.CONTRASENA = p_contrasena THEN
        -- Credenciales correctas
        p_resultado := COD_EXITO; -- Usando 1 para éxito
        p_mensaje := 'Inicio de sesión exitoso';
        p_id_usuario := v_usuario.ID_USUARIO;
        p_nombre_completo := v_usuario.NOMBRE || ' ' || v_usuario.APELLIDO;

        -- Obtener nombre del tipo de usuario
        BEGIN
            SELECT NOMBRE INTO p_tipo_usuario
            FROM TIPO_USUARIO
            WHERE ID_TIPO_USUARIO = v_usuario.ID_TIPO_USUARIO;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_tipo_usuario := 'Desconocido';
        END;

        -- Reiniciar contador de intentos fallidos
        UPDATE USUARIO
        SET INTENTOS_FALLIDOS = 0,
            FECHA_BLOQUEO = NULL,
            FECHA_ULTIMO_ACCESO = v_fecha_actual
        WHERE ID_USUARIO = v_usuario.ID_USUARIO;
    ELSE
        -- Credenciales incorrectas
        v_intentos_actuales := NVL(v_usuario.INTENTOS_FALLIDOS, 0) + 1;

        -- Actualizar intentos fallidos (el trigger se encargará de bloquear si es necesario)
        UPDATE USUARIO
        SET INTENTOS_FALLIDOS = v_intentos_actuales,
            FECHA_ULTIMO_ACCESO = v_fecha_actual
        WHERE ID_USUARIO = v_usuario.ID_USUARIO;
        
        -- Importante: hacer commit para que el trigger se ejecute correctamente
        COMMIT;
        
        -- Para tests: re-obtener los datos actualizados del usuario
        BEGIN
            SELECT ID_ESTADO, FECHA_BLOQUEO 
            INTO v_usuario.ID_ESTADO, v_usuario.FECHA_BLOQUEO
            FROM USUARIO
            WHERE ID_USUARIO = v_usuario.ID_USUARIO;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignorar errores aquí
        END;

        -- Determinar mensaje según intentos
        IF v_intentos_actuales >= 3 OR v_usuario.FECHA_BLOQUEO IS NOT NULL OR v_usuario.ID_ESTADO = 3 THEN
            p_resultado := COD_CUENTA_BLOQUEADA;
            p_mensaje := 'Contraseña incorrecta. Cuenta bloqueada por 30 minutos.';
        ELSE
            p_resultado := COD_CONTRASENA_INCORRECTA;
            p_mensaje := 'Contraseña incorrecta. Intentos restantes: ' || (3 - v_intentos_actuales);
        END IF;
    END IF;

    -- Solo commit para login exitoso (ya hicimos commit para el caso de contraseña incorrecta)
    IF p_resultado = COD_EXITO THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := COD_ERROR_DESCONOCIDO;
        p_mensaje := 'Error durante el inicio de sesión: ' || SUBSTR(SQLERRM, 1, 200);
END LOGIN_USUARIO;

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- PROCEDURE para crear un nuevo examen
CREATE SEQUENCE SEQ_ID_EXAMEN START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE PROCEDURE SP_CREAR_EXAMEN (
    -- Parámetros de entrada básicos
    p_id_docente                   IN  NUMBER,
    p_id_tema                      IN  NUMBER,
    p_nombre                        IN  VARCHAR2,
    p_descripcion                   IN  VARCHAR2,
    -- Parámetros de configuración
    p_fecha_inicio                  IN  TIMESTAMP,
    p_fecha_fin                     IN  TIMESTAMP,
    p_tiempo_limite                 IN  NUMBER,
    p_peso_curso                    IN  NUMBER,
    p_umbral_aprobacion             IN  NUMBER,
    p_cantidad_preguntas_total      IN  NUMBER,
    p_cantidad_preguntas_presentar   IN  NUMBER,
    p_id_categoria                  IN  NUMBER,
    p_intentos_permitidos           IN  NUMBER DEFAULT 1,
    p_mostrar_resultados            IN  NUMBER DEFAULT 1,
    p_permitir_retroalimentacion    IN  NUMBER DEFAULT 1,
    -- Parámetros de salida
    p_id_examen_creado              OUT NUMBER,
    p_codigo_resultado              OUT NUMBER,
    p_mensaje_resultado             OUT VARCHAR2
)
IS
    -- Variables locales
    v_id_examen             NUMBER;
    v_tema_existe           NUMBER := 0;
    v_docente_existe        NUMBER := 0;
    v_categoria_existe      NUMBER := 0;
    v_secuencia_existe      NUMBER := 0;
    v_id_estado             NUMBER := 1; -- Por defecto activo
    
    -- Códigos de resultado
    COD_EXITO                    CONSTANT NUMBER := 0;
    COD_ERROR_PARAMETROS         CONSTANT NUMBER := 1;
    COD_DOCENTE_NO_EXISTE        CONSTANT NUMBER := 2;
    COD_TEMA_NO_EXISTE           CONSTANT NUMBER := 3;
    COD_CATEGORIA_NO_EXISTE      CONSTANT NUMBER := 4;
    COD_ERROR_FECHAS             CONSTANT NUMBER := 5;
    COD_ERROR_CANTIDADES         CONSTANT NUMBER := 6;
    COD_ERROR_REGISTRO           CONSTANT NUMBER := 7;
    COD_ERROR_SECUENCIA          CONSTANT NUMBER := 8;
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

--//////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE PROCEDURE SP_AGREGAR_PREGUNTA (
    -- Parámetros básicos de la pregunta
    p_id_docente            IN NUMBER,
    p_id_tema               IN NUMBER,
    p_id_nivel_dificultad   IN NUMBER,
    p_id_tipo_pregunta      IN NUMBER,
    p_texto_pregunta        IN VARCHAR2,
    p_es_publica            IN NUMBER DEFAULT 0,
    p_tiempo_maximo         IN NUMBER DEFAULT NULL,
    p_porcentaje            IN NUMBER DEFAULT 100,
    p_id_pregunta_padre     IN NUMBER DEFAULT NULL,
    -- Parámetros para las opciones de respuesta (arrays)
    p_textos_opciones       IN SYS.ODCIVARCHAR2LIST,
    p_son_correctas         IN SYS.ODCINUMBERLIST,
    p_ordenes               IN SYS.ODCINUMBERLIST,
    -- Parámetros de salida
    p_id_pregunta_creada    OUT NUMBER,
    p_codigo_resultado      OUT NUMBER,
    p_mensaje_resultado     OUT VARCHAR2
)
IS
    -- Variables locales
    v_id_pregunta         NUMBER;
    v_id_opcion           NUMBER;
    v_docente_existe      NUMBER := 0;
    v_tema_existe         NUMBER := 0;
    v_nivel_existe        NUMBER := 0;
    v_tipo_existe         NUMBER := 0;
    v_pregunta_padre_existe NUMBER := 0;
    v_num_opciones_correctas NUMBER := 0;
    v_id_estado           NUMBER := 1; -- Por defecto activo
    v_seq_exists          NUMBER := 0;
    v_max_id_pregunta     NUMBER := 0;
    
    -- Códigos de resultado
    COD_EXITO                   CONSTANT NUMBER := 0;
    COD_ERROR_PARAMETROS        CONSTANT NUMBER := 1;
    COD_DOCENTE_NO_EXISTE       CONSTANT NUMBER := 2;
    COD_TEMA_NO_EXISTE          CONSTANT NUMBER := 3;
    COD_NIVEL_NO_EXISTE         CONSTANT NUMBER := 4;
    COD_TIPO_NO_EXISTE          CONSTANT NUMBER := 5;
    COD_PREGUNTA_PADRE_NO_EXISTE CONSTANT NUMBER := 6;
    COD_ERROR_OPCIONES          CONSTANT NUMBER := 7;
    COD_ERROR_REGISTRO          CONSTANT NUMBER := 8;
    COD_ERROR_SECUENCIA         CONSTANT NUMBER := 9;
BEGIN
    -- Inicializar parámetros de salida
    p_id_pregunta_creada := NULL;
    p_codigo_resultado := COD_ERROR_REGISTRO;
    p_mensaje_resultado := 'Error en el proceso de creación de la pregunta';

    -- 1. Validación de parámetros obligatorios
    IF p_id_docente IS NULL OR p_id_tema IS NULL OR 
       p_id_nivel_dificultad IS NULL OR p_id_tipo_pregunta IS NULL OR
       p_texto_pregunta IS NULL THEN
        p_codigo_resultado := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Los campos docente, tema, nivel, tipo y texto son obligatorios';
        RETURN;
    END IF;

    -- 2. Validación de longitudes máximas
    IF LENGTH(p_texto_pregunta) > 1000 THEN
        p_codigo_resultado := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: El texto de la pregunta excede la longitud permitida (1000 caracteres)';
        RETURN;
    END IF;

    -- 3. Validar que el docente exista y sea de tipo docente
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

    -- 5. Validar nivel de dificultad
    BEGIN
        SELECT 1 INTO v_nivel_existe
        FROM NIVEL_DIFICULTAD
        WHERE ID_NIVEL_DIFICULTAD = p_id_nivel_dificultad
          AND ESTADO = 1
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := COD_NIVEL_NO_EXISTE;
            p_mensaje_resultado := 'Error: El nivel de dificultad especificado no existe o no está activo';
            RETURN;
    END;

    -- 6. Validar tipo de pregunta
    BEGIN
        SELECT 1 INTO v_tipo_existe
        FROM TIPO_PREGUNTA
        WHERE ID_TIPO_PREGUNTA = p_id_tipo_pregunta
          AND ESTADO = 1
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := COD_TIPO_NO_EXISTE;
            p_mensaje_resultado := 'Error: El tipo de pregunta especificado no existe o no está activo';
            RETURN;
    END;

    -- 7. Validar pregunta padre si se proporciona
    IF p_id_pregunta_padre IS NOT NULL THEN
        BEGIN
            SELECT 1 INTO v_pregunta_padre_existe
            FROM PREGUNTA
            WHERE ID_PREGUNTA = p_id_pregunta_padre
              AND ID_ESTADO = 1
              AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_codigo_resultado := COD_PREGUNTA_PADRE_NO_EXISTE;
                p_mensaje_resultado := 'Error: La pregunta padre especificada no existe o no está activa';
                RETURN;
        END;
    END IF;

    -- 8. Validar opciones de respuesta
    IF p_textos_opciones IS NULL OR p_textos_opciones.COUNT = 0 THEN
        p_codigo_resultado := COD_ERROR_OPCIONES;
        p_mensaje_resultado := 'Error: Debe proporcionar al menos una opción de respuesta';
        RETURN;
    END IF;

    IF p_textos_opciones.COUNT != p_son_correctas.COUNT OR 
       p_textos_opciones.COUNT != p_ordenes.COUNT THEN
        p_codigo_resultado := COD_ERROR_OPCIONES;
        p_mensaje_resultado := 'Error: Las listas de textos, corrección y órdenes deben tener la misma longitud';
        RETURN;
    END IF;

    -- 9. Validaciones específicas según el tipo de pregunta
    IF p_id_tipo_pregunta = 2 THEN -- Selección múltiple
        v_num_opciones_correctas := 0;
        FOR i IN 1..p_son_correctas.COUNT LOOP
            IF p_son_correctas(i) = 1 THEN
                v_num_opciones_correctas := v_num_opciones_correctas + 1;
            END IF;
        END LOOP;
        IF v_num_opciones_correctas = 0 THEN
            p_codigo_resultado := COD_ERROR_OPCIONES;
            p_mensaje_resultado := 'Error: Debe haber al menos una opción correcta en selección múltiple';
            RETURN;
        END IF;
    ELSIF p_id_tipo_pregunta = 1 THEN -- Selección única
        v_num_opciones_correctas := 0;
        FOR i IN 1..p_son_correctas.COUNT LOOP
            IF p_son_correctas(i) = 1 THEN
                v_num_opciones_correctas := v_num_opciones_correctas + 1;
            END IF;
        END LOOP;
        IF v_num_opciones_correctas != 1 THEN
            p_codigo_resultado := COD_ERROR_OPCIONES;
            p_mensaje_resultado := 'Error: Debe haber exactamente una opción correcta en selección única';
            RETURN;
        END IF;
    ELSIF p_id_tipo_pregunta = 3 THEN -- Verdadero/Falso
        IF p_textos_opciones.COUNT != 2 THEN
            p_codigo_resultado := COD_ERROR_OPCIONES;
            p_mensaje_resultado := 'Error: Debe haber exactamente dos opciones en Falso/Verdadero';
            RETURN;
        END IF;
        IF UPPER(p_textos_opciones(1)) NOT IN ('VERDADERO', 'FALSO') OR 
           UPPER(p_textos_opciones(2)) NOT IN ('VERDADERO', 'FALSO') THEN
            p_codigo_resultado := COD_ERROR_OPCIONES;
            p_mensaje_resultado := 'Error: Las opciones deben ser "Verdadero" y "Falso"';
            RETURN;
        END IF;
        v_num_opciones_correctas := 0;
        FOR i IN 1..p_son_correctas.COUNT LOOP
            IF p_son_correctas(i) = 1 THEN
                v_num_opciones_correctas := v_num_opciones_correctas + 1;
            END IF;
        END LOOP;
        IF v_num_opciones_correctas != 1 THEN
            p_codigo_resultado := COD_ERROR_OPCIONES;
            p_mensaje_resultado := 'Error: Debe haber exactamente una opción correcta en Falso/Verdadero';
            RETURN;
        END IF;
    END IF;

    -- 10. Verificar y crear secuencias si no existen
    -- Secuencia para preguntas
    BEGIN
        SELECT COUNT(*) INTO v_seq_exists
        FROM USER_SEQUENCES
        WHERE SEQUENCE_NAME = 'SEQ_ID_PREGUNTA';
    
        IF v_seq_exists = 0 THEN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ID_PREGUNTA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_codigo_resultado := COD_ERROR_SECUENCIA;
            p_mensaje_resultado := 'Error al verificar la secuencia SEQ_ID_PREGUNTA: ' || SQLERRM;
            RETURN;
    END;

    -- Secuencia para opciones
    BEGIN
        SELECT COUNT(*) INTO v_seq_exists
        FROM USER_SEQUENCES
        WHERE SEQUENCE_NAME = 'SEQ_ID_OPCION';
    
        IF v_seq_exists = 0 THEN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ID_OPCION START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_codigo_resultado := COD_ERROR_SECUENCIA;
            p_mensaje_resultado := 'Error al verificar la secuencia SEQ_ID_OPCION: ' || SQLERRM;
            RETURN;
    END;

    -- 11. Insertar la pregunta y opciones de respuesta
    BEGIN
        -- Obtener el máximo ID de pregunta actual y añadir 1
        SELECT NVL(MAX(ID_PREGUNTA), 0) + 1 INTO v_id_pregunta FROM PREGUNTA;
        
        -- Si por alguna razón el ID es menor que el valor de la secuencia, usar secuencia
        SELECT SEQ_ID_PREGUNTA.NEXTVAL INTO p_id_pregunta_creada FROM DUAL;
        IF v_id_pregunta <= p_id_pregunta_creada THEN
            v_id_pregunta := p_id_pregunta_creada;
        ELSE
            -- Avanzar la secuencia para que no haya problemas en el futuro
            EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_ID_PREGUNTA INCREMENT BY ' || (v_id_pregunta - p_id_pregunta_creada + 1);
            SELECT SEQ_ID_PREGUNTA.NEXTVAL INTO p_id_pregunta_creada FROM DUAL;
            EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_ID_PREGUNTA INCREMENT BY 1';
            v_id_pregunta := p_id_pregunta_creada;
        END IF;
        
        -- Insertar la pregunta
        INSERT INTO PREGUNTA (
            ID_PREGUNTA, ID_DOCENTE, ID_TEMA, ID_NIVEL_DIFICULTAD,
            ID_TIPO_PREGUNTA, TEXTO_PREGUNTA, ES_PUBLICA,
            TIEMPO_MAXIMO, PORCENTAJE, ID_PREGUNTA_PADRE, ID_ESTADO
        ) VALUES (
            v_id_pregunta, p_id_docente, p_id_tema, p_id_nivel_dificultad,
            p_id_tipo_pregunta, p_texto_pregunta, p_es_publica,
            p_tiempo_maximo, p_porcentaje, p_id_pregunta_padre, v_id_estado
        );

        -- Insertar opciones de respuesta
        FOR i IN 1..p_textos_opciones.COUNT LOOP
            SELECT NVL(MAX(ID_OPCION), 0) + i INTO v_id_opcion FROM OPCION_RESPUESTA;
            
            INSERT INTO OPCION_RESPUESTA (
                ID_OPCION, ID_PREGUNTA, TEXTO_OPCION, ES_CORRECTA, ORDEN
            ) VALUES (
                v_id_opcion, v_id_pregunta, p_textos_opciones(i), 
                p_son_correctas(i), p_ordenes(i)
            );
        END LOOP;

        -- Asignar valores de salida
        p_id_pregunta_creada := v_id_pregunta;
        p_codigo_resultado := COD_EXITO;
        p_mensaje_resultado := 'Pregunta creada exitosamente. ID: ' || v_id_pregunta;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_codigo_resultado := COD_ERROR_REGISTRO;
            p_mensaje_resultado := 'Error al registrar la pregunta: ' || SUBSTR(SQLERRM, 1, 500);
    END;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := COD_ERROR_REGISTRO;
        p_mensaje_resultado := 'Error inesperado: ' || SUBSTR(SQLERRM, 1, 500);
END SP_AGREGAR_PREGUNTA;

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- PROCEDURE para asignar preguntas a un examen
CREATE SEQUENCE SEQ_ID_EXAMEN_PREGUNTA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE PROCEDURE SP_ASIGNAR_PREGUNTAS_EXAMEN (
    -- Parámetros de entrada
    p_id_examen            IN NUMBER,
    p_id_docente           IN NUMBER,
    p_ids_preguntas        IN SYS.ODCINUMBERLIST,
    p_porcentajes          IN SYS.ODCINUMBERLIST,
    p_ordenes              IN SYS.ODCINUMBERLIST,
    -- Parámetros de salida
    p_cantidad_asignadas   OUT NUMBER,
    p_codigo_resultado     OUT NUMBER,
    p_mensaje_resultado    OUT VARCHAR2
)
IS
    -- Variables locales
    v_examen_existe         NUMBER := 0;
    v_docente_es_creador    NUMBER := 0;
    v_examen_iniciado       NUMBER := 0;
    v_pregunta_existe       NUMBER := 0;
    v_pregunta_ya_asignada  NUMBER := 0;
    v_suma_porcentajes      NUMBER := 0;
    v_id_examen_pregunta    NUMBER;
    v_fecha_actual          TIMESTAMP;
    v_seq_existe            NUMBER := 0;
    v_fecha_inicio          TIMESTAMP;
    v_fecha_fin             TIMESTAMP;
    
    -- Códigos de resultado
    COD_EXITO                     CONSTANT NUMBER := 0;
    COD_ERROR_PARAMETROS          CONSTANT NUMBER := 1;
    COD_EXAMEN_NO_EXISTE          CONSTANT NUMBER := 2;
    COD_DOCENTE_NO_AUTORIZADO     CONSTANT NUMBER := 3;
    COD_EXAMEN_YA_INICIADO        CONSTANT NUMBER := 4;
    COD_PREGUNTA_NO_EXISTE        CONSTANT NUMBER := 5;
    COD_PREGUNTA_YA_ASIGNADA      CONSTANT NUMBER := 6;
    COD_ERROR_PORCENTAJES         CONSTANT NUMBER := 7;
    COD_ERROR_REGISTRO            CONSTANT NUMBER := 8;
    COD_ERROR_SECUENCIA           CONSTANT NUMBER := 9;
BEGIN
    -- Inicializar parámetros de salida
    p_cantidad_asignadas := 0;
    p_codigo_resultado := COD_ERROR_REGISTRO;
    p_mensaje_resultado := 'Error en el proceso de asignación de preguntas';
    v_fecha_actual := SYSTIMESTAMP;

    -- 1. Validación de parámetros obligatorios
    IF p_id_examen IS NULL OR p_id_docente IS NULL OR 
       p_ids_preguntas IS NULL OR p_ids_preguntas.COUNT = 0 THEN
        p_codigo_resultado := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Los campos id_examen, id_docente y al menos una pregunta son obligatorios';
        RETURN;
    END IF;

    -- Validar que las listas tengan la misma longitud
    IF p_ids_preguntas.COUNT != p_porcentajes.COUNT OR 
       p_ids_preguntas.COUNT != p_ordenes.COUNT THEN
        p_codigo_resultado := COD_ERROR_PARAMETROS;
        p_mensaje_resultado := 'Error: Las listas de preguntas, porcentajes y órdenes deben tener la misma longitud';
        RETURN;
    END IF;

    -- 2. Validar que el examen exista y obtener sus fechas
    BEGIN
        SELECT 1, FECHA_INICIO, FECHA_FIN INTO v_examen_existe, v_fecha_inicio, v_fecha_fin
        FROM EXAMEN
        WHERE ID_EXAMEN = p_id_examen
          AND ID_ESTADO = 1 -- Activo
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := COD_EXAMEN_NO_EXISTE;
            p_mensaje_resultado := 'Error: El examen especificado no existe o no está activo';
            RETURN;
    END;

    -- 3. Validar que el docente sea el creador del examen o tenga permisos
    BEGIN
        SELECT 1 INTO v_docente_es_creador
        FROM EXAMEN
        WHERE ID_EXAMEN = p_id_examen
          AND ID_DOCENTE = p_id_docente
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_codigo_resultado := COD_DOCENTE_NO_AUTORIZADO;
            p_mensaje_resultado := 'Error: El docente no está autorizado a modificar este examen';
            RETURN;
    END;

    -- 4. Validar que el examen no haya iniciado
    -- Un examen se considera iniciado si:
    -- a) La fecha actual es mayor o igual a la fecha de inicio, o
    -- b) Existe una presentación activa
    IF v_fecha_actual >= v_fecha_inicio THEN
        -- Verificar si hay presentaciones activas
        BEGIN
            SELECT 1 INTO v_examen_iniciado
            FROM PRESENTACION_EXAMEN
            WHERE ID_EXAMEN = p_id_examen
              AND ID_ESTADO = 6  -- EN_PROCESO
              AND ROWNUM = 1;
            
            p_codigo_resultado := COD_EXAMEN_YA_INICIADO;
            p_mensaje_resultado := 'Error: No se pueden modificar las preguntas de un examen ya iniciado';
            RETURN;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- No hay presentaciones activas, se puede continuar
        END;
    END IF;

    -- 5. Verificar y crear secuencia si no existe
    BEGIN
        SELECT COUNT(*) INTO v_seq_existe
        FROM USER_SEQUENCES
        WHERE SEQUENCE_NAME = 'SEQ_ID_EXAMEN_PREGUNTA';
    
        IF v_seq_existe = 0 THEN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ID_EXAMEN_PREGUNTA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_codigo_resultado := COD_ERROR_SECUENCIA;
            p_mensaje_resultado := 'Error al verificar la secuencia SEQ_ID_EXAMEN_PREGUNTA: ' || SQLERRM;
            RETURN;
    END;

    -- 6. Validar la suma de porcentajes (debe ser igual a 100)
    v_suma_porcentajes := 0;
    FOR i IN 1..p_porcentajes.COUNT LOOP
        v_suma_porcentajes := v_suma_porcentajes + p_porcentajes(i);
    END LOOP;
    
    IF v_suma_porcentajes != 100 THEN
        p_codigo_resultado := COD_ERROR_PORCENTAJES;
        p_mensaje_resultado := 'Error: La suma de los porcentajes debe ser igual a 100. Suma actual: ' || v_suma_porcentajes;
        RETURN;
    END IF;

    -- 7. Procesar cada pregunta y asignarla al examen
    BEGIN
        -- Primero, eliminar las preguntas actualmente asignadas al examen
        DELETE FROM EXAMEN_PREGUNTA
        WHERE ID_EXAMEN = p_id_examen;
        
        -- Asegurarnos que la secuencia esté actualizada correctamente
        DECLARE
            v_max_id NUMBER;
            v_current_seq_value NUMBER;
        BEGIN
            -- Obtener el máximo ID actual
            SELECT NVL(MAX(ID_EXAMEN_PREGUNTA), 0) INTO v_max_id FROM EXAMEN_PREGUNTA;
            
            -- Obtener el valor actual de la secuencia
            SELECT SEQ_ID_EXAMEN_PREGUNTA.NEXTVAL INTO v_current_seq_value FROM DUAL;
            
            -- Si el máximo ID es mayor que el valor actual de la secuencia,
            -- incrementar la secuencia para que empiece en max_id + 1
            IF v_max_id >= v_current_seq_value THEN
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_ID_EXAMEN_PREGUNTA INCREMENT BY ' 
                    || TO_CHAR(v_max_id - v_current_seq_value + 1);
                SELECT SEQ_ID_EXAMEN_PREGUNTA.NEXTVAL INTO v_current_seq_value FROM DUAL;
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_ID_EXAMEN_PREGUNTA INCREMENT BY 1';
            END IF;
        END;
        
        -- Asignar las nuevas preguntas
        FOR i IN 1..p_ids_preguntas.COUNT LOOP
            -- Validar que la pregunta exista
            BEGIN
                SELECT 1 INTO v_pregunta_existe
                FROM PREGUNTA
                WHERE ID_PREGUNTA = p_ids_preguntas(i)
                  AND ID_ESTADO = 1 -- Activa
                  AND ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    ROLLBACK;
                    p_codigo_resultado := COD_PREGUNTA_NO_EXISTE;
                    p_mensaje_resultado := 'Error: La pregunta ID ' || p_ids_preguntas(i) || ' no existe o no está activa';
                    RETURN;
            END;
            
            -- Generar ID para la asignación de pregunta-examen
            SELECT SEQ_ID_EXAMEN_PREGUNTA.NEXTVAL INTO v_id_examen_pregunta FROM DUAL;
            
            -- Insertar la asignación (sin FECHA_ASIGNACION)
            INSERT INTO EXAMEN_PREGUNTA (
                ID_EXAMEN_PREGUNTA, ID_EXAMEN, ID_PREGUNTA, 
                PORCENTAJE, ORDEN
            ) VALUES (
                v_id_examen_pregunta, p_id_examen, p_ids_preguntas(i),
                p_porcentajes(i), p_ordenes(i)
            );
            
            p_cantidad_asignadas := p_cantidad_asignadas + 1;
        END LOOP;
        
        -- Actualizar el examen para reflejar que tiene preguntas asignadas
        UPDATE EXAMEN 
        SET FECHA_ULTIMA_MODIFICACION = v_fecha_actual,
            ID_USUARIO_ULTIMA_MODIFICACION = p_id_docente
        WHERE ID_EXAMEN = p_id_examen;
        
        -- Asignar valores de salida
        p_codigo_resultado := COD_EXITO;
        p_mensaje_resultado := 'Se asignaron exitosamente ' || p_cantidad_asignadas || ' preguntas al examen ID: ' || p_id_examen;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_codigo_resultado := COD_ERROR_REGISTRO;
            p_mensaje_resultado := 'Error al asignar preguntas al examen: ' || SUBSTR(SQLERRM, 1, 500);
    END;
EXCEPTION
    WHEN OTHERS THEN
        p_codigo_resultado := COD_ERROR_REGISTRO;
        p_mensaje_resultado := 'Error inesperado: ' || SUBSTR(SQLERRM, 1, 500);
END SP_ASIGNAR_PREGUNTAS_EXAMEN;

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- PROCEDURE para recuperar cuenta bloqueada
CREATE OR REPLACE PROCEDURE RECUPERAR_CUENTA (
    p_correo            IN VARCHAR2,
    p_contrasena        IN VARCHAR2,
    p_id_usuario        OUT NUMBER,
    p_nombre_completo   OUT VARCHAR2,
    p_tipo_usuario      OUT VARCHAR2,
    p_resultado         OUT NUMBER,
    p_mensaje           OUT VARCHAR2
) AS
    v_usuario           USUARIO%ROWTYPE;
    v_fecha_actual      TIMESTAMP := SYSTIMESTAMP;
    v_estado_nombre     VARCHAR2(100);

    -- Códigos de resultado estandarizados
    COD_EXITO                   CONSTANT NUMBER := 1;
    COD_USUARIO_NO_ENCONTRADO   CONSTANT NUMBER := -1;
    COD_CUENTA_NO_BLOQUEADA     CONSTANT NUMBER := -2;
    COD_TIEMPO_NO_COMPLETADO    CONSTANT NUMBER := -3;
    COD_CONTRASENA_INCORRECTA   CONSTANT NUMBER := -4;
    COD_ERROR_DESCONOCIDO       CONSTANT NUMBER := -99;
BEGIN
    -- Inicializar parámetros de salida
    p_id_usuario := NULL;
    p_nombre_completo := NULL;
    p_tipo_usuario := NULL;
    p_resultado := COD_ERROR_DESCONOCIDO;
    p_mensaje := 'Error durante la recuperación de cuenta';

    -- Validación de parámetros de entrada
    IF p_correo IS NULL OR LENGTH(TRIM(p_correo)) = 0 THEN
        p_resultado := COD_USUARIO_NO_ENCONTRADO;
        p_mensaje := 'El correo electrónico es obligatorio';
        RETURN;
    END IF;

    IF p_contrasena IS NULL THEN
        p_resultado := COD_CONTRASENA_INCORRECTA;
        p_mensaje := 'La contraseña es obligatoria';
        RETURN;
    END IF;

    -- Buscar usuario por correo electrónico
    BEGIN
        SELECT * INTO v_usuario
        FROM USUARIO
        WHERE EMAIL = p_correo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_resultado := COD_USUARIO_NO_ENCONTRADO;
            p_mensaje := 'Correo electrónico no registrado';
            RETURN;
    END;

    -- Verificar si la cuenta está bloqueada
    IF v_usuario.ID_ESTADO != 3 THEN
        p_resultado := COD_CUENTA_NO_BLOQUEADA;
        p_mensaje := 'La cuenta no está bloqueada';
        RETURN;
    END IF;

    -- Verificar si han pasado los 30 minutos del bloqueo
    IF v_usuario.FECHA_BLOQUEO IS NOT NULL AND
       v_usuario.FECHA_BLOQUEO > v_fecha_actual - INTERVAL '30' MINUTE THEN
        p_resultado := COD_TIEMPO_NO_COMPLETADO;
        p_mensaje := 'Debes esperar 30 minutos desde el bloqueo para recuperar la cuenta';
        RETURN;
    END IF;

    -- Verificar la contraseña
    IF v_usuario.CONTRASENA != p_contrasena THEN
        p_resultado := COD_CONTRASENA_INCORRECTA;
        p_mensaje := 'Contraseña incorrecta';
        RETURN;
    END IF;

    -- Desbloquear la cuenta
    UPDATE USUARIO
    SET ID_ESTADO = 1, -- Estado activo
        INTENTOS_FALLIDOS = 0,
        FECHA_BLOQUEO = NULL
    WHERE ID_USUARIO = v_usuario.ID_USUARIO;

    -- Obtener el nombre del tipo de usuario
    BEGIN
        SELECT NOMBRE INTO p_tipo_usuario
        FROM TIPO_USUARIO
        WHERE ID_TIPO_USUARIO = v_usuario.ID_TIPO_USUARIO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_tipo_usuario := 'Desconocido';
    END;

    -- Configurar respuesta exitosa
    p_id_usuario := v_usuario.ID_USUARIO;
    p_nombre_completo := v_usuario.NOMBRE || ' ' || v_usuario.APELLIDO;
    p_resultado := COD_EXITO;
    p_mensaje := 'Cuenta recuperada exitosamente';

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := COD_ERROR_DESCONOCIDO;
        p_mensaje := 'Error durante la recuperación de cuenta: ' || SUBSTR(SQLERRM, 1, 200);
END RECUPERAR_CUENTA;



--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--Procedimiento para asignar preguntas aleatorias a un examen
CREATE OR REPLACE PROCEDURE ASIGNAR_PREGUNTAS_ALEATORIAS (
    P_ID_EXAMEN      IN NUMBER,
    P_TEMA           IN VARCHAR2,
    P_CANTIDAD       IN NUMBER
)
IS
    V_PORCENTAJE NUMBER := ROUND(100 / P_CANTIDAD, 2);
BEGIN
    -- Eliminar preguntas previas del examen si existen
    DELETE FROM EXAMEN_PREGUNTA
    WHERE ID_EXAMEN = P_ID_EXAMEN;

    -- Insertar nuevas preguntas aleatorias desde el tema indicado
    INSERT INTO EXAMEN_PREGUNTA (
        ID_EXAMEN_PREGUNTA,
        ID_EXAMEN,
        ID_PREGUNTA,
        PORCENTAJE,
        ORDEN
    )
    SELECT
        SEQ_EXAMEN_PREGUNTA.NEXTVAL,
        P_ID_EXAMEN,
        ID_PREGUNTA,
        V_PORCENTAJE,
        ROWNUM
    FROM (
        SELECT ID_PREGUNTA
        FROM PREGUNTA
        WHERE ID_TEMA = (
            SELECT ID_TEMA FROM TEMA WHERE NOMBRE = P_TEMA
        )
        AND ES_PUBLICA = 1
        ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE ROWNUM <= P_CANTIDAD;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error al asignar preguntas aleatorias: ' || SQLERRM);
END ASIGNAR_PREGUNTAS_ALEATORIAS;

CREATE OR REPLACE PROCEDURE OBTENER_EXAMENES_POR_ESTADO(
    p_id_estado IN NUMBER,
    p_id_estudiante IN NUMBER,  -- Añadimos este parámetro
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            e.ID_EXAMEN,
            e.NOMBRE,
            e.DESCRIPCION,
            TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') as FECHA_INICIO,
            TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') as FECHA_FIN,
            e.TIEMPO_LIMITE,
            e.PESO_CURSO,
            e.UMBRAL_APROBACION,
            t.NOMBRE as NOMBRE_TEMA,
            c.NOMBRE as NOMBRE_CURSO,
            eg.NOMBRE as NOMBRE_ESTADO
        FROM EXAMEN e
        INNER JOIN TEMA t ON e.ID_TEMA = t.ID_TEMA
        INNER JOIN CURSO c ON t.ID_CURSO = c.ID_CURSO
        INNER JOIN ESTADO_GENERAL eg ON e.ID_ESTADO = eg.ID_ESTADO
        INNER JOIN MATRICULA m ON m.ID_ESTUDIANTE = p_id_estudiante
        INNER JOIN GRUPO g ON m.ID_GRUPO = g.ID_GRUPO AND g.ID_CURSO = c.ID_CURSO
        WHERE e.ID_ESTADO = p_id_estado
        ORDER BY e.FECHA_INICIO DESC;
END;
/


CREATE OR REPLACE PROCEDURE OBTENER_EXAMENES_ESTUDIANTE_UI (
    p_id_estudiante IN NUMBER,
    p_cursor        OUT SYS_REFCURSOR
)
AS
    -- Constantes para los IDs de estado de ESTADO_GENERAL (basado en tu scriptInsert.sql)
    -- ID_ESTADO_ACTIVO_GENERAL CONSTANT NUMBER := 1;
    -- ID_ESTADO_INACTIVO_GENERAL CONSTANT NUMBER := 2;
    -- ID_ESTADO_BLOQUEADO_GENERAL CONSTANT NUMBER := 3;
    -- ID_ESTADO_EXAMEN_DISPONIBLE CONSTANT NUMBER := 4;
    -- ID_ESTADO_PRESENTACION_EN_PROCESO CONSTANT NUMBER := 6;
    -- ID_ESTADO_PRESENTACION_COMPLETADO CONSTANT NUMBER := 7;
    -- ID_ESTADO_PRESENTACION_FINALIZADO CONSTANT NUMBER := 8; -- Asumo que 8 es similar a Completado para presentaciones
    -- ID_ESTADO_EXAMEN_EXPIRADO CONSTANT NUMBER := 9;


BEGIN
    -- NOTA: Este procedimiento asume que el estudiante (p_id_estudiante) existe
    -- y está matriculado en cursos que tienen exámenes asociados.
    -- Si necesitas validar la existencia/estado del estudiante, podrías agregarlo aquí
    -- al inicio del bloque BEGIN.

    OPEN p_cursor FOR
        SELECT
            e.ID_EXAMEN,
            e.NOMBRE,
            e.DESCRIPCION,
            TO_CHAR(e.FECHA_INICIO, 'DD/MM/YYYY HH24:MI') AS FECHA_INICIO_EXAMEN_FORMATEADA, -- Cambiado nombre para claridad
            TO_CHAR(e.FECHA_FIN, 'DD/MM/YYYY HH24:MI') AS FECHA_FIN_EXAMEN_FORMATEADA,     -- Cambiado nombre para claridad
            e.TIEMPO_LIMITE,
            e.PESO_CURSO,
            e.UMBRAL_APROBACION,
            e.CANTIDAD_PREGUNTAS_TOTAL,
            e.CANTIDAD_PREGUNTAS_PRESENTAR,
            e.INTENTOS_PERMITIDOS,
            e.MOSTRAR_RESULTADOS,
            e.PERMITIR_RETROALIMENTACION,
            t.NOMBRE AS NOMBRE_TEMA,
            c.NOMBRE AS NOMBRE_CURSO,
            -- Información de la presentación (puede ser NULL si no hay presentación)
            pe.ID_PRESENTACION,
            pe.PUNTAJE_OBTENIDO,
            pe.TIEMPO_UTILIZADO,
            pe.FECHA_INICIO AS FECHA_INICIO_PRESENTACION, -- **CORREGIDO: Usar FECHA_INICIO de PRESENTACION_EXAMEN**
            pe.FECHA_FIN AS FECHA_FIN_PRESENTACION,       -- **AÑADIDO: Incluir FECHA_FIN de PRESENTACION_EXAMEN**
            pe.ID_ESTADO AS ID_ESTADO_PRESENTACION, -- Incluir el ID del estado de la presentación
            ep.NOMBRE AS NOMBRE_ESTADO_PRESENTACION, -- Nombre del estado de la presentación (ej: 'En proceso', 'Completado')
             eg.NOMBRE AS NOMBRE_ESTADO_EXAMEN, -- Nombre del estado general del examen

            -- Lógica para determinar el estado en la UI (ESTADO_UI)
            CASE
                -- PRIORIDAD 1: Expirados
                -- Si la fecha fin del EXAMEN ya pasó Y la presentación NO está en estado 'Completado' (7) o 'Finalizado' (8)
                WHEN CURRENT_TIMESTAMP > e.FECHA_FIN AND (pe.ID_ESTADO IS NULL OR pe.ID_ESTADO NOT IN (7, 8)) THEN 'Expirado'
                -- O si el estado general del examen es 'Expirado' (9)
                 WHEN e.ID_ESTADO = 9 THEN 'Expirado'


                -- PRIORIDAD 2: Completados
                -- Si existe una presentación Y su estado es 'Completado' (7) o 'Finalizado' (8)
                WHEN pe.ID_ESTADO IN (7, 8) THEN 'Completado'

                -- PRIORIDAD 3: En Progreso
                -- Si existe una presentación Y su estado es 'En proceso' (6)
                WHEN pe.ID_ESTADO = 6 THEN 'En Progreso'
                 -- O si existe una presentación y NO está completada/finalizada (7,8) Y la fecha fin del EXAMEN AÚN NO PASA
                WHEN pe.ID_PRESENTACION IS NOT NULL AND pe.ID_ESTADO NOT IN (7, 8) AND CURRENT_TIMESTAMP <= e.FECHA_FIN THEN 'En Progreso'


                -- PRIORIDAD 4: Disponibles
                -- Si la fecha actual está dentro del rango de inicio/fin del EXAMEN Y NO HAY presentación iniciada/completada/en proceso (pe.ID_ESTADO IS NULL)
                WHEN CURRENT_TIMESTAMP BETWEEN e.FECHA_INICIO AND e.FECHA_FIN AND pe.ID_ESTADO IS NULL THEN 'Disponible'
                 -- O si el estado general del examen es 'Disponible' (4) Y la fecha fin del EXAMEN AÚN NO PASA Y NO HAY presentación iniciada/completada
                 WHEN e.ID_ESTADO = 4 AND CURRENT_TIMESTAMP <= e.FECHA_FIN AND pe.ID_ESTADO IS NULL THEN 'Disponible'
                 -- O si el estado general del examen es 'Activo' (1) Y la fecha actual está dentro del rango del EXAMEN Y NO HAY presentación iniciada/completada
                 WHEN e.ID_ESTADO = 1 AND CURRENT_TIMESTAMP BETWEEN e.FECHA_INICIO AND e.FECHA_FIN AND pe.ID_ESTADO IS NULL THEN 'Disponible'


                -- PRIORIDAD 5: Pendiente (fecha futura)
                -- Si la fecha de inicio del EXAMEN es en el futuro (y no ha sido marcado como Expirado por un estado de examen)
                WHEN CURRENT_TIMESTAMP < e.FECHA_INICIO AND e.ID_ESTADO != 9 THEN 'Pendiente'


                -- Otro/Indefinido: Cualquier otro caso no cubierto explícitamente
                ELSE 'Otro/Indefinido'
            END AS ESTADO_UI -- Campo que la UI usará para clasificar
        FROM EXAMEN e
        JOIN TEMA t ON e.ID_TEMA = t.ID_TEMA
        JOIN CURSO c ON t.ID_CURSO = c.ID_CURSO
        JOIN GRUPO g ON c.ID_CURSO = g.ID_CURSO -- Conexión via Curso a Grupo
        JOIN MATRICULA m ON g.ID_GRUPO = m.ID_GRUPO -- Conexión via Grupo a Matricula
        LEFT JOIN PRESENTACION_EXAMEN pe ON pe.ID_EXAMEN = e.ID_EXAMEN
            AND pe.ID_ESTUDIANTE = p_id_estudiante -- LEFT JOIN para incluir exámenes sin presentación
        LEFT JOIN ESTADO_GENERAL ep ON pe.ID_ESTADO = ep.ID_ESTADO -- LEFT JOIN para obtener el nombre del estado de la presentación (será NULL si no hay presentación)
        LEFT JOIN ESTADO_GENERAL eg ON e.ID_ESTADO = eg.ID_ESTADO -- LEFT JOIN para obtener el nombre del estado general del examen

        WHERE m.ID_ESTUDIANTE = p_id_estudiante -- Filtra por el estudiante
        -- Opcional: Puedes añadir filtros adicionales aquí si no quieres mostrar ciertos estados de EXAMEN
        -- Por ejemplo, para no mostrar exámenes Inactivos a nivel general:
        -- AND e.ID_ESTADO != 2

        ORDER BY e.FECHA_INICIO DESC; -- Ordenar por fecha de inicio (del examen) descendente

END OBTENER_EXAMENES_ESTUDIANTE_UI;
/

-- Crear secuencia para presentaciones si no existe
CREATE SEQUENCE SEQ_PRESENTACION_EXAMEN START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE PROCEDURE INICIAR_EXAMEN(
    p_id_examen IN NUMBER,
    p_id_estudiante IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
    v_examen_existe NUMBER;
    v_estudiante_existe NUMBER;
    v_fecha_actual TIMESTAMP;
    v_fecha_inicio TIMESTAMP;
    v_fecha_fin TIMESTAMP;
    v_intentos_permitidos NUMBER;
    v_intentos_realizados NUMBER;
    v_id_presentacion NUMBER;
    v_presentacion_activa NUMBER;
    v_estado_examen NUMBER;
    v_max_id NUMBER;
BEGIN
    -- Inicializar fecha actual
    v_fecha_actual := SYSTIMESTAMP;

    -- Verificar si ya existe una presentación activa
    SELECT COUNT(1) INTO v_presentacion_activa
    FROM PRESENTACION_EXAMEN
    WHERE ID_EXAMEN = p_id_examen
    AND ID_ESTUDIANTE = p_id_estudiante
    AND ID_ESTADO IN (1, 6); -- 1 = EN_PROGRESO, 6 = EN_PROCESO

    IF v_presentacion_activa > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ya existe una presentación activa para este examen');
    END IF;

    -- Verificar si el examen existe y obtener su estado
    BEGIN
        SELECT ID_ESTADO INTO v_estado_examen
        FROM EXAMEN
        WHERE ID_EXAMEN = p_id_examen;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'El examen no existe');
    END;

    -- Verificar estado del examen
    IF v_estado_examen != 1 THEN -- 1 = ACTIVO
        RAISE_APPLICATION_ERROR(-20001, 'El examen no está activo');
    END IF;

    -- Verificar si el estudiante existe y está activo
    BEGIN
        SELECT 1 INTO v_estudiante_existe
        FROM USUARIO u
        WHERE u.ID_USUARIO = p_id_estudiante
        AND u.ID_ESTADO = 1; -- 1 = ACTIVO
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estudiante no existe o no está activo');
    END;

    -- Obtener fechas y configuración del examen
    SELECT 
        FECHA_INICIO,
        FECHA_FIN,
        INTENTOS_PERMITIDOS
    INTO 
        v_fecha_inicio,
        v_fecha_fin,
        v_intentos_permitidos
    FROM EXAMEN
    WHERE ID_EXAMEN = p_id_examen;

    -- Verificar rango de fechas
    IF v_fecha_actual < v_fecha_inicio THEN
        RAISE_APPLICATION_ERROR(-20001, 'El examen aún no está disponible');
    END IF;

    IF v_fecha_actual > v_fecha_fin THEN
        RAISE_APPLICATION_ERROR(-20001, 'El examen ya ha expirado');
    END IF;

    -- Contar intentos realizados
    SELECT COUNT(1) INTO v_intentos_realizados
    FROM PRESENTACION_EXAMEN
    WHERE ID_EXAMEN = p_id_examen
    AND ID_ESTUDIANTE = p_id_estudiante;

    -- Verificar intentos permitidos
    IF v_intentos_realizados >= v_intentos_permitidos THEN
        RAISE_APPLICATION_ERROR(-20001, 'Has alcanzado el número máximo de intentos permitidos');
    END IF;

    -- Obtener el máximo ID actual
    SELECT NVL(MAX(ID_PRESENTACION), 0) INTO v_max_id FROM PRESENTACION_EXAMEN;
    
    -- Generar nuevo ID
    v_id_presentacion := v_max_id + 1;

    -- Crear nueva presentación
    INSERT INTO PRESENTACION_EXAMEN (
        ID_PRESENTACION,
        ID_EXAMEN,
        ID_ESTUDIANTE,
        FECHA_INICIO,
        ID_ESTADO,
        PUNTAJE_OBTENIDO,
        TIEMPO_UTILIZADO
    ) VALUES (
        v_id_presentacion,
        p_id_examen,
        p_id_estudiante,
        v_fecha_actual,
        6, -- 6 = EN_PROCESO
        0, -- Puntaje inicial
        0  -- Tiempo inicial
    );

    -- Abrir cursor con la información de la presentación
    OPEN p_cursor FOR
        SELECT 
            pe.ID_PRESENTACION as idPresentacion,
            pe.ID_EXAMEN as idExamen,
            pe.ID_ESTUDIANTE as idEstudiante,
            pe.FECHA_INICIO as fechaInicio,
            e.TIEMPO_LIMITE as tiempoLimite,
            0 as tiempoUtilizado,
            'EN_PROGRESO' as estado
        FROM PRESENTACION_EXAMEN pe, EXAMEN e
        WHERE e.ID_EXAMEN = pe.ID_EXAMEN
        AND pe.ID_PRESENTACION = v_id_presentacion;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error al iniciar el examen: ' || SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION OBTENER_PREGUNTAS_PRESENTACION(
    p_id_presentacion IN NUMBER
) RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
    v_presentacion_existe NUMBER;
    v_id_examen NUMBER;
BEGIN
    -- Validar que la presentación exista
    BEGIN
        SELECT ID_EXAMEN INTO v_id_examen
        FROM PRESENTACION_EXAMEN
        WHERE ID_PRESENTACION = p_id_presentacion
          AND ID_ESTADO = 6 -- EN_PROCESO
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'La presentación no existe o no está en proceso');
    END;

    -- Obtener preguntas aleatorias para el examen
    OPEN v_cursor FOR
        SELECT 
            ep.ID_PREGUNTA,
            p.TEXTO_PREGUNTA,
            ep.PORCENTAJE,
            ep.ORDEN
        FROM EXAMEN_PREGUNTA ep
        INNER JOIN PREGUNTA p ON ep.ID_PREGUNTA = p.ID_PREGUNTA
        WHERE ep.ID_EXAMEN = v_id_examen
        ORDER BY DBMS_RANDOM.VALUE;

    RETURN v_cursor;
END;
/

CREATE OR REPLACE FUNCTION OBTENER_OPCIONES_PREGUNTA(
    p_id_pregunta IN NUMBER
) RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT 
            ID_OPCION,
            TEXTO_OPCION,
            ORDEN
        FROM OPCION_RESPUESTA
        WHERE ID_PREGUNTA = p_id_pregunta
        ORDER BY ORDEN;

    RETURN v_cursor;
END;
/

CREATE OR REPLACE FUNCTION RESPONDER_PREGUNTA(
    p_id_presentacion IN NUMBER,
    p_id_pregunta IN NUMBER,
    p_id_opcion IN NUMBER,
    p_respuesta_texto IN VARCHAR2
) RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
    v_presentacion_existe NUMBER;
    v_pregunta_existe NUMBER;
    v_es_correcta NUMBER;
    v_puntaje NUMBER;
    v_id_respuesta NUMBER;
    v_fecha_actual TIMESTAMP := SYSTIMESTAMP;
BEGIN
    -- Validar que la presentación exista y esté en proceso
    BEGIN
        SELECT 1 INTO v_presentacion_existe
        FROM PRESENTACION_EXAMEN
        WHERE ID_PRESENTACION = p_id_presentacion
          AND ID_ESTADO = 6 -- EN_PROCESO
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20006, 'La presentación no existe o no está en proceso');
    END;

    -- Validar que la pregunta pertenezca al examen
    BEGIN
        SELECT 1 INTO v_pregunta_existe
        FROM EXAMEN_PREGUNTA ep
        INNER JOIN PRESENTACION_EXAMEN pe ON ep.ID_EXAMEN = pe.ID_EXAMEN
        WHERE pe.ID_PRESENTACION = p_id_presentacion
          AND ep.ID_PREGUNTA = p_id_pregunta
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20007, 'La pregunta no pertenece a este examen');
    END;

    -- Generar ID para la respuesta
    SELECT SEQ_ID_RESPUESTA.NEXTVAL INTO v_id_respuesta FROM DUAL;

    -- Determinar si la respuesta es correcta y calcular puntaje
    IF p_id_opcion IS NOT NULL THEN
        -- Para preguntas de opción múltiple
        SELECT 
            CASE WHEN ES_CORRECTA = 1 THEN 1 ELSE 0 END,
            ep.PORCENTAJE
        INTO v_es_correcta, v_puntaje
        FROM OPCION_RESPUESTA op
        INNER JOIN EXAMEN_PREGUNTA ep ON op.ID_PREGUNTA = ep.ID_PREGUNTA
        WHERE op.ID_OPCION = p_id_opcion
          AND ep.ID_PREGUNTA = p_id_pregunta;
    ELSE
        -- Para preguntas abiertas (aquí deberías implementar tu lógica de evaluación)
        v_es_correcta := 0; -- Por defecto incorrecta
        v_puntaje := 0; -- Por defecto 0 puntos
    END IF;

    -- Registrar la respuesta
    INSERT INTO RESPUESTA_ESTUDIANTE (
        ID_RESPUESTA,
        ID_PRESENTACION,
        ID_PREGUNTA,
        RESPUESTA_DADA,
        ES_CORRECTA,
        PUNTAJE_OBTENIDO,
        TIEMPO_UTILIZADO
    ) VALUES (
        v_id_respuesta,
        p_id_presentacion,
        p_id_pregunta,
        p_respuesta_texto,
        v_es_correcta,
        v_puntaje,
        EXTRACT(SECOND FROM (v_fecha_actual - (SELECT FECHA_INICIO FROM PRESENTACION_EXAMEN WHERE ID_PRESENTACION = p_id_presentacion)))
    );

    -- Retornar el resultado
    OPEN v_cursor FOR
        SELECT 
            v_es_correcta as CORRECTA,
            CASE 
                WHEN v_es_correcta = 1 THEN '¡Respuesta correcta!'
                ELSE 'Respuesta incorrecta'
            END as RETROALIMENTACION,
            v_puntaje as PUNTAJE_OBTENIDO
        FROM DUAL;

    RETURN v_cursor;
END;
/

CREATE OR REPLACE FUNCTION FINALIZAR_EXAMEN(
    p_id_presentacion IN NUMBER
) RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
    v_presentacion_existe NUMBER;
    v_fecha_actual TIMESTAMP := SYSTIMESTAMP;
    v_puntaje_total NUMBER;
BEGIN
    -- Validar que la presentación exista y esté en proceso
    BEGIN
        SELECT 1 INTO v_presentacion_existe
        FROM PRESENTACION_EXAMEN
        WHERE ID_PRESENTACION = p_id_presentacion
          AND ID_ESTADO = 6 -- EN_PROCESO
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20008, 'La presentación no existe o no está en proceso');
    END;

    -- Calcular puntaje total
    SELECT NVL(SUM(PUNTAJE_OBTENIDO), 0) INTO v_puntaje_total
    FROM RESPUESTA_ESTUDIANTE
    WHERE ID_PRESENTACION = p_id_presentacion;

    -- Actualizar la presentación
    UPDATE PRESENTACION_EXAMEN
    SET 
        FECHA_FIN = v_fecha_actual,
        PUNTAJE_OBTENIDO = v_puntaje_total,
        TIEMPO_UTILIZADO = EXTRACT(SECOND FROM (v_fecha_actual - FECHA_INICIO)),
        ID_ESTADO = 7 -- COMPLETADO
    WHERE ID_PRESENTACION = p_id_presentacion;

    -- Retornar la información actualizada
    OPEN v_cursor FOR
        SELECT 
            pe.ID_PRESENTACION,
            pe.ID_EXAMEN,
            pe.ID_ESTUDIANTE,
            pe.FECHA_INICIO,
            pe.FECHA_FIN,
            e.TIEMPO_LIMITE,
            pe.TIEMPO_UTILIZADO,
            'COMPLETADO' as ESTADO
        FROM PRESENTACION_EXAMEN pe
        INNER JOIN EXAMEN e ON pe.ID_EXAMEN = e.ID_EXAMEN
        WHERE pe.ID_PRESENTACION = p_id_presentacion;

    RETURN v_cursor;
END;
/

-- Bloque de prueba para INICIAR_EXAMEN
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id_presentacion NUMBER;
    v_id_examen NUMBER;
    v_id_estudiante NUMBER;
    v_fecha_inicio TIMESTAMP;
    v_tiempo_limite NUMBER;
    v_tiempo_utilizado NUMBER;
    v_estado VARCHAR2(50);
    v_count NUMBER;
BEGIN
    -- 1. Verificar datos existentes
    DBMS_OUTPUT.PUT_LINE('=== Verificando datos existentes ===');
    
    -- Verificar exámenes activos
    SELECT COUNT(1) INTO v_count
    FROM EXAMEN
    WHERE ID_ESTADO = 1;
    
    DBMS_OUTPUT.PUT_LINE('Exámenes activos encontrados: ' || v_count);
    
    -- Verificar estudiantes activos
    SELECT COUNT(1) INTO v_count
    FROM USUARIO
    WHERE ID_ESTADO = 1
    AND ID_TIPO_USUARIO = 1;  -- Tipo estudiante
    
    DBMS_OUTPUT.PUT_LINE('Estudiantes activos encontrados: ' || v_count);
    
    -- 2. Obtener datos para la prueba
    DBMS_OUTPUT.PUT_LINE('=== Obteniendo datos para la prueba ===');
    
    -- Verificar examen activo
    BEGIN
        SELECT ID_EXAMEN INTO v_id_examen
        FROM EXAMEN
        WHERE ID_ESTADO = 1
        AND ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('ID Examen encontrado: ' || v_id_examen);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontró ningún examen activo');
            RETURN;
    END;
    
    -- Verificar estudiante activo
    BEGIN
        SELECT ID_USUARIO INTO v_id_estudiante
        FROM USUARIO
        WHERE ID_ESTADO = 1
        AND ID_TIPO_USUARIO = 1  -- Tipo estudiante
        AND ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('ID Estudiante encontrado: ' || v_id_estudiante);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontró ningún estudiante activo');
            RETURN;
    END;
    
    -- 3. Verificar si ya existe una presentación activa
    SELECT COUNT(1) INTO v_count
    FROM PRESENTACION_EXAMEN
    WHERE ID_EXAMEN = v_id_examen
    AND ID_ESTUDIANTE = v_id_estudiante
    AND ID_ESTADO IN (1, 6);
    
    DBMS_OUTPUT.PUT_LINE('Presentaciones activas existentes: ' || v_count);
    
    -- 4. Intentar iniciar el examen
    DBMS_OUTPUT.PUT_LINE('=== Intentando iniciar examen ===');
    
    BEGIN
        INICIAR_EXAMEN(v_id_examen, v_id_estudiante, v_cursor);
        
        -- 5. Leer los resultados del cursor
        LOOP
            FETCH v_cursor INTO v_id_presentacion, v_id_examen, v_id_estudiante, 
                              v_fecha_inicio, v_tiempo_limite, v_tiempo_utilizado, v_estado;
            EXIT WHEN v_cursor%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('=== Presentación creada exitosamente ===');
            DBMS_OUTPUT.PUT_LINE('ID Presentación: ' || v_id_presentacion);
            DBMS_OUTPUT.PUT_LINE('ID Examen: ' || v_id_examen);
            DBMS_OUTPUT.PUT_LINE('ID Estudiante: ' || v_id_estudiante);
            DBMS_OUTPUT.PUT_LINE('Fecha Inicio: ' || v_fecha_inicio);
            DBMS_OUTPUT.PUT_LINE('Tiempo Límite: ' || v_tiempo_limite);
            DBMS_OUTPUT.PUT_LINE('Tiempo Utilizado: ' || v_tiempo_utilizado);
            DBMS_OUTPUT.PUT_LINE('Estado: ' || v_estado);
        END LOOP;
        
        CLOSE v_cursor;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al iniciar examen: ' || SQLERRM);
            IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
            END IF;
    END;
    
    -- 6. Verificar que se creó la presentación
    DBMS_OUTPUT.PUT_LINE('=== Verificando presentación creada ===');
    
    SELECT COUNT(1) INTO v_count
    FROM PRESENTACION_EXAMEN
    WHERE ID_EXAMEN = v_id_examen
    AND ID_ESTUDIANTE = v_id_estudiante
    AND ID_ESTADO = 6;
    
    DBMS_OUTPUT.PUT_LINE('Presentaciones activas encontradas: ' || v_count);
    
END;
/

-- Procere para obtener las estadisticas de las repuestas de un estudainet

CREATE OR REPLACE PROCEDURE EXA_Y_PORC_POR_ESTUE  (
    P_ID_USUARIO IN NUMBER,
    CURSOR_RESULT OUT SYS_REFCURSOR
) AS
BEGIN
OPEN CURSOR_RESULT FOR
SELECT
    pe.ID_PRESENTACION,
    e.NOMBRE AS NOMBRE_EXAMEN,
    PORCENTAJE_PREGUNTAS_CORRECTAS(pe.ID_PRESENTACION) AS PORCENTAJE
FROM PRESENTACION_EXAMEN pe
         JOIN EXAMEN e ON pe.ID_EXAMEN = e.ID_EXAMEN
WHERE pe.ID_ESTUDIANTE = P_ID_USUARIO;
END;
/

