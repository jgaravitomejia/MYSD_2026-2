--Actores
-- Un rol por actor del diagrama de funciones. Cada uno entra a la base con su usuario y contrasena.
-- No hace falta GRANT CONNECT: PostgreSQL deja conectarse a cualquier rol por defecto.
CREATE ROLE administrador LOGIN PASSWORD 'admin123';
CREATE ROLE vendedor LOGIN PASSWORD 'vend123';
CREATE ROLE encargado_inventario LOGIN PASSWORD 'inv123';