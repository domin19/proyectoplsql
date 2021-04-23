--REQUISITOS COMPLETOS

SET SERVEROUTPUT ON;

ALTER SESSION SET nls_date_format='yyyy-mm-ddhh24:mi';

--1
CREATE OR REPLACE PROCEDURE PacientesIngresadosNumDias(v_NumDias NUMBER) IS



CURSOR c_Paciente IS SELECT PAC.NOMBRE AS "NOMBRE", PAC.NSS AS "NSS", (EST.FINESTANCIA-EST.INICIOESTANCIA) AS "NUMERO_DIAS", NVL(TO_CHAR(EST.FINESTANCIA, 'dd/mm/yyyy hh24:mm'), 'El paciente sigue ingresado') AS "FINESTANCIA" 
    FROM PACIENTE PAC, ESTANCIA EST 
    WHERE PAC.NSS=EST.PACIENTE(+) 
    AND (EST.FINESTANCIA-EST.INICIOESTANCIA)>v_NumDias;
v_Registro c_Paciente%ROWTYPE;

BEGIN
    OPEN c_Paciente;
    
    FETCH c_Paciente INTO v_Registro;
    
    IF(c_Paciente%NOTFOUND) THEN
        DBMS_OUTPUT.PUT_LINE('No se han encontrado pacientes que coincidan con los requisitos.');
        RETURN;
    END IF;
    
    LOOP
    
        
        EXIT WHEN c_Paciente%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nombre: '||v_Registro.NOMBRE||'   Número SS: '||v_Registro.NSS||'   Días ingresado: '||v_Registro.NUMERO_DIAS||'   Fecha de salida del hospital: '||v_Registro.FINESTANCIA);
        
        FETCH c_Paciente INTO v_Registro;
        
    END LOOP;
    CLOSE c_Paciente;
END;
/

--2
CREATE OR REPLACE TRIGGER DisparadorHoraCitas
    BEFORE INSERT ON Cita FOR EACH ROW
DECLARE
    e_HoraCitaIncorrecta EXCEPTION;
    v_HoraI VARCHAR2(60);
    v_HoraF VARCHAR2(60);

BEGIN
    


        v_HoraI:=TO_CHAR(:NEW.INICIO_CITA, 'hh24');
        v_HoraF:=TO_CHAR(:NEW.FIN_CITA, 'hh24');
    
    IF(v_HoraI < 8 OR v_HoraI > 20) THEN
        RAISE e_HoraCitaIncorrecta;
        
    ELSIF (v_HoraF < 8 OR v_HoraF > 20) THEN
        RAISE e_HoraCitaIncorrecta;
    
    END IF;
    
    EXCEPTION
    WHEN e_HoraCitaIncorrecta THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERROR: Las citas deben de estar en el intervalo de horas 8:00-20:00');

END;
/

--3
CREATE OR REPLACE PROCEDURE CalcularIntervencionesMedico (v_Nombre VARCHAR2, v_Puesto VARCHAR2) IS

    CURSOR c_Interv IS 
    
    
    SELECT MED.NOMBRE AS "NOMBRE", MED.PUESTO AS "PUESTO", NVL(SUM(INTE.Id_Intervencion),0) AS "SUMA", NVL(SUM(INTE.Coste),0) AS "COSTE" 
            FROM INTERVENCION INTE, TRATADO_EN TRAT, MEDICO MED 
            WHERE INTE.Id_Intervencion=TRAT.TRATAMIENTO
                AND TRAT.MEDICO=MED.ID_EMPLEADO 
                    AND UPPER(MED.NOMBRE)=UPPER(v_Nombre) AND UPPER(MED.PUESTO)=UPPER(v_Puesto) 
                        GROUP BY MED.NOMBRE, MED.PUESTO;
                        
    v_Registro c_Interv%ROWTYPE;


BEGIN
    OPEN c_Interv;
    
    FETCH c_Interv INTO v_Registro;
    
    
    IF(c_Interv%NOTFOUND) THEN
        DBMS_OUTPUT.PUT_LINE('No se ha encontrado medico que coincida con los requisitos.');
        RETURN;
    END IF;
    
    LOOP        
        EXIT WHEN c_Interv%NOTFOUND;
        
        
        DBMS_OUTPUT.PUT_LINE('Nombre: '||v_Registro.NOMBRE||'  Puesto: '||v_Registro.PUESTO||'  Suma Intervenciones: '||v_Registro.SUMA||'  Suma Costes: '||v_Registro.COSTE);
        FETCH c_Interv INTO v_Registro;
   END LOOP;
   
   CLOSE c_Interv;
END;
/

--4
CREATE OR REPLACE FUNCTION verificarHabitacionLibre (v_NumHabitacion NUMBER)

    RETURN NUMBER IS 
    
    CURSOR c_Habitacion IS SELECT HAB.NUMERO_HABITACION AS "HABITACION", EST.INICIOESTANCIA AS "INICIO", EST.FINESTANCIA AS "FIN" 
        FROM HABITACION HAB, ESTANCIA EST 
        WHERE HAB.NUMERO_HABITACION=EST.HABITACION(+)
            AND HAB.NUMERO_HABITACION=v_NumHabitacion;
        
    v_Registro c_Habitacion%ROWTYPE;
 
