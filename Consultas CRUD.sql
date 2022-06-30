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
exec eliminar_usuario 4,@resultado_e out,@mensaje_e out
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
exec modificar_usuario 5,'70418855', 'jorgito','jorgito@gmail.com','12345','987456123',1,@resultado_m out,@mensaje_m out
select @resultado_m
select @mensaje_m
select * from usuario 
go

/* insertar categoria */
declare @resultado_c int
declare @mensaje_c varchar(500)
exec insertar_categoria 'domestico',1,@resultado_c out,@mensaje_c out
select @resultado_c
select @mensaje_c
select * from categoria 
go
/* modificar categoria */
declare @resultado_mc int
declare @mensaje_mc varchar(500)
exec modificar_categoria 4,'cereales',1,@resultado_mc out,@mensaje_mc out
select @resultado_mc
select @mensaje_mc
select * from categoria 
go
/* eliminar categoria */
declare @resultado_ec int
declare @mensaje_ec varchar(500)
exec eliminar_categoria 4,@resultado_ec out,@mensaje_ec out
select @resultado_ec
select @mensaje_ec
select * from categoria 
go

/* insertar producto */
declare @resultado_p int
declare @mensaje_p varchar(500)
exec insertar_producto 1,'CE01','Lentejas','Una bolsa de 1kg Andes',50,4.5,6.2,1,@resultado_p out,@mensaje_p out
select @resultado_p
select @mensaje_p
select * from producto 
go
/* registrar venta */
declare @dato EDetalle_Venta
insert into @dato(id_producto,precio_venta,cantidad,sub_total) values (6,6.20,10,62.0)
declare @resultado_v bit
declare @mensaje_v varchar(500)
exec registrar_venta 2,'factura','00001','70418555','rony',100.0,38.0,100.0,@dato,@resultado_v out,@mensaje_v out
select @resultado_v
select @mensaje_v
select * from detalle_venta
go

/* disparadores */
-- nos genera error porque ya existe un usuario con ese documento
insert into usuario (documento,nombre_completo,correo,clave,telefono,estado) values 
('22222324', 'jorgito','jorgito@gmail.com','12345','987456123',1) 
select * from historial_usuario
