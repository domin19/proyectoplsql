
CREATE TABLE Medico (
  ID_Empleado NUMBER NOT NULL,
  Nombre VARCHAR2(30) NOT NULL,
  Puesto VARCHAR2(30) NOT NULL,
  NSS NUMBER NOT NULL,
  CONSTRAINT MED_EID_PK PRIMARY KEY(ID_Empleado)
); 


CREATE TABLE Departamento (
  ID_Departamento NUMBER NOT NULL,
  Nombre VARCHAR2(30) NOT NULL,
  ID_Jefe NUMBER NOT NULL,
  CONSTRAINT DEP_IDD_PK PRIMARY KEY(ID_Departamento),
  CONSTRAINT DEP_IDJ_FK FOREIGN KEY(ID_Jefe) REFERENCES Medico(ID_Empleado)
);



CREATE TABLE Afiliado_Con (
  Medico NUMBER NOT NULL,
  Departamento NUMBER NOT NULL,
  AfiliacionPrimaria NUMBER NOT NULL,
  CONSTRAINT AFC_MED_FK FOREIGN KEY(Medico) REFERENCES Medico(ID_Empleado),
  CONSTRAINT AFC_DEP_FK FOREIGN KEY(Departamento) REFERENCES Departamento(ID_Departamento),
  CONSTRAINT AFC_PK PRIMARY KEY(Medico, Departamento),
  CONSTRAINT AFC_AFP_CK CHECK(AfiliacionPrimaria IN(0,1))
);


CREATE TABLE Intervencion (
  ID_Intervencion NUMBER,
  Nombre VARCHAR2(30) NOT NULL,
  Coste NUMBER NOT NULL,
  CONSTRAINT TRA_IDI_PK PRIMARY KEY(ID_Intervencion)
);


CREATE TABLE Tratado_En (
  Medico NUMBER NOT NULL,
  Tratamiento NUMBER NOT NULL,
  FechaCertificacion DATE NOT NULL,
  ExpiracionCertificacion DATE NOT NULL,
  CONSTRAINT TRE_MED_FK FOREIGN KEY(Medico) REFERENCES Medico(ID_Empleado),
  CONSTRAINT TRE_TRA_FK FOREIGN KEY(Tratamiento) REFERENCES Intervencion(ID_Intervencion),
  CONSTRAINT TRE_PK PRIMARY KEY(Medico, Tratamiento)
);


CREATE TABLE Paciente (
  NSS NUMBER,
  Nombre VARCHAR2(30) NOT NULL,
  Direccion VARCHAR2(30) NOT NULL,
  Telefono VARCHAR2(30) NOT NULL,
  ID_Seguro_Medico NUMBER NOT NULL,
  PCP NUMBER NOT NULL,
  CONSTRAINT PAC_NSS_PK PRIMARY KEY(NSS), 
  CONSTRAINT PAC_PCP_FK FOREIGN KEY(PCP) REFERENCES Medico(ID_Empleado)
);


CREATE TABLE Enfermera (
  ID_Empleado NUMBER,
  Nombre VARCHAR2(30) NOT NULL,
  Puesto VARCHAR2(30) NOT NULL,
  Registrado NUMBER NOT NULL,
  NSS NUMBER NOT NULL,
  CONSTRAINT ENF_IDE_PK PRIMARY KEY(ID_Empleado),
  CONSTRAINT ENF_REG_CK CHECK(Registrado IN(0,1))
);


CREATE TABLE Cita (
  ID_Cita NUMBER,
  Paciente NUMBER NOT NULL,    
  Enfermera NUMBER,
  Medico NUMBER NOT NULL,
  Inicio_Cita DATE NOT NULL,
  Fin_Cita DATE NOT NULL,
  ObservacionHabitacion VARCHAR2(200) NOT NULL,
  CONSTRAINT CIT_IDC_PK PRIMARY KEY(ID_Cita),
  CONSTRAINT CIT_PAC_FK FOREIGN KEY(Paciente) REFERENCES Paciente(NSS),
  CONSTRAINT CIT_ENF_FK FOREIGN KEY(Enfermera) REFERENCES Enfermera(ID_Empleado),
  CONSTRAINT CIT_MED_FK FOREIGN KEY(Medico) REFERENCES Medico(ID_Empleado)
);


