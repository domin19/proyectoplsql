/*  -Calcular Intervenciones Medico
    -Listado de nombre y puesto del médico, junto con el total de intervenciones realizadas y el total de su coste. Pasar como 
     parámetro el nombre y el puesto del medico.

*/

SET SERVEROUTPUT ON;



/*Procedimiento que recibe por parámetros el nombre y el puesto del médico, y devuelve el total de intervenciones y la suma de sus costes.*/

CREATE OR REPLACE PROCEDURE CalcularIntervencionesMedico (v_Nombre VARCHAR2, v_Puesto VARCHAR2) IS

    CURSOR c_Interv IS 
    
    /*Este cursor devuelve el nombre, el puesto, la suma de las intervenciones y la suma de los costes de las mismas del médico que
    se corresponda con los valores introducidos por parámetros.*/
    
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
    
    /*Si no se ha encontrado medico, devuelve un mensaje y termina la aplicación*/
    
    IF(c_Interv%NOTFOUND) THEN
        DBMS_OUTPUT.PUT_LINE('No se ha encontrado medico que coincida con los requisitos.');
        RETURN;
    END IF;
    
    LOOP        
        EXIT WHEN c_Interv%NOTFOUND;
        
        /*Muestra cada uno de los valores devueltos por el cursor por pantalla.*/
        
        DBMS_OUTPUT.PUT_LINE('Nombre: '||v_Registro.NOMBRE||'  Puesto: '||v_Registro.PUESTO||'  Suma Intervenciones: '||v_Registro.SUMA||'  Suma Costes: '||v_Registro.COSTE);
        FETCH c_Interv INTO v_Registro;
   END LOOP;
   
   CLOSE c_Interv;
END;
/

--DROP PROCEDURE CalcularIntervencionesMedico;

--begin
    --calcularintervencionesmedico('Todd Quinlan', 'Médico Quirúrgico');
--end;
--/