USE master
go

DROP DATABASE IF EXISTS actividadbd
go

CREATE DATABASE actividadbd
go

USE actividadbd
go
--******************************************************************
--****************************TABLAS********************************
--******************************************************************
DROP TABLE IF EXISTS usuario
go
CREATE TABLE usuario(
	id_usuario int primary key IDENTITY  ,
	documento varchar(50) ,
	nombre_completo varchar(50) ,
	correo varchar(50) ,
	clave varchar(50) ,
	telefono varchar(50) ,
	estado bit ,
	fecha_registro datetime default getdate(),
)
go
DROP TABLE IF EXISTS categoria
go
CREATE TABLE categoria(
	id_categoria int primary key IDENTITY  ,
	descripcion varchar(100) ,
	estado bit ,
	fecha_registro datetime default getdate(),
)

go
DROP TABLE IF EXISTS producto
go
CREATE TABLE producto(
	id_producto int primary key IDENTITY  ,
	id_categoria int,
	codigo varchar (20),
	nombre_pro varchar(30)  ,
	descripcion varchar(50) ,
	stock int  ,
	precio_compra decimal(10, 2) ,
	precio_venta decimal(10, 2) ,
	estado bit ,
	fecha_registro datetime default getdate(),

	CONSTRAINT fk_id_categoria
	FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
		ON UPDATE CASCADE
		ON DELETE CASCADE
	
)
go
DROP TABLE IF EXISTS venta
go
CREATE TABLE venta(
	id_venta int primary key IDENTITY  ,
	id_usuario int,
	tipo_documento varchar(50) ,
	numero_documento varchar(50) ,
	documento_cliente varchar(50) ,
	nombre_cliente varchar(100) ,
	monto_pago decimal(10, 2) ,
	monto_cambio decimal(10, 2) ,
	monto_total decimal(10, 2) ,
	fecha_registro datetime default getdate(),

	CONSTRAINT fk_id_usuario
	FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
		ON UPDATE CASCADE
		ON DELETE CASCADE
)
go
DROP TABLE IF EXISTS detalle_venta
go
CREATE TABLE detalle_venta(
	id_detalle_venta int primary key IDENTITY  ,
	id_venta int,
	id_producto int,
	precio_venta decimal(10, 2) ,
	cantidad int ,
	sub_total decimal(10, 2) ,
	fecha_registro datetime default getdate(),

	CONSTRAINT fk_id_venta
	FOREIGN KEY (id_venta) REFERENCES venta(id_venta)
		ON UPDATE CASCADE
		ON DELETE CASCADE,

	CONSTRAINT fk_id_producto
	FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
		ON UPDATE CASCADE
		ON DELETE CASCADE
)
go
DROP TABLE IF EXISTS historial_usuario
go
create table historial_usuario (
	documento varchar(50) ,
	nombre_completo varchar(50) ,
	correo varchar(50) ,
	clave varchar(50) ,
	telefono varchar(50) ,
	estado bit,
	fecha datetime,
	descripcion varchar(50),
	usuario varchar(50)
)
go
-- -------------------------------------------------------------
--	INSERTAMOS ALGUNOS DATOS
-- -------------------------------------------------------------
insert into usuario (documento,nombre_completo,correo,clave,telefono,estado)
values
	('70418855','joseph camasca', 'jos@gamil.com','12345','975295416',1),
	('70418555','rony camasca', 'rony@gamil.com','1111','99999999',1),
	('70415555','guiler camasca', 'guiler@gamil.com','2222','999623220',1);
go
insert into categoria(descripcion,estado)
values
	('cereales',1),
	('lacteos',1),
	('bebidas',1);
go
insert into producto (id_categoria,codigo,nombre_pro,descripcion,stock,precio_compra,precio_venta,estado)
values
	(1,'CE02','frejol', 'frejol',15,10.50,12.50,1),
	(2,'CE03','leche', 'leche',20,10.50,15.50,1),
	(3,'CE04','Coca Cola', 'Coca Cola 3L',30,12.50,15.50,1)
