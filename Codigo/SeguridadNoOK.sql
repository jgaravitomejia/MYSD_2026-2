-- Vendedor no hace lo del administrador
SET ROLE vendedor;

-- No puede mantener proveedor
CALL adicionar_proveedor(95010, 'Intruso', '6019999999', 'intruso@test.com', 1);
-- Error esperado: permission denied

-- No puede eliminar cliente 
DELETE FROM CLIENTES WHERE id_cliente = 1;
-- Error esperado: permission denied

-- No puede ver vistas de gerencia
SELECT * FROM vw_rentabilidad_categoria;
-- Error esperado: permission denied

RESET ROLE;



-- Vendedor no hace lo del encargado
SET ROLE vendedor;

-- No puede mantener producto
CALL adicionar_producto(95010, 'Intruso', 'No deberia', 10000, 'X', 5, NULL);
-- Error esperado: permission denied

-- No puede registrar compra
CALL adicionar_compra(95010, 'Intruso', 1);
-- Error esperado: permission denied

-- No puede ver vistas del inventario
SELECT * FROM vw_inventario_productos LIMIT 5;
-- Error esperado: permission denied

RESET ROLE;



-- Encargado no puede hacer lo del vendedor
SET ROLE encargado_inventario;

-- No puede mantener producto
CALL adicionar_venta(95010, 'Efectivo', 'Domicilio', 'Intruso', 1);
-- Error esperado: permission denied

-- No puede ver vistas de inventario
SELECT * FROM vw_vendedor_ventas;
-- Error esperado: permission denied

RESET ROLE;



-- Encargado no hace lo del administrador
SET ROLE encargado_inventario;

-- No puede mantener proveedor
CALL adicionar_proveedor(95010, 'Intruso', '6019999999', 'intruso@test.com', 1);
-- Error esperado: permission denied

-- No puede eliminar cliente 
DELETE FROM CLIENTES WHERE id_cliente = 1;
-- Error esperado: permission denied

-- No puede ver vistas de gerencia
SELECT * FROM vw_rentabilidad_categoria;
-- Error esperado: permission denied

RESET ROLE;