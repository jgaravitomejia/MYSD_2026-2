--DisparadoresOK

--Datos de apoyo
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro)
    VALUES (92010, 'Proveedor Trigger', '6011234567', 'prov92010@mail.com', '2026-05-15 08:00:00');
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (92010, 'Cliente Trigger', '3009990009', 'cli92010@mail.com', '2026-05-15 09:00:00', NULL);
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (92010, 'Producto Trigger', NULL, 60000.00, 'Nike', 5, 'Disponible', '2026-05-15 09:00:00', NULL);
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
    VALUES (92010, '2026-05-15 10:00:00', 'Recibida', NULL, 92010);
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (92010, '2026-05-15 11:00:00', 'Efectivo', 'Completada', 'Domicilio', NULL, 92010);

-- Prueba 1: comprar 10 unidades -> el trigger sube el stock de 5 a 15
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (92010, 92010, 10, 40000.00);
--SELECT stock FROM PRODUCTOS WHERE id_producto = 92010; --verificacomos y debe dar 15

-- Prueba 2: vender 3 unidades -> el trigger baja el stock de 15 a 12
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (92010, 92010, 3, 60000.00, NULL);
--SELECT stock FROM PRODUCTOS WHERE id_producto = 92010; --verificamos y debe dar  12

--Prueba 3: facturar una venta completada -> debe pasar sin problemas
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (92010, '2026-05-15 12:00:00', 180000.00, 'Emitida', NULL);
INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
    VALUES (92010, 92010, 'GUIA-92010');

-- Prueba 4: facturar una compra recibida -> debe pasar sin problemas
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (92011, '2026-05-15 12:30:00', 400000.00, 'Emitida', NULL);
INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
    VALUES (92011, 92010, 'REM-92010');

-- Prueba 5: insertar factura sin fecha -> el trigger la rellena con NOW()
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (92012, NULL, 50000.00, 'Emitida', NULL);
--SELECT fecha_emision FROM FACTURAS WHERE id_factura = 92012; --verificamos y debe dar la fecha actual

-- Prueba 6: insertar cliente sin fecha_registro -> el trigger la rellena con NOW()
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (92011, 'Cliente Trigger 2', '3009990010', 'cli92011@mail.com', NULL, NULL);
--SELECT fecha_registro FROM CLIENTES WHERE id_cliente = 92011; --verificamos y debe dar la fecha actual

-- Prueba 7: eliminar cliente SIN ventas -> debe pasar sin problemas
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (92012, 'Cliente sin fecha', '3009990011', 'borrable92012@gmail.com', '2026-06-01 10:00:00', NULL);
DELETE FROM CLIENTES WHERE id_cliente = 92012;

-- Prueba 8: modificar una factura que NO esta pagada -> debe pasar sin problema
UPDATE FACTURAS SET estado_factura = 'Pagada' WHERE id_factura = 92010;

-- Prueba 9: cancelar venta -> devuelve stock (stock actual: 12, vendimos 2, queda 10, vuelve a 12)
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (92011, '2026-05-15 13:00:00', 'Efectivo', 'Completada', 'Domicilio', NULL, 92010);
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (92011, 92010, 2, 60000.00, NULL);
--SELECT stock FROM PRODUCTOS WHERE id_producto = 92010; --verificamos y debe dar 10
UPDATE VENTAS SET estado_venta = 'Cancelada' WHERE id_venta = 92011;
--SELECT stock FROM PRODUCTOS WHERE id_producto = 92010; --verificamos y debe dar 12

-- Prueba 10: cancelar compra -> retira stock (stock actual: 12, compramos 2, queda 14, vuelve a 12)
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
    VALUES (92011, '2026-05-15 13:30:00', 'Recibida', NULL, 92010);
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (92011, 92010, 5, 35000.00);
--SELECT stock FROM PRODUCTOS WHERE id_producto = 92010; --verificamos y debe dar 14
UPDATE COMPRAS SET estado_compra = 'Cancelada' WHERE id_compra = 92011;
--SELECT stock FROM PRODUCTOS WHERE id_producto = 92010; --verificamos y debe dar 12

--Prueba 11: el total de la factura de venta se calculo automaticamente 
--SELECT total FROM FACTURAS WHERE id_factura = 92010; --verificamos y debe dar el total calculado automaticamente

--Prueba 12: el total de la factura de compra se calculo automaticamente 
--SELECT total FROM FACTURAS WHERE id_factura = 92011; --verificamos y debe dar el total calculado automaticamente