-- Consultas. Ciclo 1.
-- CO = consultas operativas (1. Ciclo 1)   CG = consultas gerenciales (0. General)



-- CONSULTAS OPERATIVAS


-- CO1. Consultar detalle de un proveedor.
-- COMO administrador, QUIERO consultar los datos de contacto de un proveedor, su ubicación
-- y cuántas compras le he hecho, PARA PODER contactarlo y evaluar qué tanto le compro.
-- Filtro: id_proveedor = el que se indique; total_compras cuenta solo compras no canceladas
SELECT pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, pr.fecha_registro,
       u.ciudad,
       COUNT(co.id_compra) AS total_compras
FROM PROVEEDORES pr
LEFT JOIN UBICACIONES u ON pr.id_ubicacion = u.id_ubicacion
LEFT JOIN COMPRAS co    ON pr.id_proveedor = co.id_proveedor
                       AND co.estado_compra <> 'Cancelada'
WHERE pr.id_proveedor = 1 --puede cambiar al deseado
GROUP BY pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, pr.fecha_registro, u.ciudad;


-- CO2. Consultar productos de un proveedor.
-- COMO encargado de inventario, QUIERO consultar qué productos le he comprado a un proveedor
-- específico, PARA PODER saber qué me surte y a quién pedirle reposición.
-- Filtro: id_proveedor = el que se indique; solo compras no canceladas
-- Orden: por nombre_producto, ascendente
SELECT DISTINCT p.id_producto, p.nombre AS nombre_producto, p.marca,
       p.precio_referencia, p.stock, p.estado
FROM COMPRAS co
JOIN DETALLESDECOMPRAS dc ON co.id_compra = dc.id_compra
JOIN PRODUCTOS p          ON dc.id_producto = p.id_producto
WHERE co.id_proveedor = 1 --puede cambiar al deseado
  AND co.estado_compra <> 'Cancelada'
ORDER BY nombre_producto;


-- CO3. Consultar productos disponibles por categoría.
-- COMO vendedor, QUIERO consultar los productos disponibles organizados por tipo y categoría,
-- PARA PODER saber qué le puedo ofrecer a un cliente.
-- Filtro: estado = 'Disponible'
-- Orden: por tipo_producto, categoria y nombre_producto, ascendente
SELECT p.id_producto, p.nombre AS nombre_producto, p.marca, p.precio_referencia, p.stock,
       CASE
           WHEN r.id_producto IS NOT NULL THEN 'Ropa'
           WHEN c.id_producto IS NOT NULL THEN 'Calzado'
           WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
       END AS tipo_producto,
       COALESCE(r.categoria_ropa, c.categoria_calzado, a.categoria) AS categoria
FROM PRODUCTOS p
LEFT JOIN ROPA r       ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c    ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a ON p.id_producto = a.id_producto
WHERE p.estado = 'Disponible'
ORDER BY tipo_producto, categoria, nombre_producto;


-- CO4. Consultar ventas de un cliente.
-- COMO vendedor, QUIERO consultar todas las ventas de un cliente específico con su total,
-- PARA PODER revisar su historial de compras.
-- Filtro: id_cliente = el que se indique
-- Orden: por fecha_venta, descendente (más recientes primero)
SELECT v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago,
       COALESCE(SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)), 0) AS total_venta
FROM VENTAS v
LEFT JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.id_cliente = 1 --puede cambiar al deseado
GROUP BY v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago
ORDER BY v.fecha_venta DESC;


-- CO5. Consultar estado de una venta.
-- COMO vendedor, QUIERO consultar los datos, los productos, la dirección de entrega y la factura
-- de una venta específica, PARA PODER informarle al cliente en qué va su pedido.
-- Filtro: id_venta = el que se indique
-- Orden: por nombre_producto, ascendente
SELECT v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago, v.medio_entrega,
       c.nombre AS nombre_cliente,
       u.calle, u.barrio, u.ciudad,
       p.nombre AS nombre_producto, dv.cantidad, dv.precio_venta, dv.descuento,
       f.id_factura, f.estado_factura
FROM VENTAS v
JOIN CLIENTES c              ON v.id_cliente = c.id_cliente
JOIN UBICACIONES u           ON v.id_ubicacion = u.id_ubicacion
LEFT JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
LEFT JOIN PRODUCTOS p        ON dv.id_producto = p.id_producto
LEFT JOIN FACTURASVENTA fv   ON v.id_venta = fv.id_venta
LEFT JOIN FACTURAS f         ON fv.id_factura = f.id_factura
WHERE v.id_venta = 1 --puede cambiar al deseado
ORDER BY nombre_producto;



-- CONSULTAS GERENCIALES


-- CG1. Consultar informe de rentabilidad por categoría.
-- COMO administrador del negocio, QUIERO consultar la ganancia de cada categoría de producto
-- durante los últimos 6 meses, PARA PODER decidir en qué categorías invertir más y cuáles reducir.
-- Filtro: ventas no canceladas de los últimos 6 meses
-- Orden: por ganancia, de mayor a menor
-- costo_vendido = cantidad vendida x precio de compra promedio del producto
WITH costo_promedio AS (
    SELECT dc.id_producto, AVG(dc.precio_compra) AS precio_compra_promedio
    FROM DETALLESDECOMPRAS dc
    JOIN COMPRAS co ON dc.id_compra = co.id_compra
    WHERE co.estado_compra <> 'Cancelada'
    GROUP BY dc.id_producto
)
SELECT CASE
           WHEN r.id_producto IS NOT NULL THEN 'Ropa'
           WHEN c.id_producto IS NOT NULL THEN 'Calzado'
           WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
       END AS tipo_producto,
       COALESCE(r.categoria_ropa, c.categoria_calzado, a.categoria) AS categoria,
       SUM(dv.cantidad) AS unidades_vendidas,
       SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)) AS total_vendido,
       ROUND(SUM(dv.cantidad * COALESCE(cp.precio_compra_promedio, 0)), 2) AS costo_vendido,
       ROUND(SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0))
             - SUM(dv.cantidad * COALESCE(cp.precio_compra_promedio, 0)), 2) AS ganancia
