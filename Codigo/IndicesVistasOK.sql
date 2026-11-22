--IndicesVistasOK


-- Consultas con vistas

-- CG1. Rentabilidad por categoria en los ultimos 6 meses (VW_LINEAS_VENTA, VW_PRODUCTOS_TIPO, VW_COSTO_PROMEDIO)
SELECT pt.tipo_producto, pt.categoria,
       SUM(lv.cantidad) AS unidades_vendidas,
       SUM(lv.subtotal) AS total_vendido,
       ROUND(SUM(lv.cantidad * COALESCE(cp.precio_compra_promedio, 0)), 2) AS costo_vendido,
       ROUND(SUM(lv.subtotal) - SUM(lv.cantidad * COALESCE(cp.precio_compra_promedio, 0)), 2) AS ganancia
FROM VW_LINEAS_VENTA lv
JOIN VW_PRODUCTOS_TIPO pt      ON lv.id_producto = pt.id_producto
LEFT JOIN VW_COSTO_PROMEDIO cp ON lv.id_producto = cp.id_producto
WHERE lv.fecha_venta >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY pt.tipo_producto, pt.categoria
ORDER BY ganancia DESC;

-- CG3. Los 10 productos mas vendidos en los ultimos 3 meses (VW_LINEAS_VENTA, VW_PRODUCTOS_TIPO)
SELECT pt.nombre AS nombre_producto, pt.marca, pt.tipo_producto, pt.categoria,
       SUM(lv.cantidad) AS unidades_vendidas,
       SUM(lv.subtotal) AS ingreso_total
FROM VW_LINEAS_VENTA lv
JOIN VW_PRODUCTOS_TIPO pt ON lv.id_producto = pt.id_producto
WHERE lv.fecha_venta >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY pt.id_producto, pt.nombre, pt.marca, pt.tipo_producto, pt.categoria
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- CG4. Ventas por metodo de pago del mes anterior (VW_LINEAS_VENTA)
SELECT lv.metodo_pago,
       COUNT(DISTINCT lv.id_venta) AS numero_ventas,
       SUM(lv.subtotal) AS total_ingresos
FROM VW_LINEAS_VENTA lv
WHERE DATE_TRUNC('month', lv.fecha_venta) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
GROUP BY lv.metodo_pago
ORDER BY total_ingresos DESC;

-- CG5. Los 5 clientes que mas compraron en el ultimo año (VW_LINEAS_VENTA, VW_CLIENTES_CONTACTO)
SELECT cc.nombre AS nombre_cliente, cc.ciudad,
       COUNT(DISTINCT lv.id_venta) AS numero_compras,
       SUM(lv.subtotal) AS monto_total
FROM VW_LINEAS_VENTA lv
JOIN VW_CLIENTES_CONTACTO cc ON lv.id_cliente = cc.id_cliente
WHERE lv.fecha_venta >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY cc.id_cliente, cc.nombre, cc.ciudad
ORDER BY monto_total DESC
LIMIT 5;

-- CO3. Productos disponibles por tipo y categoria (VW_PRODUCTOS_TIPO)
SELECT id_producto, nombre AS nombre_producto, marca, precio_referencia, stock, tipo_producto, categoria
FROM VW_PRODUCTOS_TIPO
WHERE estado = 'Disponible'
ORDER BY tipo_producto, categoria, nombre_producto;


-- Consultas con indices

-- CO4. Ventas de un cliente: usa IX_VENTAS_CLIENTE
EXPLAIN
SELECT id_venta, fecha_venta, estado_venta, metodo_pago
FROM VENTAS
WHERE id_cliente = 1;

-- Ventas del ultimo mes (filtro de las consultas gerenciales): usa IX_VENTAS_FECHA
EXPLAIN
SELECT id_venta, fecha_venta, metodo_pago
FROM VENTAS
WHERE fecha_venta >= CURRENT_DATE - INTERVAL '1 month';

-- Ubicacion principal de un cliente (la buscan tg_ventas y tg_ubicaciones): usa IX_UBICACIONES_CLIENTE
EXPLAIN
SELECT id_ubicacion
FROM UBICACIONES
WHERE id_cliente = 1 AND es_principal;

-- Ventas entregadas en una ubicacion (la revisa tg_ubicaciones): usa IX_VENTAS_UBICACION
EXPLAIN
SELECT id_venta
FROM VENTAS
WHERE id_ubicacion = 3;

-- Ventas de un producto (CG3 agrupa por producto): usa IX_DETALLESDEVENTAS_PRODUCTO
EXPLAIN
SELECT id_venta, cantidad
FROM DETALLESDEVENTAS
WHERE id_producto = 5;

-- Compras de un producto (VW_COSTO_PROMEDIO): usa IX_DETALLESDECOMPRAS_PRODUCTO
EXPLAIN
SELECT id_compra, precio_compra
FROM DETALLESDECOMPRAS
WHERE id_producto = 5;

-- Compras de un proveedor (CO1 y CO2): con solo 208 compras PostgreSQL prefiere leer la tabla completa
-- (Seq Scan) porque es mas rapido; IX_COMPRAS_PROVEEDOR se empieza a usar cuando la tabla crece.
EXPLAIN
SELECT id_compra, fecha_compra
FROM COMPRAS
WHERE id_proveedor = 1;