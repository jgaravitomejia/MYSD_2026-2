--DisparadoresNoOK
-- Cada prueba debe fallar con el codigo indicado en su comentario.
-- Cada prueba es una transaccion: BEGIN, (datos que necesite), la instruccion que falla y ROLLBACK.
-- Como la instruccion falla, el ROLLBACK deshace todo y la base queda igual (atomicidad: o todo o nada).
-- Las pruebas usan los datos de PoblarOK; las subconsultas buscan una fila que cumpla el caso.


-- Prueba 1: Mantener ubicacion, modificar
-- Una ubicacion no puede pasar a ser de otro cliente.
BEGIN;
UPDATE UBICACIONES SET id_cliente = 2
    WHERE id_ubicacion = (SELECT MIN(id_ubicacion) FROM UBICACIONES WHERE id_cliente = 1); --error esperado: A0001
ROLLBACK;


-- Prueba 2: Mantener ubicacion, modificar
-- No se pueden modificar los datos de una ubicacion que ya se uso en una venta.
BEGIN;
UPDATE UBICACIONES SET calle = 'Calle 99 #9-99'
    WHERE id_ubicacion = (SELECT MIN(id_ubicacion) FROM VENTAS); --error esperado: A0002
ROLLBACK;


-- Prueba 3: Mantener ubicacion, modificar
-- La principal no se desmarca directamente; se debe marcar otra como principal.
BEGIN;
UPDATE UBICACIONES SET es_principal = FALSE
    WHERE id_ubicacion = (SELECT MIN(id_ubicacion) FROM UBICACIONES WHERE es_principal); --error esperado: A0003
ROLLBACK;


-- Prueba 4: Mantener ubicacion, eliminar
-- No se puede eliminar la ubicacion principal del cliente.
BEGIN;
DELETE FROM UBICACIONES
    WHERE id_ubicacion = (SELECT MIN(id_ubicacion) FROM UBICACIONES WHERE es_principal); --error esperado: A0004
ROLLBACK;


-- Prueba 5: Mantener cliente, modificar
-- Del cliente solo se pueden modificar el nombre y el telefono.
BEGIN;
UPDATE CLIENTES SET correo = 'nuevo1@mail.com' WHERE id_cliente = 1; --error esperado: A0005
ROLLBACK;


-- Prueba 6: Mantener proveedor, modificar
-- Del proveedor solo se pueden modificar el nombre y el telefono.
BEGIN;
UPDATE PROVEEDORES SET correo = 'nuevo1@proveedor.co' WHERE id_proveedor = 1; --error esperado: A0006
ROLLBACK;

-- Tampoco se puede cambiar su ubicacion.
BEGIN;
UPDATE PROVEEDORES SET id_ubicacion = NULL WHERE id_proveedor = 1; --error esperado: A0006
ROLLBACK;


-- Prueba 7: Mantener producto, modificar
-- Del producto solo se pueden modificar el precio de referencia y el stock.
BEGIN;
UPDATE PRODUCTOS SET nombre = 'Nombre Cambiado' WHERE id_producto = 1; --error esperado: A0007
ROLLBACK;

-- El estado tampoco, porque es automatico.
BEGIN;
UPDATE PRODUCTOS SET estado = 'Descontinuado' WHERE id_producto = 1; --error esperado: A0007
ROLLBACK;


-- Prueba 8: Mantener producto, adicionar
-- Un producto solo puede ser de un tipo: se intenta registrar como accesorio un producto que ya es ropa.
BEGIN;
INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones)
    VALUES ((SELECT MIN(id_producto) FROM ROPA), 'Bolso', NULL, NULL); --error esperado: A0008
ROLLBACK;


-- Prueba 9: Registrar compra, modificar
-- La unica modificacion permitida es cancelar la compra.
BEGIN;
UPDATE COMPRAS SET observacion = 'Cambio' WHERE id_compra = 1; --error esperado: A0009
ROLLBACK;

-- Una compra cancelada no vuelve a 'Recibida'.
BEGIN;
UPDATE COMPRAS SET estado_compra = 'Recibida'
    WHERE id_compra = (SELECT MIN(id_compra) FROM COMPRAS WHERE estado_compra = 'Cancelada'); --error esperado: A0009
