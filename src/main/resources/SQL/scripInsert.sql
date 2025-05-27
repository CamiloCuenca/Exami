-- Elimina datos en orden inverso a las dependencias
DELETE FROM RESPUESTA_ESTUDIANTE;
DELETE FROM PRESENTACION_EXAMEN;
DELETE FROM EXAMEN_PREGUNTA;
DELETE FROM EXAMEN;
DELETE FROM OPCION_RESPUESTA;
DELETE FROM PREGUNTA;
DELETE FROM MATRICULA;
DELETE FROM JORNADA;
DELETE FROM GRUPO;
DELETE FROM TEMA;
DELETE FROM CONTENIDO;
DELETE FROM UNIDAD;
DELETE FROM PLAN_ESTUDIO;
DELETE FROM USUARIO;
DELETE FROM AULA;
DELETE FROM PERIODO_ACADEMICO;
DELETE FROM CURSO;
DELETE FROM PROGRAMA;
DELETE FROM FACULTAD;
DELETE FROM CATEGORIA_EXAMEN;
DELETE FROM NIVEL_DIFICULTAD;
DELETE FROM TIPO_PREGUNTA;
DELETE FROM TIPO_USUARIO;
DELETE FROM ESTADO_GENERAL;
DELETE FROM AUDITORIA;
DELETE FROM NOTIFICACION;
DELETE FROM HISTORIAL_EXAMENES_CREADOS;
DELETE FROM HISTORIAL_PRESENTACIONES;
DELETE FROM ESTUDIANTES_EXAMEN_FINALIZADO;
DELETE FROM MODIFICACION_PREGUNTAS;
DELETE FROM PREGUNTAS_CON_BAJO_RENDIMIENTO;
DELETE FROM TEMP_USUARIOS_A_BLOQUEAR;
COMMIT;




