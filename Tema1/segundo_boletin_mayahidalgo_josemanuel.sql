create database juvenil
use juvenil

create TABLE SOCIOS (
    DNI VARCHAR(10) PRIMARY KEY, -- DNI as Primary Key
    Nombre VARCHAR(20) NOT NULL,
    Direccion VARCHAR(20) NOT NULL,
    Penalizaciones INT DEFAULT 0
);
create TABLE LIBROS (
    RefLibro VARCHAR(10) PRIMARY KEY, -- RefLibro as Primary Key
    Nombre VARCHAR(30) NOT NULL,
    Autor VARCHAR(20) NOT NULL,
    Genero VARCHAR(10) NOT NULL,
    AñoPublicacion INT,
    Editorial VARCHAR(10)
);
create TABLE PRESTAMOS (
    DNI VARCHAR(10) NOT NULL,
    RefLibro VARCHAR(10) NOT NULL,
    FechaPrestamo DATE NOT NULL,
    Duración INT DEFAULT 24,
    CONSTRAINT PK_PRESTAMOS PRIMARY KEY (DNI, RefLibro, FechaPrestamo),
    CONSTRAINT FK_PRESTAMOS_SOCIOS FOREIGN KEY (DNI) REFERENCES SOCIOS (DNI),
    CONSTRAINT FK_PRESTAMOS_LIBROS FOREIGN KEY (RefLibro) REFERENCES LIBROS (RefLibro)
);

INSERT INTO socios VALUES ('111-A', 'David',   'Sevilla Este', 2);
INSERT INTO socios VALUES ('222-B', 'Mariano', 'Los Remedios', 3);

INSERT INTO socios (DNI, Nombre, Direccion)
VALUES ('333-C', 'Raul',    'Triana'      );

INSERT INTO socios (DNI, Nombre, Direccion)
VALUES ('444-D', 'Rocio',   'La Oliva'    );

INSERT INTO socios VALUES ('555-E', 'Marilo',  'Triana',       2);
INSERT INTO socios VALUES ('666-F', 'Benjamin','Montequinto',  5);

INSERT INTO socios (DNI, Nombre, Direccion)
VALUES ('777-G', 'Carlos',  'Los Remedios');

INSERT INTO socios VALUES ('888-H', 'Manolo',  'Montequinto',  2);


INSERT INTO libros
VALUES('E-1', 'El valor de educar', 'Savater',    'Ensayo', 1994, 'Alfaguara');
INSERT INTO libros
VALUES('N-1', 'El Quijote',         'Cervantes',  'Novela', 1602, 'Anagrama');
INSERT INTO libros
VALUES('E-2', 'La Republica',       'Plat�n',     'Ensayo', -230, 'Anagrama');
INSERT INTO libros
VALUES('N-2', 'Tombuctu',           'Auster',     'Novela', 1998, 'Planeta');
INSERT INTO libros
VALUES('N-3', 'Todos los nombres',  'Saramago',   'Novela', 1995, 'Planeta');
INSERT INTO libros
VALUES('E-3', 'Etica para Amador',  'Savater',    'Ensayo', 1991, 'Alfaguara');
INSERT INTO libros
VALUES('P-1', 'Rimas y Leyendas',   'Becquer',    'Poesia', 1837, 'Anagrama');
INSERT INTO libros
VALUES('P-2', 'Las flores del mal', 'Baudelaire', 'Poesia', 1853, 'Anagrama');
INSERT INTO libros
VALUES('P-3', 'El fulgor',          'Valente',    'Poesia', 1998, 'Alfaguara');
INSERT INTO libros
VALUES('N-4', 'Lolita',             'Nabokov',    'Novela', 1965, 'Planeta');
INSERT INTO libros
VALUES('C-1', 'En salvaje compa�ia','Rivas',      'Cuento', 2001, 'Alfaguara');


INSERT INTO prestamos VALUES('111-A','E-1', '17/12/00',24);
INSERT INTO prestamos VALUES('333-C','C-1', '15/12/01',48);
INSERT INTO prestamos VALUES('111-A','N-1', '17/12/01',24);
INSERT INTO prestamos VALUES('444-D','E-1', '17/12/01',48);
--INSERT INTO prestamos VALUES('111-A','C-2', '17/12/01',72);

INSERT INTO prestamos (DNI, RefLibro, FechaPrestamo) 
VALUES('777-G','N-1', '07/12/01');

