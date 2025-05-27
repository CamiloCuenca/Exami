-- Eliminar todos los triggers existentes
BEGIN
    FOR trg IN (SELECT trigger_name FROM user_triggers) LOOP
        EXECUTE IMMEDIATE 'DROP TRIGGER ' || trg.trigger_name;
    END LOOP;
END;
/

COMMIT;

-- Verificar que no queden triggers
SELECT TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_NAME 
FROM USER_TRIGGERS 
ORDER BY TABLE_NAME; 