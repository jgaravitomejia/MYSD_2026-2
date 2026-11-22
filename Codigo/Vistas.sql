--Vistas


-- Cada producto con su tipo (Ropa, Calzado o Accesorio) y su categoria.
-- Reemplaza los LEFT JOIN a ROPA, CALZADO y ACCESORIOS que usan CO3, CG1 y CG3
CREATE OR REPLACE VIEW VW_PRODUCTOS_TIPO AS
SELECT p.id_producto, p.nombre, p.marca, p.precio_referencia, p.stock, p.estado,
       CASE
           WHEN r.id_producto IS NOT NULL THEN 'Ropa'
           WHEN c.id_producto IS NOT NULL THEN 'Calzado'
           WHEN a.id_producto IS NOT NULL THEN 'Accesorio'
       END AS tipo_producto,
       COALESCE(r.categoria_ropa, c.categoria_calzado, a.categoria) AS categoria
FROM PRODUCTOS p
LEFT JOIN ROPA r       ON p.id_producto = r.id_producto
LEFT JOIN CALZADO c    ON p.id_producto = c.id_producto
LEFT JOIN ACCESORIOS a ON p.id_producto = a.id_producto;

-- Cada producto vendido en ventas no canceladas, con su subtotal (cantidad * precio - descuento).
-- El filtro de canceladas y el calculo del subtotal se repiten en las 5 consultas gerenciales
CREATE OR REPLACE VIEW VW_LINEAS_VENTA AS
SELECT v.id_venta, v.fecha_venta, v.metodo_pago, v.id_cliente,
       dv.id_producto, dv.cantidad, dv.precio_venta, dv.descuento,
       dv.cantidad * dv.precio_venta - COALESCE(dv.descuento, 0) AS subtotal
FROM VENTAS v
JOIN DETALLESDEVENTAS dv ON v.id_venta = dv.id_venta
WHERE v.estado_venta <> 'Cancelada';

-- Precio de compra promedio de cada producto en compras no canceladas.
-- CG1 lo necesita para calcular el costo de lo vendido y la ganancia
CREATE OR REPLACE VIEW VW_COSTO_PROMEDIO AS
SELECT dc.id_producto,
       AVG(dc.precio_compra) AS precio_compra_promedio
FROM DETALLESDECOMPRAS dc
JOIN COMPRAS co ON dc.id_compra = co.id_compra
WHERE co.estado_compra <> 'Cancelada'
GROUP BY dc.id_producto;

-- Cada cliente con los datos de su ubicacion principal, sin las notas internas.
-- CG5 la usa para la ciudad; en Seguridad el vendedor consulta esta vista en vez de la tabla CLIENTES
CREATE OR REPLACE VIEW VW_CLIENTES_CONTACTO AS
SELECT c.id_cliente, c.nombre, c.telefono, c.correo,
       u.calle, u.barrio, u.ciudad, u.departamento
FROM CLIENTES c
LEFT JOIN UBICACIONES u ON u.id_cliente = c.id_cliente AND u.es_principal;


-- MANTENER_PROVEEDOR
CREATE SCHEMA IF NOT EXISTS mantener_proveedor;

-- Adicionar: la ubicacion es opcional; si viene p_id_ubicacion se registra junto con el proveedor
CREATE OR REPLACE PROCEDURE mantener_proveedor.adicionar(
    p_id_proveedor INTEGER, p_nombre VARCHAR, p_telefono VARCHAR, p_correo VARCHAR,
    p_id_ubicacion INTEGER, p_calle VARCHAR, p_barrio VARCHAR, p_ciudad VARCHAR,
    p_departamento VARCHAR, p_codigo_postal VARCHAR)
AS $$
BEGIN
    IF p_id_ubicacion IS NOT NULL THEN
        INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente)
            VALUES (p_id_ubicacion, p_calle, p_barrio, p_ciudad, p_departamento, p_codigo_postal, FALSE, NULL);
    END IF;

    INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, id_ubicacion)
        VALUES (p_id_proveedor, p_nombre, p_telefono, p_correo, p_id_ubicacion);

    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Modificar: solo el nombre y el telefono
CREATE OR REPLACE PROCEDURE mantener_proveedor.modificar(p_id_proveedor INTEGER, p_nombre VARCHAR, p_telefono VARCHAR)
AS $$
BEGIN
    UPDATE PROVEEDORES
        SET nombre = p_nombre, telefono = p_telefono
        WHERE id_proveedor = p_id_proveedor;

    IF NOT FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION USING MESSAGE = 'El proveedor no existe.',
        ERRCODE = 'C0003';
    END IF;

    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Eliminar: se borra el proveedor y su ubicacion; si tiene compras lo impide FK_COMPRAS_PROVEEDORES
