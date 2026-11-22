--SeguridadNoOK


-- Vendedor
SET ROLE vendedor;
CALL registrar_compra.adicionar(97399, 1, NULL); --error esperado: permiso denegado para el esquema registrar_compra
INSERT INTO COMPRAS (id_compra, id_proveedor) VALUES (97399, 1); --error esperado: permiso denegado para la tabla compras
RESET ROLE;


-- Encargado de inventario
SET ROLE encargado_inventario;
CALL registrar_venta.cancelar(1); --error esperado: permiso denegado para el esquema registrar_venta
SELECT * FROM CLIENTES; --error esperado: permiso denegado para la tabla clientes
RESET ROLE;


-- Administrador
SET ROLE administrador;
CALL mantener_cliente.eliminar(1); --error esperado: permiso denegado para el esquema mantener_cliente
UPDATE PRODUCTOS SET stock = 0 WHERE id_producto = 12; --error esperado: permiso denegado para la tabla productos
RESET ROLE;