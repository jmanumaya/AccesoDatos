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

-- Sin Cursor

create or alter procedure MostrarCostesSalariales as
begin
	select d.dname as [Nombre de Departamento], (sum(isnull(e.sal, 0)) + sum(isnull(e.COMM, 0))) as [Coste Salarial] from dept as d
	left join emp as e
	on d.deptno = e.deptno
	group by d.dname
end

-- Sin Cursor

-- Con Cursor

create or alter procedure MostrarCostesSalariales as
begin
	declare @DeptNo int
	declare @DeptName varchar(50)
	declare @CosteSalarial money;

	declare cur_dept cursor for select deptno, dname from dept;

	open cur_dept;
	fetch next from cur_dept into @DeptNo, @DeptName;

	while @@FETCH_STATUS = 0
	begin
		
		select @CosteSalarial = sum(isnull(sal,0) + isnull(comm, 0)) from emp
		where deptno = @DeptNo

		print 'Departamento: ' + @DeptName + '| Coste Salarial: ' + cast(@CosteSalarial as varchar(20))
	
		fetch next from cur_dept into @DeptNo, @DeptName;
	end

	close cur_dept;
	deallocate cur_dept;
end

-- Con Cursor

execute MostrarCostesSalariales

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

select * from EMP

select * from DEPT

create or alter procedure MostrarMasAntiguos as
begin

	declare @DeptNo int
	declare @DeptName varchar(30)
	declare @EmpName varchar(30)
	
	declare cur_empant cursor for select deptno, dname from dept;

	open cur_empant
	fetch next from cur_empant into @DeptNo, @DeptName;

	while @@FETCH_STATUS = 0
	begin
		
		select TOP 1 @EmpName = ENAME from EMP where DEPTNO = @DeptNo order by HIREDATE ASC

		print 'Departamento: ' + @DeptName + '| Empleado mas Antiguo: ' + @EmpName
	
		fetch next from cur_empant into @DeptNo, @DeptName;
	end
	close cur_empant;
	deallocate cur_empant;
end

execute MostrarMasAntiguos
/*
Ejercicio 7 CR

Realiza un procedimiento MostrarJefes que reciba el nombre de un departamento y muestre los nombres de los empleados 
de ese departamento que son jefes de otros empleados.Trata las excepciones que consideres necesarias.
*/

create procedure mostrarjefes
    @dptoname varchar(14)
as
begin
    -- declaración de variables
    declare @deptno int;
    declare @jefenombre varchar(10);
    declare @jefesencontrados int = 0;

    -- 1. validar que el departamento exista y obtener su deptno
    select @deptno = deptno
    from dept
    where dname = @dptoname;

    if @deptno is null
    begin
        -- excepción: departamento no encontrado
        raiserror('error: el departamento ''%s'' no existe.', 16, 1, @dptoname);
        return;
    end

    -- 2. declarar el cursor
    declare jefescursor cursor for
    select distinct e.ename
    from emp e
    inner join dept d on e.deptno = d.deptno
    where d.dname = @dptoname
      and e.empno in (select mgr from emp where mgr is not null); -- solo empleados que son mgr de alguien

    -- abrir el cursor
    open jefescursor;

    -- obtener el primer jefe
    fetch next from jefescursor into @jefenombre;

    -- 3. recorrer el cursor
    while @@fetch_status = 0
    begin
        -- mostrar el nombre del jefe
        print 'jefe encontrado: ' + @jefenombre;
        set @jefesencontrados = @jefesencontrados + 1;
        
        -- obtener el siguiente jefe
        fetch next from jefescursor into @jefenombre;
    end

    -- cerrar y liberar el cursor
    close jefescursor;
    deallocate jefescursor;

    -- 4. manejo de excepciones: no hay jefes en ese departamento
    if @jefesencontrados = 0
    begin
        print 'aviso: no se encontraron empleados que sean jefes en el departamento de ' + @dptoname + '.';
    end
end

-- Prueba 1: Departamento con jefes (ej. research)
exec mostrarjefes 'RESEARCH';
-- Salida esperada: JONES, SCOTT, FORD