-- 1. Catálogos y configuración
INSERT INTO ESTADO_GENERAL VALUES (1, 'Activo', 'Registro activo', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (2, 'Inactivo', 'Registro inactivo', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (3, 'Bloqueado', 'Registro bloqueado', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (4, 'Disponible', 'Estado Examen disponible', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (6, 'En proceso', 'Estado Examen en proceso', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (7, 'Completado', 'Estado Examen completado', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (8, 'Finalizado', 'Estado Examen finalizado', 'GENERAL', 1);
INSERT INTO ESTADO_GENERAL VALUES (9, 'Expirado', 'Estado Examen expirado', 'GENERAL', 1);


INSERT INTO TIPO_USUARIO VALUES (1, 'Estudiante', 'Usuario estudiante', 1);
INSERT INTO TIPO_USUARIO VALUES (2, 'Docente', 'Usuario docente', 1);

INSERT INTO TIPO_PREGUNTA VALUES (1, 'Selección única', 'Una sola respuesta correcta', 1);
INSERT INTO TIPO_PREGUNTA VALUES (2, 'Selección múltiple', 'Varias respuestas correctas', 1);
INSERT INTO TIPO_PREGUNTA VALUES (3, 'Falso/Verdadero', 'Respuesta de verdadero o falso', 1);

INSERT INTO NIVEL_DIFICULTAD VALUES (1, 'Fácil', 'Pregunta sencilla', 1);
INSERT INTO NIVEL_DIFICULTAD VALUES (2, 'Media', 'Pregunta de dificultad media', 1);
INSERT INTO NIVEL_DIFICULTAD VALUES (3, 'Difícil', 'Pregunta compleja', 1);

INSERT INTO CATEGORIA_EXAMEN VALUES (1, 'Parcial', 'Examen parcial', 1);
INSERT INTO CATEGORIA_EXAMEN VALUES (2, 'Final', 'Examen final', 1);
INSERT INTO CATEGORIA_EXAMEN VALUES (3, 'Quiz', 'Quiz', 1);


-- 2. Estructura académica
INSERT INTO FACULTAD VALUES (1, 'Ingeniería', 'Facultad de Ingeniería', 1);
INSERT INTO FACULTAD VALUES (2, 'Ciencias', 'Facultad de Ciencias', 1);
INSERT INTO FACULTAD VALUES (3, 'Artes', 'Facultad de Artes', 1);

INSERT INTO PROGRAMA VALUES (1, 1, 'Sistemas', 'Ingeniería de Sistemas', 1);
INSERT INTO PROGRAMA VALUES (2, 1, 'Ingeniería de Software', 'Programa de Ingeniería de Software', 1);
INSERT INTO PROGRAMA VALUES (3, 1, 'Ingeniería de Sistemas', 'Programa de Ingeniería de Sistemas', 1);
INSERT INTO PROGRAMA VALUES (4, 2, 'Matemáticas', 'Programa de Matemáticas', 1);
INSERT INTO PROGRAMA VALUES (5, 3, 'Diseño Gráfico', 'Programa de Diseño Gráfico', 1);

INSERT INTO CURSO VALUES (1, 'Bases de Datos II', 'Curso avanzado de bases de datos', 4, 1, 1);
INSERT INTO CURSO VALUES (2, 'Programación Avanzada', 'Curso de programación avanzada', 4, 1, 2);
INSERT INTO CURSO VALUES (3, 'Estructuras de Datos', 'Curso de estructuras de datos', 4, 1, 2);
INSERT INTO CURSO VALUES (4, 'Cálculo I', 'Curso de cálculo diferencial', 4, 1, 4);
INSERT INTO CURSO VALUES (5, 'Diseño Digital', 'Curso de diseño digital', 4, 1, 5);


INSERT INTO PERIODO_ACADEMICO VALUES (1, '2025-1', TO_DATE('2025-01-15','YYYY-MM-DD'), TO_DATE('2025-06-15','YYYY-MM-DD'), 1);
INSERT INTO AULA VALUES (1, 'Aula 101', 'Bloque A', 40, 1);

-- 3. Usuarios (3 docentes y 7 estudiantes)
INSERT INTO USUARIO VALUES (1, 2, 'Juan', 'Pérez', 'juan.perez@uni.edu', 'JuanP3rez#2024', 1, SYSDATE, NULL, 0, NULL, '3001112233', 'Calle 1');
INSERT INTO USUARIO VALUES (2, 2, 'María', 'López', 'maria.lopez@uni.edu', 'MariaL0pez*2024', 1, SYSDATE, NULL, 0, NULL, '3002223344', 'Calle 2');
INSERT INTO USUARIO VALUES (3, 2, 'Carlos', 'Ramírez', 'carlos.ramirez@uni.edu', 'CarlosR@2024', 1, SYSDATE, NULL, 0, NULL, '3003334455', 'Calle 3');
INSERT INTO USUARIO VALUES (4, 1, 'Ana', 'Gómez', 'ana.gomez@uni.edu', 'AnaGomez_2024', 1, SYSDATE, NULL, 0, NULL, '3011112233', 'Calle 4');
INSERT INTO USUARIO VALUES (5, 1, 'Luis', 'Martínez', 'luis.martinez@uni.edu', 'LuisM2024!', 1, SYSDATE, NULL, 0, NULL, '3012223344', 'Calle 5');
INSERT INTO USUARIO VALUES (6, 1, 'Sofía', 'Torres', 'sofia.torres@uni.edu', 'SofiaT#2024', 1, SYSDATE, NULL, 0, NULL, '3013334455', 'Calle 6');
INSERT INTO USUARIO VALUES (7, 1, 'Pedro', 'Suárez', 'pedro.suarez@uni.edu', 'PedroS_2024', 1, SYSDATE, NULL, 0, NULL, '3014445566', 'Calle 7');
INSERT INTO USUARIO VALUES (8, 1, 'Lucía', 'Vargas', 'lucia.vargas@uni.edu', 'LuciaV2024*', 1, SYSDATE, NULL, 0, NULL, '3015556677', 'Calle 8');
INSERT INTO USUARIO VALUES (9, 1, 'Miguel', 'Castro', 'miguel.castro@uni.edu', 'MiguelC@2024', 1, SYSDATE, NULL, 0, NULL, '3016667788', 'Calle 9');
INSERT INTO USUARIO VALUES (10, 1, 'Elena', 'Morales', 'elena.morales@uni.edu', 'ElenaM2024!', 1, SYSDATE, NULL, 0, NULL, '3017778899', 'Calle 10');
-- 3. Más usuarios (estudiantes y docentes)
INSERT INTO USUARIO VALUES (11, 2, 'Roberto', 'Sánchez', 'roberto.sanchez@uni.edu', 'RobertoS2024!', 1, SYSDATE, NULL, 0, NULL, '3004445566', 'Calle 11');
INSERT INTO USUARIO VALUES (12, 2, 'Laura', 'Díaz', 'laura.diaz@uni.edu', 'LauraD2024*', 1, SYSDATE, NULL, 0, NULL, '3005556677', 'Calle 12');
INSERT INTO USUARIO VALUES (13, 1, 'Daniel', 'Rojas', 'daniel.rojas@uni.edu', 'DanielR2024#', 1, SYSDATE, NULL, 0, NULL, '3018889900', 'Calle 13');
INSERT INTO USUARIO VALUES (14, 1, 'Carolina', 'Mendoza', 'carolina.mendoza@uni.edu', 'CarolinaM2024@', 1, SYSDATE, NULL, 0, NULL, '3019990011', 'Calle 14');
INSERT INTO USUARIO VALUES (15, 1, 'Andrés', 'González', 'andres.gonzalez@uni.edu', 'AndresG2024!', 1, SYSDATE, NULL, 0, NULL, '3020001122', 'Calle 15');
-- 4. Planificación académica
INSERT INTO PLAN_ESTUDIO VALUES (1, 1, 'Plan 2025', 'Plan de estudios 2025', SYSDATE, 1);
INSERT INTO PLAN_ESTUDIO VALUES (2, 2, 'Plan 2025-2', 'Plan de estudios 2025-2', SYSDATE, 1);
INSERT INTO PLAN_ESTUDIO VALUES (3, 3, 'Plan 2025-3', 'Plan de estudios 2025-3', SYSDATE, 1);

INSERT INTO UNIDAD VALUES (1, 1, 'Unidad 1', 'Introducción a bases de datos', 1);
INSERT INTO UNIDAD VALUES (2, 1, 'Unidad 2', 'Modelado de datos', 2);
INSERT INTO UNIDAD VALUES (3, 1, 'Unidad 3', 'Normalización', 3);

INSERT INTO CONTENIDO VALUES (1, 1, 'Modelo Relacional', 'Conceptos básicos', 1);
INSERT INTO CONTENIDO VALUES (2, 1, 'SQL Avanzado', 'Consultas complejas', 2);
INSERT INTO CONTENIDO VALUES (3, 1, 'Optimización', 'Optimización de consultas', 3);

INSERT INTO TEMA VALUES (1, 1, 'Modelo Relacional', 'Definición y características', 1, 1);
INSERT INTO TEMA VALUES (2, 1, 'SQL Avanzado', 'Consultas complejas y optimización', 2, 2);
INSERT INTO TEMA VALUES (3, 1, 'Normalización', 'Proceso de normalización', 3, 3);
INSERT INTO TEMA VALUES (4, 2, 'POO', 'Programación Orientada a Objetos', 1, NULL);
INSERT INTO TEMA VALUES (5, 3, 'Árboles', 'Estructuras de datos tipo árbol', 1, NULL);

-- 5. Grupos y matrículas
INSERT INTO GRUPO VALUES (1, 1, 1, '2025-1', 2025, 40, 1, 1);
-- 5. Grupos y matrículas (más grupos y matrículas)
INSERT INTO GRUPO VALUES (2, 2, 2, '2025-1', 2025, 35, 1, 1);
INSERT INTO GRUPO VALUES (3, 3, 3, '2025-1', 2025, 30, 1, 1);

INSERT INTO JORNADA VALUES (1, 1, 1, 'Lunes', TO_TIMESTAMP('08:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('10:00:00', 'HH24:MI:SS'));
INSERT INTO JORNADA VALUES (2, 2, 1, 'Martes', TO_TIMESTAMP('10:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('12:00:00', 'HH24:MI:SS'));
INSERT INTO JORNADA VALUES (3, 3, 1, 'Miércoles', TO_TIMESTAMP('14:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('16:00:00', 'HH24:MI:SS'));

-- Matrícula de 7 estudiantes al grupo
INSERT INTO MATRICULA VALUES (1, 4, 1, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (2, 5, 1, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (3, 6, 1, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (4, 7, 1, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (5, 8, 1, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (6, 9, 1, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (7, 10, 1, SYSDATE, 1);
-- Matrículas adicionales
INSERT INTO MATRICULA VALUES (8, 13, 2, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (9, 14, 2, SYSDATE, 1);
INSERT INTO MATRICULA VALUES (10, 15, 3, SYSDATE, 1);


-- 6. Preguntas y opciones
INSERT INTO PREGUNTA VALUES (1, 1, 1, 1, 1, '¿Qué es una clave primaria?', 1, NULL, 100, NULL, 1);
INSERT INTO PREGUNTA VALUES (2, 2, 1, 2, 2, '¿Cuáles son características del modelo relacional?', 1, NULL, 100, NULL, 1);
INSERT INTO PREGUNTA VALUES (3, 3, 1, 1, 3, 'El modelo relacional fue propuesto por E.F. Codd. (V/F)', 1, NULL, 100, NULL, 1);

-- Opciones para pregunta 1 (Selección única)
INSERT INTO OPCION_RESPUESTA VALUES (1, 1, 'Identificador único', 1, 1);
INSERT INTO OPCION_RESPUESTA VALUES (2, 1, 'Dato repetido', 0, 2);
INSERT INTO OPCION_RESPUESTA VALUES (3, 1, 'Campo opcional', 0, 3);

-- Opciones para pregunta 2 (Selección múltiple)
INSERT INTO OPCION_RESPUESTA VALUES (4, 2, 'Integridad de datos', 1, 1);
INSERT INTO OPCION_RESPUESTA VALUES (5, 2, 'Redundancia máxima', 0, 2);
INSERT INTO OPCION_RESPUESTA VALUES (6, 2, 'Uso de tablas', 1, 3);
INSERT INTO OPCION_RESPUESTA VALUES (7, 2, 'Relaciones entre tablas', 1, 4);

-- Opciones para pregunta 3 (Verdadero/Falso)
INSERT INTO OPCION_RESPUESTA VALUES (8, 3, 'Verdadero', 1, 1);
INSERT INTO OPCION_RESPUESTA VALUES (9, 3, 'Falso', 0, 2);

-- 7. Exámenes y asignación de preguntas
-- Primero eliminamos los datos relacionados con exámenes para evitar duplicados
DELETE FROM RESPUESTA_ESTUDIANTE;
DELETE FROM PRESENTACION_EXAMEN;
DELETE FROM EXAMEN_PREGUNTA;
DELETE FROM EXAMEN;

-- Insertamos los 10 exámenes con diferentes estados
-- 1. Examen Activo
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    1, -- ID_DOCENTE (Juan Pérez)
    1, -- ID_TEMA (Modelo Relacional)
    'Quiz Modelo Relacional', 
    'Quiz sobre conceptos básicos del modelo relacional',
    SYSDATE,
    TO_TIMESTAMP('2025-03-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60, -- TIEMPO_LIMITE
    20, -- PESO_CURSO
    60, -- UMBRAL_APROBACION
    3, -- CANTIDAD_PREGUNTAS_TOTAL
    3, -- CANTIDAD_PREGUNTAS_PRESENTAR
    1, -- ID_ESTADO (Activo)
    1, -- ID_CATEGORIA (Parcial)
    1, -- INTENTOS_PERMITIDOS
    1, -- MOSTRAR_RESULTADOS
    1, -- PERMITIR_RETROALIMENTACION
    SYSDATE,
    1
);

-- 2. Examen Inactivo
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    1,
    1,
    'Quiz SQL Básico',
    'Quiz sobre comandos SQL básicos',
    SYSDATE,
    TO_TIMESTAMP('2025-03-15 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    2, -- ID_ESTADO (Inactivo)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 3. Examen Bloqueado
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    2, -- ID_DOCENTE (María López)
    2, -- ID_TEMA (SQL Avanzado)
    'Quiz SQL Avanzado',
    'Quiz sobre consultas complejas',
    SYSDATE,
    TO_TIMESTAMP('2025-03-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-20 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    3, -- ID_ESTADO (Bloqueado)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 4. Examen Disponible
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    2,
    2,
    'Quiz Joins',
    'Quiz sobre diferentes tipos de joins',
    SYSDATE,
    TO_TIMESTAMP('2025-03-25 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-25 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    4, -- ID_ESTADO (Disponible)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 5. Examen En Proceso
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    3, -- ID_DOCENTE (Carlos Ramírez)
    3, -- ID_TEMA (Normalización)
    'Quiz Normalización',
    'Quiz sobre formas normales',
    SYSDATE,
    TO_TIMESTAMP('2025-04-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-04-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    6, -- ID_ESTADO (En proceso)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 6. Examen Completado
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    3,
    3,
    'Quiz Índices',
    'Quiz sobre índices y optimización',
    SYSDATE,
    TO_TIMESTAMP('2025-02-15 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-02-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    7, -- ID_ESTADO (Completado)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 7. Examen Finalizado
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    1,
    1,
    'Quiz Vistas',
    'Quiz sobre vistas en bases de datos',
    SYSDATE,
    TO_TIMESTAMP('2025-02-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-02-20 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    8, -- ID_ESTADO (Finalizado)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 8. Examen Expirado
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    2,
    2,
    'Quiz Transacciones',
    'Quiz sobre transacciones y concurrencia',
    SYSDATE,
    TO_TIMESTAMP('2025-01-15 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-01-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    9, -- ID_ESTADO (Expirado)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 9. Examen Activo (otro)
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    3,
    3,
    'Quiz Triggers',
    'Quiz sobre triggers y procedimientos',
    SYSDATE,
    TO_TIMESTAMP('2025-04-15 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-04-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    1, -- ID_ESTADO (Activo)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- 10. Examen Disponible (otro)
INSERT INTO EXAMEN VALUES (
    SEQ_ID_EXAMEN.NEXTVAL,
    1,
    1,
    'Quiz Seguridad',
    'Quiz sobre seguridad en bases de datos',
    SYSDATE,
    TO_TIMESTAMP('2025-04-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-04-20 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60,
    20,
    60,
    3,
    3,
    4, -- ID_ESTADO (Disponible)
    1,
    1,
    1,
    1,
    SYSDATE,
    1
);

-- Asignar las 3 preguntas existentes a cada examen
INSERT INTO EXAMEN_PREGUNTA (ID_EXAMEN_PREGUNTA, ID_EXAMEN, ID_PREGUNTA, PORCENTAJE, ORDEN)
SELECT ROWNUM, e.ID_EXAMEN, p.ID_PREGUNTA, 
       CASE WHEN ROWNUM = 3 THEN 33.34 ELSE 33.33 END, ROWNUM
FROM EXAMEN e
CROSS JOIN (SELECT ID_PREGUNTA FROM PREGUNTA WHERE ID_PREGUNTA IN (1,2,3)) p
ORDER BY e.ID_EXAMEN, p.ID_PREGUNTA;

-- Crear presentaciones para los exámenes completados, finalizados y expirados
INSERT INTO PRESENTACION_EXAMEN (ID_PRESENTACION, ID_EXAMEN, ID_ESTUDIANTE, FECHA_INICIO, FECHA_FIN, PUNTAJE_OBTENIDO, TIEMPO_UTILIZADO, IP_ACCESO, ID_ESTADO)
SELECT ROWNUM, e.ID_EXAMEN, u.ID_USUARIO, 
       SYSTIMESTAMP, SYSTIMESTAMP, 
       ROUND(DBMS_RANDOM.VALUE(60, 100), 2), -- PUNTAJE_OBTENIDO aleatorio
       ROUND(DBMS_RANDOM.VALUE(30, 60)), -- TIEMPO_UTILIZADO aleatorio
       '192.168.1.' || ROWNUM, -- IP_ACCESO
       1 -- ID_ESTADO
FROM EXAMEN e
CROSS JOIN (SELECT ID_USUARIO FROM USUARIO WHERE ID_TIPO_USUARIO = 1) u
WHERE e.ID_ESTADO IN (7, 8, 9) -- Solo para exámenes completados, finalizados y expirados
AND ROWNUM <= 15; -- Limitar a 15 presentaciones

-- Crear respuestas para las presentaciones
INSERT INTO RESPUESTA_ESTUDIANTE (ID_RESPUESTA, ID_PRESENTACION, ID_PREGUNTA, RESPUESTA_DADA, ES_CORRECTA, PUNTAJE_OBTENIDO, TIEMPO_UTILIZADO)
SELECT ROWNUM, p.ID_PRESENTACION, ep.ID_PREGUNTA,
       CASE 
           WHEN ep.ID_PREGUNTA = 1 THEN 'Identificador único'
           WHEN ep.ID_PREGUNTA = 2 THEN 'Integridad de datos;Uso de tablas;Relaciones entre tablas'
           ELSE 'Verdadero'
       END,
       1, -- ES_CORRECTA
       CASE WHEN ROWNUM = 3 THEN 33.34 ELSE 33.33 END, -- PUNTAJE_OBTENIDO
       ROUND(DBMS_RANDOM.VALUE(10, 30)) -- TIEMPO_UTILIZADO
FROM PRESENTACION_EXAMEN p
JOIN EXAMEN_PREGUNTA ep ON p.ID_EXAMEN = ep.ID_EXAMEN;

-- 9. Notificaciones y auditoría
INSERT INTO NOTIFICACION VALUES (1, 4, 'Examen disponible', 'Ya puedes presentar el Quiz 1', 'Examen', SYSTIMESTAMP, NULL, 1);
INSERT INTO NOTIFICACION VALUES (2, 5, 'Examen disponible', 'Ya puedes presentar el Quiz 1', 'Examen', SYSTIMESTAMP, NULL, 1);


-- 9. Más notificaciones
INSERT INTO NOTIFICACION VALUES (3, 13, 'Nuevo examen disponible', 'Ya puedes presentar el Quiz SQL Avanzado', 'Examen', SYSTIMESTAMP, NULL, 1);
INSERT INTO NOTIFICACION VALUES (4, 14, 'Nuevo examen disponible', 'Ya puedes presentar el Quiz SQL Avanzado', 'Examen', SYSTIMESTAMP, NULL, 1);
INSERT INTO NOTIFICACION VALUES (5, 15, 'Nuevo examen disponible', 'Ya puedes presentar el Quiz Normalización', 'Examen', SYSTIMESTAMP, NULL, 1);

INSERT INTO AUDITORIA VALUES (1, 1, 'EXAMEN', 1, 'INSERT', SYSTIMESTAMP, NULL, NULL, '192.168.1.1');
-- 10. Más registros de auditoría
INSERT INTO AUDITORIA VALUES (2, 1, 'EXAMEN', 2, 'INSERT', SYSTIMESTAMP, NULL, NULL, '192.168.1.2');
INSERT INTO AUDITORIA VALUES (3, 2, 'EXAMEN', 3, 'INSERT', SYSTIMESTAMP, NULL, NULL, '192.168.1.3');


COMMIT;