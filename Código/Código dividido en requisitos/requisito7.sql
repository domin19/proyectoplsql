-- Creacion tabla auditoria
CREATE TABLE auditoria (

    usuario VARCHAR2(30) NOT NULL, -- USUARIO QUE REALIZA EL CAMBIO
    fecha VARCHAR2(20) NOT NULL, -- DD/MM/AAAA 
    hora VARCHAR2(20) NOT NULL, -- HH:MI
    operacion NUMBER(1) NOT NULL, --1 INSERT, 2 UPDATE, 3 DELETE
    registro_old VARCHAR2(60), -- REGISTRO PREVIO
    registro_new VARCHAR2(60) -- REGISTRO NUEVO
    
);

CREATE OR REPLACE PROCEDURE insertarAuditoria(p_operacion NUMBER, p_registro_old VARCHAR2, p_registro_new VARCHAR2) AS -- CREACION DEL PROCEDIMIENTO GENERAL PARA LA INSERCCIÓN EN LA TABLA AUDITORIA.
                                                                                                         
BEGIN

    INSERT INTO AUDITORIA VALUES (USER,TO_CHAR(SYSDATE,'dd/mm/yyyy'),TO_CHAR(SYSDATE,'hh24:mi'),p_operacion, p_registro_old, p_registro_new);        

END;
/

-- 
DROP TABLE AUDITORIA;
DROP PROCEDURE insertarAuditoria;