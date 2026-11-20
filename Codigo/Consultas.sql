-- Consultas operativas

--Consulta 1: Productos disponibles por categoría (todos)
-- Muestra todos los productos con estado 'Disponible', indicando si es ropa, calzado o accesorio y su categoría.
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


-- Consulta 2: Estado de una venta (Administrador y Vendedor)
-- Dado un id_venta, muestra su estado, los productos vendidos y si tiene factura
SELECT v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago, v.medio_entrega, cl.nombre AS cliente, dv.id_producto, p.nombre AS producto, dv.cantidad, dv.precio_venta, dv.descuento, f.id_factura, f.estado_factura
FROM VENTAS v
JOIN CLIENTES cl ON v.id_cliente = cl.id_cliente
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
JOIN PRODUCTOS p ON dv.id_producto = p.id_producto
LEFT JOIN FACTURASVENTA fv ON v.id_venta = fv.id_venta                      
LEFT JOIN FACTURAS f ON fv.id_factura = f.id_factura
WHERE v.id_venta = 2;


-- Consulta 3: Ventas de un cliente (Administrador y Vendedor)
-- Dado un id_cliente, muestra todas sus ventas con el total de cada una
SELECT v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago, SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS total_venta
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.id_cliente = 2
GROUP BY v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago
ORDER BY v.fecha_venta DESC;


-- Consulta 4: Productos de un proveedor (Administrador y Encargado inventario)
-- Dado un id_proveedor, muestra los productos que se le han comprado
SELECT DISTINCT p.id_producto, p.nombre, p.precio_referencia, p.stock, p.estado, p.marca
FROM COMPRAS co
JOIN DETALLESDECOMPRAS dc ON co.id_compra = dc.id_compra
JOIN PRODUCTOS p ON dc.id_producto = p.id_producto
WHERE co.id_proveedor = 2
ORDER BY p.nombre;



-- Consulta 5: Detalle de un proveedor (Administrador y Encargado inventario)
-- Dado un id_proveedor, muestra su s datos de contacto y cuantas compras de le han hecho
SELECT pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, pr.fecha_registro, COUNT(co.id_compra) AS total_compras
FROM PROVEEDORES pr
LEFT JOIN COMPRAS co ON pr.id_proveedor = co.id_proveedor
WHERE pr.id_proveedor = 2
GROUP BY pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, pr.fecha_registro;


--Consultas Gerenciales (Administrador)
-- Consulta 6: Rentabilidad por categoria 
-- Muestra cuanto se vendio de cada tipo de producto
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
HAVING CASE
    WHEN r.id_producto IS NOT NULL THEN r.categoria_ropa
    WHEN c.id_producto IS NOT NULL THEN c.categoria_calzado
    WHEN a.id_producto IS NOT NULL THEN a.categoria
END IS NOT NULL
ORDER BY ingresos DESC;


-- Consulta 7: Inversion vs ingresos por mes
-- Compara cuanto se gasto en compras versus cuanto se gano en ventas por mes
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


--Consulta 8: Productos mas vendidos
-- Muestra los 10 productos con mas unidades vendidas
SELECT p.id_producto, p.nombre, p.marca,SUM(dv.cantidad) AS unidades_vendidas, SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS ingresos_generados
FROM DETALLESDEVENTAS dv
JOIN PRODUCTOS p ON dv.id_producto = p.id_producto
JOIN VENTAS v ON dv.id_venta = v.id_venta
WHERE v.estado_venta <> 'Cancelada'
GROUP BY p.id_producto, p.nombre, p.marca
ORDER BY unidades_vendidas DESC
LIMIT 10;


--Consulta 9: Ventas por metodo de pago
-- Muestra cuantas ventas y cuanto se recibio por cada metodo de pago
SELECT v.metodo_pago,
       COUNT(DISTINCT v.id_venta) AS total_ventas,
       SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS ingresos
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada'
GROUP BY v.metodo_pago
ORDER BY total_ventas DESC;


--Consulta 10: Ranking de clientes
-- Muestra los 10 clientes con mas compras (por monto total)
SELECT cl.id_cliente, cl.nombre, cl.correo, SUM(dv.precio_venta * dv.cantidad - COALESCE(dv.descuento, 0)) AS total_gastado
FROM CLIENTES cl
JOIN VENTAS v ON cl.id_cliente = v.id_cliente
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada'
GROUP BY cl.id_cliente, cl.nombre, cl.correo
ORDER BY total_gastado DESC
LIMIT 10;