INSERT INTO prestamos VALUES('111-A','N-1', '16/12/01',48);

/*Ejercicio 1 (Despues de la creacion y tal)
Realiza un procedimiento llamado listadocuatromasprestados que nos muestre por pantalla un listado 
de los cuatro libros más prestados y los socios a los que han sido prestados con el siguiente formato:

NombreLibro1	NumPrestamosLibro1 	GeneroLibro1	DNISocio1	FechaPrestamoalSocio1
*/

create or alter procedure listadocuatromasprestados
as
begin
    set nocount on;

    -- a) La tabla Libros está vacía.
    if not exists (select 1 from libros)
    begin
        raiserror('Excepción: La tabla Libros está vacía.', 16, 1);
        return;
    end

    -- b) La tabla Socios está vacía.
    if not exists (select 1 from socios)
    begin
        raiserror('Excepción: La tabla Socios está vacía.', 16, 1);
        return;
    end

    -- 1. Identificar los 4 libros más prestados y sus detalles.
    declare @toplibros table (
        rank int,
        reflibro varchar(10),
        nombrelibro varchar(30),
        numprestamos int,
        genero varchar(10)
    );

    insert into @toplibros (rank, reflibro, nombrelibro, numprestamos, genero)
    select top 4
        row_number() over (order by count(p.reflibro) desc) as rank,
        l.reflibro,
        l.nombre as nombrelibro,
        count(p.reflibro) as numprestamos,
        l.genero
    from prestamos p
    inner join libros l on p.reflibro = l.reflibro
    group by l.reflibro, l.nombre, l.genero
    order by numprestamos desc, l.reflibro asc;

    declare @countlibros int = (select count(*) from @toplibros);

    -- c) Hay menos de cuatro o 0 libros que hayan sido prestados.
    if @countlibros = 0
    begin
        raiserror('Excepción: Hay cero libros prestados. No se puede generar el listado.', 16, 1);
        return;
    end
    
    if @countlibros < 4
    begin
        print '------------------------------------------------------------';
        print 'AVISO: Solo se han encontrado ' + cast(@countlibros as varchar) + ' libros con préstamos. Se listarán todos.';
        print '------------------------------------------------------------';
    end

    -- 2. Declaro el cursor para iterar a través de los top libros
    declare @reflibro_c varchar(10), @nombrelibro_c varchar(30), @numprestamos_c int, @genero_c varchar(10);
    declare @dnisocio_c varchar(10), @fechaprestamo_c date;
    declare @outputline varchar(200);

    declare topbookscursor cursor local forward_only read_only for
    select reflibro, nombrelibro, numprestamos, genero
    from @toplibros
    order by rank;

    open topbookscursor;
    fetch next from topbookscursor into @reflibro_c, @nombrelibro_c, @numprestamos_c, @genero_c;

    -- Iteraro por cada uno de los libros más prestados
    while @@fetch_status = 0
    begin
        -- Imprimo la línea de encabezado del libro
        -- Formato: NombreLibroX NumPrestamosLibroX GeneroLibroX
        set @outputline = 
            @nombrelibro_c + replicate(' ', 31 - len(@nombrelibro_c)) + 
            cast(@numprestamos_c as varchar) + replicate(' ', 20 - len(cast(@numprestamos_c as varchar))) + 
            @genero_c;
        print @outputline;

        -- 3. Declaro el cursor para los préstamos de ese libro.
        declare prestamoscursor cursor local forward_only read_only for
        select p.dni, p.fechaprestamo
        from prestamos p
        where p.reflibro = @reflibro_c
        order by p.fechaprestamo desc;

        open prestamoscursor;
        fetch next from prestamoscursor into @dnisocio_c, @fechaprestamo_c;

        -- Iteraro por cada préstamo de este libro
        while @@fetch_status = 0
        begin
            -- Imprimo la línea de préstamo
            -- Formato: DNISocioX FechaPrestamoalSocioX
            set @outputline = 
                replicate(' ', 50) +
                @dnisocio_c + replicate(' ', 15 - len(@dnisocio_c)) + 
                convert(varchar, @fechaprestamo_c, 103);

            print @outputline;

            fetch next from prestamoscursor into @dnisocio_c, @fechaprestamo_c;
        end

        close prestamoscursor;
        deallocate prestamoscursor;
        
        print replicate('-', 60);

        fetch next from topbookscursor into @reflibro_c, @nombrelibro_c, @numprestamos_c, @genero_c;
    end

    close topbookscursor;
    deallocate topbookscursor;
