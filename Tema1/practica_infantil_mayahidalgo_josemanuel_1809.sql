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
select * from DEPT

create or alter procedure HallarNumEmp @nameDept varchar(30)
as
begin
    if not exists (select 1 from dept where dname = @nameDept)
    begin
        print('El departamento indicado no existe')
    end
    else
    begin
        declare @numEmp int;

        select @numEmp = count(e.empno)
        from emp as e
        inner join dept as d on e.deptno = d.deptno
        where d.dname = @nameDept;

        if (@numEmp = 0)
        begin
            print('El departamento indicado no tiene empleados')
        end
        else
        begin
            select @numEmp as [Número de Empleados]
        end
    end
end

execute HallarNumEmp 'SALES'

/*
Ejercicio 3

Realiza una función llamada CalcularCosteSalarial que reciba un nombre de departamento y devuelva la suma de los salarios y 
comisiones de los empleados de dicho departamento. Trata las excepciones que consideres necesarias.
*/

create or alter function CalcularCosteSalarial(@nameDept as varchar(30)) returns decimal(10,2) as
begin
	
	declare @sum as decimal(10,2)

	set @sum = (select (sum(ISNULL(e.SAL, 0)) + sum(ISNULL(e.COMM, 0))) as [Suma de salarios y comisiones] from emp 
				as e inner join dept as d 
				on e.deptno = d.deptno 
				where d.dname = @nameDept)

	return ISNULL(@sum, 0)
end

select dbo.CalcularCosteSalarial('sales') as [Suma de salarios y comisiones]

/*
Ejercicio 4 Cr

Realiza un procedimiento MostrarCostesSalariales que muestre los nombres de todos los departamentos y 
el coste salarial de cada uno de ellos. Puedes usar la función del ejercicio 3.
*/

-- PREGUNTAR SI HAY QUE USAR CURSOR EN ESTE EJERCICIO

select * from DEPT
select * from EMP

create or alter procedure MostrarCostesSalariales as
begin
	select d.dname as [Nombre de Departamento], (sum(isnull(e.sal, 0)) + sum(isnull(e.COMM, 0))) as [Coste Salarial] from dept as d
	left join emp as e
	on d.deptno = e.deptno
	group by d.dname
end

/*
Ejercicio 5

Realiza un procedimiento MostrarAbreviaturas que muestre las tres primeras letras del nombre de cada empleado.
*/

create or alter procedure MostrarAbreviaturas as
begin
	select left(e.ename, 3) as [Abreviatura del Nombre] from emp as e
end

execute MostrarAbreviaturas

/*
Ejercicio 6 cr

Realiza un procedimiento MostrarMasAntiguos que muestre el nombre del empleado más antiguo de cada departamento 
junto con el nombre del departamento. Trata las excepciones que consideres necesarias.
*/



/*
Ejercicio 7 CR

Realiza un procedimiento MostrarJefes que reciba el nombre de un departamento y muestre los nombres de los empleados 
de ese departamento que son jefes de otros empleados.Trata las excepciones que consideres necesarias.
*/

/*
Ejercicio 8

Realiza un procedimiento MostrarMejoresVendedores que muestre los nombres de los dos vendedores con más comisiones. Trata las excepciones que consideres necesarias.
*/

select * from emp

create or alter procedure MostrarMejoresVendedores
as
begin
    begin try
        if not exists (select 1 from emp where job = 'SALESMAN')
        begin
            print('No hay vendedores en la tabla EMP.');
        end
		else
		begin
        select top 2 
            e.ename as [Mejores Vendedores], 
            isnull(e.comm, 0) as [Comisiones]
        from Emp as e
        where e.job = 'SALESMAN'
        order by isnull(e.comm, 0) desc;
		end
    end try
    begin catch
        print('Se produjo un error al mostrar los mejores vendedores.');
    end catch
end

execute MostrarMejoresVendedores

/*Ejercicio 10
Realiza un procedimiento RecortarSueldos que recorte el sueldo un 20% a los empleados cuyo nombre 
empiece por la letra que recibe como parámetro.Trata las excepciones  que consideres necesarias
*/

create or alter procedure RecortarSueldos @letra char as
begin
	
end

/*
Ejercicio 11 cr
 
Realiza un procedimiento BorrarBecarios que borre a los dos empleados más nuevos de cada departamento. Trata las excepciones que consideres necesarias.
*/