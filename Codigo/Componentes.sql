-- MANTENER_UBICACION

-- Inserta una nueva ubicacion
CREATE OR REPLACE PROCEDURE adicionar_ubicacion(p_id_ubicacion INTEGER, p_calle VARCHAR, p_barrio VARCHAR, p_ciudad VARCHAR, p_departamento VARCHAR, p_codigo_postal VARCHAR, p_es_principal BOOLEAN)
AS $$
BEGIN
    INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal)
    VALUES (p_id_ubicacion, p_calle, p_barrio, p_ciudad, p_departamento, p_codigo_postal, p_es_principal);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_ubicacion: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- MANTENER_CLIENTE

--(fecha_registro la asigna el trigger T6 si es NULL)
CREATE OR REPLACE PROCEDURE adicionar_cliente(p_id_cliente INTEGER, p_nombre VARCHAR, p_telefono VARCHAR, p_correo VARCHAR, p_notas VARCHAR, p_id_ubicacion INTEGER)
AS $$
BEGIN
    INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas, id_ubicacion)
    VALUES (p_id_cliente, p_nombre, p_telefono, p_correo, NULL, p_notas, p_id_ubicacion);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_cliente: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--Modifica nombre y telefono de un cliente existente
CREATE OR REPLACE PROCEDURE modificar_cliente(p_Nnombre VARCHAR, p_Ntelefono VARCHAR, p_Nid_cliente INTEGER)
AS $$
BEGIN 
    UPDATE CLIENTES
    SET nombre = p_Nnombre,
        telefono = p_Ntelefono
    WHERE id_cliente = p_Nid_cliente;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en modificar_cliente: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- MANTENER_PROVEEDOR

-- Inserta un nuevo proveedor
CREATE OR REPLACE PROCEDURE adicionar_proveedor(p_id_proveedor INTEGER, p_nombre VARCHAR, p_telefono VARCHAR, p_correo VARCHAR, p_id_ubicacion INTEGER)
AS $$
BEGIN
    INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion)
    VALUES (p_id_proveedor, p_nombre, p_telefono, p_correo, NOW(), p_id_ubicacion);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_proveedor: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Modifica nombre y telefono de un proveedor existente
CREATE OR REPLACE PROCEDURE modificar_proveedor(p_Nnombre VARCHAR, p_Ntelefono VARCHAR, p_Nid_proveedor INTEGER)
AS $$
BEGIN 
    UPDATE PROVEEDORES
    SET nombre = p_Nnombre,
        telefono = p_Ntelefono
    WHERE id_proveedor = p_Nid_proveedor;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en modificar_proveedor: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- MANTENER_PRODUCTO

-- Inserta un nuevo producto base
CREATE OR REPLACE PROCEDURE adicionar_producto(p_id_producto INTEGER, p_nombre VARCHAR, p_descripcion VARCHAR, p_precio_referencia NUMERIC, p_marca VARCHAR, p_stock INTEGER, p_imagen_url VARCHAR)
AS $$
BEGIN
    INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (p_id_producto, p_nombre, p_descripcion, p_precio_referencia, p_marca, p_stock,
            CASE WHEN p_stock > 0 THEN 'Disponible' ELSE 'Agotado' END, NOW(), p_imagen_url);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_producto: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Modificar un precio y stock de un producto 
CREATE OR REPLACE PROCEDURE modificar_producto(p_Nprecio_referencia NUMERIC, p_Nstock INTEGER, p_Nid_producto INTEGER)
AS $$
BEGIN
    UPDATE PRODUCTOS
    SET precio_referencia = p_Nprecio_referencia,
        stock = p_Nstock,
        estado = CASE WHEN p_Nstock > 0 THEN 'Disponible' ELSE 'Agotado' END
    WHERE id_producto = p_Nid_producto;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en modificar_producto: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Inserta un producto de tipo ropa 
CREATE OR REPLACE PROCEDURE adicionar_producto_ropa(p_id_producto INTEGER, p_talla VARCHAR, p_genero VARCHAR, p_categoria_ropa VARCHAR, p_material VARCHAR)
AS $$
BEGIN
    INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
    VALUES (p_id_producto, p_talla, p_genero, p_categoria_ropa, p_material);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_producto_ropa: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Inserta un producto de tipo calzado
