-- MANTENER_UBICACION
CALL adicionar_ubicacion(93010, 'Calle 50 #20-30', 'Centro', 'Bogotá', 'Cundinamarca', '110111', true);
SELECT * FROM UBICACIONES WHERE id_ubicacion = 93010;


-- MANTENER_CLIENTE

-- Adicionar cliente
CALL adicionar_cliente(93010, 'Juan Pérez', '1234567890', 'juan.perez@email.com', 'Cliente de prueba', 93010);
SELECT * FROM CLIENTES WHERE id_cliente = 93010;

-- Modificar cliente
CALL modificar_cliente('Juan Garavito', '987654321', 93010);
SELECT * FROM CLIENTES WHERE id_cliente = 93010;


-- MANTENER_PROVEEDOR

-- Adicionar proveedor
CALL adicionar_proveedor(93010, 'Proveedor A', '1234567890', 'proveedor.a@email.com', 93010);
SELECT * FROM PROVEEDORES WHERE id_proveedor = 93010;

-- Modificar proveedor
CALL modificar_proveedor('Proveedor B', '987654321', 93010);
SELECT * FROM PROVEEDORES WHERE id_proveedor = 93010;

-- MANTENER_PRODUCTO

--Adicionar producto + ropa
CALL adicionar_producto(93010, 'Camiseta Deportiva', 'Camiseta dry-fit', 45000.00, 'Nike', 20, NULL);
SELECT * FROM PRODUCTOS WHERE id_producto = 93010;
CALL adicionar_producto_ropa(93010, 'M', 'Unisex', 'Camisa', 'Poliester');
SELECT * FROM ROPA WHERE id_producto = 93010;

--Adicionar producto + calzado
CALL adicionar_producto(93011, 'Tenis Running', 'Tenis para correr', 25000.00, 'Adidas', 10, NULL);
SELECT * FROM PRODUCTOS WHERE id_producto = 93011;
CALL adicionar_producto_calzado(93011, 42.0, 'Hombre', 'Deportivo', 'Sintetico');
SELECT * FROM CALZADO WHERE id_producto = 93011;

--Adicionar producto + accesorio
CALL adicionar_producto(93012, 'Gorro Clasica', NULL, 35000.00, 'Puma', 30, NULL);
SELECT * FROM PRODUCTOS WHERE id_producto = 93012;
CALL adicionar_producto_accesorio(93012, 'Gorra', 'Algodon', NULL);
SELECT * FROM ACCESORIOS WHERE id_producto = 93012;

-- Modificar producto
CALL modificar_producto(50000.00, 25, 93010);
SELECT * FROM PRODUCTOS WHERE id_producto = 93010;

-- REGISTAR_VENTA

-- Adicionar venta con productos
CALL adicionar_venta(93010, 'Efectivo', 'Domicilio', NULL, 93010);
SELECT * FROM VENTAS WHERE id_venta = 93010;
CALL adicionar_detalle_venta(93010, 93010, 2, 50000.00, 5000.00);
SELECT * FROM DETALLESDEVENTAS WHERE id_venta = 93010;
CALL adicionar_detalle_venta(93010, 93012, 1, 35000.00, NULL);
-- stock 93010: 25-2=23
-- stock 93012: 30-1=29
SELECT * FROM DETALLESDEVENTAS WHERE id_producto = 93012;

--Cancelar venta
--(adicionar una venta)
CALL adicionar_venta(93011, 'Efectivo', 'Domicilio', NULL, 93010);
CALL adicionar_detalle_venta(93011, 93011, 1, 25000.00, NULL);
-- stock 93011: 10-1=9
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 93011;
CALL cancelar_venta(93011);
-- stock 93011: 9+1=10

-- Asercion: verificar estado cancelada y stock devuelto
SELECT id_venta, estado_venta FROM VENTAS WHERE id_venta = 93011;
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 93011;

-- REGISTAR_COMPRA

-- Adicionar compra con productos
CALL adicionar_compra(93010, NULL, 93010);
SELECT id_compra, estado_compra, fecha_compra FROM COMPRAS WHERE id_compra = 93010;
CALL adicionar_detalle_compra(93010, 93010, 15, 30000.00);
-- stock 93010: 23+15=38
SELECT * FROM DETALLESDECOMPRAS WHERE id_producto = 93010;
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 93010;



-- Cancelar compra
--(adicionar una compra)
CALL adicionar_compra(93011, NULL, 93010);
CALL adicionar_detalle_compra(93011, 93010, 5, 25000.00);
-- stock 93010: 38+5=43
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 93010;

CALL cancelar_compra(93011);
-- stock 93010: 43-5=38
-- Asercion: verificar estado cancelada y stock devuelto
SELECT id_compra, estado_compra FROM COMPRAS WHERE id_compra = 93011;
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 93010;


-- REGISTRAR_FACTURA

-- Facturar venta
CALL adicionar_factura(93010, 'Emitida', NULL);
-- fecha_emision asignada por trigger T5
CALL adicionar_factura_venta(93010, 93010, 'GUIA-OK-001');
-- total calculado por trigger T11
SELECT * FROM FACTURAS WHERE id_factura = 93010;
SELECT * FROM FACTURASVENTA WHERE id_factura = 93010;


-- Facturar compra
CALL adicionar_factura(93011, 'Emitida', NULL);
-- fecha_emision asignada por trigger T5
CALL adicionar_factura_compra(93011, 93010, 'REM-OK-001');
-- total calculado por trigger T12
SELECT * FROM FACTURAS WHERE id_factura = 93011;
SELECT * FROM FACTURASCOMPRA WHERE id_factura = 93011;