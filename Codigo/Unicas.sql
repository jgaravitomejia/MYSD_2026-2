-- Unicas

-- Clientes: dos clientes no pueden tener el mismo correo
ALTER TABLE CLIENTES
    ADD CONSTRAINT UK_CLIENTES_CORREO UNIQUE (correo);

-- Proveedores: dos proveedores no pueden tener el mismo correo
ALTER TABLE PROVEEDORES
    ADD CONSTRAINT UK_PROVEEDORES_CORREO UNIQUE (correo);

-- Proveedores: una ubicacion es de maximo un proveedor 
ALTER TABLE PROVEEDORES
    ADD CONSTRAINT UK_PROVEEDORES_UBICACION UNIQUE (id_ubicacion);

-- Facturas de venta: una venta tiene maximo una factura 
ALTER TABLE FACTURASVENTA
    ADD CONSTRAINT UK_FACTURASVENTA_VENTA UNIQUE (id_venta);

-- Facturas de compra: una compra tiene maximo una factura
ALTER TABLE FACTURASCOMPRA
    ADD CONSTRAINT UK_FACTURASCOMPRA_COMPRA UNIQUE (id_compra);