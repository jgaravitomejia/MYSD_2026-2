-- XPoblar. Ciclo 1.
-- Elimina todos los datos.
--
-- Se usa TRUNCATE y no DELETE porque:
--   1. Borra todas las tablas en una sola instruccion, sin importar el orden de las llaves foraneas.
--   2. No activa los disparadores de fila. Con DELETE, los disparadores que protegen el negocio


TRUNCATE TABLE
    FACTURASCOMPRA,
    FACTURASVENTA,
    FACTURAS,
    DETALLESDEVENTAS,
    DETALLESDECOMPRAS,
    VENTAS,
    COMPRAS,
    ROPA,
    CALZADO,
    ACCESORIOS,
    PRODUCTOS,
    PROVEEDORES,
    UBICACIONES,
    CLIENTES;