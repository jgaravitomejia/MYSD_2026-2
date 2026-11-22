--Componentes

-- MANTENER_CLIENTE
CREATE SCHEMA IF NOT EXISTS mantener_cliente;

-- El cliente se registra con su primera ubicacion (queda como principal)
CREATE OR REPLACE PROCEDURE mantener_cliente.adicionar(p_id INTEGER, p_nombre VARCHAR, p_telefono VARCHAR, p_correo VARCHAR, p_notas VARCHAR,
    p_id_ubicacion INTEGER, p_calle VARCHAR, p_barrio VARCHAR, p_ciudad VARCHAR, p_departamento VARCHAR, p_codigo_postal VARCHAR) AS $$
BEGIN
    INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, notas) VALUES (p_id, p_nombre, p_telefono, p_correo, p_notas);
    INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, id_cliente)
        VALUES (p_id_ubicacion, p_calle, p_barrio, p_ciudad, p_departamento, p_codigo_postal, p_id);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_cliente.modificar(p_id INTEGER, p_nombre VARCHAR, p_telefono VARCHAR) AS $$
BEGIN
    UPDATE CLIENTES SET nombre = p_nombre, telefono = p_telefono WHERE id_cliente = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'El cliente no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_cliente.eliminar(p_id INTEGER) AS $$
BEGIN
    DELETE FROM CLIENTES WHERE id_cliente = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'El cliente no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- MANTENER_UBICACION
CREATE SCHEMA IF NOT EXISTS mantener_ubicacion;

CREATE OR REPLACE PROCEDURE mantener_ubicacion.adicionar(p_id INTEGER, p_id_cliente INTEGER, p_calle VARCHAR, p_barrio VARCHAR,
    p_ciudad VARCHAR, p_departamento VARCHAR, p_codigo_postal VARCHAR, p_es_principal BOOLEAN) AS $$
BEGIN
    IF p_id_cliente IS NULL THEN RAISE EXCEPTION 'La ubicacion debe pertenecer a un cliente.'; END IF;
    INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
        VALUES (p_id, p_calle, p_barrio, p_ciudad, p_departamento, p_codigo_postal, p_es_principal, p_id_cliente);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_ubicacion.modificar(p_id INTEGER, p_calle VARCHAR, p_barrio VARCHAR, p_ciudad VARCHAR,
    p_departamento VARCHAR, p_codigo_postal VARCHAR) AS $$
BEGIN
    UPDATE UBICACIONES SET calle = p_calle, barrio = p_barrio, ciudad = p_ciudad, departamento = p_departamento,
        codigo_postal = p_codigo_postal WHERE id_ubicacion = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La ubicacion no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- Al marcar una como principal, tg_ubicaciones desmarca la anterior
CREATE OR REPLACE PROCEDURE mantener_ubicacion.marcar_principal(p_id INTEGER) AS $$
BEGIN
    UPDATE UBICACIONES SET es_principal = TRUE WHERE id_ubicacion = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La ubicacion no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_ubicacion.eliminar(p_id INTEGER) AS $$
BEGIN
    DELETE FROM UBICACIONES WHERE id_ubicacion = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La ubicacion no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- MANTENER_PROVEEDOR
CREATE SCHEMA IF NOT EXISTS mantener_proveedor;

-- La ubicacion es opcional: solo se registra si viene p_id_ubicacion
CREATE OR REPLACE PROCEDURE mantener_proveedor.adicionar(p_id INTEGER, p_nombre VARCHAR, p_telefono VARCHAR, p_correo VARCHAR,
    p_id_ubicacion INTEGER, p_calle VARCHAR, p_barrio VARCHAR, p_ciudad VARCHAR, p_departamento VARCHAR, p_codigo_postal VARCHAR) AS $$
BEGIN
    IF p_id_ubicacion IS NOT NULL THEN
        INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal)
            VALUES (p_id_ubicacion, p_calle, p_barrio, p_ciudad, p_departamento, p_codigo_postal);
    END IF;
    INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, id_ubicacion) VALUES (p_id, p_nombre, p_telefono, p_correo, p_id_ubicacion);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_proveedor.modificar(p_id INTEGER, p_nombre VARCHAR, p_telefono VARCHAR) AS $$
BEGIN
    UPDATE PROVEEDORES SET nombre = p_nombre, telefono = p_telefono WHERE id_proveedor = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'El proveedor no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- Se borra el proveedor y luego su ubicacion, para que no quede suelta
CREATE OR REPLACE PROCEDURE mantener_proveedor.eliminar(p_id INTEGER) AS $$
DECLARE v_ubicacion INTEGER;
BEGIN
    DELETE FROM PROVEEDORES WHERE id_proveedor = p_id RETURNING id_ubicacion INTO v_ubicacion;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'El proveedor no existe.'; END IF;
    DELETE FROM UBICACIONES WHERE id_ubicacion = v_ubicacion;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- CO1: datos de un proveedor, su ciudad y cuantas compras se le han hecho