CREATE OR REPLACE PROCEDURE adicionar_producto_calzado(p_id_producto INTEGER, p_talla NUMERIC, p_genero VARCHAR, p_categoria_calzado VARCHAR, p_material VARCHAR)
AS $$
BEGIN
    INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (p_id_producto, p_talla, p_genero, p_categoria_calzado, p_material);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_producto_calzado: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Inserta un producto de tipo accesorio
CREATE OR REPLACE PROCEDURE adicionar_producto_accesorio(p_id_producto INTEGER, p_categoria VARCHAR, p_material VARCHAR, p_dimensiones VARCHAR)
AS $$
BEGIN
    INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones)
    VALUES (p_id_producto, p_categoria, p_material, p_dimensiones);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_producto_accesorio: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- REGISTAR_VENTA

-- Crear una nueva venta
CREATE OR REPLACE PROCEDURE adicionar_venta(p_id_venta INTEGER, p_metodo_pago VARCHAR, p_medio_entrega VARCHAR, p_observaciones VARCHAR, p_id_cliente INTEGER)
AS $$
BEGIN
    INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (p_id_venta, NOW(), p_metodo_pago, 'Completada', p_medio_entrega, p_observaciones, p_id_cliente);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_venta: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Agregar un producto a una venta 
-- (el trigger T1 valida el stock y lo descuenta)
CREATE OR REPLACE PROCEDURE adicionar_detalle_venta(p_id_venta INTEGER, p_id_producto INTEGER, p_cantidad INTEGER, p_precio_venta NUMERIC, p_descuento NUMERIC)
AS $$
BEGIN
    INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (p_id_venta, p_id_producto, p_cantidad, p_precio_venta, p_descuento);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_detalle_venta: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Cancelar una venta
CREATE OR REPLACE PROCEDURE cancelar_venta(p_id_venta INTEGER)
AS $$
BEGIN
    UPDATE VENTAS
    SET estado_venta = 'Cancelada'
    WHERE id_venta = p_id_venta;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en cancelar_venta: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- REGISTRAR_COMPRA

-- Crear una nueva compra
CREATE OR REPLACE PROCEDURE adicionar_compra(p_id_compra INTEGER, p_observacion VARCHAR, p_id_proveedor INTEGER)
AS $$
BEGIN
    INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
    VALUES (p_id_compra, NOW(), 'Recibida', p_observacion, p_id_proveedor);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_compra: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Agregar un producto a una compra
-- (el trigger T2 aumenta el stock)
CREATE OR REPLACE PROCEDURE adicionar_detalle_compra(p_id_compra INTEGER, p_id_producto INTEGER, p_cantidad INTEGER, p_precio_compra NUMERIC)
AS $$
BEGIN
    INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (p_id_compra, p_id_producto, p_cantidad, p_precio_compra);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_detalle_compra: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Cancela una compra
CREATE OR REPLACE PROCEDURE cancelar_compra(p_id_compra INTEGER)
AS $$
BEGIN
    UPDATE COMPRAS
    SET estado_compra = 'Cancelada'
    WHERE id_compra = p_id_compra;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en cancelar_compra: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- REGISTRAR_FACTURA

-- Crear una nueva factura
-- (el trigger T5 asigna fecha si es NULL)
CREATE OR REPLACE PROCEDURE adicionar_factura(p_id_factura INTEGER, p_estado_factura VARCHAR, p_observaciones VARCHAR)
AS $$
BEGIN
    INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (p_id_factura, NULL, 1, p_estado_factura, p_observaciones);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_factura: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Asocia una factura a una venta 
CREATE OR REPLACE PROCEDURE adicionar_factura_venta(p_id_factura INTEGER, p_id_venta INTEGER, p_numero_guia VARCHAR)
AS $$
BEGIN
    INSERT INTO FACTURASVENTA (id_factura, id_venta,  numero_guia)
    VALUES (p_id_factura, p_id_venta, p_numero_guia);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_factura_venta: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Asocia una factura a una compra
CREATE OR REPLACE PROCEDURE adicionar_factura_compra(p_id_factura INTEGER, p_id_compra INTEGER, p_numero_remision VARCHAR)
AS $$
BEGIN
    INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
    VALUES (p_id_factura, p_id_compra, p_numero_remision);
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Error en adicionar_factura_compra: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
