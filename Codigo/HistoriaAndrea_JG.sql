--Historia: Las Zapatillas Runner de Andrea
-- Es lunes por la mañana en Pytar-Shop y llega mercancia nueva: unas Zapatillas Runner de Nike.
-- El encargado de inventario las registra y las compra, el administrador registra al proveedor y factura,
-- y el vendedor se las vende a Andrea, una clienta nueva que por la tarde cancela su pedido.


-- La mañana: llega la mercancia

-- Paso 1. El encargado registra las Zapatillas Runner de Nike con las 4 que llegaron en la muestra
SET ROLE encargado_inventario;
CALL mantener_producto.adicionar_calzado(98001, 'Zapatillas Runner', 'Zapatilla para correr', 320000, 'Nike', 4, NULL,
                                         40, 'Unisex', 'Zapatilla', 'Malla');
SELECT p.id_producto, p.nombre, p.marca, p.precio_referencia, p.stock, p.estado, p.fecha_ingreso, c.talla, c.genero
FROM PRODUCTOS p JOIN CALZADO c ON c.id_producto = p.id_producto
WHERE p.id_producto = 98001;

-- Paso 2. Llega el camion con 10 pares mas y el encargado intenta registrar la compra
-- debe fallar: el proveedor todavia no esta registrado (FK_COMPRAS_PROVEEDORES)
CALL registrar_compra.adicionar(98001, 98001, 'Pares de Zapatillas Runner');
RESET ROLE;

-- Paso 3. El administrador ve que el proveedor es nuevo y lo registra con la direccion de su bodega
SET ROLE administrador;
CALL mantener_proveedor.adicionar(98001, 'Deportes del Norte', '6017654321', 'ventas@deportesnorte.co',
                                  98001, 'Calle 170 #45-10', 'Toberin', 'Bogota', 'Cundinamarca', '110131');
SELECT pr.id_proveedor, pr.nombre, pr.telefono, pr.fecha_registro, u.calle, u.barrio
FROM PROVEEDORES pr JOIN UBICACIONES u ON u.id_ubicacion = pr.id_ubicacion
WHERE pr.id_proveedor = 98001;
RESET ROLE;

-- Paso 4. Ahora si el encargado registra la compra de los 10 pares: el stock se actualiza solo (4 + 10 = 14)
SET ROLE encargado_inventario;
CALL registrar_compra.adicionar(98001, 98001, 'Pares de Zapatillas Runner');
CALL registrar_compra.adicionar_producto(98001, 98001, 10, 190000);
SELECT id_compra, fecha_compra, estado_compra FROM COMPRAS WHERE id_compra = 98001;
SELECT id_producto, nombre, stock, estado FROM PRODUCTOS WHERE id_producto = 98001;
RESET ROLE;

-- Paso 5. La mercancia ya fue verificada y el administrador factura la compra:
-- la fecha y el total (10 * 190000 = 1900000) los pone el sistema
SET ROLE administrador;
CALL registrar_factura.adicionar_de_compra(98001, 98001, 'REM-98001', NULL);
SELECT id_factura, fecha_emision, total, estado_factura FROM FACTURAS WHERE id_factura = 98001;
RESET ROLE;


-- A media mañana: llega Andrea

-- Paso 6. El vendedor registra a Andrea con su direccion en La Candelaria
SET ROLE vendedor;
CALL mantener_cliente.adicionar(98001, 'Andrea Martinez', '3157894561', 'andrea.martinez@mail.com', NULL,
                                98002, 'Calle 11 #4-21', 'La Candelaria', 'Bogota', 'Cundinamarca', NULL);
SELECT c.id_cliente, c.nombre, c.fecha_registro, u.calle, u.barrio, u.es_principal
FROM CLIENTES c JOIN UBICACIONES u ON u.id_cliente = c.id_cliente
WHERE c.id_cliente = 98001;

-- Paso 7. Andrea busca zapatillas para correr y el vendedor revisa que tiene disponible
SELECT id_producto, nombre, marca, precio_referencia, stock, tipo_producto, categoria
FROM VW_PRODUCTOS_TIPO
WHERE estado = 'Disponible' AND categoria = 'Zapatilla' AND marca = 'Nike'
ORDER BY nombre;

-- Paso 8. Andrea se lleva 2 pares, paga en efectivo y pide envio a domicilio antes de las 5pm.
-- El vendedor le da 20000 de descuento por ser clienta nueva; el stock baja a 12
CALL registrar_venta.adicionar(98001, 98001, 'Efectivo', 'Domicilio', 'Entregar antes de las 5pm', NULL);
CALL registrar_venta.adicionar_producto(98001, 98001, 2, 320000, 20000);
SELECT id_venta, fecha_venta, metodo_pago, medio_entrega, estado_venta, id_ubicacion, observaciones
FROM VENTAS WHERE id_venta = 98001;
SELECT id_producto, nombre, stock FROM PRODUCTOS WHERE id_producto = 98001;
RESET ROLE;

