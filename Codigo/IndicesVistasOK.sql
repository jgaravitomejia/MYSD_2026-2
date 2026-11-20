-- Pruebas vistas 
--Vista 1
SELECT * FROM vw_vendedor_productos_disponibles LIMIT 5;

--Vista 2
SELECT * FROM vw_vendedor_ventas LIMIT 5;

--Vista 3
SELECT * FROM vw_inventario_productos LIMIT 5;

--Vista 4
SELECT * FROM vw_inventario_proveedores LIMIT 5;

--Vista 5
SELECT * FROM vw_rentabilidad_categoria LIMIT 5;

--Vista 6
SELECT * FROM vw_inversion_vs_ingresos LIMIT 5;

--Vista 7
SELECT * FROM vw_productos_mas_vendidos LIMIT 5;

--Vista 8
SELECT * FROM vw_ventas_por_metodo_pago LIMIT 5;

--Vista 9
SELECT * FROM vw_ranking_clientes LIMIT 5;


-- Pruebas indices
-- EXPLAIN muestra el plan de ejecucion. si aparece "Index Scan" significa que se está utilizando un índice.

-- Indice idx_ventas_id_cliente
EXPLAIN SELECT * FROM VENTAS WHERE id_cliente = 1;

--Indice idx_compras_id_proveedor
EXPLAIN SELECT * FROM COMPRAS WHERE id_proveedor = 1;

-- Indice idx_detallesventas_id_producto
EXPLAIN SELECT * FROM DETALLESDEVENTAS WHERE id_producto = 1;

-- Indice idx_detallescompras_id_producto
EXPLAIN SELECT * FROM DETALLESDECOMPRAS WHERE id_producto = 1;

-- Indice idx_facturasventa_id_venta
EXPLAIN SELECT * FROM FACTURASVENTA WHERE id_venta = 1;

-- Indice idx_facturascompra_id_compra
EXPLAIN SELECT * FROM FACTURASCOMPRA WHERE id_compra = 1;

-- Indice idx_productos_estado
EXPLAIN SELECT * FROM PRODUCTOS WHERE estado = 'Disponible';

-- Indice idx_ventas_estado_venta
EXPLAIN SELECT * FROM VENTAS WHERE estado_venta = 'Completada';

-- Indice idx_compras_estado_compra
EXPLAIN SELECT * FROM COMPRAS WHERE estado_compra = 'Recibida';

-- Indice idx_factura_estado_fractura
EXPLAIN SELECT * FROM FACTURAS WHERE estado_factura = 'Pagada';

-- Indice idx_venta_fecha_venta
EXPLAIN SELECT EXTRACT(YEAR FROM fecha_venta), COUNT(*) FROM VENTAS GROUP BY EXTRACT(YEAR FROM fecha_venta);

-- Indice idx_compra_fecha_compra
EXPLAIN SELECT EXTRACT(YEAR FROM fecha_compra), COUNT(*) FROM COMPRAS GROUP BY EXTRACT(YEAR FROM fecha_compra);

-- Indice idx_ventas_metodo_pago
EXPLAIN SELECT metodo_pago, COUNT(*) FROM VENTAS GROUP BY metodo_pago;
