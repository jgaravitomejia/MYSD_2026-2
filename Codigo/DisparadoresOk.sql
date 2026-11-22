--DisparadoresOK

BEGIN;


-- Prueba 1: Mantener cliente, adicionar
-- La fecha de registro la pone el DEFAULT.
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, notas)
    VALUES (95001, 'Cliente Prueba', '3005550001', 'prueba95001@mail.com', NULL);
SELECT id_cliente, fecha_registro FROM CLIENTES WHERE id_cliente = 95001; --verificar que fecha_registro tenga la fecha de hoy


-- Prueba 2: Mantener ubicacion, adicionar
-- La primera ubicacion del cliente queda como principal aunque llegue con es_principal en FALSE.
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (95001, 'Calle 10 #5-20', 'Centro', 'Bogota', 'Cundinamarca', NULL, FALSE, 95001);
SELECT id_ubicacion, es_principal FROM UBICACIONES WHERE id_cliente = 95001; --verificar que 95001 aparezca en TRUE


-- Prueba 3: Mantener ubicacion, adicionar
-- Una segunda ubicacion queda como no principal.
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (95002, 'Carrera 7 #40-10', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, 95001);
SELECT id_ubicacion, es_principal FROM UBICACIONES WHERE id_cliente = 95001 ORDER BY id_ubicacion; --verificar 95001 TRUE y 95002 FALSE


-- Prueba 4: Mantener ubicacion, modificar
-- Al marcar otra ubicacion como principal, la anterior deja de serlo.
UPDATE UBICACIONES SET es_principal = TRUE WHERE id_ubicacion = 95002;
SELECT id_ubicacion, es_principal FROM UBICACIONES WHERE id_cliente = 95001 ORDER BY id_ubicacion; --verificar 95001 FALSE y 95002 TRUE


-- Prueba 5: Mantener ubicacion, modificar
-- Se pueden cambiar los datos de una ubicacion que nunca se uso en una venta.
UPDATE UBICACIONES SET calle = 'Calle 12 #5-30', barrio = 'La Candelaria' WHERE id_ubicacion = 95001;
SELECT id_ubicacion, calle, barrio FROM UBICACIONES WHERE id_ubicacion = 95001; --verificar la nueva calle y el nuevo barrio


-- Prueba 6: Mantener cliente, modificar
-- Se pueden cambiar el nombre y el telefono.
UPDATE CLIENTES SET nombre = 'Cliente Prueba Modificado', telefono = '3005559999' WHERE id_cliente = 95001;
SELECT id_cliente, nombre, telefono FROM CLIENTES WHERE id_cliente = 95001; --verificar el nuevo nombre y el nuevo telefono


-- Prueba 7: Mantener ubicacion, eliminar
-- Se puede eliminar una ubicacion que no es la principal y que no se uso en ventas.
DELETE FROM UBICACIONES WHERE id_ubicacion = 95001;
SELECT id_ubicacion FROM UBICACIONES WHERE id_cliente = 95001; --verificar que solo quede 95002


-- Prueba 8: Mantener cliente, eliminar
-- Un cliente sin ventas se puede eliminar y su ubicacion principal se borra en cascada.
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, notas)
    VALUES (95002, 'Cliente Sin Ventas', '3005550002', NULL, NULL);
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (95003, 'Calle 80 #20-15', NULL, 'Medellin', 'Antioquia', NULL, TRUE, 95002);
DELETE FROM CLIENTES WHERE id_cliente = 95002;
SELECT * FROM UBICACIONES WHERE id_cliente = 95002; --verificar que aparezcan 0 filas


-- Prueba 9: Mantener proveedor, adicionar y modificar
-- La fecha la pone el DEFAULT y se pueden cambiar el nombre y el telefono.
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (95004, 'Avenida 30 #12-40', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, NULL);
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, id_ubicacion)
    VALUES (95001, 'Proveedor Prueba', '6015550001', 'prueba95001@proveedor.co', 95004);
