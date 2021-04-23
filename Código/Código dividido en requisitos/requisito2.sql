---Restriccion horario cita.
  --Incluir restricciones sobre la hora a que se puede insertar citas. Una cita no puede empezar ni acabar antes de las 8 o despues de las 20.



SET SERVEROUTPUT ON;

ALTER SESSION SET nls_date_format='yyyy-mm-ddhh24:mi';

CREATE OR REPLACE TRIGGER DisparadorHoraCitas
    BEFORE INSERT ON Cita FOR EACH ROW
DECLARE
    e_HoraCitaIncorrecta EXCEPTION;
    v_HoraI VARCHAR2(60);
    v_HoraF VARCHAR2(60);

BEGIN
    
/*Si las citas no están en el intervalo 8:00 - 20:00, no se insertarán, y saltará una excepción*/

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

--insert into cita values(5, 100000001, 101, 1, '2008-04-24 7:00', '2008-04-24 7:50', 'PRUEBA');
--rolback;