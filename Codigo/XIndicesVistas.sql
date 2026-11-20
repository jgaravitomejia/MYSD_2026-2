-- Indices 
DROP INDEX IF EXISTS idx_compras_id_proveedor;
DROP INDEX IF EXISTS idx_detallesdecompras_id_producto;
DROP INDEX IF EXISTS idx_ventas_id_cliente;
DROP INDEX IF EXISTS idx_detallesventas_id_producto;
DROP INDEX IF EXISTS idx_facturasventa_id_venta;
DROP INDEX IF EXISTS idx_facturascompra_id_compra;
DROP INDEX IF EXISTS idx_productos_estado;
DROP INDEX IF EXISTS idx_ventas_estado_venta;
DROP INDEX IF EXISTS idx_compras_estado_compra;
DROP INDEX IF EXISTS idx_facturas_estado_factura;
DROP INDEX IF EXISTS idx_ventas_metodo_pago;
DROP INDEX IF EXISTS idx_ventas_fecha_venta;
DROP INDEX IF EXISTS idx_compras_fecha_compra;

-- Vistas 
DROP VIEW IF EXISTS vw_vendedor_productos_disponibles;
DROP VIEW IF EXISTS vw_vendedor_ventas;
DROP VIEW IF EXISTS vw_inventario_productos;
DROP VIEW IF EXISTS vw_inventario_proveedores;
DROP VIEW IF EXISTS vw_rentabilidad_categoria;
DROP VIEW IF EXISTS vw_inversion_vs_ingresos;
DROP VIEW IF EXISTS vw_productos_mas_vendidos;
DROP VIEW IF EXISTS vw_ventas_por_metodo_pago;
DROP VIEW IF EXISTS vw_ranking_clientes;