Use SCOTT

/*Ejercicio 1
Haz una función llamada DevolverCodDept que reciba el nombre de un departamento y devuelva su código.
*/

select * from DEPT

Create or alter function devolverCodDept(@nombre varchar(30)) returns int as
begin
	declare @code int
	
	set @code = (select DEPTNO from DEPT where DNAME = @nombre)

	return @code
end

select dbo.DevolverCodDept('SALES') as [Codigo de Departamento]

/*
Ejercicio 2

Realiza un procedimiento llamado HallarNumEmp que recibiendo un nombre de departamento, muestre en pantalla el número de empleados de dicho departamento. Puedes utilizar la función creada en el ejercicio 1.

Si el departamento no tiene empleados deberá mostrar un mensaje informando de ello. Si el departamento no existe se tratará la excepción correspondiente.
*/

select * from EMP

create or alter procedure HallarNumEmp @nameDept varchar(30)
as
begin
begin try
	if (0 = (select count(e.EMPNO) from DEPT as d inner join EMP as e on d.DEPTNO = e.DEPTNO where d.DEPTNO = @nameDept))
	begin
	print('El departamento indicado no tiene empleados')
	end
	select count(e.EMPNO) from DEPT as d inner join EMP as e on d.DEPTNO = e.DEPTNO where d.DEPTNO = @nameDept
end try
begin catch
	print('El departamento indicado no existe')
end catch
end

execute HallarNumEmp 70
