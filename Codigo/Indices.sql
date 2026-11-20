-- Indices en FK (joins)
CREATE INDEX idx_compras_id_proveedor ON COMPRAS(id_proveedor);
CREATE INDEX idx_detallesdecompras_id_producto ON DETALLESDECOMPRAS(id_producto);
CREATE INDEX idx_ventas_id_cliente ON VENTAS(id_cliente);
CREATE INDEX idx_detallesventas_id_producto ON DETALLESDEVENTAS(id_producto);
CREATE INDEX idx_facturasventa_id_venta ON FACTURASVENTA(id_venta);
CREATE INDEX idx_facturascompra_id_compra ON FACTURASCOMPRA(id_compra);

--Indices coluimnas de filtro (where)
CREATE INDEX idx_productos_estado ON PRODUCTOS(estado);
CREATE INDEX idx_ventas_estado_venta ON VENTAS(estado_venta);
CREATE INDEX idx_compras_estado_compra ON COMPRAS(estado_compra);
CREATE INDEX idx_facturas_estado_factura ON FACTURAS(estado_factura);

--Indices en columnas de ordenamiento/agrupacion (order by/group by)
CREATE INDEX idx_ventas_metodo_pago ON VENTAS(metodo_pago);
CREATE INDEX idx_ventas_fecha_venta ON VENTAS(fecha_venta);
CREATE INDEX idx_compras_fecha_compra ON COMPRAS(fecha_compra);

-- No se crean otros por ser UK o PK