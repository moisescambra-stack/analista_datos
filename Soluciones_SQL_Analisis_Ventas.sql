


-- Creación del esquema
CREATE SCHEMA ventas;
go

-- Creación de las tablas e inserción de los datos

CREATE TABLE ventas.fabricantes (
	id_fabricante INT IDENTITY (1, 1) PRIMARY KEY,
	nombre_fabricante VARCHAR (100) NOT NULL
);

SET IDENTITY_INSERT ventas.fabricantes ON; 

INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(1,'Fabricante de ropa y materiales de running')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(2,'Fabricante de ropa y materialesde natación')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(3,'Fabricante de ropa y materiales de fútbol')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(4,'Fabricante de ropa y materiales de rugby')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(5,'Fabricante de ropa y materiales de baloncesto')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(6,'Fabricante de ropa y materiales de senderismo')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(7,'Fabricante de ropa y materiales de voleybol')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(8,'Fabricante de ropa y materiales de trail')
INSERT INTO ventas.fabricantes(id_fabricante,nombre_fabricante) VALUES(9,'Fabricante de ropa y materiales de surf')

SET IDENTITY_INSERT ventas.fabricantes OFF;  


CREATE TABLE ventas.productos (
	id_producto INT IDENTITY (1, 1) PRIMARY KEY,
	nombre_producto VARCHAR (100) NOT NULL,
	precio_producto INT NOT NULL,
	id_fabricante INT NOT NULL
	FOREIGN KEY (id_fabricante) REFERENCES ventas.fabricantes (id_fabricante) ON DELETE CASCADE ON UPDATE CASCADE
);

SET IDENTITY_INSERT ventas.productos ON;  

INSERT INTO ventas.productos(id_producto,nombre_producto, precio_producto, id_fabricante) VALUES(1,'Mono de surf', 300,9 )
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(2,'Equipación de futbol', 70, 3)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(3,'Equipación de baloncesto', 100,5)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(4,'Equipación de rugby', 150, 4)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(5,'Equipación de voleybol', 50,7)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(6,'Tabla de surf', 600, 9)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(7,'Protectores de rugby', 100, 4)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(8,'Mochila de senderismo', 150, 6)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(9,'Zapatillas de trail', 200, 8)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(10,'Zapatillas de senderismo',100,6)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(11,'Balón de fútbol', 50, 3)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(12,'Equipación de trail' , 150, 8)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(13,'Protectores de voleybol',50,7)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(14,'Equipación de senderismo', 150, 6)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(15,'Saco de dormir', 20, 6)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(16,'Mochila de trail', 250, 8)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(17,'Zapatillas de fútbol', 150,3)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(18,'Zapatillas de baloncesto', 200,5)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(19,'Zapatillas de rugby',75,4)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(20,'Zapatillas de voleybol',50,7)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(21,'Zapatillas de running',150,1)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(22,'Equipación de natación', 100,2)
INSERT INTO ventas.productos(id_producto, nombre_producto, precio_producto, id_fabricante) VALUES(23,'Equipación de running', 100,1)

SET IDENTITY_INSERT ventas.productos OFF;  

CREATE TABLE ventas.departamentos (
	codigo_departamento INT IDENTITY (1, 1) PRIMARY KEY,
	nombre_departamento VARCHAR (100) NOT NULL,
	presupuesto INT NOT NULL);
	
SET IDENTITY_INSERT ventas.departamentos ON; 

INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(1,'Departamento de running', 20000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(2,'Departamento de natación', 50000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(3,'Departamento de fútbol', 75000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(4,'Departamento de rugby', 90000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(5,'Departamento de baloncesto',90000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(6,'Departamento de senderismo', 50000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(7,'Departamento de voleybol', 75000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(8,'Departamento de trail', 100000)
INSERT INTO ventas.departamentos(codigo_departamento, nombre_departamento, presupuesto) VALUES(9,'Departamento de surf', 120000)

SET IDENTITY_INSERT ventas.departamentos OFF;  

CREATE TABLE ventas.empleados (
	DNI VARCHAR(8) PRIMARY KEY,
	nombre_empleado VARCHAR (100) NOT NULL,
	apellidos_empleado VARCHAR (255) NOT NULL,
	departamento INT,
	CONSTRAINT FK_DPTO FOREIGN KEY (departamento) REFERENCES ventas.departamentos (codigo_departamento));
	
ALTER TABLE ventas.empleados
nocheck constraint FK_DPTO;


INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('47547556','Manuel','Martínez González',2)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('48844891','Luis', 'Jiménez Lobato',3)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('25624532','Carmen', 'Fernández Mateo',4)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('78945632','Rosario', 'Arenas Verdejo',5)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('74185236','Diego', 'Díaz Martín',9)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('25836947','Marta', 'García Zafra',7)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('47548629','Noelia', 'García Pérez',1)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('42365897','José Manuel', 'Navarro Díaz',8)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('85236914','Enrique', 'Medina López',1)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('84712369','Noemí','Suárez León',1)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('12589647','Nazaret', 'Molina Pérez',3)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('45632178','Vicente' , 'Rubio Vidal',4)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('75321469','Isabel','García  Gonzalez',9)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('85201473','Ricardo', 'Blanco  Herrero',8)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('15895632','Javier', 'Fernández  Pascual',6)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('85412973','Juan Manuel', 'Serrano  Rodríguez',7)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('65478931','Jorge', 'Cruz  Saez',8)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('45698712','Miriam', 'Muñoz  Rodríguez',2)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('19684597','Sergio','Domínguez  Soler',3)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('20025478','Joaquín','Martínez Franco',4)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('78965412','Elena','Martín  Rodríguez',4)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('23698547','Vanesa', 'Gómez  Rodríguez',9)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('28963547','Álvaro','Gómez  Carrasco',5)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('10258476','Francisco', 'Reyes  Rodríguez',4)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('73214698','Julio', 'Luna  Garrido',2)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('96325874','Belén','Ramos  López',3)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('14725836','Lucía','Suarez  Martínez',5)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('25836914','Nicolás','García  Martínez',5)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('29852963','Sonia', 'Álvarez  Pérez',8)
INSERT INTO ventas.empleados(DNI, nombre_empleado, apellidos_empleado, departamento) VALUES('30698745','Yolanda', 'Diaz  Silva',7)


CREATE TABLE ventas.almacen (
	codigo_almacen INT IDENTITY (1, 1) PRIMARY KEY,
	lugar_almacen NVARCHAR (100) NOT NULL,
	capacidad_almacen INT NOT NULL
);

SET IDENTITY_INSERT ventas.almacen ON;  

INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(1,'Barcelona',300)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(2,'Madrid',400)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(3,'Murcia',250)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(4,'Valencia',20)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(5,'Salamanca',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(6,'La Coruña',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(7,'Sevilla',300)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(8,'Malaga',350)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(9,'La Rioja',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(10,'Asturias',200)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(11,'Cantabria',150)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(12,'Barcelona',250)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(13,'Madrid',300)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(14,'Albacete',300)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(15,'Ciudad Real',450)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(16,'Segovia',50)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(17,'Toledo',50)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(18,'Burgos',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(19,'Teruel',150)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(20,'Zaragoza',125)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(21,'Almeria',200)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(22,'País Vasco',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(23,'Alicante',200)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(24,'Córdoba',300)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(25,'Tarragona',200)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(26,'Santiago de Compostela',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(27,'Barcelona',500)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(28,'Vigo',100)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(29,'Madrid',800)
INSERT INTO ventas.almacen(codigo_almacen, lugar_almacen, capacidad_almacen) VALUES(30,'Málaga',200)

SET IDENTITY_INSERT ventas.almacen OFF;  

CREATE TABLE ventas.cajas (
	id_caja INT IDENTITY (1, 1) PRIMARY KEY,
	contenido VARCHAR (255) NOT NULL,
	valor INT NOT NULL,
	almacen INT NOT NULL,
	FOREIGN KEY (almacen) REFERENCES ventas.almacen (codigo_almacen) ON DELETE CASCADE ON UPDATE CASCADE
);

SET IDENTITY_INSERT ventas.cajas ON;  

INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(1,'Zapatillas de running',150,30)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(2,'Zapatillas de futbol',150,27)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(3,'Zapatillas de senderismo',100,28)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(4,'Zapatillas de baloncesto',150,29)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(5,'Mochila de senderismo',100,26)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(6,'Balón de fútbol',50,25)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(7,'Zapatillas de trail',200,24)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(8,'Mochila de trail',250,23)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(9,'Saco de dormir',20,22)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(10,'Mono de surf',300,21)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(11,'Equipación de fútbol',70,20)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(12,'Equipación senderismo',150,19)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(13,'Equipación de natación',100,18)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(14,'Equipación de trail',150,17)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(15,'Equipación de baloncesto',100,16)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(16,'Tabla de surf',600,15)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(17,'Equipación de rugby',150,14)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(18,'Equipación de voleybol',50,13)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(19,'Protectores de rugby',100,12)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(20,'Protectores de voleybol',50,11)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(21,'Zapatillas de rugby',75,10)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(22,'Zapatillas de voleybol',50,9)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(23,'Zapatillas de running',150,8)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(24,'Equipación de running',100,30)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(25,'Zapatillas de senderismo',100,28)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(26,'Zapatillas de baloncesto',200,29)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(27,'Mochila de senderismo',150,26)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(28,'Balón de fútbol',50,25)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(29,'Zapatillas de trail',200,24)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(30,'Mochila de trail',250,23)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(31,'Saco de dormir',20,22)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(32,'Mono de surf',300,21)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(33,'Equipación de fútbol',70,20)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(34,'Equipación senderismo',150,19)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(35,'Equipación de natación',100,18)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(36,'Equipación de trail',150,17)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(37,'Equipación de baloncesto',100,16)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(38,'Tabla de surf',600,15)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(39,'Equipación de rugby',150,14)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(40,'Equipación de voleybol',50,13)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(41,'Protectores de rugby',100,12)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(42,'Protectores de voleybol',50,11)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(43,'Zapatillas de rugby',75,10)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(44,'Zapatillas de voleybol',50,9)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(45,'Zapatillas de running',150,8)
INSERT INTO ventas.cajas(id_caja, contenido, valor,almacen) VALUES(46,'Equipación de running',100,30)


SET IDENTITY_INSERT ventas.cajas OFF; 


--1. Seleccionar el precio de los productos.

SELECT precio_producto FROM ventas.productos


--2. Seleccionar toda la información acerca de la tabla empleados.

SELECT * FROM ventas.empleados


--3. Seleccionar el precio medio de todos los productos.

SELECT AVG(precio_producto) AS precio_medio FROM ventas.productos


--4. Obtener todos los nombres de los productos cuyo precio es mayor a 400 euros.

SELECT nombre_producto FROM ventas.productos WHERE precio_producto > 400;


--5. Obtener todos los identificadores y contenidos de las cajas cuyo valor supere los 100 euros.

SELECT id_caja, contenido FROM ventas.cajas WHERE valor > 100;


--6. Obtener el número de productos cuyo precio es mayor o igual a 100 euros.

SELECT COUNT(*) AS cantidad_productos FROM ventas.productos WHERE precio_producto >= 100;


--7. Obtener la cantidad de empleados que posee cada departamento. 


SELECT d.nombre_departamento, COUNT(e.DNI) AS total_empleados
FROM ventas.empleados e
INNER JOIN ventas.departamentos d ON e.departamento = d.codigo_departamento
GROUP BY d.nombre_departamento;


--8. Obtener todos los lugares/ciudades distintos ordenados de los almacenes.

SELECT DISTINCT lugar_almacen FROM ventas.almacen ORDER BY lugar_almacen;


--9. Seleccionar el nombre y precio de los productos cuyo precio sea mayor o igual a 200 euros, ordenándolo descendentemente.

SELECT nombre_producto, precio_producto
FROM ventas.productos
WHERE precio_producto >= 200
ORDER BY precio_producto DESC;


--10. Seleccionar el nombre de los departamentos cuyo presupuesto supere los 75000 euros, ordenándolo ascendentemente.

SELECT nombre_departamento
FROM ventas.departamentos
WHERE presupuesto > 75000
ORDER BY presupuesto ASC;


--11. Ordenar todos los nombres de los departamentos según su presupuesto más caro.

SELECT nombre_departamento, presupuesto
FROM ventas.departamentos
ORDER BY presupuesto DESC;


--12. Obtener el precio medio de los productos de cada identificador de fabricante.


SELECT f.nombre_fabricante, AVG(p.precio_producto) AS precio_medio
FROM ventas.productos p
INNER JOIN ventas.fabricantes f ON p.id_fabricante = f.id_fabricante
GROUP BY f.nombre_fabricante;


--13. Obtener el nombre y precio de los diez productos más baratos 


SELECT TOP 10 nombre_producto, precio_producto
FROM ventas.productos
ORDER BY precio_producto ASC;




SELECT nombre_empleado, departamento
FROM ventas.empleados
ORDER BY nombre_empleado
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;


--15. Obtener aquellos productos que posean los precios incluidos en el siguiente listado: 100, 150, 200.
SELECT * FROM ventas.productos WHERE precio_producto IN (100,150,200);



--16. Obtener todos los datos de aquellos empleados que se apelliden Jiménez Lobato o los que se apelliden Molina Pérez.

SELECT * FROM ventas.empleados
WHERE apellidos_empleado IN ('Jiménez Lobato', 'Molina Pérez');

	
--17. Obtener todos los datos de los productos cuyo precio se encuentre ENTRE 50  y 100 euros.

SELECT * FROM ventas.productos WHERE precio_producto BETWEEN 50 AND 100;


--18. Obtener todos los datos de los empleados cuyo nombre comience por J.

SELECT * FROM ventas.empleados WHERE nombre_empleado LIKE 'J%';


--19. Obtener el nombre y el precio del producto más caro.
-- PISTA: Usa la instrucción TOP

SELECT TOP 1 nombre_producto, precio_producto
FROM ventas.productos
ORDER BY precio_producto DESC;


--20. Obtener la cantidad de almacenes agrupados por por lugar/ciudad.

SELECT lugar_almacen, COUNT(*) AS cantidad_almacenes
FROM ventas.almacen
GROUP BY lugar_almacen;


--21. Obtener aquellos lugares/ciudades que tienen más de dos almacenes.

	
SELECT lugar_almacen, COUNT(*) AS total
FROM ventas.almacen
GROUP BY lugar_almacen
HAVING COUNT(*) > 2;


--22. Obtener los nombres y presupuesto de los departamentos que tienen menos de 5 empleados.

SELECT d.nombre_departamento, d.presupuesto, COUNT(e.DNI) AS empleados
FROM ventas.departamentos d
LEFT JOIN ventas.empleados e ON d.codigo_departamento = e.departamento
GROUP BY d.nombre_departamento, d.presupuesto
HAVING COUNT(e.DNI) < 5;
	

--23. Obtener aquellas cajas que pertenezcan al almacen 15 y el valor sea mayor a 500.

SELECT * FROM ventas.cajas WHERE almacen = 15 AND valor > 500;


--24. Seleccionar los nombres de los productos y el nombre de fabricante 


SELECT p.nombre_producto, f.nombre_fabricante
FROM ventas.productos p
INNER JOIN ventas.fabricantes f ON p.id_fabricante = f.id_fabricante;

--25. Obtener el precio medio de los productos de cada fabricante
-- PISTA: Ayudate de la instrucción INNER JOIN para relacionar tablas si es necesario
SELECT f.nombre_fabricante, AVG(p.precio_producto) AS precio_medio
FROM ventas.productos p
INNER JOIN ventas.fabricantes f ON p.id_fabricante = f.id_fabricante
GROUP BY f.nombre_fabricante;


--26. Obtener un listado de empleados incluyendo nombre y apellidos junto con el nombre del departamento al que pertenece.
-
SELECT e.nombre_empleado, e.apellidos_empleado, d.nombre_departamento
FROM ventas.empleados e
INNER JOIN ventas.departamentos d ON e.departamento = d.codigo_departamento;


--27. Obtener las referencias de aquellas cajas que se encuentran en Madrid o Barcelona

SELECT c.id_caja, c.contenido, a.lugar_almacen
FROM ventas.cajas c
INNER JOIN ventas.almacen a ON c.almacen = a.codigo_almacen
WHERE a.lugar_almacen IN ('Madrid','Barcelona');


--28. Buscar aquellos de los productos cuyos precios son mayores que el precio medio.

	SELECT nombre_producto, precio_producto
FROM ventas.productos
WHERE precio_producto > (SELECT AVG(precio_producto) FROM ventas.productos);

--29. Se debe realizar una consulta que contenga una columna condicional que clasifique los productos según sus distintos precios en 
--    ENTRE 0 y 50€   - Muy Barato, 
--    ENTRE 51 y 100  - Barato, 
--    ENTRE 101 y 250 - Normal, 
--    ENTRE 251 y 400 - Caro, 
--    > 400 		  - Muy Caro.

SELECT nombre_producto, precio_producto,
       CASE
           WHEN precio_producto BETWEEN 0 AND 50 THEN 'Muy Barato'
           WHEN precio_producto BETWEEN 51 AND 100 THEN 'Barato'
           WHEN precio_producto BETWEEN 101 AND 250 THEN 'Normal'
           WHEN precio_producto BETWEEN 251 AND 400 THEN 'Caro'
           ELSE 'Muy Caro'
       END AS categoria_precio
FROM ventas.productos;


--30. Crear una columna condicional que aplicaque un descuento de un 10% si el producto tiene un precio mayor a 100 euros.

SELECT nombre_producto, precio_producto,
       CASE
           WHEN precio_producto > 100 THEN precio_producto * 0.9
           ELSE precio_producto
       END AS precio_descuento
FROM ventas.productos;


--31. Crear una columna dentro de la SELECT que aplique un descuento del 20% a los presupuestos de los departamentos.

SELECT nombre_departamento, presupuesto, presupuesto * 0.8 AS presupuesto_con_descuento
FROM ventas.departamentos;


--32. Elimina aquellos cajas cuyo valor no supere los 50 euros.
DELETE FROM ventas.cajas WHERE valor <= 50;


--33. Elimina de la tabla de almacen la columna de capacidad.

ALTER TABLE ventas.almacen DROP COLUMN capacidad_almacen;

--34. Añadir una columna en la tabla de empleados que sea el resultado de la concatenación de los nombres y apellidos de los empleados.
ALTER TABLE ventas.empleados ADD nombre_completo AS (nombre_empleado + ' ' + apellidos_empleado);

--35. Elimina todos los regustros de la tabla de empleados
DELETE FROM ventas.empleados;

--36. Elimina la base de datos ejercicios que hemos creado

DROP DATABASE ejercicios;