CREATE OR REPLACE FUNCTION mantener_proveedor.consultar(p_id INTEGER) RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_proveedor';
BEGIN
    OPEN cur FOR
        SELECT pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, u.ciudad, COUNT(co.id_compra) AS total_compras
        FROM PROVEEDORES pr
        LEFT JOIN UBICACIONES u ON pr.id_ubicacion = u.id_ubicacion
        LEFT JOIN COMPRAS co ON pr.id_proveedor = co.id_proveedor AND co.estado_compra <> 'Cancelada'
        WHERE pr.id_proveedor = p_id
        GROUP BY pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, u.ciudad;
    RETURN cur;
END; $$ LANGUAGE plpgsql;

-- MANTENER_PRODUCTO
CREATE SCHEMA IF NOT EXISTS mantener_producto;

-- El producto se registra con su tipo; el estado lo asigna tg_productos
CREATE OR REPLACE PROCEDURE mantener_producto.adicionar_ropa(p_id INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio NUMERIC,
    p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR, p_talla VARCHAR, p_genero VARCHAR, p_categoria VARCHAR, p_material VARCHAR) AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
        VALUES (p_id, p_nombre, p_descripcion, p_precio, p_marca, p_stock, p_imagen_url);
    INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material) VALUES (p_id, p_talla, p_genero, p_categoria, p_material);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_producto.adicionar_calzado(p_id INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio NUMERIC,
    p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR, p_talla INTEGER, p_genero VARCHAR, p_categoria VARCHAR, p_material VARCHAR) AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
        VALUES (p_id, p_nombre, p_descripcion, p_precio, p_marca, p_stock, p_imagen_url);
    INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material) VALUES (p_id, p_talla, p_genero, p_categoria, p_material);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_producto.adicionar_accesorio(p_id INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio NUMERIC,
    p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR, p_categoria VARCHAR, p_material VARCHAR, p_dimensiones VARCHAR) AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
        VALUES (p_id, p_nombre, p_descripcion, p_precio, p_marca, p_stock, p_imagen_url);
    INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones) VALUES (p_id, p_categoria, p_material, p_dimensiones);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_producto.modificar(p_id INTEGER, p_precio NUMERIC, p_stock INTEGER) AS $$
BEGIN
    UPDATE PRODUCTOS SET precio_referencia = p_precio, stock = p_stock WHERE id_producto = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'El producto no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_producto.eliminar(p_id INTEGER) AS $$
BEGIN
    DELETE FROM PRODUCTOS WHERE id_producto = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'El producto no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- CO3: productos disponibles por tipo y categoria
CREATE OR REPLACE FUNCTION mantener_producto.consultar_disponibles() RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_disponibles';
BEGIN
    OPEN cur FOR
        SELECT id_producto, nombre, marca, precio_referencia, stock, tipo_producto, categoria
        FROM VW_PRODUCTOS_TIPO WHERE estado = 'Disponible' ORDER BY tipo_producto, categoria, nombre;
    RETURN cur;
END; $$ LANGUAGE plpgsql;

-- REGISTRAR_COMPRA
CREATE SCHEMA IF NOT EXISTS registrar_compra;

CREATE OR REPLACE PROCEDURE registrar_compra.adicionar(p_id INTEGER, p_id_proveedor INTEGER, p_observacion VARCHAR) AS $$
BEGIN
    INSERT INTO COMPRAS (id_compra, observacion, id_proveedor) VALUES (p_id, p_observacion, p_id_proveedor);
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- tg_detallesdecompras aumenta el stock
CREATE OR REPLACE PROCEDURE registrar_compra.adicionar_producto(p_id INTEGER, p_id_producto INTEGER, p_cantidad INTEGER, p_precio NUMERIC) AS $$
BEGIN
    INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra) VALUES (p_id, p_id_producto, p_cantidad, p_precio);
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- tg_compras retira del stock las unidades que habia ingresado
CREATE OR REPLACE PROCEDURE registrar_compra.cancelar(p_id INTEGER) AS $$
BEGIN
    UPDATE COMPRAS SET estado_compra = 'Cancelada' WHERE id_compra = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La compra no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- CO2: productos que se le han comprado a un proveedor
CREATE OR REPLACE FUNCTION registrar_compra.consultar_productos_proveedor(p_id_proveedor INTEGER) RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_productos_proveedor';
BEGIN
    OPEN cur FOR
        SELECT DISTINCT p.id_producto, p.nombre, p.marca, p.precio_referencia, p.stock, p.estado
        FROM COMPRAS co
        JOIN DETALLESDECOMPRAS dc ON co.id_compra = dc.id_compra
        JOIN PRODUCTOS p ON dc.id_producto = p.id_producto
        WHERE co.id_proveedor = p_id_proveedor AND co.estado_compra <> 'Cancelada'
        ORDER BY p.nombre;
    RETURN cur;
END; $$ LANGUAGE plpgsql;