-- Paso 9. El administrador factura la venta con la guia de envio: total = 2 * 320000 - 20000 = 620000
SET ROLE administrador;
CALL registrar_factura.adicionar_de_venta(98002, 98001, 'GUIA-98001', NULL);
SELECT f.id_factura, f.fecha_emision, f.total, f.estado_factura, fv.numero_guia
FROM FACTURAS f JOIN FACTURASVENTA fv ON fv.id_factura = f.id_factura
WHERE f.id_factura = 98002;


-- Despues del almuerzo: el administrador revisa el negocio (con las vistas)

-- Paso 10. Los 5 productos mas vendidos de los ultimos 3 meses
SELECT pt.nombre, pt.marca, pt.categoria, SUM(lv.cantidad) AS unidades, SUM(lv.subtotal) AS ingresos
FROM VW_LINEAS_VENTA lv JOIN VW_PRODUCTOS_TIPO pt ON pt.id_producto = lv.id_producto
WHERE lv.fecha_venta >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY pt.id_producto, pt.nombre, pt.marca, pt.categoria
ORDER BY unidades DESC
LIMIT 5;

-- Paso 11. Los 5 clientes que mas han gastado en el ultimo año
SELECT cc.nombre, cc.ciudad, COUNT(DISTINCT lv.id_venta) AS compras, SUM(lv.subtotal) AS total_gastado
FROM VW_LINEAS_VENTA lv JOIN VW_CLIENTES_CONTACTO cc ON cc.id_cliente = lv.id_cliente
WHERE lv.fecha_venta >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY cc.id_cliente, cc.nombre, cc.ciudad
ORDER BY total_gastado DESC
LIMIT 5;

-- Paso 12. La categoria que mas ganancia deja en los ultimos 6 meses
SELECT pt.tipo_producto, pt.categoria,
       ROUND(SUM(lv.subtotal) - SUM(lv.cantidad * COALESCE(cp.precio_compra_promedio, 0)), 2) AS ganancia
FROM VW_LINEAS_VENTA lv
JOIN VW_PRODUCTOS_TIPO pt ON pt.id_producto = lv.id_producto
LEFT JOIN VW_COSTO_PROMEDIO cp ON cp.id_producto = lv.id_producto
WHERE lv.fecha_venta >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY pt.tipo_producto, pt.categoria
ORDER BY ganancia DESC
LIMIT 3;

-- Paso 13. Si este mes se esta ganando o perdiendo plata (lo vendido frente a lo comprado)
SELECT (SELECT COALESCE(SUM(subtotal), 0) FROM VW_LINEAS_VENTA
        WHERE DATE_TRUNC('month', fecha_venta) = DATE_TRUNC('month', CURRENT_DATE)) AS vendido_mes,
       (SELECT COALESCE(SUM(dc.cantidad * dc.precio_compra), 0)
        FROM COMPRAS co JOIN DETALLESDECOMPRAS dc ON dc.id_compra = co.id_compra
        WHERE co.estado_compra <> 'Cancelada'
          AND DATE_TRUNC('month', co.fecha_compra) = DATE_TRUNC('month', CURRENT_DATE)) AS comprado_mes;


-- Correcciones de la tarde

-- Paso 14. El proveedor cambio de razon social y el administrador le actualiza el nombre
CALL mantener_proveedor.modificar(98001, 'Deportes del Norte S.A.S.', '6017654321');
SELECT id_proveedor, nombre FROM PROVEEDORES WHERE id_proveedor = 98001;
RESET ROLE;

-- Paso 15. Andrea llama: su apellido completo es Martinez Lopez, y el vendedor lo corrige
SET ROLE vendedor;
CALL mantener_cliente.modificar(98001, 'Andrea Martinez Lopez', '3157894561');
SELECT id_cliente, nombre FROM CLIENTES WHERE id_cliente = 98001;
RESET ROLE;

-- Paso 16. Llega la nueva lista de precios y el encargado actualiza el precio de la zapatilla
-- (el procedimiento recibe tambien el stock, que se deja igual: 12)
SET ROLE encargado_inventario;
CALL mantener_producto.modificar(98001, 299900, 12);
SELECT id_producto, nombre, precio_referencia, stock FROM PRODUCTOS WHERE id_producto = 98001;

-- Paso 17. El encargado revisa que lo que llego hoy cuadra con el proveedor (CO2):
-- 4 de la muestra + 10 comprados - 2 vendidos = 12
BEGIN;
SELECT registrar_compra.consultar_productos_proveedor(98001);
FETCH ALL IN cur_productos_proveedor;
COMMIT;
RESET ROLE;


-- Por la tarde: Andrea cancela

-- Paso 18. Andrea cancela su pedido: el vendedor cancela la venta y el stock vuelve a 14
SET ROLE vendedor;
CALL registrar_venta.cancelar(98001);
SELECT id_venta, estado_venta FROM VENTAS WHERE id_venta = 98001;
SELECT id_producto, nombre, stock FROM PRODUCTOS WHERE id_producto = 98001;

-- Paso 19. El vendedor confirma en el sistema como quedo el pedido de Andrea (CO5)
BEGIN;
SELECT registrar_venta.consultar_venta(98001);
FETCH ALL IN cur_venta;
COMMIT;
RESET ROLE;