CREATE TABLE Medicacion (
  Codigo NUMBER,
  Nombre VARCHAR2(30) NOT NULL,
  Marca VARCHAR2(30) NOT NULL,
  Descripcion VARCHAR2(30) NOT NULL,
  CONSTRAINT MED_COD_PK PRIMARY KEY(Codigo)
);

CREATE TABLE Prescribe (
  Medico NUMBER NOT NULL,
  Paciente NUMBER NOT NULL, 
  Medicacion NUMBER NOT NULL, 
  Fecha DATE NOT NULL,
  Cita NUMBER,  
  Dosis VARCHAR2(30) NOT NULL,
  CONSTRAINT PRE_PK PRIMARY KEY(Medico, Paciente, Medicacion, Fecha),
  CONSTRAINT PRE_MEA_FK FOREIGN KEY(Medico) REFERENCES Medico(ID_Empleado),
  CONSTRAINT PRE_PAC_FK FOREIGN KEY(Paciente) REFERENCES Paciente(NSS),
  CONSTRAINT PRE_MEO_FK FOREIGN KEY(Medicacion) REFERENCES Medicacion(Codigo),
  CONSTRAINT PRE_CIT_FK FOREIGN KEY(Cita) REFERENCES Cita(ID_Cita)
);


CREATE TABLE Bloque (
  Planta NUMBER NOT NULL,
  Codigo_Bloque NUMBER NOT NULL,
  CONSTRAINT BLO_PK PRIMARY KEY(Planta, Codigo_Bloque)
); 


CREATE TABLE Habitacion (
  Numero_Habitacion NUMBER,
  Tipo_Habitacion VARCHAR2(30) NOT NULL,
  Planta NUMBER NOT NULL,  
  Codigo_Bloque NUMBER NOT NULL,  
  NoDisponible NUMBER NOT NULL,
  CONSTRAINT HAB_NUM_PK PRIMARY KEY(Numero_Habitacion),
  CONSTRAINT HAB_BLO_FK FOREIGN KEY(Planta, Codigo_Bloque) REFERENCES Bloque(Planta, Codigo_Bloque),
  CONSTRAINT HAB_UNA_CK CHECK(NoDisponible in (0,1))
);


CREATE TABLE En_Guardia (
  Enfermera NUMBER NOT NULL,
  Planta NUMBER NOT NULL, 
  Codigo_Bloque NUMBER NOT NULL,
  InicioGuardia DATE NOT NULL,
  FinGuardia DATE NOT NULL,
  CONSTRAINT EGU_PK PRIMARY KEY(Enfermera, Planta, Codigo_Bloque, InicioGuardia, FinGuardia),
  CONSTRAINT EGU_ENF_FK FOREIGN KEY(Enfermera) REFERENCES Enfermera(ID_Empleado),
  CONSTRAINT EGU_PLA_FK FOREIGN KEY(Planta, Codigo_Bloque) REFERENCES Bloque(Planta, Codigo_Bloque)
);


CREATE TABLE Estancia (
  ID_Estancia NUMBER PRIMARY KEY,
  Paciente NUMBER NOT NULL,
  Habitacion NUMBER NOT NULL,
  InicioEstancia DATE NOT NULL,
  FinEstancia DATE NOT NULL,
  CONSTRAINT EST_PAC_FK FOREIGN KEY(Paciente) REFERENCES Paciente(NSS),
  CONSTRAINT EST_HAB_FK FOREIGN KEY(Habitacion) REFERENCES Habitacion(Numero_Habitacion)
);


CREATE TABLE Padece (
  Paciente NUMBER NOT NULL,
  Intervencion NUMBER NOT NULL,
  Estancia NUMBER NOT NULL,
  Fecha_Sintomas DATE NOT NULL,
  Medico NUMBER NOT NULL,
  Enfermera_Asistente NUMBER,
  CONSTRAINT PAD_PK PRIMARY KEY(Paciente, Intervencion, Estancia, Fecha_Sintomas),
  CONSTRAINT PAD_PAC_FK FOREIGN KEY(Paciente) REFERENCES Paciente(NSS),
  CONSTRAINT PAD_INT_FK FOREIGN KEY(Intervencion) REFERENCES Intervencion(ID_Intervencion),
  CONSTRAINT PAD_EST_FK FOREIGN KEY(Estancia) REFERENCES Estancia(ID_Estancia),
  CONSTRAINT PAD_MED_FK FOREIGN KEY(Medico) REFERENCES Medico(ID_Empleado),
  CONSTRAINT PAD_ENF_FK FOREIGN KEY(Enfermera_Asistente) REFERENCES Enfermera(ID_Empleado)
);

