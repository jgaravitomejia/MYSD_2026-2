-- Revocar permisos del administrador
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM administrador;
REVOKE ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public FROM administrador;
REVOKE USAGE ON SCHEMA public FROM administrador;
REVOKE CONNECT ON DATABASE pytar_shop FROM administrador;

-- Revocar permisos de vendedor
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM vendedor;
REVOKE ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public FROM vendedor;
REVOKE USAGE ON SCHEMA public FROM vendedor;
REVOKE CONNECT ON DATABASE pytar_shop FROM vendedor;

-- revocar permisos del encargado del inventario
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM encargado_inventario;
REVOKE ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public FROM encargado_inventario;
REVOKE USAGE ON SCHEMA public FROM encargado_inventario;
REVOKE CONNECT ON DATABASE pytar_shop FROM encargado_inventario;

-- Eliminar roles
DROP ROLE IF EXISTS administrador;
DROP ROLE IF EXISTS vendedor;
DROP ROLE IF EXISTS encargado_inventario;