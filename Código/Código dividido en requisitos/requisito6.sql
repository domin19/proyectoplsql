/*
- Baja medico
- Se dar� de baja a un m�dico, trasladando a todos sus pacientes al m�dico con menos pacientes en ese momento. Se pasara por par�metros el id del m�dico. / Procedimiento
*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE bajaMedico(p_ID NUMBER) AS /*Dicho procedimiento se encarga de dar de baja a un m�dico y trasladar sus pacientes al m�dico que tenga menos*/

    v_IdMedico NUMBER; /*Variable que guarda el m�dico con menos pacientes*/
    e_ErrorId EXCEPTION;

BEGIN

    SELECT PCP INTO v_idMedico FROM PACIENTE WHERE ROWNUM <= 1 GROUP BY PCP ORDER BY COUNT(NSS); /*A�adimos el m�dico con menos pacientes a la variable anteriormente declarada*/
    
    DELETE FROM AFILIADO_CON WHERE MEDICO = p_ID; /*Procedemos a borrar el m�dico pasado por par�metros de la tabla de afiliados*/
    IF SQL%NOTFOUND THEN /*Comprobamos que existe el m�dico pasado por par�metros, ya que todos los m�dicos deben estar afiliados, en caso de que no exista saltar� una excepci�n*/
        RAISE e_errorId;
    END IF;    
   /*A partir de aqui se procede a pasar los pacientes del m�dico pasado por par�metros al calculado anteriormente.*/
    UPDATE PRESCRIBE SET MEDICO = v_IdMedico WHERE MEDICO = p_ID OR PACIENTE IN (SELECT PACIENTE.NSS FROM PACIENTE WHERE PCP = p_ID);
    UPDATE CITA SET MEDICO = v_IdMedico WHERE MEDICO = p_ID OR PACIENTE IN (SELECT PACIENTE.NSS FROM PACIENTE WHERE PCP = p_ID);
    UPDATE PADECE SET MEDICO = v_IdMedico WHERE MEDICO = p_ID OR PACIENTE IN (SELECT PACIENTE.NSS FROM PACIENTE WHERE PCP = p_ID);
    UPDATE TRATADO_EN SET MEDICO = v_IdMedico WHERE MEDICO = p_ID;
    UPDATE PACIENTE SET PCP = v_IdMedico WHERE PCP = p_ID;
    DELETE FROM MEDICO WHERE ID_EMPLEADO = p_ID; /*Se elimina al m�dico*/
    
    EXCEPTION
    WHEN e_ErrorId THEN
        DBMS_OUTPUT.PUT_LINE('-35123 El ID del m�dico indicado no existe');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-32573 Error inesperado');
    
END bajaMedico;
/

--TEST
SELECT * FROM MEDICO; -- lista de medicos
SELECT COUNT(NSS) AS "PACIENTES" , PCP FROM PACIENTE WHERE ROWNUM <= 1 GROUP BY PCP ORDER BY COUNT(NSS); -- m�dico con menos pacientes
EXEC bajaMedico(3);

--ELIMINACION
ROLLBACK;
DROP PROCEDURE bajaMedico;