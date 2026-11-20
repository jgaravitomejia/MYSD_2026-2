-- DisparadoresNoOK

--Prueba
-- Intentamos vender 1000 unidades cuando solo hay 12.
-- Debe fallar porque el trigger tg_descontar_stock_venta lanza EXCEPTION por stock insuficiente.
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (92010, 92010, 1000, 60000.00, NULL);

--Prueba: facturar venta canjcelada -> debe fallar por tg_validar_venta_facturable
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (92011, '2024-06-01 14:00:00', 'Efectivo', 'Cancelada', 'Domicilio', NULL, 92010);
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (92013, '2024-06-01 14:30:00', 60000.00, 'Emitida', NULL);
INSERT INTO FACTURASVENTA(id_factura, id_venta, numero_guia)
    VALUES (92013, 92011, 'GUIA-92014');

--Prueba: facturar compra cancelada -> debe fallar por tg_validar_compra_facturable
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
    VALUES (92011, '2026-05-15 15:00:00', 'Cancelada', NULL, 92010);
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (92014, '2026-05-15 15:30:00', 400000.00, 'Emitida', NULL);
INSERT INTO FACTURASCOMPRA(id_factura, id_compra, numero_remision)
    VALUES (92014, 92011, 'REM-92014');

--Prueba: eliminar cliente con ventas -> debe fallar por tg_validar_eliminacion_cliente
DELETE FROM CLIENTES WHERE id_cliente = 92010;

--Prueba: modificar factura que ya esta pagada -> debe fallar por tg_validar_modificacion_factura
--la factura 92010 ya fue pagada en la prueba 8 de DisparadoresOk, por lo que no se puede modificar
UPDATE FACTURAS SET estado_factura = 'Anulada' WHERE id_factura = 92010;

--Prueba: cancelar compra cuando no hay stock suficiente para retirar -> debe fallar por tg_cancelar_compra_retira_stock
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
    VALUES (92012, '2026-06-02 10:00:00', 'Recibida', NULL, 92010);
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (92012, 92010, 9999, 30000.00);
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (92012, '2026-06-02 11:00:00', 'Efectivo', 'Completada', 'Tienda', NULL, 92010);
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (92012, 92010, 10000, 60000.00, NULL);
UPDATE COMPRAS SET estado_compra = 'Cancelada' WHERE id_compra = 92012;