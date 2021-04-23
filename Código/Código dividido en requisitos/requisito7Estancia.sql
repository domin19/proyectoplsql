-- Auditoria Estancia
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER auditarEstancia 
    BEFORE INSERT OR DELETE OR UPDATE ON ESTANCIA
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

    v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
    v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN

    v_RegOld := OLD.ID_ESTANCIA||'#'||OLD.PACIENTE||'#'||OLD.HABITACION||'#'||OLD.INICIOESTANCIA||'#'||OLD.FINESTANCIA; 
    v_RegNew:= NEW.ID_ESTANCIA||'#'||NEW.PACIENTE||'#'||NEW.HABITACION||'#'||NEW.INICIOESTANCIA||'#'||NEW.FINESTANCIA;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarEstancia;
/

--TEST
INSERT INTO Estancia VALUES(4217,100000004,112,'02/05/2008','03/05/2008');
UPDATE ESTANCIA SET INICIOESTANCIA = '02/02/2004' WHERE ID_ESTANCIA = 4217;
DELETE FROM ESTANCIA WHERE ID_ESTANCIA = 4217;

SELECT * FROM AUDITORIA;

--ELIMINACION
ROLLBACK;