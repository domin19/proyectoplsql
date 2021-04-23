-- Auditoria Padece
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER auditarPadece 
    BEFORE INSERT OR DELETE OR UPDATE ON PADECE
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

    v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
    v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN

    v_RegOld :=OLD.PACIENTE||'#'||OLD.INTERVENCION||'#'||OLD.ESTANCIA||'#'||OLD.FECHA_SINTOMAS||'#'||OLD.MEDICO||'#'||OLD.ENFERMERA_ASISTENTE; 
    v_RegNew :=NEW.PACIENTE||'#'||NEW.INTERVENCION||'#'||NEW.ESTANCIA||'#'||NEW.FECHA_SINTOMAS||'#'||NEW.MEDICO||'#'||NEW.ENFERMERA_ASISTENTE;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarPadece;
/

-- TEST
INSERT INTO Padece VALUES(100000004,4,3217,'2008-05-13',3,103);
UPDATE PADECE SET MEDICO = 3;
DELETE FROM PADECE WHERE PACIENTE = 100000004 AND INTERVENCION = 4 AND ESTANCIA = 3217 AND MEDICO = 3 AND ENFERMERA_ASISTENTE = 103;

SELECT * FROM AUDITORIA;
