-- PoblarNoOK. Ciclo 1.
-- Intentos de ingreso de datos erroneos. TODOS deben fallar.
-- Se protegen por: tipos (Dominios), atributos, nulidades, claves primarias, unicas y foraneas.
-- Se ejecuta despues de PoblarOK (usa datos que ya existen: cliente 1, venta 1, proveedor 1, etc.).
-- Al lado de cada caso esta la restriccion que lo rechaza.



-- 1. TIPOS (Dominios)


-- TTelefono: menos de 7 caracteres                              -> CK_CLIENTES_TELEFONO
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
VALUES (90001, 'Cliente Prueba', '12345', NULL, '2026-01-10 10:00:00', NULL);

-- TCorreo: correo sin '@'                                       -> CK_CLIENTES_CORREO
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
VALUES (90002, 'Cliente Prueba', '3001234567', 'correo.sin.arroba.com', '2026-01-10 10:00:00', NULL);

-- TCorreo: correo sin '.' despues de la '@'                     -> CK_PROVEEDORES_CORREO
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion)
VALUES (90001, 'Proveedor Prueba', '6011234567', 'ventas@proveedor', '2026-01-10 10:00:00', NULL);

-- TPrecio: precio de referencia en cero                         -> CK_PRODUCTOS_PRECIOREFERENCIA
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (90001, 'Camisa Prueba', NULL, 0, NULL, 10, 'Disponible', '2026-01-10 10:00:00', NULL);

-- TEstadoProducto: estado que no existe                         -> CK_PRODUCTOS_ESTADO
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (90002, 'Camisa Prueba', NULL, 50000, NULL, 10, 'Vendido', '2026-01-10 10:00:00', NULL);

-- TGenero: genero que no existe                                 -> CK_ROPA_GENERO
INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
VALUES (3, 'M', 'Masculino', 'Camisa', NULL);

-- TTallaRopa: talla que no existe                               -> CK_ROPA_TALLA
INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
VALUES (3, 'XXXL', 'Hombre', 'Camisa', NULL);

-- TRopa: categoria de ropa que no existe                        -> CK_ROPA_CATEGORIA
INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
VALUES (3, 'M', 'Hombre', 'Corbata', NULL);

-- TTallaCalzado: talla impar de niño (solo pares de 18 a 34)    -> CK_CALZADO_TALLA
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (1, 21, 'Niño', 'Zapatilla', NULL);

-- TTallaCalzado: talla fuera de rango                           -> CK_CALZADO_TALLA
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (1, 48, 'Hombre', 'Bota', NULL);

-- TCalzado: categoria de calzado que no existe                  -> CK_CALZADO_CATEGORIA
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
VALUES (1, 38, 'Mujer', 'Pantufla', NULL);

-- TAccesorio: categoria de accesorio que no existe              -> CK_ACCESORIOS_CATEGORIA
INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones)
VALUES (12, 'Sombrero', NULL, NULL);

-- TMetodoPago: metodo de pago no aceptado                       -> CK_VENTAS_METODOPAGO
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90001, '2026-11-01 10:00:00', 'Tarjeta', 'Pendiente', 'Domicilio', NULL, 1, 1);

-- TMedioEntrega: medio de entrega no aceptado                   -> CK_VENTAS_MEDIOENTREGA
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90002, '2026-11-01 10:00:00', 'Efectivo', 'Pendiente', 'Recoger en tienda', NULL, 1, 1);

-- TEstadoVenta: estado que ya no existe                         -> CK_VENTAS_ESTADOVENTA
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90003, '2026-11-01 10:00:00', 'Efectivo', 'En devolucion', 'Domicilio', NULL, 1, 1);

-- TEstadoCompra: estado que ya no existe                        -> CK_COMPRAS_ESTADOCOMPRA
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
VALUES (90001, '2026-11-01 10:00:00', 'Parcial', NULL, 1);

-- TEstadoFactura: estado que no existe                          -> CK_FACTURAS_ESTADOFACTURA
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
VALUES (90001, '2026-11-01 10:00:00', 100000, 'Pendiente', NULL);

-- TPrecio: total de factura en cero                             -> CK_FACTURAS_TOTAL
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
VALUES (90002, '2026-11-01 10:00:00', 0, 'Emitida', NULL);

-- TDescuento: descuento negativo                                -> CK_DETALLESVENTA_DESCUENTO
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (1, 1, 1, 50000, -500);



-- 2. ATRIBUTOS


-- Stock negativo                                                -> CK_PRODUCTOS_STOCK
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (90003, 'Camisa Prueba', NULL, 50000, NULL, -5, 'Disponible', '2026-01-10 10:00:00', NULL);

-- Cantidad comprada en cero                                     -> CK_DETALLESCOMPRA_CANTIDAD
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
VALUES (1, 1, 0, 30000);



