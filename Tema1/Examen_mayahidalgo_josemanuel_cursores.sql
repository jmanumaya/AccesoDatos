create database cursores2526JoseManuel

use cursores2526JoseManuel

CREATE TABLE EMPLEADOS (
 IdEmpleado VARCHAR(10) PRIMARY KEY,
 Nombre VARCHAR(30) NOT NULL,
 Ciudad VARCHAR(20),
 PuntosFidelidad INT DEFAULT 0
);
CREATE TABLE PRODUCTOS (
 CodProducto VARCHAR(10)PRIMARY KEY,
 Nombre VARCHAR(30) NOT NULL,
 Categoria VARCHAR(20),
 Precio DECIMAL(8,2),
 Stock INT
);
CREATE TABLE VENTAS (
 IdEmpleado VARCHAR(10) ,
 CodProducto VARCHAR(10),
 FechaVenta DATE NOT NULL,
 Cantidad INT DEFAULT 1,
 primary key (idEmpleado, CodProducto, fechaVenta),
 FOREIGN KEY (idEmpleado) REFERENCES EMPLEADOS(idEmpleado),
 FOREIGN KEY (CodProducto) REFERENCES PRODUCTOS(CodProducto)
);
INSERT INTO EMPLEADOS VALUES
('C01', 'Laura Pérez', 'Madrid', 150),
('C02', 'Juan Gómez', 'Barcelona', 80),
('C03', 'Ana López', 'Sevilla', 120),
('C04', 'Pedro Ruiz', 'Valencia', 60),
('C05', 'Marta Díaz', 'Bilbao', 40);
INSERT INTO PRODUCTOS VALUES
('P01', 'Camiseta Roja', 'Ropa', 19.99, 50),
('P02', 'Pantalón Jeans', 'Ropa', 39.99, 30),
('P03', 'Zapatillas Running', 'Calzado', 59.99, 20),
('P04', 'Sudadera Negra', 'Ropa', 29.99, 25),
('P05', 'Mochila Deportiva', 'Accesorios', 24.99, 15);
INSERT INTO VENTAS VALUES
('C01', 'P01', '2024-10-01', 2),
('C02', 'P01', '2024-10-02', 1),
('C03', 'P02', '2024-10-03', 1),
('C04', 'P02', '2024-10-04', 3),
('C05', 'P03', '2024-10-05', 1),
('C01', 'P03', '2024-10-06', 2),
('C02', 'P03', '2024-10-07', 1),
('C03', 'P04', '2024-10-08', 1),
('C01', 'P05', '2024-10-09', 1);

select * from Empleados
select * from Productos
select * from Ventas

/*Explicación: Está el procedimiento main que es el que lleva el flujo de todo y luego el procedimiento normal que es el que lista los tres mas vendidos*/


CREATE or alter VIEW TopTresMasVendidos
AS
select TOP 3 v.CodProducto, p.nombre as [Nombre Producto], count(v.CodProducto) as NumVentasProducto, p.categoria as Categoria from productos as p inner join ventas as v on p.CodProducto = v.CodProducto group by v.CodProducto, p.nombre, p.Categoria order by count(v.CodProducto) DESC;

create or alter procedure ListadoTresMasVendidos as
begin
 -- Cursor 1
    DECLARE @codProducto as varchar(10), @nombreProd varchar(20), @numVentasProd int, @CatProducto varchar(20), @idEmpleado varchar(10), @nombreEmp varchar(20), @fechaVenta datetime;
 -- Cursor 1
    DECLARE RecorreProductosMasVendidos CURSOR FOR
	select * from TopTresMasVendidos
 -- Cursor 1
    OPEN RecorreProductosMasVendidos;
 -- Cursor 1
    FETCH NEXT FROM RecorreProductosMasVendidos INTO @codProducto, @nombreProd, @numVentasProd, @CatProducto;

 -- Cursor 1
    WHILE @@FETCH_STATUS = 0
    BEGIN
 -- Cursor 1
     PRINT CONCAT(@nombreProd,'	',@numVentasProd,'	',@CatProducto);
		-- Cursor 2
			DECLARE RecorreEmpleadosDeProdMasVendidos CURSOR FOR
			select e.IdEmpleado, e.nombre, v.fechaVenta from EMPLEADOS as e inner join ventas as v on e.IdEmpleado = v.IdEmpleado where v.CodProducto = @codProducto;
		-- Cursor 2
			OPEN RecorreEmpleadosDeProdMasVendidos;
		-- Cursor 2
			FETCH NEXT FROM RecorreEmpleadosDeProdMasVendidos INTO @idEmpleado, @nombreEmp, @fechaVenta;

		-- Cursor 2
			WHILE @@FETCH_STATUS = 0
			BEGIN
		-- Cursor 2
			 PRINT CONCAT('	', @idEmpleado,'	',@nombreEmp,'	',@fechaVenta);
			-- Cursor 2
			 FETCH NEXT FROM RecorreEmpleadosDeProdMasVendidos INTO @idEmpleado, @nombreEmp, @fechaVenta;
			END;
		-- Cursor 2
		CLOSE RecorreEmpleadosDeProdMasVendidos;
		DEALLOCATE RecorreEmpleadosDeProdMasVendidos;
 -- Cursor 1
     FETCH NEXT FROM RecorreProductosMasVendidos INTO @codProducto, @nombreProd, @numVentasProd, @CatProducto;
    END;
 -- Cursor 1
CLOSE RecorreProductosMasVendidos;
DEALLOCATE RecorreProductosMasVendidos;
end

create or alter procedure ListadoTresMasVendidosMain as
begin

	if((select COUNT(*) from PRODUCTOS) = 0)
	begin
		print 'La tabla Productos está vacía'
	end
	else
	begin
	
	if((select COUNT(*) from Empleados) = 0)
	begin
		print 'La tabla Empleados está vacía'
	end
	else
	begin
	if((select count(*) from TopTresMasVendidos) < 3)
	begin
	print 'Hay menos de tres productos'
	exec ListadoTresMasVendidos
	end
	else
	exec ListadoTresMasVendidos
	end
	end
end

exec ListadoTresMasVendidosMain

select * from TopTresMasVendidos