UPDATE PROVEEDORES SET nombre = 'Proveedor Prueba SAS', telefono = '6015559999' WHERE id_proveedor = 95001;
SELECT id_proveedor, nombre, telefono, fecha_registro FROM PROVEEDORES WHERE id_proveedor = 95001; --verificar nombre, telefono y fecha de hoy


-- Prueba 10: Mantener producto, adicionar
-- El estado se asigna segun el stock: sin unidades queda 'Agotado' y con unidades 'Disponible'.
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
    VALUES (95001, 'Tenis Prueba', NULL, 180000, 'Pytar', 0, NULL);
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
    VALUES (95002, 'Bolso Prueba', NULL, 120000, 'Pytar', 3, NULL);
SELECT id_producto, stock, estado, fecha_ingreso FROM PRODUCTOS WHERE id_producto IN (95001, 95002) ORDER BY id_producto; --verificar 95001 Agotado y 95002 Disponible


-- Prueba 11: Mantener producto, adicionar
-- El producto se registra con un solo tipo.
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (95001, 40, 'Hombre', 'Zapatilla', NULL);
INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones)
    VALUES (95002, 'Bolso', 'Cuero', NULL);
SELECT id_producto, talla, genero FROM CALZADO WHERE id_producto = 95001; --verificar que aparezca el calzado
SELECT id_producto, categoria FROM ACCESORIOS WHERE id_producto = 95002; --verificar que aparezca el accesorio


-- Prueba 12: Mantener producto, modificar
-- Al cambiar el stock, el estado se actualiza solo; el precio tambien se puede cambiar.
UPDATE PRODUCTOS SET stock = 0, precio_referencia = 125000 WHERE id_producto = 95002;
SELECT id_producto, stock, estado, precio_referencia FROM PRODUCTOS WHERE id_producto = 95002; --verificar stock 0, Agotado y precio 125000
UPDATE PRODUCTOS SET stock = 3 WHERE id_producto = 95002;
SELECT id_producto, stock, estado FROM PRODUCTOS WHERE id_producto = 95002; --verificar stock 3 y Disponible


-- Prueba 13: Registrar compra, adicionar
-- El estado 'Recibida' y la fecha los pone el DEFAULT.
INSERT INTO COMPRAS (id_compra, observacion, id_proveedor)
    VALUES (95001, 'Compra de prueba', 95001);
SELECT id_compra, estado_compra, fecha_compra FROM COMPRAS WHERE id_compra = 95001; --verificar Recibida y fecha de hoy


-- Prueba 14: Registrar compra, adicionar productos
-- El stock aumenta con lo comprado y el producto agotado pasa a 'Disponible'.
SELECT id_producto, stock, estado FROM PRODUCTOS WHERE id_producto = 95001; --antes: stock 0, Agotado
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (95001, 95001, 5, 100000);
SELECT id_producto, stock, estado FROM PRODUCTOS WHERE id_producto = 95001; --verificar stock 5 y Disponible


-- Prueba 15: Registrar compra, modificar
-- Al cancelar la compra se retiran del stock las unidades que habia ingresado.
INSERT INTO COMPRAS (id_compra, observacion, id_proveedor)
    VALUES (95002, 'Compra para cancelar', 95001);
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (95002, 95002, 2, 70000);
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 95002; --antes: stock 5
UPDATE COMPRAS SET estado_compra = 'Cancelada' WHERE id_compra = 95002;
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 95002; --verificar stock 3
SELECT id_compra, estado_compra FROM COMPRAS WHERE id_compra = 95002; --verificar Cancelada


-- Prueba 16: Registrar venta, adicionar
-- Si no se indica la ubicacion de entrega, se usa la principal del cliente. El estado queda 'Pendiente'.
INSERT INTO VENTAS (id_venta, metodo_pago, medio_entrega, observaciones, id_cliente, id_ubicacion)
    VALUES (95001, 'Transferencia', 'Domicilio', NULL, 95001, NULL);
SELECT id_venta, estado_venta, id_ubicacion FROM VENTAS WHERE id_venta = 95001; --verificar Pendiente y ubicacion 95002


