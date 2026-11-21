-- Atributos
-- Restricciones de un unico atributo que no corresponden a un tipo
-- los tipos TTelefono, TCorreo, TPrecio y TDescuento estan en Dominios

-- Stock no puede ser negativo
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_STOCK
    CHECK (stock >= 0);

-- Cantidades en detalles siempre positivas
ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT CK_DETALLESCOMPRA_CANTIDAD
    CHECK (cantidad > 0);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_CANTIDAD
    CHECK (cantidad > 0);