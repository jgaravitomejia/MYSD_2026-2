-- PoblarNoOK
-- Caso 1: producto con stock negativo.
-- Deberia fallar porque stock no puede ser menor a 0.
-- Pero entra, porque aun no se ha declarado la restriccion CHECK sobre stock.
--INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
--    VALUES (99, 'Producto invalido', NULL, 50000.00, NULL, -5, 'Disponible', '2026-04-01 10:00:00', NULL);

-- Caso 2: venta con metodo_pago invalido ('Bitcoin').
-- Deberia fallar porque metodo_pago solo puede ser Nequi, Daviplata, Efectivo o Transferencia.
-- Pero entra, porque aun no se ha declarado la restriccion CHECK sobre metodo_pago.
--INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
--    VALUES (99, '2026-04-01 10:00:00', 'Bitcoin', 'Completada', 'Domicilio', NULL, 1);

-- Caso 3: cliente con id duplicado (id=1 ya existe).
-- Deberia fallar porque id_cliente es llave primaria y no puede repetirse.
-- Pero entra, porque aun no se ha declarado la restriccion de que es una PK.
--INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
--    VALUES (1, 'Duplicado', '3000000000', 'dup@mail.co', '2026-04-01 10:00:00', NULL);
