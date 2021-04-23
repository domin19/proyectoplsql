-- Auditoria Paciente
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER auditarPaciente 
    BEFORE INSERT OR DELETE OR UPDATE ON PACIENTE
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
 

   
DECLARE 

    v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
    v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.NSS||'#'||OLD.NOMBRE||'#'||OLD.DIRECCION||'#'||OLD.TELEFONO||'#'||OLD.ID_SEGURO_MEDICO||'#'||OLD.PCP;
    v_RegNew := NEW.NSS||'#'||NEW.NOMBRE||'#'||NEW.DIRECCION||'#'||NEW.TELEFONO||'#'||NEW.ID_SEGURO_MEDICO||'#'||NEW.PCP; 

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarPaciente;
/

--TEST
INSERT INTO Paciente VALUES(100000005,'John Smith','1100 Foobaz Avenue','555-2048',68421879,3);

UPDATE PACIENTE SET NOMBRE = 'PEPE',TELEFONO = '6545' WHERE NSS = 100000005;

INSERT INTO Paciente VALUES(100000006,'John Smith','1100 Foobaz Avenue','555-2048',68421879,3);
DELETE FROM PACIENTE WHERE NSS = 100000005;
DELETE FROM PACIENTE WHERE NSS = 100000006;
SELECT * FROM AUDITORIA;
-- ELIMINACION