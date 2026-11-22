--Seguridad

REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA mantener_cliente, mantener_ubicacion, mantener_proveedor, mantener_producto,
    registrar_compra, registrar_venta, registrar_factura FROM PUBLIC;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA mantener_proveedor, mantener_producto, registrar_compra, registrar_venta FROM PUBLIC;


-- Administrador: Mantener proveedor y Registrar factura
GRANT USAGE ON SCHEMA mantener_proveedor, registrar_factura TO administrador;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA mantener_proveedor, registrar_factura TO administrador;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA mantener_proveedor TO administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON PROVEEDORES, UBICACIONES, FACTURAS, FACTURASVENTA, FACTURASCOMPRA TO administrador;
GRANT SELECT ON CLIENTES, COMPRAS, DETALLESDECOMPRAS, VENTAS, DETALLESDEVENTAS TO administrador;
GRANT SELECT ON VW_LINEAS_VENTA, VW_PRODUCTOS_TIPO, VW_COSTO_PROMEDIO, VW_CLIENTES_CONTACTO TO administrador;


-- Vendedor: Mantener cliente, Mantener ubicacion y Registrar venta (y consultar los productos disponibles)
GRANT USAGE ON SCHEMA mantener_cliente, mantener_ubicacion, registrar_venta, mantener_producto TO vendedor;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA mantener_cliente, mantener_ubicacion, registrar_venta TO vendedor;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA registrar_venta TO vendedor;
GRANT EXECUTE ON FUNCTION mantener_producto.consultar_disponibles() TO vendedor;
GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENTES, UBICACIONES TO vendedor;
GRANT SELECT, INSERT, UPDATE ON VENTAS, DETALLESDEVENTAS TO vendedor;
GRANT SELECT, UPDATE ON PRODUCTOS TO vendedor;
GRANT SELECT ON ROPA, CALZADO, ACCESORIOS, FACTURAS, FACTURASVENTA, VW_PRODUCTOS_TIPO TO vendedor;


-- Encargado de inventario: Mantener producto y Registrar compra
GRANT USAGE ON SCHEMA mantener_producto, registrar_compra TO encargado_inventario;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA mantener_producto, registrar_compra TO encargado_inventario;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA registrar_compra TO encargado_inventario;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODUCTOS, ROPA, CALZADO, ACCESORIOS TO encargado_inventario;
GRANT SELECT, INSERT, UPDATE ON COMPRAS, DETALLESDECOMPRAS TO encargado_inventario;
GRANT SELECT ON PROVEEDORES TO encargado_inventario;