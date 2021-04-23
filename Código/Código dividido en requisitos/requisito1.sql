--Listado de pacientes ingresados m�s de X d�as (Pasar n�mero de d�as por par�metro)

SET SERVEROUTPUT ON;

/*Procedimiento que mostrar� aquellos pacientes que esten ingresados o hayan estado ingresados en el hospital por mas de el n�mero
de d�as especificados*/

CREATE OR REPLACE PROCEDURE PacientesIngresadosNumDias(v_NumDias NUMBER) IS

/*El cursor devolver� el nombre y n�mero de SS del paciente, el n�mero de dias de ingreso y la fecha de fin de estancia para 
aquellos pacientes que hayan estado en el hospital por mas de v_NumDias d�as*/

CURSOR c_Paciente IS SELECT PAC.NOMBRE AS "NOMBRE", PAC.NSS AS "NSS", (EST.FINESTANCIA-EST.INICIOESTANCIA) AS "NUMERO_DIAS", NVL(TO_CHAR(EST.FINESTANCIA, 'dd/mm/yyyy hh24:mm'), 'El paciente sigue ingresado') AS "FINESTANCIA" 
    FROM PACIENTE PAC, ESTANCIA EST 
    WHERE PAC.NSS=EST.PACIENTE(+) 
    AND (EST.FINESTANCIA-EST.INICIOESTANCIA)>v_NumDias;
v_Registro c_Paciente%ROWTYPE;

BEGIN
    OPEN c_Paciente;
    
    FETCH c_Paciente INTO v_Registro;
    /*Si no se ha encontrado paciente, devuelve un mensaje y termina la aplicaci�n*/
    
    IF(c_Paciente%NOTFOUND) THEN
        DBMS_OUTPUT.PUT_LINE('No se han encontrado pacientes que coincidan con los requisitos.');
        RETURN;
    END IF;
    
    LOOP
    /*Saldr� cuando ya no haya m�s pacientes en el cursor, y mostrar� de manera formateada los registros devueltos por la consulta del cursor.*/
        
        EXIT WHEN c_Paciente%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nombre: '||v_Registro.NOMBRE||'   N�mero SS: '||v_Registro.NSS||'   D�as ingresado: '||v_Registro.NUMERO_DIAS||'   Fecha de salida del hospital: '||v_Registro.FINESTANCIA);
        
        FETCH c_Paciente INTO v_Registro;
        
    END LOOP;
    CLOSE c_Paciente;
END;
/

--BEGIN
--pacientesingresadosnumdias(1);
--END;
--/