-- 3. NULIDADES (NOT NULL)


-- Cliente sin nombre                                            -> NOT NULL en CLIENTES.nombre
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
VALUES (90003, NULL, '3001234567', NULL, '2026-01-10 10:00:00', NULL);

-- Ubicacion sin ciudad                                          -> NOT NULL en UBICACIONES.ciudad
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
VALUES (90001, 'Calle 1 #2-3', NULL, NULL, 'Cundinamarca', NULL, FALSE, 1);

-- Producto sin precio                                           -> NOT NULL en PRODUCTOS.precio_referencia
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
VALUES (90004, 'Camisa Prueba', NULL, NULL, NULL, 10, 'Disponible', '2026-01-10 10:00:00', NULL);

-- Venta sin cliente                                             -> NOT NULL en VENTAS.id_cliente
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90004, '2026-11-01 10:00:00', 'Efectivo', 'Pendiente', 'Domicilio', NULL, NULL, 1);

-- Venta sin direccion de entrega                                -> NOT NULL en VENTAS.id_ubicacion
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90005, '2026-11-01 10:00:00', 'Efectivo', 'Pendiente', 'Domicilio', NULL, 1, NULL);



-- 4. CLAVES PRIMARIAS


-- Cliente con un id que ya existe                               -> PK_CLIENTES
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
VALUES (1, 'Cliente Repetido', '3001234567', NULL, '2026-01-10 10:00:00', NULL);

-- Mismo producto dos veces en la misma venta (llave compuesta)  -> PK_DETALLESDEVENTAS
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (1, 433, 1, 50000, NULL);



-- 5. CLAVES UNICAS


-- Correo de cliente repetido                                    -> UK_CLIENTES_CORREO
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
VALUES (90004, 'Paula Ramirez', '3001234567', 'paula.ramirez1@outlook.com', '2026-01-10 10:00:00', NULL);

-- Correo de proveedor repetido                                  -> UK_PROVEEDORES_CORREO
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion)
VALUES (90002, 'Proveedor Prueba', '6011234567', 'ventas1@distribuciones.co', '2026-01-10 10:00:00', NULL);

-- Dos proveedores con la misma ubicacion                        -> UK_PROVEEDORES_UBICACION
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion)
VALUES (90003, 'Proveedor Prueba', '6011234567', NULL, '2026-01-10 10:00:00', 1102);

-- Segunda factura para una venta que ya tiene factura           -> UK_FACTURASVENTA_VENTA
INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
VALUES (1013, 1, NULL);

-- Segunda factura para una compra que ya tiene factura          -> UK_FACTURASCOMPRA_COMPRA
INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
VALUES (1, 1, NULL);



-- 6. CLAVES FORANEAS


-- Ubicacion de un cliente que no existe                         -> FK_UBICACIONES_CLIENTES
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
VALUES (90002, 'Calle 1 #2-3', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE, 99999);

-- Proveedor con una ubicacion que no existe                     -> FK_PROVEEDORES_UBICACIONES
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion)
VALUES (90004, 'Proveedor Prueba', '6011234567', NULL, '2026-01-10 10:00:00', 99999);

-- Ropa de un producto que no existe                             -> FK_ROPA_PRODUCTOS
INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
VALUES (99999, 'M', 'Mujer', 'Blusa', NULL);

-- Compra a un proveedor que no existe                           -> FK_COMPRAS_PROVEEDORES
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
VALUES (90002, '2026-11-01 10:00:00', 'Recibida', NULL, 99999);

-- Venta a un cliente que no existe                              -> FK_VENTAS_CLIENTES
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90006, '2026-11-01 10:00:00', 'Efectivo', 'Pendiente', 'Domicilio', NULL, 99999, 1);

-- Venta entregada en una ubicacion que no existe                -> FK_VENTAS_UBICACIONES
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion)
VALUES (90007, '2026-11-01 10:00:00', 'Efectivo', 'Pendiente', 'Domicilio', NULL, 1, 99999);

-- Detalle de una venta que no existe                            -> FK_DETALLESVENTA_VENTAS
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (99999, 1, 1, 50000, NULL);

-- Detalle de venta con un producto que no existe                -> FK_DETALLESVENTA_PRODUCTOS
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
VALUES (1, 99999, 1, 50000, NULL);

-- Detalle de compra con un producto que no existe               -> FK_DETALLESCOMPRA_PRODUCTOS
INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
VALUES (1, 99999, 5, 30000);

-- Factura de venta de una venta que no existe                   -> FK_FACTURASVENTA_VENTAS
INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
VALUES (1013, 99999, NULL);

-- Factura de compra de una factura que no existe                -> FK_FACTURASCOMPRA_FACTURAS
INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
VALUES (99999, 14, NULL);
