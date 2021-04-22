/*
- Control/Limpieza estancias
- Verificar el fin de la estancia del paciente, eliminar la estancia y dejar disponible la habitación / Procedimiento, Trigger
*/

SET SERVEROUTPUT ON;


CREATE OR REPLACE PROCEDURE controlEstancias AS  /*En este procedimiento revisamos si hay alguna estancia cuya habitación está disponible, por lo que habría un error y se 
                                                 procede a eliminarla*/
    
    /*Realizamos un cursor el cual nos indicará el ID de la estancia, cuya habitación está disponible y no está registrado en la tabla PADECE, 
        por lo que dicha estancia no debería existir*/
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
        DELETE ESTANCIA WHERE ID_ESTANCIA = v_Reg."ID_ESTANCIA"; /*Si el cursor devuelve algún valor una vez que estemos recorriendolo, procedemos inmediatamente a su eliminación*/
        EXIT WHEN c_Estancia%NOTFOUND;
        
        END LOOP;
    CLOSE c_Estancia;
    
    EXCEPTION
    WHEN OTHERS THEN  /*Control de excepciones inesperadas*/
        DBMS_OUTPUT.PUT_LINE('-2564 Error inesperado'); 

END controlEstancias;
/

CREATE OR REPLACE TRIGGER limpiezaEstancia
    BEFORE INSERT OR UPDATE ON ESTANCIA /*Disparador que saltará antes de realizar cualquier inserción o actualización sobre la tabla ESTANCIA*/
                                        
BEGIN 

    controlEstancias;   
    
END limpiezaEstancia;
/

-- TEST

SELECT est.ID_ESTANCIA AS "ID_ESTANCIA", hab.NUMERO_HABITACION, hab.NODISPONIBLE /*Datos de la estancia a eliminar*/
                            FROM ESTANCIA est, HABITACION hab      
                            WHERE (hab.NODISPONIBLE = 0 
                                AND hab.NUMERO_HABITACION = est.HABITACION) AND
                                est.ID_ESTANCIA NOT IN (SELECT pad.ESTANCIA FROM PADECE pad);


INSERT INTO Estancia VALUES(3218,100000002,112,'02/05/2008','03/05/2008'); /*Prueba*/


--ROLLBACK;
--DROP TRIGGER limpiezaEstancia;
--DROP PROCEDURE controlEstancias;