-- Administrador

-- Mantener ubicacion
GRANT EXECUTE ON PROCEDURE adicionar_ubicacion(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN) TO administrador;
GRANT SELECT, INSERT ON UBICACIONES TO administrador;

-- Mantener cliente (adicionar, modificar, eliminar)
GRANT EXECUTE ON PROCEDURE adicionar_cliente(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER) TO administrador;
GRANT EXECUTE ON PROCEDURE modificar_cliente(VARCHAR, VARCHAR, INTEGER) TO administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENTES TO administrador;

-- Mantener proveedor
GRANT EXECUTE ON PROCEDURE adicionar_proveedor(INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER) TO administrador;
GRANT EXECUTE ON PROCEDURE modificar_proveedor(VARCHAR, VARCHAR, INTEGER) TO administrador;
GRANT SELECT, INSERT, UPDATE ON PROVEEDORES TO administrador;

-- Vistas de gerencia
GRANT SELECT ON vw_rentabilidad_categoria TO administrador;
GRANT SELECT ON vw_inversion_vs_ingresos TO administrador;
GRANT SELECT ON vw_productos_mas_vendidos TO administrador;
GRANT SELECT ON vw_ventas_por_metodo_pago TO administrador;
GRANT SELECT ON vw_ranking_clientes TO administrador;

-- Tablas que las vistas necesitas leer
GRANT SELECT ON VENTAS, DETALLESDEVENTAS, COMPRAS, DETALLESDECOMPRAS, PRODUCTOS, ROPA, CALZADO, ACCESORIOS TO administrador;



-- Vendedor

-- Registar cliente
GRANT EXECUTE ON PROCEDURE adicionar_cliente(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER) TO vendedor;
GRANT SELECT, INSERT ON CLIENTES TO vendedor;
GRANT SELECT ON UBICACIONES TO vendedor;

-- Registrar venta
GRANT EXECUTE ON PROCEDURE adicionar_venta(INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER) TO vendedor;
GRANT EXECUTE ON PROCEDURE adicionar_detalle_venta(INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC) TO vendedor;
GRANT EXECUTE ON PROCEDURE cancelar_venta(INTEGER) TO vendedor;
GRANT SELECT, INSERT, UPDATE ON VENTAS TO vendedor;
GRANT SELECT, INSERT ON DETALLESDEVENTAS TO vendedor;
GRANT SELECT, UPDATE ON PRODUCTOS TO vendedor;

-- Registrar factura de venta
GRANT EXECUTE ON PROCEDURE adicionar_factura(INTEGER, VARCHAR, VARCHAR) TO vendedor;
GRANT EXECUTE ON PROCEDURE adicionar_factura_venta(INTEGER, INTEGER, VARCHAR) TO vendedor;
GRANT SELECT, INSERT, UPDATE ON FACTURAS TO vendedor;
GRANT SELECT, INSERT ON FACTURASVENTA TO vendedor;

-- Vista del vendedor
GRANT SELECT ON vw_vendedor_productos_disponibles TO vendedor;
GRANT SELECT ON vw_vendedor_ventas TO vendedor;

-- Tablas que las vistas necesitan leer
GRANT SELECT ON ROPA, CALZADO, ACCESORIOS TO vendedor;



-- Encargado de inventario

-- Mantener producto 
GRANT EXECUTE ON PROCEDURE adicionar_producto(INTEGER, VARCHAR, VARCHAR, NUMERIC, VARCHAR, INTEGER, VARCHAR) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE modificar_producto(NUMERIC, INTEGER, INTEGER) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE adicionar_producto_ropa(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE adicionar_producto_calzado(INTEGER, NUMERIC, VARCHAR, VARCHAR, VARCHAR) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE adicionar_producto_accesorio(INTEGER, VARCHAR, VARCHAR, VARCHAR) TO encargado_inventario;
GRANT SELECT, INSERT, UPDATE ON PRODUCTOS TO encargado_inventario;
GRANT SELECT, INSERT ON ROPA TO encargado_inventario;
GRANT SELECT, INSERT ON CALZADO TO encargado_inventario;
GRANT SELECT, INSERT ON ACCESORIOS TO encargado_inventario;

-- Registrar compra
GRANT EXECUTE ON PROCEDURE adicionar_compra(INTEGER, VARCHAR, INTEGER) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE adicionar_detalle_compra(INTEGER, INTEGER, INTEGER, NUMERIC) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE cancelar_compra(INTEGER) TO encargado_inventario;
GRANT SELECT, INSERT, UPDATE ON COMPRAS TO encargado_inventario;
GRANT SELECT, INSERT ON DETALLESDECOMPRAS TO encargado_inventario;

-- Registrar factura de compra
GRANT EXECUTE ON PROCEDURE adicionar_factura(INTEGER, VARCHAR, VARCHAR) TO encargado_inventario;
GRANT EXECUTE ON PROCEDURE adicionar_factura_compra(INTEGER, INTEGER, VARCHAR) TO encargado_inventario;
GRANT SELECT, INSERT, UPDATE ON FACTURAS TO encargado_inventario;
GRANT SELECT, INSERT ON FACTURASCOMPRA TO encargado_inventario;

-- Vistas del encargado del inventario
GRANT SELECT ON vw_inventario_productos TO encargado_inventario;
GRANT SELECT ON vw_inventario_proveedores TO encargado_inventario;

-- Tablas que las vistas necesitan leer
GRANT SELECT ON PROVEEDORES TO encargado_inventario;
GRANT SELECT ON VENTAS TO encargado_inventario;
GRANT SELECT ON DETALLESDEVENTAS TO encargado_inventario;