--SeguridadOK


-- Vendedor: registra un cliente, le hace una venta y consulta como va
SET ROLE vendedor;
CALL mantener_cliente.adicionar(97301, 'Cliente Seguridad', '3003330001', NULL, NULL,
                                97301, 'Calle 1 #1-01', NULL, 'Bogota', 'Cundinamarca', NULL);
CALL registrar_venta.adicionar(97301, 97301, 'Efectivo', 'Domicilio', NULL, NULL);
CALL registrar_venta.adicionar_producto(97301, 12, 1, 50000, NULL);
BEGIN;
SELECT registrar_venta.consultar_venta(97301);
FETCH ALL IN cur_venta;
COMMIT;
RESET ROLE;


-- Encargado de inventario: registra un producto y lo compra
SET ROLE encargado_inventario;
CALL mantener_producto.adicionar_calzado(97301, 'Bota Seguridad', NULL, 200000, 'Pytar', 0, NULL, 40, 'Hombre', 'Bota', NULL);
CALL registrar_compra.adicionar(97301, 1, NULL);
CALL registrar_compra.adicionar_producto(97301, 97301, 5, 120000);
RESET ROLE;


-- Administrador: factura la venta del vendedor y consulta un proveedor
SET ROLE administrador;
CALL registrar_factura.adicionar_de_venta(97301, 97301, NULL, NULL);
BEGIN;
SELECT mantener_proveedor.consultar(1);
FETCH ALL IN cur_proveedor;
COMMIT;
RESET ROLE;