-- Prueba 17: Registrar venta, adicionar
-- Se puede indicar otra ubicacion, siempre que sea del mismo cliente.
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (95005, 'Calle 26 #68-35', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, 95001);
INSERT INTO VENTAS (id_venta, metodo_pago, medio_entrega, observaciones, id_cliente, id_ubicacion)
    VALUES (95002, 'Efectivo', 'Paqueteria', NULL, 95001, 95005);
SELECT id_venta, id_ubicacion FROM VENTAS WHERE id_venta = 95002; --verificar ubicacion 95005


-- Prueba 18: Registrar venta, adicionar productos
-- El stock se descuenta y, si llega a cero, el producto queda 'Agotado'.
SELECT id_producto, stock, estado FROM PRODUCTOS WHERE id_producto IN (95001, 95002) ORDER BY id_producto; --antes: 95001 stock 5, 95002 stock 3
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (95001, 95001, 2, 180000, 10000);
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (95002, 95002, 3, 125000, NULL);
SELECT id_producto, stock, estado FROM PRODUCTOS WHERE id_producto IN (95001, 95002) ORDER BY id_producto; --verificar 95001 stock 3 Disponible y 95002 stock 0 Agotado


-- Prueba 19: Registrar venta, modificar
-- El estado pasa de 'Pendiente' a 'Completada'.
UPDATE VENTAS SET estado_venta = 'Completada' WHERE id_venta = 95001;
SELECT id_venta, estado_venta FROM VENTAS WHERE id_venta = 95001; --verificar Completada


-- Prueba 20: Registrar venta, modificar
-- Al cancelar la venta, las unidades vendidas vuelven al stock.
UPDATE VENTAS SET estado_venta = 'Cancelada' WHERE id_venta = 95002;
SELECT id_venta, estado_venta FROM VENTAS WHERE id_venta = 95002; --verificar Cancelada
SELECT id_producto, stock, estado FROM PRODUCTOS WHERE id_producto = 95002; --verificar stock 3 y Disponible


-- Prueba 21: Registrar factura, adicionar (venta)
-- El total se calcula con los productos de la venta: 2 * 180000 - 10000 = 350000.
-- El total que se inserta (1) es provisional y lo reemplaza el disparador.
INSERT INTO FACTURAS (id_factura, total, observaciones)
    VALUES (95001, 1, NULL);
INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
    VALUES (95001, 95001, 'GUIA-95001');
SELECT id_factura, total, estado_factura, fecha_emision FROM FACTURAS WHERE id_factura = 95001; --verificar total 350000, Emitida y fecha de hoy


-- Prueba 22: Registrar factura, adicionar (compra)
-- El total se calcula con los productos de la compra: 5 * 100000 = 500000.
INSERT INTO FACTURAS (id_factura, total, observaciones)
    VALUES (95002, 1, NULL);
INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
    VALUES (95002, 95001, 'REM-95001');
SELECT id_factura, total FROM FACTURAS WHERE id_factura = 95002; --verificar total 500000


-- Prueba 23: Registrar factura, eliminar
-- Una factura no pagada se puede eliminar y su FACTURASCOMPRA se borra en cascada.
DELETE FROM FACTURAS WHERE id_factura = 95002;
SELECT * FROM FACTURASCOMPRA WHERE id_factura = 95002; --verificar que aparezcan 0 filas


-- Prueba 24: Registrar factura, modificar
-- Se puede cambiar el estado de la factura.
UPDATE FACTURAS SET estado_factura = 'Pagada' WHERE id_factura = 95001;
SELECT id_factura, estado_factura FROM FACTURAS WHERE id_factura = 95001; --verificar Pagada


-- Prueba 25: Mantener proveedor
-- Si se elimina la ubicacion del proveedor, queda sin ubicacion (la FK la pone en NULL).
DELETE FROM UBICACIONES WHERE id_ubicacion = 95004;
SELECT id_proveedor, id_ubicacion FROM PROVEEDORES WHERE id_proveedor = 95001; --verificar que id_ubicacion aparezca en NULL

--chao pruebas
ROLLBACK;
SELECT COUNT(*) FROM CLIENTES WHERE id_cliente >= 95001; --verificar 0: la base quedo como antes
--si aplicamos transacciones