ROLLBACK;

-- Los productos de una compra no se cambian.
BEGIN;
UPDATE DETALLESDECOMPRAS SET cantidad = 10 WHERE id_compra = 1; --error esperado: A0009
ROLLBACK;

-- Los productos de una compra no se quitan.
BEGIN;
DELETE FROM DETALLESDECOMPRAS WHERE id_compra = 1; --error esperado: A0009
ROLLBACK;


-- Prueba 10: Registrar compra, modificar
-- No se puede cancelar una compra si sus unidades ya se vendieron
-- (se busca una compra con un producto cuyo stock actual es menor que lo que se compro).
BEGIN;
UPDATE COMPRAS SET estado_compra = 'Cancelada'
    WHERE id_compra = (SELECT MIN(c.id_compra)
                       FROM COMPRAS c
                       JOIN DETALLESDECOMPRAS d ON d.id_compra = c.id_compra
                       JOIN PRODUCTOS p ON p.id_producto = d.id_producto
                       WHERE c.estado_compra = 'Recibida' AND p.stock < d.cantidad); --error esperado: A0010
ROLLBACK;


-- Prueba 11: Registrar compra, eliminar
-- Las compras no se eliminan, se cancelan.
BEGIN;
DELETE FROM COMPRAS
    WHERE id_compra = (SELECT MIN(id_compra) FROM COMPRAS WHERE estado_compra = 'Cancelada'); --error esperado: A0011
ROLLBACK;


-- Prueba 12: Registrar compra, adicionar productos
-- El producto debe estar registrado como ropa, calzado o accesorio (96001 no tiene tipo).
BEGIN;
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
    VALUES (96001, 'Producto Sin Tipo', NULL, 50000, 'Pytar', 10, NULL);
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (1, 96001, 1, 30000); --error esperado: A0012
ROLLBACK;

