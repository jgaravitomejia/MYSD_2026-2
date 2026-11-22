--Indices

-- Las 5 consultas gerenciales filtran las ventas por rango de fechas
CREATE INDEX IX_VENTAS_FECHA ON VENTAS (fecha_venta);

-- CO4 y CG5 buscan las ventas de un cliente; tambien lo usa FK_VENTAS_CLIENTES al eliminar un cliente
CREATE INDEX IX_VENTAS_CLIENTE ON VENTAS (id_cliente);

-- tg_ubicaciones revisa si una ubicacion ya se uso en una venta antes de modificarla
CREATE INDEX IX_VENTAS_UBICACION ON VENTAS (id_ubicacion);

-- tg_ubicaciones y tg_ventas buscan la ubicacion principal del cliente; CG5 tambien la usa
CREATE INDEX IX_UBICACIONES_CLIENTE ON UBICACIONES (id_cliente);

-- La PK de DETALLESDEVENTAS empieza por id_venta y no sirve para buscar por producto (CG3)
CREATE INDEX IX_DETALLESDEVENTAS_PRODUCTO ON DETALLESDEVENTAS (id_producto);

-- Igual que el anterior; lo usa el costo promedio de compra de cada producto (CG1)
CREATE INDEX IX_DETALLESDECOMPRAS_PRODUCTO ON DETALLESDECOMPRAS (id_producto);

-- CO1 y CO2 buscan las compras de un proveedor
CREATE INDEX IX_COMPRAS_PROVEEDOR ON COMPRAS (id_proveedor);