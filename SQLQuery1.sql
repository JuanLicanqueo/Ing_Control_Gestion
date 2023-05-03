                   /*=================================================
				                SESIÓN 02 : NIVEL BÁSICO
					================================================*/
/*===============================
  I.- CREACIÓN DE BASES DE DATOS
=================================*/
--1.- Creación de la base de datos llamada "Venta"
CREATE DATABASE VENTA2 --Forma genérica // Ejecutar presiona F5

--Forma específica de crear una base de datos
CREATE DATABASE VENTA_2
ON 
(NAME = VENTA_2_1,
 FILENAME = 'C:\BaseDeDatos\VENTA_2_1.MDF',
 SIZE = 10,
 MAXSIZE = 50,
 FILEGROWTH = 5
 )
 LOG ON 

 --Eliminar una base de datos
 (NAME = VENTA_2_1_LOG,
  FILENAME = 'C:\BaseDeDatos\VENTA_2_1_LOG.MDF',
  SIZE = 5,
  MAXSIZE = 25,
  FILEGROWTH = 5
  );

--2.-Respaldo de la base de datos (BACKUP)
BACKUP DATABASE VENTA2
TO DISK = 'C:\BaseDeDatos\VENTABK_1.BAK'
WITH FORMAT;

--3.-Eliminar base de dato
USE master --Base de datos por default de SQL
DROP DATABASE VENTA_1
DROP DATABASE VENTA_2

/*=================================
     II.- CREACIÓN DE TABLAS
=================================*/
--1.- Creación de una base de datos llamada "Universidad"
CREATE DATABASE UNIVERSIDAD

--2.-Usar la base creada
USE UNIVERSIDAD

--3.-Creación de tablas
	--i)Tabla para estudiantes
  CREATE TABLE ESTUDIANTES
	(
		CODIGO INT NOT NULL PRIMARY KEY,
		NOMBRE NVARCHAR NOT NULL,
		CREDITOS INT NOT NULL,
		FACULTAD NVARCHAR NOT NULL,
		EDAD INT NOT NULL
	)

	--Visualizar la tabla
	SELECT*
	FROM ESTUDIANTES

--2.-Creación de la base de datos RENIEC
CREATE DATABASE RENIEC_1

--2.1.-Usar la base RENIEC_1
	USE RENIEC_1

--2.2 Creación de una tabla "Persona"
	CREATE TABLE PERSONA
	(
		DNI INT NOT NULL PRIMARY KEY,
		SEXO NVARCHAR(50) NOT NULL,
		NOMBRES NVARCHAR(50) NOT NULL,
		NACIONALIDAD NVARCHAR(50) NOT NULL,
	)
--2.3.-Contraints (validación de información)
	--A) Ingreso para SEXO: Masculino, Femenino
		ALTER TABLE PERSONA
		ADD CONSTRAINT CHK_SEXO
		CHECK (SEXO IN('MASCULINO', 'FEMENINO'))

--2.4.-Información por default
	ALTER TABLE PERSONA
	ADD CONSTRAINT DFT_NACIONALIDAD
	DEFAULT 'PERUANO' FOR NACIONALIDAD

--2.5.-Ingreso de la información
	INSERT INTO PERSONA (DNI, SEXO, NOMBRES, NACIONALIDAD)
	VALUES (789456123, 'MASCULINO', 'VICTOR ANDRES', 'CHILENO')

	INSERT INTO PERSONA (DNI, SEXO, NOMBRES, NACIONALIDAD)
	VALUES (785984515, 'FEMENINO', 'MARÍA FERNANDA','COLOMBIANA')

	INSERT INTO PERSONA (DNI, SEXO, NOMBRES)
	VALUES (456789123, 'MASCULINO', 'JOSE DOMINGO')

--6.-Visulizar los registros
	SELECT *
	FROM PERSONA

--2.7.-Actulalización de registros
UPDATE PERSONA SET NACIONALIDAD = 'PARAGUAY' WHERE DNI = 785984515

--2.8.-Eliminar algún registro en particular
DELETE FROM PERSONA WHERE DNI = 456789123
	SELECT *
	FROM PERSONA

--2.9.-Agregar un campo en una tabla
	ALTER TABLE PERSONA
	ADD ESTADO_CIVIL NVARCHAR(50) NOT NULL

/*=========================================
	III.-Consultas en SQL (primera parte)
  =========================================*/
USE Northwind
--1.-Consulta sobre las tablas
SELECT *
FROM Products
SELECT *
FROM [Order Details]

--2.-Ordenar de forma descendente
	SELECT *
	FROM Orders
	ORDER BY OrderID DESC