end

print '--- COMPROBACIÓN 1: LISTADO PRINCIPAL (TOP 4) ---';
exec listadocuatromasprestados;

/*
Ejercicio 2

Partiendo del siguiente script, crea la BD correspondiente a los alumnos matriculados en algunos de los módulos de 1º y 2º curso del CFS y sus correspondientes notas:
*/

create database gestionAlumnos
use gestionAlumnos

-- Crear tabla ALUMNOS
CREATE TABLE ALUMNOS (
    DNI VARCHAR(10) NOT NULL PRIMARY KEY,
    APENOM VARCHAR(30),
    DIREC VARCHAR(30),
    POBLA VARCHAR(15),
    TELEF VARCHAR(10)
);

-- Crear tabla ASIGNATURAS
CREATE TABLE ASIGNATURAS (
    COD INT NOT NULL PRIMARY KEY,
    NOMBRE VARCHAR(25)
);

-- Crear tabla NOTAS
CREATE TABLE NOTAS (
    DNI VARCHAR(10) NOT NULL,
    COD INT NOT NULL,
    NOTA INT,
    CONSTRAINT FK_NOTAS_ALUMNOS FOREIGN KEY (DNI) REFERENCES ALUMNOS(DNI),
    CONSTRAINT FK_NOTAS_ASIGNATURAS FOREIGN KEY (COD) REFERENCES ASIGNATURAS(COD)
);

-- Insertar datos en ASIGNATURAS
INSERT INTO ASIGNATURAS VALUES (1, 'Prog. Leng. Estr.');
INSERT INTO ASIGNATURAS VALUES (2, 'Sist. Informáticos');
INSERT INTO ASIGNATURAS VALUES (3, 'Análisis');
INSERT INTO ASIGNATURAS VALUES (4, 'FOL');
INSERT INTO ASIGNATURAS VALUES (5, 'RET');
INSERT INTO ASIGNATURAS VALUES (6, 'Entornos Gráficos');
INSERT INTO ASIGNATURAS VALUES (7, 'Aplic. Entornos 4ªGen');

-- Insertar datos en ALUMNOS
INSERT INTO ALUMNOS VALUES ('12344345', 'Alcalde García, Elena', 'C/Las Matas, 24', 'Madrid', '917766545');
INSERT INTO ALUMNOS VALUES ('4448242', 'Cerrato Vela, Luis', 'C/Mina 28 - 3A', 'Madrid', '916566545');
INSERT INTO ALUMNOS VALUES ('56882942', 'Díaz Fernández, María', 'C/Luis Vives 25', 'Móstoles', '915577545');

-- Insertar datos en NOTAS
INSERT INTO NOTAS VALUES ('12344345', 1, 6);
INSERT INTO NOTAS VALUES ('12344345', 2, 5);
INSERT INTO NOTAS VALUES ('12344345', 3, 6);

INSERT INTO NOTAS VALUES ('4448242', 4, 6);
INSERT INTO NOTAS VALUES ('4448242', 5, 8);
INSERT INTO NOTAS VALUES ('4448242', 6, 4);
INSERT INTO NOTAS VALUES ('4448242', 7, 5);

INSERT INTO NOTAS VALUES ('56882942', 5, 7);
INSERT INTO NOTAS VALUES ('56882942', 6, 8);
INSERT INTO NOTAS VALUES ('56882942', 7, 9);

/*Diseña un procedimiento al que pasemos como parámetro de entrada el nombre de uno de los módulos existentes en la BD y visualice el nombre de los alumnos que lo han cursado junto a su nota.
Al final del listado debe aparecer el nº de suspensos, aprobados, notables y sobresalientes.
Asimismo, deben aparecer al final los nombres y notas de los alumnos que tengan la nota más alta y la más baja.
Debes comprobar que las tablas tengan almacenada información y que exista el módulo cuyo nombre pasamos como parámetro al procedimiento.
*/

create or alter procedure mostrar_notas_por_modulo
    @nombre_modulo varchar(50)
