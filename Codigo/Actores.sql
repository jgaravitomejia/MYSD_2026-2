-- Crear roles para los actores del sistema
CREATE ROLE administrador LOGIN PASSWORD 'admin123';
CREATE ROLE vendedor LOGIN PASSWORD 'vend123';
CREATE ROLE encargado_inventario LOGIN PASSWORD 'inv123';

-- Dar permiso de conexion a la base de datos
GRANT CONNECT ON DATABASE pytar_shop TO administrador;
GRANT CONNECT ON DATABASE pytar_shop TO vendedor;
GRANT CONNECT ON DATABASE pytar_shop TO encargado_inventario;

-- Dar acceso al esquema public 
GRANT USAGE ON SCHEMA public TO administrador;
GRANT USAGE ON SCHEMA public TO vendedor;
GRANT USAGE ON SCHEMA public TO encargado_inventario;