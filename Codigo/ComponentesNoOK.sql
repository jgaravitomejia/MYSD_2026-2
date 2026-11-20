-- Prueba T1
-- Prueba T1: vender más de lo que hay en stock
-- (producto 93012 tiene 29 unidades)
CALL adicionar_detalle_venta(93010, 93012, 1000, 35000.00, NULL);

-- Prueba T3: facturar venta cancelada (venta 93011 fue cancelada)
CALL adicionar_factura(93020, 'Pendiente', NULL);
CALL adicionar_factura_venta(93020, 93011, 'GUIA-NOOK-001');

-- Prueba T4: facturar compra cancelada (compra 93011 fue cancelada)
CALL adicionar_factura(93021, 'Pendiente', NULL);
CALL adicionar_factura_compra(93021, 93011, 'REM-NOOK-001');

-- Prueba T7: eliminar cliente con ventas
DELETE FROM CLIENTES WHERE id_cliente = 93010;

-- Prueba T8: modificar factura pagada
UPDATE FACTURAS SET estado_factura = 'Pagada' WHERE id_factura = 93010;
UPDATE FACTURAS SET observaciones = 'Intento modificar pagada' WHERE id_factura = 93010;

-- Prueba T8b: eliminar factura pagada
DELETE FROM FACTURAS WHERE id_factura = 93010;

-- Prueba T10: cancelar compra sin stock suficiente para retirar
CALL adicionar_compra(93012, NULL, 93010);
CALL adicionar_detalle_compra(93012, 93010, 9999, 30000.00);
-- stock sube a 38 + 9999 = 10037
CALL adicionar_venta(93012, 'Efectivo', 'Domicilio', NULL, 93010);
CALL adicionar_detalle_venta(93012, 93010, 10030, 50000.00, NULL);
-- stock baja a 10037 - 10030 = 7. Cancelar compra de 9999 -> no hay suficiente:
CALL cancelar_compra(93012);