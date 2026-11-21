-- TuplasOK

-- CK_PRODUCTOS_ESTADOVSSTOCK 

-- Producto 'Disponible' con stock mayor que 0
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (91001, 'Camisa Lino', NULL, 80000, 'Zara', 15, 'Disponible', '2026-05-01 11:00:00', NULL);

-- Producto 'Agotado' con stock en 0
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (91002, 'Bota Cuero', NULL, 220000, 'Bosi', 0, 'Agotado', '2026-05-01 11:00:00', NULL);

-- Producto 'Descontinuado' con stock mayor que 0 (aun quedan unidades por vender)
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (91003, 'Zapatilla Running', NULL, 180000, 'Nike', 4, 'Descontinuado', '2026-05-01 11:00:00', NULL);


-- CK_CALZADO_TALLAVSGENERO 

INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (91004, 'Sandalia Plana', NULL, 90000, NULL, 10, 'Disponible', '2026-05-01 11:00:00', NULL);
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (91005, 'Tenis Infantil', NULL, 70000, 'Puma', 10, 'Disponible', '2026-05-01 11:00:00', NULL);

-- Mujer, talla 41 (limite superior para mujer)
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (91002, 41, 'Mujer', 'Bota', 'Cuero genuino');

-- Hombre, talla 45 (limite superior para hombre)
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (91003, 45, 'Hombre', 'Zapatilla', 'Malla sintetica');

-- Unisex, talla 35 (limite inferior para unisex)
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (91004, 35, 'Unisex', 'Sandalia', NULL);

-- Niño, talla 24 (par entre 18 y 34)
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (91005, 24, 'Niño', 'Deportivo', 'Lona');


-- CK_UBICACIONES_PRINCIPAL --

-- Cliente de apoyo
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
VALUES (91001, 'Cliente Prueba', '3001112233', 'prueba91001@mail.com', '2026-05-01 10:00:00', NULL);

-- Ubicacion principal de un cliente
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
VALUES (91001, 'Calle 80 #15-20', 'Chapinero', 'Bogota', 'Cundinamarca', NULL, TRUE, 91001);

-- Segunda ubicacion del mismo cliente, no principal
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
VALUES (91002, 'Carrera 7 #45-10', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, 91001);

-- Ubicacion de un proveedor: sin cliente y no principal
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
VALUES (91003, 'Avenida 68 #10-05', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, NULL);


-- CK_DETALLESVENTA_DESCUENTOVSPRECIO

-- Venta de apoyo, entregada en la segunda ubicacion del cliente
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (91001, '2026-05-02 12:00:00', 'Efectivo', 'Completada', 'Domicilio', NULL, 91001, 91002);

-- Descuento menor que el precio
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (91001, 91001, 1, 80000, 10000);

-- Descuento igual al precio (limite permitido)
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (91001, 91004, 1, 90000, 90000);

-- Sin descuento
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (91001, 91005, 2, 70000, NULL);
--Usamos ids desde 91001 para no chocar con PoblarOK.