BEGIN
    OPEN c_Habitacion;
            FETCH c_Habitacion INTO v_Registro;
                IF (c_Habitacion%NOTFOUND) THEN 
                    RETURN 0;                
                ELSIF (SYSDATE BETWEEN v_Registro.INICIO AND v_Registro.FIN) THEN
                    RETURN 2; 
                END IF;
    RETURN 1;   
    CLOSE c_Habitacion;
END;
/

CREATE OR REPLACE PROCEDURE verificarHabitacion(v_NumHabitacion NUMBER) IS

    v_Libre NUMBER;
    
BEGIN

        IF (v_Libre=1) THEN /*Si el resultado es 1, muestra un mensaje de que la habitacion esta libre*/
            DBMS_OUTPUT.PUT_LINE('Habitación libre');
        ELSIF (v_Libre=2) THEN /*Si el resultado es 2, muestra un mensaje de que la habitacion esta ocupada*/
            DBMS_OUTPUT.PUT_LINE('Habitación ocupada.');
        ELSIF (v_Libre=0) THEN /*Si el resultado es 0, muestra un mensaje de error, ya que el número de habitación no existe.*/
            DBMS_OUTPUT.PUT_LINE('¡ERROR! El número de habitación introducido ('||v_NumHabitacion||') no es válido');
        END IF;
END;
/

--5
CREATE OR REPLACE PROCEDURE controlEstancias AS  

     CURSOR c_Estancia IS SELECT est.ID_ESTANCIA AS "ID_ESTANCIA" 
                            FROM ESTANCIA est, HABITACION HAB       
                            WHERE (HAB.NODISPONIBLE = 0 
                                AND HAB.NUMERO_HABITACION = EST.HABITACION) AND
                                EST.ID_ESTANCIA NOT IN (SELECT PAD.ESTANCIA FROM PADECE PAD);
    
    v_Reg c_ESTANCIA%ROWTYPE;  
    
BEGIN
    
    OPEN c_Estancia;
        LOOP   
        
        FETCH c_Estancia INTO v_reg;       
        DELETE ESTANCIA WHERE ID_ESTANCIA = v_Reg."ID_ESTANCIA"; 
        EXIT WHEN c_Estancia%NOTFOUND;
        
        END LOOP;
    CLOSE c_Estancia;
    
    EXCEPTION
    WHEN OTHERS THEN  
        DBMS_OUTPUT.PUT_LINE('-2564 Error inesperado'); 

END controlEstancias;
/

CREATE OR REPLACE TRIGGER limpiezaEstancia
    BEFORE INSERT OR UPDATE ON ESTANCIA 
                                        
BEGIN 

    controlEstancias;   
    
END limpiezaEstancia;
/

--6
CREATE OR REPLACE PROCEDURE bajaMedico(p_ID NUMBER) AS 

    v_IdMedico NUMBER; 
    e_ErrorId EXCEPTION;

BEGIN

    SELECT PCP INTO v_idMedico FROM PACIENTE WHERE ROWNUM <= 1 GROUP BY PCP ORDER BY COUNT(NSS); 
    
    DELETE FROM AFILIADO_CON WHERE MEDICO = p_ID; 
    IF SQL%NOTFOUND THEN 
        RAISE e_errorId;
    END IF;    
   
    UPDATE PRESCRIBE SET MEDICO = v_IdMedico WHERE MEDICO = p_ID OR PACIENTE IN (SELECT PACIENTE.NSS FROM PACIENTE WHERE PCP = p_ID);
    UPDATE CITA SET MEDICO = v_IdMedico WHERE MEDICO = p_ID OR PACIENTE IN (SELECT PACIENTE.NSS FROM PACIENTE WHERE PCP = p_ID);
    UPDATE PADECE SET MEDICO = v_IdMedico WHERE MEDICO = p_ID OR PACIENTE IN (SELECT PACIENTE.NSS FROM PACIENTE WHERE PCP = p_ID);
    UPDATE TRATADO_EN SET MEDICO = v_IdMedico WHERE MEDICO = p_ID;
    UPDATE PACIENTE SET PCP = v_IdMedico WHERE PCP = p_ID;
    DELETE FROM MEDICO WHERE ID_EMPLEADO = p_ID; 
    
    EXCEPTION
    WHEN e_ErrorId THEN
        DBMS_OUTPUT.PUT_LINE('-35123 El ID del médico indicado no existe');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-32573 Error inesperado');
    
END bajaMedico;
/

--7
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

-- Auditoria AFILIADO_CON


CREATE OR REPLACE TRIGGER auditarAfiliado_Con 
    BEFORE INSERT OR DELETE OR UPDATE ON AFILIADO_CON
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.DEPARTAMENTO||'#'||OLD.MEDICO||'#'||OLD.AFILIACIONPRIMARIA;
    v_RegNew := NEW.DEPARTAMENTO||'#'||NEW.MEDICO||'#'||NEW.AFILIACIONPRIMARIA; 

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarAfiliado_Con;
/

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

