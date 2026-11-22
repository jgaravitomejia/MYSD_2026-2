--Vistas


-- Cada producto con su tipo (Ropa, Calzado o Accesorio) y su categoria.

CREATE OR REPLACE VIEW VW_PRODUCTOS_TIPO AS
SELECT p.id_producto, p.nombre, p.marca, p.precio_referencia, p.stock, p.estado,
       CASE
           WHEN r.id_producto IS NOT NULL THEN 'Ropa'
           WHEN c.id_producto IS NOT NULL THEN 'Calzado'
           WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
       END AS tipo_producto,
       COALESCE(r.categoria_ropa, c.categoria_calzado, a.categoria) AS categoria
FROM PRODUCTOS p
LEFT JOIN ROPA r       ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c    ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a ON p.id_producto = a.id_producto;

-- Cada producto vendido en ventas no canceladas, con su subtotal (cantidad * precio - descuento).

CREATE OR REPLACE VIEW VW_LINEAS_VENTA AS
SELECT v.id_venta, v.fecha_venta, v.metodo_pago, v.id_cliente,
       dv.id_producto, dv.cantidad, dv.precio_venta, dv.descuento,
       dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0) AS subtotal
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada';

-- Precio de compra promedio de cada producto en compras no canceladas.
-- CG1 lo necesita para calcular el costo de lo vendido y la ganancia
CREATE OR REPLACE VIEW VW_COSTO_PROMEDIO AS
SELECT dc.id_producto,
       AVG(dc.precio_compra) AS precio_compra_promedio
FROM DETALLESDECOMPRAS dc
JOIN COMPRAS co ON dc.id_compra = co.id_compra
WHERE co.estado_compra <> 'Cancelada'
GROUP BY dc.id_producto;

-- Cada cliente con los datos de su ubicacion principal, sin las notas internas.
-- CG5 la usa para la ciudad; en Seguridad el vendedor consulta esta vista en vez de la tabla CLIENTES
CREATE OR REPLACE VIEW VW_CLIENTES_CONTACTO AS
SELECT c.id_cliente, c.nombre, c.telefono, c.correo,
       u.calle, u.barrio, u.ciudad, u.departamento
FROM CLIENTES c
LEFT JOIN UBICACIONES u ON u.id_cliente = c.id_cliente AND u.es_principal;