as
begin
    set nocount on;

    -- comprobar que existen datos y el módulo
    if not exists (select 1 from alumnos) or 
       not exists (select 1 from asignaturas) or
       not exists (select 1 from notas)
    begin
        print '⚠️ faltan datos en las tablas.';
        return;
    end

    if not exists (select 1 from asignaturas where nombre = @nombre_modulo)
    begin
        print '❌ el módulo no existe.';
        return;
    end

    -- mostrar alumnos y notas
    select a.apenom as alumno, n.nota
    from notas n
    join alumnos a on a.dni = n.dni
    join asignaturas s on s.cod = n.cod
    where s.nombre = @nombre_modulo
    order by a.apenom;

    -- resumen de calificaciones
    select
        sum(case when n.nota < 5 then 1 else 0 end) as suspensos,
        sum(case when n.nota between 5 and 6 then 1 else 0 end) as aprobados,
        sum(case when n.nota between 7 and 8 then 1 else 0 end) as notables,
        sum(case when n.nota >= 9 then 1 else 0 end) as sobresalientes
    from notas n
    join asignaturas s on s.cod = n.cod
    where s.nombre = @nombre_modulo;

    -- alumnos con nota máxima y mínima
    declare @max int, @min int;

    select @max = max(nota), @min = min(nota)
    from notas n
    join asignaturas s on s.cod = n.cod
    where s.nombre = @nombre_modulo;

    select 'nota más alta' as tipo, a.apenom as alumno, n.nota
    from notas n
    join alumnos a on a.dni = n.dni
    join asignaturas s on s.cod = n.cod
    where s.nombre = @nombre_modulo and n.nota = @max

    union all

    select 'nota más baja', a.apenom, n.nota
    from notas n
    join alumnos a on a.dni = n.dni
    join asignaturas s on s.cod = n.cod
    where s.nombre = @nombre_modulo and n.nota = @min;
end;

exec mostrar_notas_por_modulo 'RET';



/*Ejercicio 3*/

create database tienda
use tienda

CREATE TABLE productos
(
	CodProducto VARCHAR(10) CONSTRAINT p_cod_no_nulo NOT NULL,
	Nombre VARCHAR(20) CONSTRAINT p_nom_no_nulo NOT NULL,
	LineaProducto VARCHAR(10),
	PrecioUnitario NUMERIC(6, 0),
	Stock INT,
	CONSTRAINT PK_productos PRIMARY KEY (CodProducto)
);

CREATE TABLE ventas
(
	CodVenta VARCHAR(10) CONSTRAINT cod_no_nula NOT NULL,
	CodProducto VARCHAR(10) CONSTRAINT pro_no_nulo NOT NULL,
	FechaVenta DATE,
	UnidadesVendidas TINYINT,
	CONSTRAINT PK_ventas PRIMARY KEY (CodVenta),
	CONSTRAINT FK_ventas_productos FOREIGN KEY (CodProducto) REFERENCES productos(CodProducto)
);

INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('1','Procesador P133', 'Proc',15000,20);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('2','Placa base VX', 'PB', 18000,15);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('3','Simm EDO 16Mb', 'Memo', 7000,30);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('4','Disco SCSI 4Gb', 'Disc',38000, 5);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('5','Procesador K6-2', 'Proc',18500,10);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('6','Disco IDE 2.5Gb', 'Disc',20000,25);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('7','Procesador MMX', 'Proc',15000, 5);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('8','Placa Base Atlas','PB', 12000, 3);
INSERT INTO productos (CodProducto, Nombre, LineaProducto, PrecioUnitario, Stock) VALUES ('9','DIMM SDRAM 32Mb', 'Memo',17000,12);
GO

SET DATEFORMAT DMY;

INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V1', '2', '22/09/97',2);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V2', '4', '22/09/97',1);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V3', '6', '23/09/97',3);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V4', '5', '26/09/97',5);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V5', '9', '28/09/97',3);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V6', '4', '28/09/97',1);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V7', '6', '02/10/97',2);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V8', '6', '02/10/97',1);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V9', '2', '04/10/97',4);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V10','9', '04/10/97',4);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V11','6', '05/10/97',2);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V12','7', '07/10/97',1);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V13','4', '10/10/97',3);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V14','4', '16/10/97',2);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V15','3', '18/10/97',3);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V16','4', '18/10/97',5);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V17','6', '22/10/97',2);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V18','6', '02/11/97',2);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V19','2', '04/11/97',3);
INSERT INTO ventas (CodVenta, CodProducto, FechaVenta, UnidadesVendidas) VALUES('V20','9', '04/12/97',3);