-- Prueba 2: Departamento sin jefes (ej. operations)
exec mostrarjefes 'OPERATIONS';
-- Salida esperada: aviso de no encontrados

-- Prueba 3: Departamento inexistente
exec mostrarjefes 'IT';
-- Salida esperada: error (raiserror)

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

create procedure recortarsueldos
    @letrainicial char(1)
as
begin
    -- declaración de variables
    declare @filasafectadas int;

    -- 1. manejo de excepción: parámetro nulo o vacío
    if @letrainicial is null or @letrainicial = ''
    begin
        raiserror('error: debe proporcionar una letra inicial válida.', 16, 1);
        return;
    end

    -- 2. realizar la actualización basada en conjuntos (sin cursor)
    update emp
    set sal = sal * 0.80  -- reduce el salario en un 20%
    where ename like @letrainicial + '%';

    -- obtener el número de filas actualizadas
    set @filasafectadas = @@rowcount;

    -- 3. manejo de excepción: empleados no encontrados
    if @filasafectadas = 0
    begin
        print 'aviso: no se encontraron empleados cuyo nombre empiece por la letra "' + @letrainicial + '". no se realizó ninguna actualización.';
    end
    else
    begin
        print 'éxito: se han actualizado ' + cast(@filasafectadas as varchar) + ' empleado(s). el sueldo se ha reducido un 20% para los que empiezan por "' + @letrainicial + '".';
    end
end

-- Verificar salarios ANTES
select ename, sal from emp where ename like 'A%';

-- Ejecutar el procedimiento
exec recortarsueldos 'A';

-- Verificar salarios DESPUÉS (Debe ser 1280.00 y 880.00)
select ename, sal from emp where ename like 'A%';

/*
Ejercicio 11 cr
 
Realiza un procedimiento BorrarBecarios que borre a los dos empleados más nuevos de cada departamento. Trata las excepciones que consideres necesarias.
*/

create procedure borrarbecarios
as
begin
    -- variables del cursor y contadores
    declare @deptno_actual int;
    declare @dname_actual varchar(14);
    declare @borrados_en_dpto int;
    declare @borrados_totales int = 0;

    -- declaración del cursor principal
    -- este cursor recorre todos los departamentos que tienen al menos un empleado
    declare dptocursor cursor for
    select distinct e.deptno, d.dname
    from emp e
    inner join dept d on e.deptno = d.deptno;

    -- abrir el cursor
    open dptocursor;

    -- obtener el primer departamento
    fetch next from dptocursor into @deptno_actual, @dname_actual;

    -- recorrer los departamentos
    while @@fetch_status = 0
    begin
        
        -- lógica de borrado (basada en conjunto):
        -- encuentra y borra los EMPNO que tienen el TOP 2 en HIREDATE descendente
        delete from emp
        where empno in (
            select top (2) empno
            from emp
            where deptno = @deptno_actual
            order by hiredate desc
        );

        -- contar y registrar los empleados borrados en este departamento
        set @borrados_en_dpto = @@rowcount;
        set @borrados_totales = @borrados_totales + @borrados_en_dpto;

        -- manejar la retroalimentación
        if @borrados_en_dpto = 2
            print 'éxito: 2 empleados más nuevos borrados en el dpto. ' + @dname_actual + '.';
        else if @borrados_en_dpto = 1
            print 'aviso: solo 1 empleado borrado (el dpto. tenía menos de 2) en ' + @dname_actual + '.';
        else
            print 'aviso: no se encontraron empleados para borrar en ' + @dname_actual + '.';
        
        -- obtener el siguiente departamento
        fetch next from dptocursor into @deptno_actual, @dname_actual;
    end

    -- cerrar y liberar el cursor
    close dptocursor;
    deallocate dptocursor;

    -- manejo de excepción final
    if @borrados_totales = 0
    begin
        raiserror('aviso: la tabla de empleados está vacía o no se pudo realizar ninguna eliminación.', 10, 1);
    end
end

-- Consultar los empleados ANTES de la ejecución:
select ename, deptno, hiredate from emp order by deptno, hiredate desc;

exec borrarbecarios;

-- Verificar los empleados restantes:
select ename, deptno, hiredate from emp order by deptno, hiredate desc;