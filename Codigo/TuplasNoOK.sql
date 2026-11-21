-- TuplasNoOK

-- CK_PRODUCTOS_ESTADOVSSTOCK
-- 'Agotado' pero con 20 unidades en stock                       --
CK_PRODUCTOS_ESTADOVSSTOCK
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (91101, 'Gorra Roja', NULL, 30000, 'Nike', 20, 'Agotado', '2026-05-02 11:00:00', NULL);

-- 'Disponible' pero sin unidades                                --
--CK_PRODUCTOS_ESTADOVSSTOCK
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (91102, 'Gorra Azul', NULL, 30000, 'Nike', 0, 'Disponible', '2026-05-02 11:00:00', NULL);

-- 'Descontinuado' sin unidades (sin stock debe quedar 'Agotado') 
-- CK_PRODUCTOS_ESTADOVSSTOCK
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (91103, 'Gorra Negra', NULL, 30000, 'Nike', 0, 'Descontinuado', '2026-05-02 11:00:00', NULL);


-- CK_CALZADO_TALLAVSGENERO

-- Mujer con talla 44 (mujer va de 35 a 41)                      
-- CK_CALZADO_TALLAVSGENERO
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (91001, 44, 'Mujer', 'Botin', NULL);

-- Hombre con talla 36 (hombre va de 38 a 45)                    --
-- CK_CALZADO_TALLAVSGENERO
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (91001, 36, 'Hombre', 'Moccasin', NULL);

-- Niña con talla 38 (niño o niña va de 18 a 34)                 --
-- CK_CALZADO_TALLAVSGENERO
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (91001, 38, 'Niña', 'Sandalia', NULL);

-- Unisex con talla 30 (unisex va de 35 a 45)                    
-- CK_CALZADO_TALLAVSGENERO
INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (91001, 30, 'Unisex', 'Chancla', NULL);


-- CK_UBICACIONES_PRINCIPAL

-- Ubicacion de proveedor (sin cliente) marcada como principal   
--CK_UBICACIONES_PRINCIPAL
INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
    VALUES (91101, 'Avenida 68 #10-05', NULL, 'Bogota', 'Cundinamarca', NULL, TRUE, NULL);


-- CK_DETALLESVENTA_DESCUENTOVSPRECIO 

-- Descuento de 90.000 sobre un precio de 80.000              
--  CK_DETALLESVENTA_DESCUENTOVSPRECIO
INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (91001, 91003, 1, 80000, 90000);