ALTER SESSION SET nls_date_format='yyyy-mm-dd hh24:mi';

INSERT INTO Medico VALUES(1,'John Dorian','Interino',111111111);
INSERT INTO Medico VALUES(2,'Elliot Reid','M�dico de cabecera',222222222);
INSERT INTO Medico VALUES(3,'Christopher Turk','M�dico Quir�rgico',333333333);
INSERT INTO Medico VALUES(4,'Percival Cox','M�dico de cabecera senior',444444444);
INSERT INTO Medico VALUES(5,'Bob Kelso','Jefe de Medicina',555555555);
INSERT INTO Medico VALUES(6,'Todd Quinlan','M�dico Quir�rgico',666666666);
INSERT INTO Medico VALUES(7,'John Wen','M�dico Quir�rgico',777777777);
INSERT INTO Medico VALUES(8,'Keith Dudemeister','M�dico residente',888888888);
INSERT INTO Medico VALUES(9,'Molly Clock','M�dico psiquiatra',999999999);

INSERT INTO Departamento VALUES(1,'Medicina general',4);
INSERT INTO Departamento VALUES(2,'Cirug�a',7);
INSERT INTO Departamento VALUES(3,'Psiquiatr�a',9);

INSERT INTO Afiliado_Con VALUES(1,1,1);
INSERT INTO Afiliado_Con VALUES(2,1,1);
INSERT INTO Afiliado_Con VALUES(3,1,0);
INSERT INTO Afiliado_Con VALUES(3,2,1);
INSERT INTO Afiliado_Con VALUES(4,1,1);
INSERT INTO Afiliado_Con VALUES(5,1,1);
INSERT INTO Afiliado_Con VALUES(6,2,1);
INSERT INTO Afiliado_Con VALUES(7,1,0);
INSERT INTO Afiliado_Con VALUES(7,2,1);
INSERT INTO Afiliado_Con VALUES(8,1,1);
INSERT INTO Afiliado_Con VALUES(9,3,1);

INSERT INTO Intervencion VALUES(1,'Rinopodoplastia inversa',1500.0);
INSERT INTO Intervencion VALUES(2,'Recombobulaci�n obtusa',3750.0);
INSERT INTO Intervencion VALUES(3,'Demiophtalmectomy plegado',4500.0);
INSERT INTO Intervencion VALUES(4,'Walletectomy completo',10000.0);
INSERT INTO Intervencion VALUES(5,'Dermogastrotom�a ofuscada',4899.0);
INSERT INTO Intervencion VALUES(6,'Pancreomioplastia reversible',5600.0);
INSERT INTO Intervencion VALUES(7,'Demiectomia folicular',25.0);

INSERT INTO Paciente VALUES(100000001,'John Smith','42 Foobar Lane','555-0256',68476213,1);
INSERT INTO Paciente VALUES(100000002,'Grace Ritchie','37 Snafu Drive','555-0512',36546321,2);
INSERT INTO Paciente VALUES(100000003,'Random J. Paciente','101 Omgbbq Street','555-1204',65465421,2);
INSERT INTO Paciente VALUES(100000004,'Dennis Doe','1100 Foobaz Avenue','555-2048',68421879,3);

INSERT INTO Enfermera VALUES(101,'Carla Espinosa','Enfermera Jefe',1,111111110);
INSERT INTO Enfermera VALUES(102,'Laverne Roberts','Enfermera',1,222222220);
INSERT INTO Enfermera VALUES(103,'Paul Flowers','Enfermera',0,333333330);

