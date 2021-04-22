-- Auditoria Habitacion
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER auditarHabitacion 
    BEFORE INSERT OR DELETE OR UPDATE ON HABITACION
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN

    v_RegOld := OLD.NUMERO_HABITACION||'#'||OLD.TIPO_HABITACION||'#'||OLD.PLANTA||'#'||OLD.CODIGO_BLOQUE||'#'||OLD.NODISPONIBLE;
    v_RegNew := NEW.NUMERO_HABITACION||'#'||NEW.TIPO_HABITACION||'#'||NEW.PLANTA||'#'||NEW.CODIGO_BLOQUE||'#'||NEW.NODISPONIBLE;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarHabitacion;
/

--TEST

INSERT INTO Habitacion VALUES(424,'Individual',4,3,0);
UPDATE HABITACION SET NODISPONIBLE = 1, TIPO_HABITACION = 'DOBLE' WHERE NUMERO_HABITACION = 424;
DELETE FROM HABITACION WHERE NUMERO_HABITACION = 424;

SELECT * FROM AUDITORIA;

--ELIMINACION
ROLLBACK;
DROP TRIGGER auditarHabitacion;