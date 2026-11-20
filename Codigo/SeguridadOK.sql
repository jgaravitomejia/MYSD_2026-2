-- Prubeas como administraador 
SET ROLE administrador;

-- Mantener ubicacion
CALL adicionar_ubicacion(94010, 'Calle 100', 'Usaquen', 'Bogota', 'Cundinamarca', '110111', TRUE);
SELECT * FROM UBICACIONES WHERE id_ubicacion = 94010;

-- Mantener cliente 
CALL adicionar_cliente(94010, 'Admin Cliente', '3101111111', 'admin@test.com', 'Creado por admin', 94010);
SELECT * FROM CLIENTES WHERE id_cliente = 94010;
CALL modificar_cliente('Admin Modificado', '3102222222', 94010);
SELECT * FROM CLIENTES WHERE id_cliente = 94010;

-- Eliminar cliente
DELETE FROM CLIENTES WHERE id_cliente = 94010;
SELECT * FROM CLIENTES WHERE id_cliente = 94010;

-- Mantener proveedor 
CALL adicionar_proveedor(94010, 'Proveedor Admin', '6011111111', 'provadmin@test.com', 94010);
SELECT * FROM PROVEEDORES WHERE id_proveedor = 94010;

-- Vista de gerencia

--Vista 5
SELECT * FROM vw_rentabilidad_categoria LIMIT 3;
--Vista 6
SELECT * FROM vw_inversion_vs_ingresos LIMIT 3;
--Vista 7
SELECT * FROM vw_productos_mas_vendidos LIMIT 3;
--Vista 8
SELECT * FROM vw_ventas_por_metodo_pago LIMIT 3;
--Vista 9
SELECT * FROM vw_ranking_clientes LIMIT 3;

RESET ROLE;



-- Pruebas como vendedor 
SET ROLE vendedor; 

-- Registrar cliente
CALL adicionar_cliente(94011, 'Vendedor Cliente', '3103333333', 'vendedor@test.com', 'Creado por vendedor', 94010);
SELECT * FROM CLIENTES WHERE id_cliente = 94011;

-- Registrar venta 
CALL adicionar_venta(94010, 'Efectivo', 'Domicilio', 'Venta seguridad', 94011);
SELECT * FROM VENTAS WHERE id_venta = 94010;
CALL adicionar_detalle_venta(94010, 1, 1, 50000, 0);
SELECT * FROM DETALLESDEVENTAS WHERE id_venta = 94010;

-- Facturar venta
CALL adicionar_factura(94010, 'Emitida', 'Factura seguridad');
CALL adicionar_factura_venta(94010, 94010, 'GUIA-SEG-001');
SELECT * FROM FACTURAS WHERE id_factura = 94010;

-- Vistas del vendedor

--Vista 1
SELECT * FROM vw_vendedor_productos_disponibles LIMIT 3;
--Vista 2
SELECT * FROM vw_vendedor_ventas LIMIT 3;

RESET ROLE;



-- Pruebas encargado de inventario
SET ROLE encargado_inventario;

-- Mantener producto
CALL adicionar_producto(94010, 'Producto Inventario', 'Prueba seguridad', 60000, 'MarcaTest', 15, NULL);
SELECT * FROM PRODUCTOS WHERE id_producto = 94010;
CALL adicionar_producto_ropa(94010, 'L', 'Unisex', 'Camisa', 'Algodon');
SELECT * FROM ROPA WHERE id_producto = 94010;

-- Registrar compra 
CALL adicionar_compra(94010, 'Compra seguridad', 1);
SELECT * FROM COMPRAS WHERE id_compra = 94010;
CALL adicionar_detalle_compra(94010, 94010, 10, 40000);
SELECT * FROM DETALLESDECOMPRAS WHERE id_compra = 94010;


-- Facturar compra
CALL adicionar_factura(94011, 'Emitida', 'Factura compra seguridad');
CALL adicionar_factura_compra(94011, 94010, 'REM-SEG-001');
SELECT * FROM FACTURAS WHERE id_factura = 94011;


-- Vista del inventerista

--Vista 3
SELECT * FROM vw_inventario_productos LIMIT 5;
--Vista 4
SELECT * FROM vw_inventario_proveedores LIMIT 5;

RESET ROLE;