INSERT INTO Cita VALUES(13216584,100000001,101,1,'2008-04-24 10:00','2008-04-24 11:00','A');
INSERT INTO Cita VALUES(26548913,100000002,101,2,'2008-04-24 10:00','2008-04-24 11:00','B');
INSERT INTO Cita VALUES(36549879,100000001,102,1,'2008-04-25 10:00','2008-04-25 11:00','A');
INSERT INTO Cita VALUES(46846589,100000004,103,4,'2008-04-25 10:00','2008-04-25 11:00','B');
INSERT INTO Cita VALUES(59871321,100000004,NULL,4,'2008-04-26 10:00','2008-04-26 11:00','C');
INSERT INTO Cita VALUES(69879231,100000003,103,2,'2008-04-26 11:00','2008-04-26 12:00','C');
INSERT INTO Cita VALUES(76983231,100000001,NULL,3,'2008-04-26 12:00','2008-04-26 13:00','C');
INSERT INTO Cita VALUES(86213939,100000004,102,9,'2008-04-27 10:00','2008-04-21 11:00','A');
INSERT INTO Cita VALUES(93216548,100000002,101,2,'2008-04-27 10:00','2008-04-27 11:00','B');

INSERT INTO Medicacion VALUES(1,'Procrastin-X','X','N/A');
INSERT INTO Medicacion VALUES(2,'Thesisin','Foo Labs','N/A');
INSERT INTO Medicacion VALUES(3,'Awakin','Bar Laboratories','N/A');
INSERT INTO Medicacion VALUES(4,'Crescavitin','Baz Industries','N/A');
INSERT INTO Medicacion VALUES(5,'Melioraurin','Snafu Pharmaceuticals','N/A');

INSERT INTO Prescribe VALUES(1,100000001,1,'2008-04-24 10:47',13216584,'5');
INSERT INTO Prescribe VALUES(9,100000004,2,'2008-04-27 10:53',86213939,'10');
INSERT INTO Prescribe VALUES(9,100000004,2,'2008-04-30 16:53',NULL,'5');

INSERT INTO Bloque VALUES(1,1);
INSERT INTO Bloque VALUES(1,2);
INSERT INTO Bloque VALUES(1,3);
INSERT INTO Bloque VALUES(2,1);
INSERT INTO Bloque VALUES(2,2);
INSERT INTO Bloque VALUES(2,3);
INSERT INTO Bloque VALUES(3,1);
INSERT INTO Bloque VALUES(3,2);
INSERT INTO Bloque VALUES(3,3);
INSERT INTO Bloque VALUES(4,1);
INSERT INTO Bloque VALUES(4,2);
INSERT INTO Bloque VALUES(4,3);

INSERT INTO Habitacion VALUES(101,'Individual',1,1,0);
INSERT INTO Habitacion VALUES(102,'Individual',1,1,0);
INSERT INTO Habitacion VALUES(103,'Individual',1,1,0);
INSERT INTO Habitacion VALUES(111,'Individual',1,2,0);
INSERT INTO Habitacion VALUES(112,'Individual',1,2,1);
INSERT INTO Habitacion VALUES(113,'Individual',1,2,0);
INSERT INTO Habitacion VALUES(121,'Individual',1,3,0);
INSERT INTO Habitacion VALUES(122,'Individual',1,3,0);
INSERT INTO Habitacion VALUES(123,'Individual',1,3,0);
INSERT INTO Habitacion VALUES(201,'Individual',2,1,1);
INSERT INTO Habitacion VALUES(202,'Individual',2,1,0);
INSERT INTO Habitacion VALUES(203,'Individual',2,1,0);
INSERT INTO Habitacion VALUES(211,'Individual',2,2,0);
INSERT INTO Habitacion VALUES(212,'Individual',2,2,0);
INSERT INTO Habitacion VALUES(213,'Individual',2,2,1);
INSERT INTO Habitacion VALUES(221,'Individual',2,3,0);
INSERT INTO Habitacion VALUES(222,'Individual',2,3,0);
INSERT INTO Habitacion VALUES(223,'Individual',2,3,0);
INSERT INTO Habitacion VALUES(301,'Individual',3,1,0);
INSERT INTO Habitacion VALUES(302,'Individual',3,1,1);
INSERT INTO Habitacion VALUES(303,'Individual',3,1,0);
INSERT INTO Habitacion VALUES(311,'Individual',3,2,0);
INSERT INTO Habitacion VALUES(312,'Individual',3,2,0);
INSERT INTO Habitacion VALUES(313,'Individual',3,2,0);
INSERT INTO Habitacion VALUES(321,'Individual',3,3,1);
INSERT INTO Habitacion VALUES(322,'Individual',3,3,0);
INSERT INTO Habitacion VALUES(323,'Individual',3,3,0);
INSERT INTO Habitacion VALUES(401,'Individual',4,1,0);
INSERT INTO Habitacion VALUES(402,'Individual',4,1,1);
INSERT INTO Habitacion VALUES(403,'Individual',4,1,0);
INSERT INTO Habitacion VALUES(411,'Individual',4,2,0);
INSERT INTO Habitacion VALUES(412,'Individual',4,2,0);
INSERT INTO Habitacion VALUES(413,'Individual',4,2,0);
INSERT INTO Habitacion VALUES(421,'Individual',4,3,1);
INSERT INTO Habitacion VALUES(422,'Individual',4,3,0);
INSERT INTO Habitacion VALUES(423,'Individual',4,3,0);

