-- Auditoria Habitacion


CREATE OR REPLACE TRIGGER auditarBloque 
    BEFORE INSERT OR DELETE OR UPDATE ON BLOQUE
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

    v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN

    v_RegOld := OLD.PLANTA||'#'||OLD.CODIGO_BLOQUE; 
    v_RegNew := NEW.PLANTA||'#'||NEW.CODIGO_BLOQUE;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarBloque;
/

-- TEST 
INSERT INTO Bloque VALUES(5,1);
DELETE FROM BLOQUE WHERE PLANTA = 5 AND CODIGO_BLOQUE = 1;

SELECT * FROM AUDITORIA;

-- ELIMINACION
ROLLBACK;
DROP TRIGGER auditarBloque;