-- REGISTRAR_VENTA
CREATE SCHEMA IF NOT EXISTS registrar_venta;

-- Si p_id_ubicacion es NULL, tg_ventas usa la ubicacion principal del cliente
CREATE OR REPLACE PROCEDURE registrar_venta.adicionar(p_id INTEGER, p_id_cliente INTEGER, p_metodo_pago VARCHAR, p_medio_entrega VARCHAR,
    p_observaciones VARCHAR, p_id_ubicacion INTEGER) AS $$
BEGIN
    INSERT INTO VENTAS (id_venta, metodo_pago, medio_entrega, observaciones, id_cliente, id_ubicacion)
        VALUES (p_id, p_metodo_pago, p_medio_entrega, p_observaciones, p_id_cliente, p_id_ubicacion);
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- tg_detallesdeventas valida el stock y lo descuenta
CREATE OR REPLACE PROCEDURE registrar_venta.adicionar_producto(p_id INTEGER, p_id_producto INTEGER, p_cantidad INTEGER,
    p_precio NUMERIC, p_descuento NUMERIC) AS $$
BEGIN
    INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
        VALUES (p_id, p_id_producto, p_cantidad, p_precio, p_descuento);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE registrar_venta.completar(p_id INTEGER) AS $$
BEGIN
    UPDATE VENTAS SET estado_venta = 'Completada' WHERE id_venta = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La venta no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- tg_ventas devuelve al stock las unidades vendidas
CREATE OR REPLACE PROCEDURE registrar_venta.cancelar(p_id INTEGER) AS $$
BEGIN
    UPDATE VENTAS SET estado_venta = 'Cancelada' WHERE id_venta = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La venta no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

-- CO4: ventas de un cliente con su total
CREATE OR REPLACE FUNCTION registrar_venta.consultar_ventas_cliente(p_id_cliente INTEGER) RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_ventas_cliente';
BEGIN
    OPEN cur FOR
        SELECT v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago,
               COALESCE(SUM(dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0)), 0) AS total_venta
        FROM VENTAS v LEFT JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
        WHERE v.id_cliente = p_id_cliente
        GROUP BY v.id_venta, v.fecha_venta, v.estado_venta, v.metodo_pago
        ORDER BY v.fecha_venta DESC;
    RETURN cur;
END; $$ LANGUAGE plpgsql;

-- CO5: datos, productos, direccion de entrega y factura de una venta
CREATE OR REPLACE FUNCTION registrar_venta.consultar_venta(p_id INTEGER) RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_venta';
BEGIN
    OPEN cur FOR
        SELECT v.id_venta, v.fecha_venta, v.estado_venta, c.nombre AS cliente, u.calle, u.ciudad,
               p.nombre AS producto, dv.cantidad, dv.precio_venta, f.id_factura, f.estado_factura
        FROM VENTAS v
        JOIN CLIENTES c ON v.id_cliente = c.id_cliente
        JOIN UBICACIONES u ON v.id_ubicacion = u.id_ubicacion
        LEFT JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
        LEFT JOIN PRODUCTOS p ON dv.id_producto = p.id_producto
        LEFT JOIN FACTURASVENTA fv ON v.id_venta = fv.id_venta
        LEFT JOIN FACTURAS f ON fv.id_factura = f.id_factura
        WHERE v.id_venta = p_id;
    RETURN cur;
END; $$ LANGUAGE plpgsql;

-- REGISTRAR_FACTURA
CREATE SCHEMA IF NOT EXISTS registrar_factura;

-- La factura nace 'Emitida' y unida a su venta o compra; el total 1 es provisional y lo calcula el disparador
CREATE OR REPLACE PROCEDURE registrar_factura.adicionar_de_venta(p_id INTEGER, p_id_venta INTEGER, p_numero_guia VARCHAR, p_observaciones VARCHAR) AS $$
BEGIN
    INSERT INTO FACTURAS (id_factura, total, observaciones) VALUES (p_id, 1, p_observaciones);
    INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia) VALUES (p_id, p_id_venta, p_numero_guia);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE registrar_factura.adicionar_de_compra(p_id INTEGER, p_id_compra INTEGER, p_numero_remision VARCHAR, p_observaciones VARCHAR) AS $$
BEGIN
    INSERT INTO FACTURAS (id_factura, total, observaciones) VALUES (p_id, 1, p_observaciones);
    INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision) VALUES (p_id, p_id_compra, p_numero_remision);
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE registrar_factura.modificar_estado(p_id INTEGER, p_estado VARCHAR) AS $$
BEGIN
    UPDATE FACTURAS SET estado_factura = p_estado WHERE id_factura = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La factura no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE registrar_factura.eliminar(p_id INTEGER) AS $$
BEGIN
    DELETE FROM FACTURAS WHERE id_factura = p_id;
    IF NOT FOUND THEN ROLLBACK; RAISE EXCEPTION 'La factura no existe.'; END IF;
    COMMIT;
END; $$ LANGUAGE plpgsql;