-- Auditoria CITA

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

-- Auditoria DEPARTAMENTO


CREATE OR REPLACE TRIGGER auditarDepartamento 
    BEFORE INSERT OR DELETE OR UPDATE ON DEPARTAMENTO
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.ID_DEPARTAMENTO||'#'||OLD.NOMBRE||'#'||OLD.ID_JEFE;
    v_RegNew := NEW.ID_DEPARTAMENTO||'#'||NEW.NOMBRE||'#'||NEW.ID_JEFE; 

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarDepartamento;
/

-- Auditoria Estancia

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

-- Auditoria Habitacion


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

-- Auditoria INTERVENCION

CREATE OR REPLACE TRIGGER auditarIntervencion 
    BEFORE INSERT OR DELETE OR UPDATE ON Intervencion
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.ID_INTERVENCION||'#'||OLD.NOMBRE||'#'||OLD.COSTE;
    v_RegNew := NEW.ID_INTERVENCION||'#'||NEW.NOMBRE||'#'||NEW.COSTE;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarIntervencion;
/

-- Auditoria Medicacion


CREATE OR REPLACE TRIGGER auditarMedicacion 
    BEFORE INSERT OR DELETE OR UPDATE ON MEDICACION
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN

    v_RegOld :=OLD.CODIGO||'#'||OLD.NOMBRE||'#'||OLD.MARCA||'#'||OLD.DESCRIPCION; 
    v_RegNew :=NEW.CODIGO||'#'||NEW.NOMBRE||'#'||NEW.MARCA||'#'||NEW.DESCRIPCION;

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarMedicacion;
/

-- Auditoria MEDICO

CREATE OR REPLACE TRIGGER auditarMedico 
    BEFORE INSERT OR DELETE OR UPDATE ON MEDICO
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.NSS||'#'||OLD.NOMBRE||'#'||OLD.ID_EMPLEADO||'#'||OLD.PUESTO;
    v_RegNew := NEW.NSS||'#'||NEW.NOMBRE||'#'||NEW.ID_EMPLEADO||'#'||NEW.PUESTO; 

    IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarMedico;
/

-- Auditoria Paciente

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

-- Auditoria Padece

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

-- Auditoria Prescribe

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

-- Auditoria TRATADO_EN

CREATE OR REPLACE TRIGGER auditarTratado_En 
    BEFORE INSERT OR DELETE OR UPDATE ON TRATADO_EN
    FOR EACH ROW -- Ejecutamos el trigger por cada accion dml que estemos realizando
    
DECLARE 

     v_RegOld VARCHAR2(100); -- Variable que almacena el registro antiguo
     v_RegNew VARCHAR2(100); -- Variable que almacena el registro nuevo
    
BEGIN
    
    v_RegOld := OLD.MEDICO||'#'||OLD.TRATAMIENTO||'#'||OLD.FECHACERTIFICACION||'#'||OLD.EXPIRACIONCERTIFICACION;
    v_RegNew := NEW.MEDICO||'#'||NEW.TRATAMIENTO||'#'||NEW.FECHACERTIFICACION||'#'||NEW.EXPIRACIONCERTIFICACION;

   IF INSERTING THEN -- mientras se este insertando ejecutamos el siguiente comando
    
        insertarAuditoria(1,v_RegOld, vRegNew); -- ejecutamos el procedimiento pasando por parametros la acción DML que se realiza, registro antiguo y registro nuevo.
        
    ELSIF DELETING THEN -- mientras estemos eliminando ejecutamos la siguiente instruccion
    
        insertarAuditoria(2,v_RegOld,v_RegNew);
        
    ELSE -- mientras estemos actualizando realizamos lo siguiente

        insertarAuditoria(3,v_RegOld,v_RegNew);
        
    END IF;

END auditarTratado_En;
/

--BORRADO

/*DROP PROCEDURE PacientesIngresadosNumDias;
DROP TRIGGER DisparadorHoraCitas;
DROP PROCEDURE CalcularIntervencionesMedico;
DROP FUNCTION verificarHabitacionLibre;
DROP PROCEDURE verificarHabitacion;
DROP PROCEDURE controlEstancias
DROP TRIGGER limpiezaEstancia;
DROP PROCEDURE bajaMedico;

DROP TABLE AUDITORIA;
DROP TRIGGER AUDITARAFILIADO_CON;
DROP TRIGGER AUDITARBLOQUE;
DROP TRIGGER AUDITARCITA;
DROP TRIGGER AUDITARDEPARTAMENTO;
DROP TRIGGER AUDITARESTANCIA;
DROP TRIGGER AUDITARHABITACION;
DROP TRIGGER AUDITARINTERVENCION;
DROP TRIGGER AUDITARMEDICACION;
DROP TRIGGER AUDITARMEDICO;
DROP TRIGGER AUDITARPACIENTE;
DROP TRIGGER AUDITARPADECE;
DROP TRIGGER AUDITARPRESCRIBE
DROP TRIGGER AUDITARTRATADO_EN*/