-- Lo mismo al venderlo.
BEGIN;
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
    VALUES (96001, 'Producto Sin Tipo', NULL, 50000, 'Pytar', 10, NULL);
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES ((SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Pendiente'), 96001, 1, 50000, NULL); --error esperado: A0012
ROLLBACK;


-- Prueba 13: Registrar compra, adicionar productos
-- No se pueden agregar productos a una compra cancelada.
BEGIN;
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES ((SELECT MIN(id_compra) FROM COMPRAS WHERE estado_compra = 'Cancelada'),
            (SELECT MIN(id_producto) FROM ROPA), 1, 30000); --error esperado: A0013
ROLLBACK;


-- Prueba 14: Registrar venta, adicionar
-- La ubicacion de entrega debe ser una de las ubicaciones del cliente (se usa una del cliente 2).
BEGIN;
INSERT INTO VENTAS (id_venta, metodo_pago, medio_entrega, observaciones, id_cliente, id_ubicacion)
    VALUES (96001, 'Efectivo', 'Domicilio', NULL, 1,
            (SELECT MIN(id_ubicacion) FROM UBICACIONES WHERE id_cliente = 2)); --error esperado: A0014
ROLLBACK;


-- Prueba 15: Registrar venta, modificar
-- De la venta solo se puede modificar el estado.
BEGIN;
UPDATE VENTAS SET metodo_pago = 'Transferencia' WHERE id_venta = 1; --error esperado: A0015
ROLLBACK;

-- Los productos de una venta no se cambian.
BEGIN;
UPDATE DETALLESDEVENTAS SET cantidad = 1 WHERE id_venta = 1; --error esperado: A0015
ROLLBACK;

-- Los productos de una venta no se quitan.
BEGIN;
DELETE FROM DETALLESDEVENTAS WHERE id_venta = 1; --error esperado: A0015
ROLLBACK;


-- Prueba 16: Registrar venta, modificar
-- Una venta cancelada no puede cambiar de estado.
BEGIN;
UPDATE VENTAS SET estado_venta = 'Completada'
    WHERE id_venta = (SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Cancelada'); --error esperado: A0016
ROLLBACK;

-- Una venta completada no puede volver a 'Pendiente'.
BEGIN;
UPDATE VENTAS SET estado_venta = 'Pendiente'
    WHERE id_venta = (SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Completada'); --error esperado: A0016
ROLLBACK;


-- Prueba 17: Registrar venta, eliminar
-- Las ventas no se eliminan, se cancelan.
BEGIN;
DELETE FROM VENTAS
    WHERE id_venta = (SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Cancelada'); --error esperado: A0017
ROLLBACK;


-- Prueba 18: Registrar venta, adicionar productos
-- Solo se pueden agregar productos a una venta 'Pendiente' (se usa una venta completada).
BEGIN;
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES ((SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Completada'),
            (SELECT MIN(id_producto) FROM ROPA), 1, 50000, NULL); --error esperado: A0018
ROLLBACK;


-- Prueba 19: Registrar venta, adicionar productos
-- No se pueden vender mas unidades de las que hay en stock (se pide el stock mas 1).
BEGIN;
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES ((SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Pendiente'),
            (SELECT MIN(id_producto) FROM ROPA),
            (SELECT stock + 1 FROM PRODUCTOS WHERE id_producto = (SELECT MIN(id_producto) FROM ROPA)),
            50000, NULL); --error esperado: A0019
ROLLBACK;


-- Prueba 20: Registrar factura, modificar
-- Una factura pagada no se puede modificar.
BEGIN;
UPDATE FACTURAS SET estado_factura = 'Anulada'
    WHERE id_factura = (SELECT MIN(id_factura) FROM FACTURAS WHERE estado_factura = 'Pagada'); --error esperado: A0020
ROLLBACK;


-- Prueba 21: Registrar factura, modificar
-- De la factura solo se puede modificar el estado: el total no.
BEGIN;
UPDATE FACTURAS SET total = 999
    WHERE id_factura = (SELECT MIN(id_factura) FROM FACTURAS WHERE estado_factura = 'Emitida'); --error esperado: A0021
ROLLBACK;

-- Las observaciones tampoco.
BEGIN;
UPDATE FACTURAS SET observaciones = 'Cambio'
    WHERE id_factura = (SELECT MIN(id_factura) FROM FACTURAS WHERE estado_factura = 'Emitida'); --error esperado: A0021
ROLLBACK;

-- La factura no cambia de compra.
BEGIN;
UPDATE FACTURASCOMPRA SET numero_remision = 'REM-1'
    WHERE id_factura = (SELECT MIN(id_factura) FROM FACTURASCOMPRA); --error esperado: A0021
ROLLBACK;

-- La factura no se separa de su compra.
BEGIN;
DELETE FROM FACTURASCOMPRA
    WHERE id_factura = (SELECT MIN(id_factura) FROM FACTURASCOMPRA); --error esperado: A0021
ROLLBACK;


-- Prueba 22: Registrar factura, eliminar
-- Una factura pagada no se puede eliminar.
BEGIN;
DELETE FROM FACTURAS
    WHERE id_factura = (SELECT MIN(id_factura) FROM FACTURAS WHERE estado_factura = 'Pagada'); --error esperado: A0022
ROLLBACK;


-- Prueba 23: Registrar factura, adicionar
-- No se puede facturar una venta cancelada.
BEGIN;
INSERT INTO FACTURAS (id_factura, total, observaciones)
    VALUES (96001, 1, NULL);
INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
    VALUES (96001, (SELECT MIN(id_venta) FROM VENTAS WHERE estado_venta = 'Cancelada'), NULL); --error esperado: A0023
ROLLBACK;

-- Tampoco una venta sin productos (96001 se crea vacia).
BEGIN;
INSERT INTO VENTAS (id_venta, metodo_pago, medio_entrega, observaciones, id_cliente, id_ubicacion)
    VALUES (96001, 'Efectivo', 'Domicilio', NULL, 1, NULL);
INSERT INTO FACTURAS (id_factura, total, observaciones)
    VALUES (96001, 1, NULL);
INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
    VALUES (96001, 96001, NULL); --error esperado: A0023
ROLLBACK;


-- Prueba 24: Registrar factura, adicionar
-- No se puede facturar una compra cancelada.
BEGIN;
INSERT INTO FACTURAS (id_factura, total, observaciones)
    VALUES (96001, 1, NULL);
INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
    VALUES (96001, (SELECT MIN(id_compra) FROM COMPRAS WHERE estado_compra = 'Cancelada'), NULL); --error esperado: A0024
ROLLBACK;