/*
    -Verificar Habitaci�n Libre
    -Verificar que la habitaci�n en la que se va a quedar un paciente est� disponible
*/

SET SERVEROUTPUT ON;

select * from estancia;
insert into estancia values (3218, 100000003, 111, '2008-05-02 00:00', '2008-05-02 00:00' );

ALTER SESSION SET nls_date_format='yyyy-mm-dd hh24:mi'; --Cambiamos fecha

/*Funcion que verificar� si la habitacion esta libre
a fecha de ejecucion de la aplicacion. Devolver� un number.*/
CREATE OR REPLACE FUNCTION verificarHabitacionLibre (v_NumHabitacion NUMBER)

    RETURN NUMBER IS 
    
    /*Cursor que realizar� la consulta sobre el n�mero de la habitacion introducido y 
    devolver�, si este existe la habitacion, el n�mero, la fecha de inicio y la fecha de fin de estancia.*/
    
    CURSOR c_Habitacion IS SELECT HAB.NUMERO_HABITACION AS "HABITACION", EST.INICIOESTANCIA AS "INICIO", EST.FINESTANCIA AS "FIN" 
        FROM HABITACION HAB, ESTANCIA EST 
        WHERE HAB.NUMERO_HABITACION=EST.HABITACION(+)
            AND HAB.NUMERO_HABITACION=v_NumHabitacion;
        
    v_Registro c_Habitacion%ROWTYPE;
 
BEGIN
    OPEN c_Habitacion;
            FETCH c_Habitacion INTO v_Registro;
                IF (c_Habitacion%NOTFOUND) THEN /*Si no se ha encontrado una habitacion, devuelve 0*/
                    RETURN 0;                
                ELSIF (SYSDATE BETWEEN v_Registro.INICIO AND v_Registro.FIN) THEN
                    RETURN 2; /*Si se ha encontrado habitacion y la fecha actual esta entre las dos fechas de la habitacion,
                                devuelve 2*/
                END IF;
    RETURN 1;   /*En caso de que la habitacion exista y no este ocupada, devolver� 0*/
    CLOSE c_Habitacion;
END;
/

/*Este procedimiento se encagar� de gestionar la respuesta devuelta por el metodo
verificarHabitacionLibre.*/
CREATE OR REPLACE PROCEDURE verificarHabitacion(v_NumHabitacion NUMBER) IS

    v_Libre NUMBER;
    
BEGIN

    /*Guardo el resultado del m�todo veirificarHabitacionLibre dentro de una variable para que sea m�s c�modo trabajar con ella.*/
    v_Libre := verificarhabitacionlibre(v_NumHabitacion); 
        IF (v_Libre=1) THEN /*Si el resultado es 1, muestra un mensaje de que la habitacion esta libre*/
            DBMS_OUTPUT.PUT_LINE('Habitaci�n libre');
        ELSIF (v_Libre=2) THEN /*Si el resultado es 2, muestra un mensaje de que la habitacion esta ocupada*/
            DBMS_OUTPUT.PUT_LINE('Habitaci�n ocupada.');
        ELSIF (v_Libre=0) THEN /*Si el resultado es 0, muestra un mensaje de error, ya que el n�mero de habitaci�n no existe.*/
            DBMS_OUTPUT.PUT_LINE('�ERROR! El n�mero de habitaci�n introducido ('||v_NumHabitacion||') no es v�lido');
        END IF;
END;
/

--BEGIN
  --  VERIFICARHABITACION(1);
--END;
--/