CREATE OR REPLACE PROCEDURE mantener_proveedor.eliminar(p_id_proveedor INTEGER)
AS $$
DECLARE v_id_ubicacion INTEGER;
BEGIN
    SELECT id_ubicacion INTO v_id_ubicacion FROM PROVEEDORES WHERE id_proveedor = p_id_proveedor;

    IF NOT FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION USING MESSAGE = 'El proveedor no existe.',
        ERRCODE = 'C0003';
    END IF;

    DELETE FROM PROVEEDORES WHERE id_proveedor = p_id_proveedor;
    DELETE FROM UBICACIONES WHERE id_ubicacion = v_id_ubicacion;

    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Consultar (CO1). COMO administrador, QUIERO consultar los datos de contacto de un proveedor, su ubicacion
-- y cuantas compras le he hecho, PARA PODER contactarlo y evaluar que tanto le compro.
CREATE OR REPLACE FUNCTION mantener_proveedor.consultar(p_id_proveedor INTEGER)
RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_proveedor';
BEGIN
    OPEN cur FOR
        SELECT pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, pr.fecha_registro,
               u.ciudad,
               COUNT(co.id_compra) AS total_compras
        FROM PROVEEDORES pr
        LEFT JOIN UBICACIONES u ON pr.id_ubicacion = u.id_ubicacion
        LEFT JOIN COMPRAS co    ON pr.id_proveedor = co.id_proveedor
                               AND co.estado_compra <> 'Cancelada'
        WHERE pr.id_proveedor = p_id_proveedor
        GROUP BY pr.id_proveedor, pr.nombre, pr.telefono, pr.correo, pr.fecha_registro, u.ciudad;
    RETURN cur;
END;
$$ LANGUAGE plpgsql;


-- MANTENER_PRODUCTO
CREATE SCHEMA IF NOT EXISTS mantener_producto;

-- Adicionar: el producto se registra junto con su tipo; el estado lo asigna tg_productos
CREATE OR REPLACE PROCEDURE mantener_producto.adicionar_ropa(
    p_id_producto INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio_referencia NUMERIC,
    p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR,
    p_talla VARCHAR, p_genero VARCHAR, p_categoria_ropa VARCHAR, p_material VARCHAR)
AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
        VALUES (p_id_producto, p_nombre, p_descripcion, p_precio_referencia, p_marca, p_stock, p_imagen_url);

    INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
        VALUES (p_id_producto, p_talla, p_genero, p_categoria_ropa, p_material);

    COMMIT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_producto.adicionar_calzado(
    p_id_producto INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio_referencia NUMERIC,
    p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR,
    p_talla INTEGER, p_genero VARCHAR, p_categoria_calzado VARCHAR, p_material VARCHAR)
AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
        VALUES (p_id_producto, p_nombre, p_descripcion, p_precio_referencia, p_marca, p_stock, p_imagen_url);

    INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
        VALUES (p_id_producto, p_talla, p_genero, p_categoria_calzado, p_material);

    COMMIT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE mantener_producto.adicionar_accesorio(
    p_id_producto INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio_referencia NUMERIC,
    p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR,
    p_categoria VARCHAR, p_material VARCHAR, p_dimensiones VARCHAR)
AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, imagen_url)
        VALUES (p_id_producto, p_nombre, p_descripcion, p_precio_referencia, p_marca, p_stock, p_imagen_url);

    INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones)
        VALUES (p_id_producto, p_categoria, p_material, p_dimensiones);

    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Modificar: solo el precio de referencia y el stock (el estado lo actualiza tg_productos)
CREATE OR REPLACE PROCEDURE mantener_producto.modificar(p_id_producto INTEGER, p_precio_referencia NUMERIC, p_stock INTEGER)
AS $$
BEGIN
    UPDATE PRODUCTOS
        SET precio_referencia = p_precio_referencia, stock = p_stock
        WHERE id_producto = p_id_producto;

    IF NOT FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION USING MESSAGE = 'El producto no existe.',
        ERRCODE = 'C0004';
    END IF;

    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Eliminar: su tipo se borra en cascada; si ya se compro o vendio lo impiden las FK de los detalles
CREATE OR REPLACE PROCEDURE mantener_producto.eliminar(p_id_producto INTEGER)
AS $$
BEGIN
    DELETE FROM PRODUCTOS WHERE id_producto = p_id_producto;

    IF NOT FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION USING MESSAGE = 'El producto no existe.',
        ERRCODE = 'C0004';
    END IF;

    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Consultar disponibles (CO3). COMO vendedor, QUIERO consultar los productos disponibles organizados por
-- tipo y categoria, PARA PODER saber que le puedo ofrecer a un cliente.
CREATE OR REPLACE FUNCTION mantener_producto.consultar_disponibles()
RETURNS REFCURSOR AS $$
DECLARE cur REFCURSOR := 'cur_disponibles';
BEGIN
    OPEN cur FOR
        SELECT id_producto, nombre AS nombre_producto, marca, precio_referencia, stock, tipo_producto, categoria
        FROM VW_PRODUCTOS_TIPO
        WHERE estado = 'Disponible'
        ORDER BY tipo_producto, categoria, nombre_producto;
    RETURN cur;
END;
$$ LANGUAGE plpgsql;