go
insert into venta (id_usuario,tipo_documento,numero_documento,documento_cliente,nombre_cliente,monto_pago,monto_cambio, monto_total)
values
	(1,'DNI', '70418855','70418855','joseph camasca',300,20,280)
go
insert into detalle_venta(id_venta,id_producto,precio_venta,cantidad,sub_total)
values
	(1,1, 12.50,10,125.0),
	(1,2, 15.50,10,155.0)
go

-- -------------------------------------------------------------
--	CREAMOS LOS PROCEDIMIENTOS PARA EL CRUD DE LA TABLA USUARIO
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	1.Procedimiento para insertar usuario con la condicion de que
--  no pueda tener el mismo documento.
-- -------------------------------------------------------------
-- -------------------------------------------------------------

DROP PROCEDURE IF EXISTS insertar_usuario
go
CREATE PROCEDURE insertar_usuario(
@documento varchar (50),
@nombre_completo varchar(50) ,
@correo varchar(50) ,
@clave varchar(50) ,
@telefono varchar(50) ,
@estado bit, 
@resultado int output,
@mensaje varchar(500) output
)
as
begin
	set @resultado = 0
	set @mensaje = ''

	if not exists (select * from usuario where documento = @documento)
	begin
		insert into usuario(documento,nombre_completo,correo,clave,telefono,estado) values
		(@documento,@nombre_completo,@correo,@clave,@telefono,@estado)
		set @resultado = SCOPE_IDENTITY()
		
	end
	else
		set @mensaje = 'Solo se puede registrar una sola vez con el DNI'

end
go

-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	2.Procedimiento para leer usuario.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS leer_usuario
go
CREATE PROCEDURE leer_usuario(
@id_usuario int,
@mensaje varchar(500) output
)
as
begin
	set @mensaje = ''

	if  exists (select * from usuario where id_usuario = @id_usuario)
	begin
		select documento,nombre_completo,correo,telefono,estado 
		from usuario
		where (id_usuario=@id_usuario)
				
	end
	else
		set @mensaje = 'No existe usuario'

end
go

-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	3.Procedimiento para modificar el usuario.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS modificar_usuario
go
CREATE PROCEDURE modificar_usuario(
@id_usuario int,
@documento varchar (50),
@nombre_completo varchar(50) ,
@correo varchar(50) ,
@clave varchar(50) ,
@telefono varchar(50) ,
@estado bit, 
@resultado bit output,
@mensaje varchar(500) output
)
as
begin
	set @resultado = 0
	set @mensaje = ''
	-- Validar que no exista otro usuario con el mis documento DNI
	if not exists (select * from usuario where documento = @documento and id_usuario != @id_usuario)
	begin
		update usuario set
		documento = @documento,
		nombre_completo = @nombre_completo,
		correo= @correo,
		telefono= @telefono,
		estado= @estado
		where id_usuario=@id_usuario

		set @resultado = 1
		
	end
	else
		set @mensaje = 'No se puede repetir el docuemnto para mas de un usuario'

end
go

-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	4.Procedimiento para eliminar usuario con la condicion de que
--  no que exista alguna venta relacionado con el usuario. 
-- -------------------------------------------------------------
-- ------------------------------------------------------------- 

DROP PROCEDURE IF EXISTS eliminar_usuario
go
CREATE PROCEDURE eliminar_usuario(
@id_usuario int,
@resultado bit output,
@mensaje varchar(500) output
)
as
begin
	set @resultado = 0
	set @mensaje = ''
	declare @go bit = 1
	-- Validar que exista alguna venta relacionado con el usuario 
	if exists (select * from venta v 
	inner join usuario u on u.id_usuario=v.id_usuario 
	where u.id_usuario = @id_usuario)
	begin
		set @resultado = 0
		set @mensaje = 'No se puede eliminar porque tiene una venta'
		set @go  = 0
		
	end

	if (@go = 1)
	begin
		delete from usuario where id_usuario=@id_usuario
		set @resultado = 1 
	end