INSERT INTO En_Guardia VALUES(101,1,1,'2008-11-04 11:00','2008-11-04 19:00');
INSERT INTO En_Guardia VALUES(101,1,2,'2008-11-04 11:00','2008-11-04 19:00');
INSERT INTO En_Guardia VALUES(102,1,3,'2008-11-04 11:00','2008-11-04 19:00');
INSERT INTO En_Guardia VALUES(103,1,1,'2008-11-04 19:00','2008-11-05 03:00');
INSERT INTO En_Guardia VALUES(103,1,2,'2008-11-04 19:00','2008-11-05 03:00');
INSERT INTO En_Guardia VALUES(103,1,3,'2008-11-04 19:00','2008-11-05 03:00');

INSERT INTO Estancia VALUES(3215,100000001,111,'2008-05-01','2008-05-04');
INSERT INTO Estancia VALUES(3216,100000003,123,'2008-05-03','2008-05-14');
INSERT INTO Estancia VALUES(3217,100000004,112,'2008-05-02','2008-05-03');

INSERT INTO Padece VALUES(100000001,6,3215,'2008-05-02',3,101);
INSERT INTO Padece VALUES(100000001,2,3215,'2008-05-03',7,101);
INSERT INTO Padece VALUES(100000004,1,3217,'2008-05-07',3,102);
INSERT INTO Padece VALUES(100000004,5,3217,'2008-05-09',6,NULL);
INSERT INTO Padece VALUES(100000001,7,3217,'2008-05-10',7,101);
INSERT INTO Padece VALUES(100000004,4,3217,'2008-05-13',3,103);

INSERT INTO Tratado_En VALUES(3,1,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(3,2,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(3,5,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(3,6,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(3,7,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(6,2,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(6,5,'2007-01-01','2007-12-31');
INSERT INTO Tratado_En VALUES(6,6,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,1,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,2,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,3,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,4,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,5,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,6,'2008-01-01','2008-12-31');
INSERT INTO Tratado_En VALUES(7,7,'2008-01-01','2008-12-31');

ALTER SESSION SET nls_date_format='dd/mm/yyyy hh24:mi';

COMMIT;

--DROP TABLE Medico CASCADE CONSTRAINTS;
--DROP TABLE Departamento CASCADE CONSTRAINTS;
--DROP TABLE Afiliado_Con CASCADE CONSTRAINTS;
--DROP TABLE Intervencion CASCADE CONSTRAINTS;
--DROP TABLE Tratado_En CASCADE CONSTRAINTS;
--DROP TABLE Paciente CASCADE CONSTRAINTS;
--DROP TABLE Enfermera CASCADE CONSTRAINTS;
--DROP TABLE Cita CASCADE CONSTRAINTS;
--DROP TABLE Medicacion CASCADE CONSTRAINTS;
--DROP TABLE Prescribe CASCADE CONSTRAINTS;
--DROP TABLE Bloque CASCADE CONSTRAINTS;
--DROP TABLE Habitacion CASCADE CONSTRAINTS;
--DROP TABLE En_Guardia CASCADE CONSTRAINTS;
--DROP TABLE Estancia CASCADE CONSTRAINTS;
--DROP TABLE Padece CASCADE CONSTRAINTS;