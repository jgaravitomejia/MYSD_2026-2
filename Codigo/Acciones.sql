--AccionesOK


-- Prueba 1: CASCADE 
-- Al borrar la venta, sus detalles se borran solos.
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (91010, 'Cliente Cascade', '3001110001', 'cascade91010@mail.com', '2026-05-10 09:00:00', NULL);

INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (91010, 'Producto Cascade', NULL, 50000.00, 'Zara', 10, 'Disponible', '2026-05-10 09:00:00', NULL);

INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (91010, '2026-05-10 10:00:00', 'Efectivo', 'Completada', 'Domicilio', NULL, 91010);

INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (91010, 91010, 2, 50000.00, NULL);

-- Accion: al borrar la venta, el detalle se va con ella (CASCADE)
DELETE FROM VENTAS WHERE id_venta = 91010;
--SELECT * FROM DETALLESDEVENTAS WHERE id_venta = 91010; --verificar que aparezca 0 filas


--Prueba 2: SET NULL
-- Al borrar la ubicacion, el cliente sigue existiendo pero sin ubicacion.
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal)
    VALUES (91020, 'Calle 50 #20-30', 'Chapinero', 'Bogota', 'Cundinamarca', '110111', true);

INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas, id_ubicacion)
    VALUES (91020, 'Cliente SetNull', '3002220002', 'setnull91020@mail.com', '2026-05-10 09:00:00', NULL, 91020);

-- Accion: al borrar la ubicacion, el cliente queda con id_ubicacion = NULL (SET NULL)
DELETE FROM UBICACIONES WHERE id_ubicacion = 91020;
--SELECT id_cliente, id_ubicacion FROM CLIENTES WHERE id_cliente = 91020; --verificacion, el cliente existe y su id_ubicacion aparece en NULL



-- Prueba 3: RESTRICT
-- Un cliente SIN ventas si se puede borrar (RESTRICT solo bloquea si hay hijos).
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (91030, 'Cliente SinVentas', '3003330003', 'sinventas91030@mail.com', '2026-05-10 09:00:00', NULL);

-- Accion: como no tiene ventas, el borrado pasa sin problema
DELETE FROM CLIENTES WHERE id_cliente = 91030;
--SELECT * FROM CLIENTES WHERE id_cliente = 91030;  --verificar que no haya filas