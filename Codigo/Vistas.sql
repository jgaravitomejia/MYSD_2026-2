--Vista 1: Productos disponibles para el vendedor 
-- Muestra lo que necesita para vender: nombre, precio, stock, marca y categoria
-- Oculta: precio_referencia, fecha_ingreso, imagen_url, descripcion
CREATE OR REPLACE VIEW vw_vendedor_productos_disponibles AS 
SELECT p.id_producto, p.nombre, p.precio_referencia, p.stock, p.marca, 
    CASE
        WHEN r.id_producto IS NOT NULL THEN 'Ropa'
        WHEN c.id_producto IS NOT NULL THEN 'Calzado'
        WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
    END AS tipo,
    CASE
        WHEN r.id_producto IS NOT NULL THEN r.categoria_ropa
        WHEN c.id_producto IS NOT NULL THEN c.categoria_calzado
        WHEN a.id_producto IS NOT NULL THEN a.categoria
    END AS categoria
FROM PRODUCTOS p
LEFT JOIN ROPA r ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a ON p.id_producto = a.id_producto
WHERE p.estado = 'Disponible'
ORDER BY tipo, categoria, p.nombre;


-- Vista 2: Ventas para el vendedor 
-- Muestra las ventas con clientre y estado, sin costos de compra ni datos financieros del negocio
-- Oculta: precio_referencia del producto y datos del proveedor
CREATE OR REPLACE VIEW vw_vendedor_ventas AS
SELECT v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago, v.medio_entrega, cl.nombre AS cliente, p.nombre AS producto, dv.cantidad, dv.precio_venta, dv.descuento
FROM VENTAS v
JOIN CLIENTES cl ON v.id_cliente = cl.id_cliente
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
JOIN PRODUCTOS p ON dv.id_producto = p.id_producto;


-- Vista 3: Productos con stock para el Encargado de inventario
-- Muestra stock, estado y categoria para gestionar inventario
-- Oculta: precio de venta, descuentos, datos de clientes
CREATE OR REPLACE VIEW vw_inventario_productos AS
SELECT p.id_producto, p.nombre, p.stock, p.estado, p.marca, p.fecha_ingreso,
    CASE
        WHEN r.id_producto IS NOT NULL THEN 'Ropa'
        WHEN c.id_producto IS NOT NULL THEN 'Calzado'
        WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
    END AS tipo,
    CASE
        WHEN r.id_producto IS NOT NULL THEN r.categoria_ropa
        WHEN c.id_producto IS NOT NULL THEN c.categoria_calzado
        WHEN a.id_producto IS NOT NULL THEN a.categoria
    END AS categoria
FROM PRODUCTOS p
LEFT JOIN ROPA r ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a ON p.id_producto = a.id_producto
ORDER BY tipo, categoria, p.nombre;


-- Vista 4: Proveedores con sus productos para el encargado de inventario
-- Muestra datos de contacto del proveedor y que productos suministra 
-- Oculta: precios de venta, datos de clientes, datos de ventas
CREATE OR REPLACE VIEW vw_inventario_proveedores AS
SELECT pr.id_proveedor, pr.nombre AS proveedor, pr.telefono, pr.correo, p.id_producto, p.nombre AS producto, p.stock, p.estado, dc.cantidad AS cantidad_comprada, dc.precio_compra
FROM PROVEEDORES pr
JOIN COMPRAS co ON pr.id_proveedor = co.id_proveedor
JOIN DETALLESDECOMPRAS dc ON co.id_compra = dc.id_compra
JOIN PRODUCTOS p ON dc.id_producto = p.id_producto
ORDER BY pr.nombre, p.nombre;


--Vista 5: Rentabilidad por categoria
CREATE OR REPLACE VIEW vw_rentabilidad_categoria AS
SELECT 
    CASE
        WHEN r.id_producto IS NOT NULL THEN r.categoria_ropa
        WHEN c.id_producto IS NOT NULL THEN c.categoria_calzado
        WHEN a.id_producto IS NOT NULL THEN a.categoria
    END AS tipo,
    COUNT(DISTINCT dv.id_venta) AS total_ventas,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS ingresos
FROM DETALLESDEVENTAS dv
JOIN PRODUCTOS p ON dv.id_producto = p.id_producto
LEFT JOIN ROPA r ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a ON p.id_producto = a.id_producto
GROUP BY tipo
ORDER BY ingresos DESC;


--Vista 6: Inversion vs ingresos 
CREATE OR REPLACE VIEW vw_inversion_vs_ingresos AS
SELECT
    EXTRACT(YEAR FROM fecha) AS anio,
    EXTRACT(MONTH FROM fecha) AS mes,
    COALESCE(SUM(gasto), 0) AS inversion,
    COALESCE(SUM(ingreso), 0) AS ingresos,
    COALESCE(SUM(ingreso), 0) - COALESCE(SUM(gasto), 0) AS ganancia
FROM (
    SELECT DATE_TRUNC('month', co.fecha_compra) AS fecha,
           SUM(dc.precio_compra * dc.cantidad) AS gasto,
           0 AS ingreso
    FROM COMPRAS co
    JOIN DETALLESDECOMPRAS dc ON co.id_compra = dc.id_compra
    WHERE co.estado_compra <> 'Cancelada'
    GROUP BY DATE_TRUNC('month', co.fecha_compra)

    UNION ALL

    SELECT DATE_TRUNC('month', v.fecha_venta) AS fecha,
           0 AS gasto,
           SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS ingreso
    FROM VENTAS v
    JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
    WHERE v.estado_venta <> 'Cancelada'
    GROUP BY DATE_TRUNC('month', v.fecha_venta)
) sub
GROUP BY anio, mes
ORDER BY anio, mes;


-- Vista 7: Productos mas vendidos 
CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT p.id_producto, p.nombre, p.marca,SUM(dv.cantidad) AS unidades_vendidas, SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS ingresos_generados
FROM DETALLESDEVENTAS dv
JOIN PRODUCTOS p ON dv.id_producto = p.id_producto
JOIN VENTAS v ON dv.id_venta = v.id_venta
WHERE v.estado_venta <> 'Cancelada'
GROUP BY p.id_producto, p.nombre, p.marca
ORDER BY unidades_vendidas DESC
LIMIT 10;


-- Vista 8: Ventas por metodo de pago
CREATE OR REPLACE VIEW vw_ventas_por_metodo_pago AS
SELECT v.metodo_pago,
       COUNT(DISTINCT v.id_venta) AS total_ventas,
       SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS ingresos
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada'
GROUP BY v.metodo_pago
ORDER BY total_ventas DESC;


-- Vista 9: Ranking clientes 
CREATE OR REPLACE VIEW vw_ranking_clientes AS
SELECT cl.id_cliente, cl.nombre, cl.correo, SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS total_gastado
FROM CLIENTES cl
JOIN VENTAS v ON cl.id_cliente = v.id_cliente
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada'
GROUP BY cl.id_cliente, cl.nombre, cl.correo
ORDER BY total_gastado DESC
LIMIT 10;
