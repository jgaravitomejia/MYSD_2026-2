--Tuplas
--El descuento nunca puede ser mayor que el precio de venta del producto 
ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_DESCUENTOVSPRECIO
    CHECK (descuento IS NULL OR descuento <= precio_venta);

--Un producto que este marcado como 'Agotado', no puede tener unidades en stock o viceversa
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_ESTADOVSSTOCK
    CHECK((estado = 'Agotado' AND stock=0) OR (estado <> 'Agotado' AND stock>0));