end
go
-- -------------------------------------------------------------
--	CREAMOS LOS PROCEDIMIENTOS PARA EL CRUD DE LA TABLA CATEGORIA
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	1.Procedimiento para insertar categoria.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS insertar_categoria
go
CREATE PROCEDURE insertar_categoria(
@descripcion varchar (100),
@estado bit, 
@resultado int output,
@mensaje varchar(500) output
)
as
begin
	set @resultado = 0
	set @mensaje = ''

	if not exists (select * from categoria where descripcion = @descripcion)
	begin
		insert into categoria(descripcion,estado) values
		(@descripcion,@estado)
		set @resultado = SCOPE_IDENTITY()
		
	end
	else
		set @mensaje = 'Solo se puede registrar una sola vez la categoria'

end
go
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	2.Procedimiento para modificar la categoria.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS modificar_categoria
go
Create procedure modificar_categoria(
@id_categoria int,
@descripcion varchar(50),
@estado bit,
@resultado bit output,
@mensaje varchar(500) output
)
as
begin
	SET @resultado = 1
	IF NOT EXISTS (SELECT * FROM categoria WHERE descripcion =@descripcion and id_categoria != @id_categoria)
		update categoria set
		descripcion = @descripcion,
		estado = @estado
		where id_categoria = @id_categoria
	ELSE
	begin
		SET @resultado = 0
		set @mensaje = 'No se puede repetir la descripcion de una categoria'
	end

end

go
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	2.Procedimiento para eliminar la categoria.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS eliminar_categoria
go
create procedure eliminar_categoria(
@id_categoria int,
@resultado bit output,
@mensaje varchar(500) output
)
as
begin
	SET @resultado = 1
	IF NOT EXISTS (
	 select *  from categoria c
	 inner join producto p on p.id_categoria = c.id_categoria
	 where c.id_categoria = @id_categoria
	)
	begin
	 delete top(1) from categoria where id_categoria = @id_categoria
	end
	ELSE
	begin
		SET @resultado = 0
		set @mensaje = 'La categoria se encuentara relacionada a un producto'
	end

end

GO
-- -------------------------------------------------------------
--	CREAMOS LOS PROCEDIMIENTOS PARA EL CRUD DE LA TABLA PRODUCTO
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	1.Procedimiento para insertar producto.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS insertar_producto
go
create PROC insertar_producto(
@id_categoria int,
@codigo varchar(20),
@nombre_pro varchar(30),
@descripcion varchar(30),
@stock int,
@precio_compra decimal(10,2),
@precio_venta decimal(10,2),
@estado bit,
@resultado int output,
@mensaje varchar(500) output
)as
begin
	SET @resultado = 0
	IF NOT EXISTS (SELECT * FROM producto WHERE codigo = @codigo)
	begin
		insert into producto(id_categoria,codigo,nombre_pro,descripcion,stock,precio_compra,precio_venta,estado) values (@id_categoria,@codigo,@nombre_pro,@descripcion,@stock,@precio_compra,@precio_venta,@estado)
		set @resultado = SCOPE_IDENTITY()
	end
	ELSE
	 SET @mensaje = 'Ya existe un producto con el mismo codigo' 
	
end

GO

-- -------------------------------------------------------------
--	CREAMOS LOS PROCEDIMIENTOS PARA EL CRUD DE LA TABLA VENTA
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	1.Procedimiento para registrar venta.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
CREATE TYPE [dbo].[EDetalle_Venta] AS TABLE(
	[id_producto] int NULL,
	[precio_venta] decimal(10,2) NULL,
	[cantidad] int NULL,
	[sub_total] decimal(10,2) NULL
)


GO

