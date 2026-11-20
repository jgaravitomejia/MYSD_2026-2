--TuplasNoOK
--Caso 1: producto marcado como 'Agotado', pero con stock de 20 unidades
--Debe fallar, si esta agotado el stock debe ser 0
--Restriccion que lo protege: CK_PRODUCTOS_ESTADOVSSTOCK
INSERT INTO PRODUCTOS(id_producto, nombre, descripcion, precio_referencia,marca,stock,estado,fecha_ingreso,imagen_url)
    VALUES(9002,'Gorra Roja',NULL,30000.00,'Nike',20,'Agotado', '2026-05-02 11:00:00',NULL);

-- Caso 2: descuento de 90000 mayor que el precio de venta 80000.
-- Debe fallar, no se puede descontar mas de lo que cuesta el producto.
-- Restriccion que lo protege: CK_DETALLESVENTA_DESCUENTOVSPRECIO
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (9001, 9001, 1, 80000.00, 90000.00);