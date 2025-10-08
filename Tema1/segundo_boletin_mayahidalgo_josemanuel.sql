CREATE TABLE SOCIOS (
    DNI VARCHAR(10) PRIMARY KEY, -- DNI as Primary Key
    Nombre VARCHAR(20) NOT NULL,
    Direccion VARCHAR(20) NOT NULL,
    Penalizaciones INT DEFAULT 0
);
CREATE TABLE LIBROS (
    RefLibro VARCHAR(10) PRIMARY KEY, -- RefLibro as Primary Key
    Nombre VARCHAR(30) NOT NULL,
    Autor VARCHAR(20) NOT NULL,
    Genero VARCHAR(10) NOT NULL,
    AñoPublicacion INT,
    Editorial VARCHAR(10)
);
CREATE TABLE PRESTAMOS (
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

/*Ejercicio 1*/

create or alter procedure listadocuatromasprestados
as
begin
    set nocount on;
    if not exists (select 1 from libros)
    begin
        raiserror('excepción: la tabla libros está vacía.', 16, 1);
        return;
    end

    if not exists (select 1 from socios)
    begin
        raiserror('excepción: la tabla socios está vacía.', 16, 1);
        return;
    end

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
    order by numprestamos desc;

    declare @countlibros int = (select count(*) from @toplibros);
    if @countlibros = 0
    begin
        raiserror('excepción: hay cero libros prestados. no se puede generar el listado.', 16, 1);
        return;
    end
    
    if @countlibros < 4
    begin
        print '------------------------------------------------------------';
        print 'aviso: se han encontrado solo ' + cast(@countlibros as varchar) + ' libros con préstamos. se listarán todos.';
        print '------------------------------------------------------------';
    end

    declare @reflibro_c varchar(10), @nombrelibro_c varchar(30), @numprestamos_c int, @genero_c varchar(10);

    declare topbookscursor cursor local forward_only read_only for
    select reflibro, nombrelibro, numprestamos, genero
    from @toplibros
    order by rank;

    open topbookscursor;
    fetch next from topbookscursor into @reflibro_c, @nombrelibro_c, @numprestamos_c, @genero_c;

    while @@fetch_status = 0
    begin
        select 
            @nombrelibro_c as 'nombrelibro', 
            @numprestamos_c as 'numprestamoslibro', 
            @genero_c as 'generolibro';

        select
            char(9) + p.dni as 'dnisocio',
            p.fechaprestamo as 'fechaprestamoalsocio'
        from prestamos p
        where p.reflibro = @reflibro_c
        order by p.fechaprestamo desc;
        
        print replicate('-', 60);

        fetch next from topbookscursor into @reflibro_c, @nombrelibro_c, @numprestamos_c, @genero_c;
    end

    close topbookscursor;
    deallocate topbookscursor;
end

print '--- COMPROBACIÓN 1: LISTADO PRINCIPAL (TOP 4) ---';
exec listadocuatromasprestados;