DROP PROCEDURE IF EXISTS registrar_venta
go
create procedure registrar_venta(
@id_usuario int,
@tipo_documento varchar(50),
@numero_documento varchar(50),
@documento_cliente varchar(50),
@nombre_cliente varchar(50),
@monto_pago decimal(10,2),
@monto_cambio decimal(10,2),
@monto_total decimal(10,2),
@detalle_venta [EDetalle_Venta] READONLY,                                      
@resultado bit output,
@mensaje varchar(500) output
)
as
begin
	
	begin try

		declare @id_venta int = 0
		set @resultado = 1
		set @mensaje = ''

		begin  transaction registro

		insert into venta(id_usuario,tipo_documento,numero_documento,documento_cliente,nombre_cliente,monto_pago,monto_cambio,monto_total)
		values(@id_usuario,@tipo_documento,@numero_documento,@documento_cliente,@nombre_cliente,@monto_pago,@monto_cambio,@monto_total)

		set @id_venta = SCOPE_IDENTITY()

		insert into detalle_venta(id_venta,id_producto,precio_venta,cantidad,sub_total)
		select @id_venta,id_producto,precio_venta,cantidad,sub_total from @detalle_venta

		commit transaction registro

	end try
	begin catch
		set @resultado = 0
		set @mensaje = ERROR_MESSAGE()
		rollback transaction registro
	end catch

end

go

-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	CREAMOS LOS TRIGGERS PARA EL CRUD DE LA TABLA USUARIO
-- -------------------------------------------------------------
-- -------------------------------------------------------------
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	1.Trigger antes de insertar verifica si tiene un usuario el
--  mismo documento.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_usuario_insert
go
create trigger tr_usuario_insert
on usuario instead of insert
as
set nocount on
declare @documento varchar (50)
declare @nombre_completo varchar(50) 
declare @correo varchar(50) 
declare @clave varchar(50) 
declare @telefono varchar(50) 
declare @estado bit
select @documento =documento, 
		@nombre_completo=nombre_completo,
		@correo=correo,
		@clave=clave,
		@telefono=telefono,
		@estado=estado from inserted
	if not exists (select * from usuario where documento = @documento)
		insert into usuario values(@documento,@nombre_completo,@correo,@clave,@telefono,@estado,getdate())
	else 
		print('Usuario ya creado DNI: ' + @documento)
go

-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	2.Trigger despues de insertar en tabla usuario, inserta en la
--  tabla historial_usuario.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_husuario_insert
go
create trigger tr_husuario_insert
on usuario for insert
as
set nocount on
declare @documento varchar (50)
declare @nombre_completo varchar(50) 
declare @correo varchar(50) 
declare @clave varchar(50) 
declare @telefono varchar(50) 
declare @estado bit
select @documento =documento, 
		@nombre_completo=nombre_completo,
		@correo=correo,
		@clave=clave,
		@telefono=telefono,
		@estado=estado from inserted
insert into historial_usuario values (@documento,@nombre_completo,@correo,@clave,@telefono,@estado,getdate(), 'registro insertado', SYSTEM_USER)

go
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	3.Trigger despues de eliminar en tabla usuario, inserta en la
--  tabla historial_usuario los datos eliminados.
-- -------------------------------------------------------------
-- -------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_usuario_delete
go
create trigger tr_usuario_delete
on usuario for delete
as
set nocount on
declare @documento varchar (50)
declare @nombre_completo varchar(50) 
declare @correo varchar(50) 
declare @clave varchar(50) 
declare @telefono varchar(50) 
declare @estado bit
select @documento =documento, 
		@nombre_completo=nombre_completo,
		@correo=correo,
		@clave=clave,
		@telefono=telefono,
		@estado=estado from deleted
insert into historial_usuario values (@documento,@nombre_completo,@correo,@clave,@telefono,@estado,getdate(), 'registro eliminado', SYSTEM_USER)

go

-- -------------------------------------------------------------
-- -------------------------------------------------------------
--	Respaldo
-- -------------------------------------------------------------
-- -------------------------------------------------------------

--backup database actividadbd
--to disk= 'E:\bk\bkactividadbd.bak'
--go

--restore database actividadbd file = 'bkactividadbd' from disk = 'E:\bk\bkactividadbd.bak'