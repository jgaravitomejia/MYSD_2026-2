--XSeguridad
-- Primero se le quitan a cada rol todos los permisos que recibio en Actores y Seguridad (REVOKE);
-- un rol que todavia tiene permisos no se puede eliminar.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM administrador, vendedor, encargado_inventario;
REVOKE ALL ON SCHEMA mantener_cliente, mantener_ubicacion, mantener_proveedor, mantener_producto,
    registrar_compra, registrar_venta, registrar_factura FROM administrador, vendedor, encargado_inventario;
REVOKE ALL ON ALL PROCEDURES IN SCHEMA mantener_cliente, mantener_ubicacion, mantener_proveedor, mantener_producto,
    registrar_compra, registrar_venta, registrar_factura FROM administrador, vendedor, encargado_inventario;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA mantener_proveedor, mantener_producto, registrar_compra, registrar_venta
    FROM administrador, vendedor, encargado_inventario;
REVOKE CONNECT ON DATABASE pytar FROM administrador, vendedor, encargado_inventario;

DROP ROLE administrador;
DROP ROLE vendedor;
DROP ROLE encargado_inventario;