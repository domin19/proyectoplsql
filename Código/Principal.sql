--PRINCIPAL
SET SERVEROUTPUT ON;

ALTER SESSION SET nls_date_format='yyyy-mm-ddhh24:mi';

BEGIN
    --Requisito 1
    pacientesingresadosnumdias(1);
    
    --Requisito 2
    insert into cita values(5, 100000001, 101, 1, '2008-04-24 7:00', '2008-04-24 7:50', 'PRUEBA');
    
    --Requisito 3
    calcularintervencionesmedico('Todd Quinlan', 'Médico Quirúrgico');
    
    --Requisito 4
    insert into estancia values (3218, 100000003, 111, '2008-05-02 00:00', '2008-05-02 00:00' );
    verificarHabitacion(1);
    
    --Requisito 5
    INSERT INTO Estancia VALUES(3218,100000002,112,'02/05/2008','03/05/2008');
    
    --Requisito 6
    bajaMedico(3);
    
    --Requisito 7
    insert into cita values(7, 100000002, 102, 2, '2008-04-24 9:00', '2008-04-24 9:50', 'PRUEBA AUDITORIA');
END;
/
