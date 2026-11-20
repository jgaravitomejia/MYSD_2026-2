--TG1
DROP TRIGGER IF EXISTS tg_descontar_stock_venta ON DETALLESDEVENTAS;
DROP FUNCTION IF EXISTS fn_descontar_stock_venta();

--TG2
DROP TRIGGER IF EXISTS tg_aumentar_stock_compra ON DETALLESDECOMPRAS;
DROP FUNCTION IF EXISTS fn_aumentar_stock_compra();

--TG3
DROP TRIGGER IF EXISTS tg_validar_venta_facturable ON FACTURASVENTA;
DROP FUNCTION IF EXISTS fn_validar_venta_facturable();

--TG4
DROP TRIGGER IF EXISTS tg_validar_compra_facturable ON FACTURASCOMPRA;
DROP FUNCTION IF EXISTS fn_validar_compra_facturable();

--TG5
DROP TRIGGER IF EXISTS tg_fecha_factura_automatica ON FACTURAS;
DROP FUNCTION IF EXISTS fn_fecha_factura_automatica();

--TG6
DROP TRIGGER IF EXISTS tg_fecha_cliente_automatica ON CLIENTES;
DROP FUNCTION IF EXISTS fn_fecha_cliente_automatica();

--TG7
DROP TRIGGER IF EXISTS tg_validar_eliminacion_cliente ON CLIENTES;
DROP FUNCTION IF EXISTS fn_validar_eliminacion_cliente();

--TG8
DROP TRIGGER IF EXISTS tg_validar_modificacion_factura ON FACTURAS;
DROP FUNCTION IF EXISTS fn_validar_modificacion_factura();

--TG9
DROP TRIGGER IF EXISTS tg_cancelar_venta_devuelve_stock ON VENTAS;
DROP FUNCTION IF EXISTS fn_cancelar_venta_devuelve_stock();

--TG10
DROP TRIGGER IF EXISTS tg_cancelar_compra_retira_stock ON COMPRAS;
DROP FUNCTION IF EXISTS fn_cancelar_compra_retira_stock();

--TG11
DROP TRIGGER IF EXISTS tg_calcula_total_factura_venta ON FACTURASVENTA;
DROP FUNCTION IF EXISTS fn_calcula_total_factura_venta();

--TG12
DROP TRIGGER IF EXISTS tg_calcula_total_factura_compra ON FACTURASCOMPRA;
DROP FUNCTION IF EXISTS fn_calcula_total_factura_compra();

--TG13
DROP TRIGGER IF EXISTS tr_validar_subtipo_venta ON DETALLESDEVENTAS;
DROP TRIGGER IF EXISTS tr_validar_subtipo_compra ON DETALLESDECOMPRAS;
DROP FUNCTION IF EXISTS fn_validar_subtipo_producto();
