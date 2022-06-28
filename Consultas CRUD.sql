/* insertar usuario */
declare @resultado1 int
declare @mensaje2 varchar(500)
exec insertar_usuario '22222324', 'jorgito','jorgito@gmail.com','12345','987456123',1,@resultado1 out,@mensaje2 out
select @resultado1
select @mensaje2
select * from usuario 
go
/* eliminar usuario */
declare @resultado_e bit
declare @mensaje_e varchar(500)
exec eliminar_usuario 1,@resultado_e out,@mensaje_e out
select @resultado_e
select @mensaje_e
select * from usuario 
go
/* leer usuario */
declare @mensaje_l varchar(500)
exec leer_usuario 1,@mensaje_l out
select @mensaje_l
select * from usuario 
go

/* modificar usuario */
declare @resultado_m bit
declare @mensaje_m varchar(500)
exec modificar_usuario 3,'22222324', 'jorgito','jorgito@gmail.com','12345','987456123',1,@resultado_m out,@mensaje_m out
select @resultado_m
select @mensaje_m
select * from usuario 
go

/* disparadores */
-- nos genera error porque ya existe un usuario con ese documento
insert into usuario (documento,nombre_completo,correo,clave,telefono,estado) values 
('22222324', 'jorgito','jorgito@gmail.com','12345','987456123',1) 
select * from historial_usuario

