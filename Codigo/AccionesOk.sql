--AccionesOK

-- Prueba 1: CASCADE en ubicaciones de un cliente
-- Al borrar un cliente sin ventas, sus ubicaciones se borran con el.
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (94001, 'Cliente Cascade', '3001110001', 'cascade94001@mail.com', '2026-05-10 09:00:00', NULL);

INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (94001, 'Calle 50 #20-30', 'Chapinero', 'Bogota', 'Cundinamarca', NULL, TRUE, 94001);

INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (94002, 'Carrera 15 #85-10', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, 94001);

DELETE FROM CLIENTES WHERE id_cliente = 94001;
SELECT * FROM UBICACIONES WHERE id_cliente = 94001; --verificar que aparezcan 0 filas


-- Prueba 2: SET NULL en la ubicacion de un proveedor
-- Al borrar la ubicacion, el proveedor sigue existiendo pero sin ubicacion.
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (94003, 'Avenida 68 #10-05', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, NULL);

INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion)
    VALUES (94001, 'Proveedor SetNull', '6014440004', 'setnull94001@proveedor.co', '2026-05-10 09:00:00', 94003);

DELETE FROM UBICACIONES WHERE id_ubicacion = 94003;
SELECT id_proveedor, id_ubicacion FROM PROVEEDORES WHERE id_proveedor = 94001; --verificar que id_ubicacion aparezca en NULL


-- Prueba 3: CASCADE en el subtipo de un producto
-- Al borrar un producto que no se ha comprado ni vendido, su registro de ROPA se borra con el.
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (94001, 'Camisa Cascade', NULL, 60000, 'Koaj', 5, 'Disponible', '2026-05-10 09:00:00', NULL);

INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
    VALUES (94001, 'M', 'Mujer', 'Camisa', 'Algodon');

DELETE FROM PRODUCTOS WHERE id_producto = 94001;
SELECT * FROM ROPA WHERE id_producto = 94001; --verificar que aparezcan 0 filas


-- Prueba 4: CASCADE en el subtipo de una factura
-- Al borrar una factura emitida, su registro de FACTURASVENTA se borra con ella.
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (94001, '2026-05-10 12:00:00', 50000, 'Emitida', NULL);

INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
    VALUES (94001, 13, NULL);

DELETE FROM FACTURAS WHERE id_factura = 94001;
SELECT * FROM FACTURASVENTA WHERE id_factura = 94001; --verificar que aparezcan 0 filas


-- Prueba 5: RESTRICT en ventas de un cliente
-- El cliente 1 tiene ventas, por eso no se puede borrar (debe salir ERROR).
DELETE FROM CLIENTES WHERE id_cliente = 1;

-- Prueba 6: RESTRICT en los productos de una venta
-- La venta 1 tiene productos, por eso no se puede borrar (debe salir ERROR).
DELETE FROM VENTAS WHERE id_venta = 1;

-- Prueba 7: RESTRICT en la ubicacion de una venta
-- La ubicacion 657 es donde se entrego la venta 1, por eso no se puede borrar (debe salir ERROR).
DELETE FROM UBICACIONES WHERE id_ubicacion = 657;