FROM VENTAS v
JOIN DETALLESDEVENTAS dv     ON v.id_venta = dv.id_venta
LEFT JOIN costo_promedio cp  ON dv.id_producto = cp.id_producto
LEFT JOIN ROPA r             ON dv.id_producto = r.id_producto
LEFT JOIN CALZADO c          ON dv.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a       ON dv.id_producto = a.id_producto
WHERE v.estado_venta <> 'Cancelada'
  AND v.fecha_venta >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY 1, 2        -- tipo_producto, categoria
ORDER BY ganancia DESC;


-- CG2. Consultar informe de inversión frente a ingresos por período.
-- COMO administrador del negocio, QUIERO consultar cuánto invertí en compras frente a cuánto
-- recuperé en ventas, mes a mes, durante el último año, PARA PODER evaluar el crecimiento del
-- negocio y regular el ritmo de reinversión.
-- Filtro: compras y ventas no canceladas de los últimos 12 meses, agrupadas por mes
-- Orden: por año y mes, de más antiguo a más reciente
WITH movimientos AS (
    SELECT DATE_TRUNC('month', co.fecha_compra) AS mes,
           dc.cantidad * dc.precio_compra AS inversion,
           0 AS ingresos
    FROM COMPRAS co
    JOIN DETALLESDECOMPRAS dc ON co.id_compra = dc.id_compra
    WHERE co.estado_compra <> 'Cancelada'
      AND co.fecha_compra >= CURRENT_DATE - INTERVAL '12 months'
    UNION ALL
    SELECT DATE_TRUNC('month', v.fecha_venta),
           0,
           dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)
    FROM VENTAS v
    JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
    WHERE v.estado_venta <> 'Cancelada'
      AND v.fecha_venta >= CURRENT_DATE - INTERVAL '12 months'
)
SELECT EXTRACT(YEAR FROM mes)  AS anio,
       EXTRACT(MONTH FROM mes) AS mes,
       SUM(inversion) AS inversion,
       SUM(ingresos)  AS ingresos,
       SUM(ingresos) - SUM(inversion) AS diferencia
FROM movimientos
GROUP BY anio, EXTRACT(MONTH FROM mes)
ORDER BY anio, mes;


-- CG3. Consultar productos más vendidos.
-- COMO administrador del negocio, QUIERO consultar los 10 productos más vendidos durante los
-- últimos 3 meses, por cantidad e ingreso generado, PARA PODER saber qué productos reponer con prioridad.
-- Filtro: ventas no canceladas de los últimos 3 meses; mostrar solo el top 10
-- Orden: por unidades_vendidas, de mayor a menor
SELECT p.nombre AS nombre_producto, p.marca,
       CASE
           WHEN r.id_producto IS NOT NULL THEN 'Ropa'
           WHEN c.id_producto IS NOT NULL THEN 'Calzado'
           WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
       END AS tipo_producto,
       COALESCE(r.categoria_ropa, c.categoria_calzado, a.categoria) AS categoria,
       SUM(dv.cantidad) AS unidades_vendidas,
       SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)) AS ingreso_total
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
JOIN PRODUCTOS p         ON dv.id_producto = p.id_producto
LEFT JOIN ROPA r         ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c      ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a   ON p.id_producto = a.id_producto
WHERE v.estado_venta <> 'Cancelada'
  AND v.fecha_venta >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY p.id_producto, p.nombre, p.marca, 3, 4        -- 3 = tipo_producto, 4 = categoria
ORDER BY unidades_vendidas DESC
LIMIT 10;


-- CG4. Consultar ventas por método de pago.
-- COMO administrador del negocio, QUIERO consultar cuánto vendí con cada método de pago
-- (efectivo, transferencia y contraentrega) durante el mes anterior, PARA PODER saber qué medios
-- prefieren mis clientes y planear mi disponibilidad de dinero.
-- Filtro: ventas no canceladas del mes calendario anterior
-- Orden: por total_ingresos, de mayor a menor
SELECT v.metodo_pago,
       COUNT(DISTINCT v.id_venta) AS numero_ventas,
       SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)) AS total_ingresos
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada'
  AND DATE_TRUNC('month', v.fecha_venta) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
GROUP BY v.metodo_pago
ORDER BY total_ingresos DESC;


-- CG5. Consultar ranking de clientes.
-- COMO administrador del negocio, QUIERO consultar los 5 clientes que más me compraron
-- (en dinero total) durante el último año, PARA PODER identificar a mis mejores clientes y fidelizarlos.
-- Filtro: ventas no canceladas de los últimos 12 meses; mostrar solo el top 5
-- Orden: por monto_total, de mayor a menor
-- ciudad = la de la ubicación principal del cliente
SELECT c.nombre AS nombre_cliente,
       u.ciudad,
       COUNT(DISTINCT v.id_venta) AS numero_compras,
       SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)) AS monto_total
FROM CLIENTES c
JOIN VENTAS v            ON c.id_cliente = v.id_cliente
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
LEFT JOIN UBICACIONES u  ON u.id_cliente = c.id_cliente AND u.es_principal
WHERE v.estado_venta <> 'Cancelada'
  AND v.fecha_venta >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY c.id_cliente, c.nombre, u.ciudad
ORDER BY monto_total DESC
LIMIT 5;