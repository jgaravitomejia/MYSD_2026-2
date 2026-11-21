--Tuplas
--El descuento nunca puede ser mayor que el precio de venta del producto 
ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_DESCUENTOVSPRECIO
    CHECK (descuento IS NULL OR descuento <= precio_venta);

--Un producto que este marcado como 'Agotado', no puede tener unidades en stock o viceversa
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_ESTADOVSSTOCK
    CHECK((estado = 'Agotado' AND stock=0) OR (estado <> 'Agotado' AND stock>0));

-- La talla de calzado debe ser valida para su genero (TTallaCalzado)
-- Mujer 35 a 41, Hombre 38 a 45, Unisex 35 a 45, Niño o Niña 18 a 34 (los pares los exige CK_CALZADO_TALLA)
ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_TALLAVSGENERO
    CHECK ((genero = 'Mujer'           AND talla BETWEEN 35 AND 41)
        OR (genero = 'Hombre'          AND talla BETWEEN 38 AND 45)
        OR (genero = 'Unisex'          AND talla BETWEEN 35 AND 45)
        OR (genero IN ('Niño', 'Niña') AND talla BETWEEN 18 AND 34)
    );

-- Solo las ubicaciones de un cliente pueden ser su ubicacion principal
-- (las ubicaciones de proveedores no tienen cliente y nunca son principales)
ALTER TABLE UBICACIONES
    ADD CONSTRAINT CK_UBICACIONES_PRINCIPAL
    CHECK (es_principal = FALSE OR id_cliente IS NOT NULL);