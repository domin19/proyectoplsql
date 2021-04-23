-- Auditoria CITA
SET SERVEROUTPUT ON

CREATE OR REPLACE TRIGGER auditarCita 
    BEFORE INSERT OR DELETE OR UPDATE ON CITA
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.ID_CITA||'#'||OLD.PACIENTE||'#'||OLD.ENFERMERA||'#'||OLD.MEDICO||'#'||OLD.INICIO_CITA||'#'||OLD.FIN_CITA||'#'||OLD.OBSERVACIONHABITACION;
    v_RegNew := NEW.ID_CITA||'#'||NEW.PACIENTE||'#'||NEW.ENFERMERA||'#'||NEW.MEDICO||'#'||NEW.INICIO_CITA||'#'||NEW.FIN_CITA||'#'||NEW.OBSERVACIONHABITACION;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarCita;
/