--3.-Aplicación de filtros en consultas 
	--Usar la tabla Productos
	SELECT *
	FROM Products
	--A)Productos que cuestan 10 dólares
	WHERE UnitPrice = 10

	--B)Productos que cuestan más de 15 dólares
	SELECT *
	FROM Products
	WHERE UnitPrice >15

	--C)Productos que cuestan menos de 40 dólares
	SELECT *
	FROM Products
	WHERE UnitPrice < 40

	--D)Productos cuyo precio es mayor o igual a 25 dólares
	SELECT *
	FROM Products
	WHERE UnitPrice >= 25

	--E)Productos que cuestán más de 10 doláres y menos de 50 dólares
	--Primera forma
	SELECT *
	FROM Products
	WHERE UnitPrice > 10 AND UnitPrice < 50

	--Segunda forma
	SELECT *
	FROM Products
	WHERE UnitPrice BETWEEN 10 AND 50

	--F)Productos que cuestán más de 10 doláres y menos de 50 doláres ordenados de forma descendente
	SELECT *
	FROM Products
	WHERE Unitprice BETWEEN 10 AND 50
	Order By Unitprice DESC

	--G)Consultas por columnas (una columna en específico)
		--i)Nombre del producto y precio
		SELECT P.ProductName 'Nombre de producto',
			   P.UnitPrice 'Precio'
		FROM Products as P --Alias (pseudónimo de productos es P)
	
	--ii)Nombre del producto y precio si es mayor a $15 (descendente)
		SELECT P.ProductName 'Nombre de producto',
			   P.UnitPrice 'Precio'
		FROM Products as P
		WHERE P.UnitPrice > 15
		Order By P.UnitPrice DESC

	--H)El precio máximo de un producto
		SELECT MAX(P.UnitPrice) 'Precio máximo'
		FROM Products as P 

	--I)El precio mínimo de un producto
		SELECT MIN(P.UnitPrice) 'Precio Minimo'
		FROM Products as P

	--J)Total de productos en stock
		SELECT SUM(P.UnitsInStock) 'Total stock'
		FROM Products as P

	--K)Inventario valorizado de cada producto
		SELECT P.ProductName 'Nombre de producto',
		       (P.UnitPrice*P.UnitsInStock) 'Inventario valorizado'
		FROM Products as P
	
	--L)Inventario valorizado de todo el almacén
		SELECT SUM(P.UnitPrice*P.UnitsInStock) 'Inventario valorizado total'
		FROM Products as P

	--M)Máximo inventario valorizado de todo el almacén
		SELECT MAX(P.UnitPrice*P.UnitsInStock) 'Máximo inventario valorizado'
		FROM Products as P

	--N)Precio promedio de productos
		SELECT AVG(P.UnitPrice) 'Precio promedio'
		FROM Products as P

	--O)Raíz cuadrada de suma total de precios
		SELECT SQRT(SUM(P.UnitPrice))
		FROM Products as P
		
/*=======================================
	IV.- Funciones matemáticas en SQL
=========================================*/
--1.-Valor absoluto
SELECT ABS(7-60) 'Valor absoluto'

--2.-Raíz cuadrada
SELECT SQRT(12) 'Raíz cuadrada'

--3.-Potencia [base, exponente]
SELECT POWER (5, 3)
SELECT POWER (2.123456,4)

--4.-Redondeo
SELECT ROUND (150.25412,1) --Redondeo a la décima
SELECT ROUND (150.25412,2) --Redondeo a la centésima
SELECT ROUND (150.25412,0) --Redondeo a la unidad

--5.-Ceiling (aproxima al entero mayor más proximo)
SELECT CEILING (191.2)
SELECT CEILING (5478.00000000000000000000001)

--6.-floor (aproxima al entero menor más próximo)
SELECT FLOOR(157.99999)
SELECT FLOOR(55478.123456789)

--7.-Logaritmos 
SELECT LOG(100) --Logaritmo natural (Ln)
SELECT LOG10(100) --Logaritmo de base 10

/*======================================
		V.-Funciones de texto
========================================*/
--1.- Charindex: Devuelve un valor entero correspondiente a la posición de una subcadena
SELECT CHARINDEX('abc', 'modificacion estructura abc del libro')

--Ejercicios sobre funciones de texto
use master --Llamar a la base

--Creando la tabla ABCD
CREATE TABLE ABCDE
(
	NOMBRE VARCHAR(50),
	APELLIDO VARCHAR(50),
	FECHA DATE
)

INSERT INTO ABCDE (NOMBRE, APELLIDO, FECHA)
VALUES ('JOSE', 'ACEVEDO', '05/05/2005')

INSERT INTO ABCDE (NOMBRE, APELLIDO, FECHA)
VALUES ('JORGE', 'GONZALES', '09/14/1999')

INSERT INTO ABCDE (NOMBRE, APELLIDO, FECHA)
VALUES ('JAVIER', 'ESPINOZA', '10/11/2018')

INSERT INTO ABCDE
VALUES
('JUAN', 'LOPEZ', '08/08/2008'),
('MARIA', 'SOSA', '09/09/1999'),
('JESUS', 'MONTES', '07/07/2007'),
('KARLA', 'ROSAS', '04/04/2004')

--Visualizar la tabla ABCDE
SELECT *
FROM ABCDE

--1.-Cantidad de caracteres del nombre (LEN)
	SELECT M.NOMBRE,
		   LEN(M.NOMBRE)'Cantidad de caracteres'
	FROM ABCDE AS M

--2.-Cantidad de caracteres del nombre y apellido
	SELECT M.Nombre,
		   M.Apellido,
		   len(CONCAT(M.NOMBRE, M.APELLIDO)) 'Cantidad de caracteres'
	FROM ABCDE AS M

--3.-Seleccionar las personas cuyos apellidos tienen más de 5 caracteres
	SELECT M.Apellido,
		   LEN(M.Apellido) 'Caracteres'
	FROM ABCDE AS M
	WHERE LEN(M.Apellido) > 5

--4.-Extraer la inicial del nombre y apellido (LEFT)
	SELECT CONCAT(LEFT(M.Nombre, 1), '.' , ' ' , M.Apellido) 'Nombre completo'
		FROM ABCDE AS M 

--5.-Inicial del nombre + apellido pero solo aquellas personas que cominecen con J
	SELECT CONCAT(LEFT(M.Nombre, 1), '.', M.Apellido) 'Nombre completo'
	FROM ABCDE AS M
	WHERE LEFT(M.Nombre, 1) = 'J' 