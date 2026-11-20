--TuplasOK
--Producto 'Disponible' con stock >0, cumple con CK_PRODUCTOS_ESTADOVSSTOCK
INSERT INTO PRODUCTOS(id_producto, nombre, descripcion, precio_referencia,marca,stock,estado,fecha_ingreso,imagen_url)
    VALUES(90001,'Camisa Lino',NULL,80000.00,'Zara',15,'Disponible', '2026-05-01 11:00:00',NULL);

-- Cliente y venta de apoyo, para poder insertar el detalle y se pueda probar el check
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (90001, 'Cliente Prueba', '3001112233', 'prueba90001@mail.com', '2026-05-01 10:00:00', NULL);

INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (90001, '2026-05-01 12:00:00', 'Efectivo', 'Completada', 'Domicilio', NULL, 90001);

--Detalle con descuento de 10,000 menor al precio que es de 80,000, cumple con CK_DETALLESVENTA_DESCUENTOVSPRECIO
INSERT INTO DETALLESDEVENTAS(id_venta,id_producto,cantidad,precio_venta,descuento)
    VALUES(90001,90001,1,80000.00,10000.00);