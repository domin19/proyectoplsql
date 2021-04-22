-- Auditoria Prescribe
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER auditarPrescribe 
    BEFORE INSERT OR DELETE OR UPDATE ON PRESCRIBE
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN

    v_RegOld := OLD.MEDICO||'#'||OLD.PACIENTE||'#'||OLD.MEDICACION||'#'||OLD.FECHA||'#'||OLD.CITA||'#'||OLD.DOSIS;
    v_RegNew := NEW.MEDICO||'#'||NEW.PACIENTE||'#'||NEW.MEDICACION||'#'||NEW.FECHA||'#'||NEW.CITA||'#'||NEW.DOSIS;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarPrescribe;
/

--TEST
INSERT INTO Prescribe VALUES(9,100000004,2,'28/04/2008 16:53',NULL,'5');
UPDATE PRESCRIBE SET MEDICO = 9, DOSIS = '3';
DELETE FROM PRESCRIBE WHERE MEDICO = 9 AND PACIENTE = 100000004 AND MEDICACION = 2;

SELECT * FROM AUDITORIA;
--ELIMINACION
ROLLBACK;