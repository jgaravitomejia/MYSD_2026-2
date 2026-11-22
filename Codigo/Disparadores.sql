--Disparadores

-- UBICACIONES. Mantener ubicacion
CREATE OR REPLACE FUNCTION fn_ubicaciones()
RETURNS TRIGGER AS $$
BEGIN
    -- Adicionar
    IF TG_OP = 'INSERT' THEN
        -- tg.automatiza: la primera ubicacion de un cliente queda como principal;
        -- si ya tiene y la nueva llega como principal, la anterior deja de serlo
        IF NEW.id_cliente IS NOT NULL THEN
            IF NOT EXISTS (SELECT 1 FROM UBICACIONES WHERE id_cliente = NEW.id_cliente) THEN
                NEW.es_principal := TRUE;
            ELSIF NEW.es_principal THEN
                UPDATE UBICACIONES
                    SET es_principal = FALSE
                    WHERE id_cliente = NEW.id_cliente AND es_principal;
            END IF;
        END IF;

        RETURN NEW;
    END IF;

    -- Modificar
    IF TG_OP = 'UPDATE' THEN
        -- tg.restringe: una ubicacion no puede pasar a ser de otro cliente
        IF NEW.id_cliente IS DISTINCT FROM OLD.id_cliente THEN
            RAISE EXCEPTION USING MESSAGE = 'Una ubicacion no puede cambiar de cliente.',
            ERRCODE = 'A0001';
        END IF;

        -- tg.restringe: no se pueden modificar los datos de una ubicacion que ya se uso en una venta
        IF (NEW.calle, NEW.barrio, NEW.ciudad, NEW.departamento, NEW.codigo_postal)
           IS DISTINCT FROM (OLD.calle, OLD.barrio, OLD.ciudad, OLD.departamento, OLD.codigo_postal)
           AND EXISTS (SELECT 1 FROM VENTAS WHERE id_ubicacion = OLD.id_ubicacion) THEN
            RAISE EXCEPTION USING MESSAGE = 'No se pueden modificar los datos de una ubicacion que ya se uso en una venta.',
            ERRCODE = 'A0002';
        END IF;

        -- tg.restringe: la principal no se desmarca directamente, se marca otra como principal.
       
        IF OLD.es_principal AND NOT NEW.es_principal AND pg_trigger_depth() = 1 THEN  -- pg_trigger_depth() = 1 indica que el cambio lo pidio el usuario 
            RAISE EXCEPTION USING MESSAGE = 'Para cambiar la ubicacion principal se debe marcar otra ubicacion como principal.',
            ERRCODE = 'A0003';
        END IF;

        -- tg.automatiza: al marcar una ubicacion como principal, la anterior deja de serlo
        IF NEW.es_principal AND NOT OLD.es_principal THEN
            UPDATE UBICACIONES
                SET es_principal = FALSE
                WHERE id_cliente = NEW.id_cliente
                  AND id_ubicacion <> NEW.id_ubicacion
                  AND es_principal;
        END IF;

        RETURN NEW;
    END IF;

    -- Eliminar
    -- tg.restringe: no se puede eliminar la ubicacion principal del cliente.
    -- Si el cliente se esta eliminando, sus ubicaciones se borran en cascada y eso si se permite
    IF OLD.es_principal AND EXISTS (SELECT 1 FROM CLIENTES WHERE id_cliente = OLD.id_cliente) THEN
        RAISE EXCEPTION USING MESSAGE = 'No se puede eliminar la ubicacion principal del cliente.',
        ERRCODE = 'A0004';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_ubicaciones
    BEFORE INSERT OR UPDATE OR DELETE ON UBICACIONES
    FOR EACH ROW
    EXECUTE FUNCTION fn_ubicaciones();


-- CLIENTES. Mantener cliente
-- Adicionar: la fecha de registro la pone el DEFAULT y el correo repetido lo impide UK_CLIENTES_CORREO
-- Eliminar: un cliente con ventas no se puede eliminar por FK_VENTAS_CLIENTES con RESTRICT;
-- si no tiene ventas, sus ubicaciones se borran en cascada por FK_UBICACIONES_CLIENTES
CREATE OR REPLACE FUNCTION fn_clientes()
RETURNS TRIGGER AS $$
BEGIN
    -- Modificar
    -- tg.restringe: del cliente solo se pueden modificar el nombre y el telefono
    IF (NEW.id_cliente, NEW.correo, NEW.fecha_registro, NEW.notas)
       IS DISTINCT FROM (OLD.id_cliente, OLD.correo, OLD.fecha_registro, OLD.notas) THEN
        RAISE EXCEPTION USING MESSAGE = 'Del cliente solo se pueden modificar el nombre y el telefono.',
        ERRCODE = 'A0005';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes
    BEFORE UPDATE ON CLIENTES
    FOR EACH ROW
    EXECUTE FUNCTION fn_clientes();


-- PROVEEDORES. Mantener proveedor
-- Adicionar: la fecha de registro la pone el DEFAULT y el correo repetido lo impide UK_PROVEEDORES_CORREO
-- Eliminar: un proveedor con compras no se puede eliminar por FK_COMPRAS_PROVEEDORES con RESTRICT
CREATE OR REPLACE FUNCTION fn_proveedores()
RETURNS TRIGGER AS $$
BEGIN
    -- Modificar
    -- tg.restringe: del proveedor solo se pueden modificar el nombre y el telefono.
    -- Si su ubicacion se elimina, FK_PROVEEDORES_UBICACIONES la pone en NULL 
    IF (NEW.id_proveedor, NEW.correo, NEW.fecha_registro)
       IS DISTINCT FROM (OLD.id_proveedor, OLD.correo, OLD.fecha_registro)
       OR (NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion AND pg_trigger_depth() = 1) THEN
        RAISE EXCEPTION USING MESSAGE = 'Del proveedor solo se pueden modificar el nombre y el telefono.',
        ERRCODE = 'A0006';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_proveedores
    BEFORE UPDATE ON PROVEEDORES
    FOR EACH ROW
    EXECUTE FUNCTION fn_proveedores();


-- PRODUCTOS. Mantener producto
-- Eliminar: un producto que ya esta en compras o ventas no se puede eliminar por
-- FK_DETALLESCOMPRA_PRODUCTOS y FK_DETALLESVENTA_PRODUCTOS con RESTRICT;
-- si no tiene movimientos, su subtipo se borra en cascada
CREATE OR REPLACE FUNCTION fn_productos()
RETURNS TRIGGER AS $$
BEGIN
    -- Adicionar
    IF TG_OP = 'INSERT' THEN
        -- tg.automatiza: el estado se asigna segun el stock (la fecha de ingreso la pone el DEFAULT)
        NEW.estado := CASE WHEN NEW.stock > 0 THEN 'Disponible' ELSE 'Agotado' END;

        RETURN NEW;
    END IF;

    -- Modificar
    -- tg.restringe: del producto solo se pueden modificar el precio de referencia y el stock
    -- (el estado tampoco, porque lo actualiza este mismo disparador)
    IF (NEW.id_producto, NEW.nombre, NEW.descripcion, NEW.marca, NEW.fecha_ingreso, NEW.imagen_url, NEW.estado)
       IS DISTINCT FROM (OLD.id_producto, OLD.nombre, OLD.descripcion, OLD.marca, OLD.fecha_ingreso, OLD.imagen_url, OLD.estado) THEN
        RAISE EXCEPTION USING MESSAGE = 'Del producto solo se pueden modificar el precio de referencia y el stock.',
        ERRCODE = 'A0007';
    END IF;

    -- tg.automatiza: sin unidades queda 'Agotado' y con unidades no puede seguir 'Agotado'.
    -- Aplica a cualquier cambio de stock: el del usuario y el que hacen compras, ventas y cancelaciones
    IF NEW.stock = 0 THEN
        NEW.estado := 'Agotado';
    ELSIF NEW.estado = 'Agotado' THEN
        NEW.estado := 'Disponible';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_productos
    BEFORE INSERT OR UPDATE ON PRODUCTOS
    FOR EACH ROW
    EXECUTE FUNCTION fn_productos();


-- ROPA, CALZADO, ACCESORIOS. Mantener producto
-- La misma funcion se usa en las tres tablas; TG_TABLE_NAME dice en cual se esta insertando
CREATE OR REPLACE FUNCTION fn_subtipos()
RETURNS TRIGGER AS $$
BEGIN
    -- Adicionar
    -- tg.restringe: un producto es ropa, calzado o accesorio, solo uno de los tres
    IF (TG_TABLE_NAME <> 'ropa'       AND EXISTS (SELECT 1 FROM ROPA       WHERE id_producto = NEW.id_producto))
    OR (TG_TABLE_NAME <> 'calzado'    AND EXISTS (SELECT 1 FROM CALZADO    WHERE id_producto = NEW.id_producto))
    OR (TG_TABLE_NAME <> 'accesorios' AND EXISTS (SELECT 1 FROM ACCESORIOS WHERE id_producto = NEW.id_producto)) THEN
        RAISE EXCEPTION USING MESSAGE = 'El producto ya esta registrado con otro tipo (ropa, calzado o accesorio).',
        ERRCODE = 'A0008';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_ropa
    BEFORE INSERT ON ROPA
    FOR EACH ROW
    EXECUTE FUNCTION fn_subtipos();

CREATE OR REPLACE TRIGGER tg_calzado
    BEFORE INSERT ON CALZADO
    FOR EACH ROW
    EXECUTE FUNCTION fn_subtipos();

CREATE OR REPLACE TRIGGER tg_accesorios
    BEFORE INSERT ON ACCESORIOS
    FOR EACH ROW
    EXECUTE FUNCTION fn_subtipos();


-- COMPRAS. Registrar compra
-- Adicionar: la fecha y el estado 'Recibida' los pone el DEFAULT y el proveedor registrado lo exige FK_COMPRAS_PROVEEDORES
CREATE OR REPLACE FUNCTION fn_compras()
RETURNS TRIGGER AS $$
DECLARE v_detalle RECORD;
        v_stock INTEGER;
BEGIN
    -- Eliminar
    -- tg.restringe: las compras no se eliminan, se cancelan
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION USING MESSAGE = 'Las compras no se pueden eliminar, se deben cancelar.',
        ERRCODE = 'A0011';
    END IF;

    -- Modificar
    -- tg.restringe: la unica modificacion permitida es cancelar la compra
    IF (NEW.id_compra, NEW.fecha_compra, NEW.observacion, NEW.id_proveedor)
       IS DISTINCT FROM (OLD.id_compra, OLD.fecha_compra, OLD.observacion, OLD.id_proveedor)
       OR (OLD.estado_compra = 'Cancelada' AND NEW.estado_compra <> 'Cancelada') THEN
        RAISE EXCEPTION USING MESSAGE = 'La unica modificacion permitida de una compra es cancelarla.',
        ERRCODE = 'A0009';
    END IF;

    -- tg.automatiza: al cancelarla se retiran del stock las unidades que habia ingresado.
    -- El FOR recorre uno a uno los productos de la compra
    IF NEW.estado_compra = 'Cancelada' AND OLD.estado_compra <> 'Cancelada' THEN
        FOR v_detalle IN SELECT id_producto, cantidad FROM DETALLESDECOMPRAS WHERE id_compra = NEW.id_compra
        LOOP
            -- tg.restringe: no se puede cancelar si esas unidades ya fueron vendidas
            SELECT stock INTO v_stock FROM PRODUCTOS WHERE id_producto = v_detalle.id_producto;
            IF v_stock < v_detalle.cantidad THEN
                RAISE EXCEPTION USING MESSAGE = 'No se puede cancelar la compra porque sus unidades ya fueron vendidas.',
                ERRCODE = 'A0010';
            END IF;

            UPDATE PRODUCTOS
                SET stock = stock - v_detalle.cantidad
                WHERE id_producto = v_detalle.id_producto;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_compras
    BEFORE UPDATE OR DELETE ON COMPRAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_compras();


-- DETALLESDECOMPRAS. Registrar compra (productos de la compra)
-- Que un producto aparezca una sola vez lo resuelve la PK compuesta; cantidad y precio > 0, los CHECK
CREATE OR REPLACE FUNCTION fn_detallesdecompras()
RETURNS TRIGGER AS $$
BEGIN
    -- Modificar y eliminar
    -- tg.restringe: los productos de una compra no se cambian ni se quitan; la compra se cancela
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        RAISE EXCEPTION USING MESSAGE = 'La unica modificacion permitida de una compra es cancelarla.',
        ERRCODE = 'A0009';
    END IF;

    -- Adicionar
    -- tg.restringe: el producto debe estar registrado como ropa, calzado o accesorio
    IF NOT EXISTS (SELECT 1 FROM ROPA       WHERE id_producto = NEW.id_producto)
       AND NOT EXISTS (SELECT 1 FROM CALZADO    WHERE id_producto = NEW.id_producto)
       AND NOT EXISTS (SELECT 1 FROM ACCESORIOS WHERE id_producto = NEW.id_producto) THEN
        RAISE EXCEPTION USING MESSAGE = 'El producto no tiene tipo registrado (ropa, calzado o accesorio).',
        ERRCODE = 'A0012';
    END IF;

    -- tg.restringe: no se pueden agregar productos a una compra cancelada
    IF (SELECT estado_compra FROM COMPRAS WHERE id_compra = NEW.id_compra) = 'Cancelada' THEN
        RAISE EXCEPTION USING MESSAGE = 'No se pueden agregar productos a una compra cancelada.',
        ERRCODE = 'A0013';
    END IF;

    -- tg.automatiza: el stock del producto aumenta con lo comprado
    -- (si estaba 'Agotado', fn_productos lo pasa a 'Disponible')
    UPDATE PRODUCTOS
        SET stock = stock + NEW.cantidad
        WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_detallesdecompras
    BEFORE INSERT OR UPDATE OR DELETE ON DETALLESDECOMPRAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_detallesdecompras();

-- VENTAS. Registrar venta
-- Adicionar: la fecha y el estado 'Pendiente' los pone el DEFAULT, el cliente registrado lo exige
-- FK_VENTAS_CLIENTES y el metodo de pago y el medio de entrega los CHECK de TMetodoPago y TMedioEntrega
CREATE OR REPLACE FUNCTION fn_ventas()
RETURNS TRIGGER AS $$
DECLARE v_detalle RECORD;
BEGIN
    -- Adicionar
    IF TG_OP = 'INSERT' THEN
        -- tg.automatiza: si no se indica la ubicacion de entrega, se usa la principal del cliente
        IF NEW.id_ubicacion IS NULL THEN
            SELECT id_ubicacion INTO NEW.id_ubicacion
                FROM UBICACIONES
                WHERE id_cliente = NEW.id_cliente AND es_principal;
        END IF;

        -- tg.restringe: la ubicacion de entrega debe ser una de las ubicaciones del cliente
        IF NOT EXISTS (SELECT 1 FROM UBICACIONES
                       WHERE id_ubicacion = NEW.id_ubicacion AND id_cliente = NEW.id_cliente) THEN
            RAISE EXCEPTION USING MESSAGE = 'La ubicacion de entrega debe ser una de las ubicaciones del cliente.',
            ERRCODE = 'A0014';
        END IF;

        RETURN NEW;
    END IF;

    -- Eliminar
    -- tg.restringe: las ventas no se eliminan, se cancelan
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION USING MESSAGE = 'Las ventas no se pueden eliminar, se deben cancelar.',
        ERRCODE = 'A0017';
    END IF;

    -- Modificar
    -- tg.restringe: de la venta solo se puede modificar el estado
    IF (NEW.id_venta, NEW.fecha_venta, NEW.metodo_pago, NEW.medio_entrega, NEW.observaciones, NEW.id_cliente, NEW.id_ubicacion)
       IS DISTINCT FROM (OLD.id_venta, OLD.fecha_venta, OLD.metodo_pago, OLD.medio_entrega, OLD.observaciones, OLD.id_cliente, OLD.id_ubicacion) THEN
        RAISE EXCEPTION USING MESSAGE = 'De la venta solo se puede modificar el estado.',
        ERRCODE = 'A0015';
    END IF;

    -- tg.restringe: el estado solo pasa de 'Pendiente' a 'Completada'
    -- y de 'Pendiente' o 'Completada' a 'Cancelada'; una venta cancelada no cambia
    IF NEW.estado_venta <> OLD.estado_venta AND NOT (
           (OLD.estado_venta = 'Pendiente'  AND NEW.estado_venta IN ('Completada', 'Cancelada'))
        OR (OLD.estado_venta = 'Completada' AND NEW.estado_venta = 'Cancelada')) THEN
        RAISE EXCEPTION USING MESSAGE = 'Cambio de estado de venta no permitido.',
        ERRCODE = 'A0016';
    END IF;

    -- tg.automatiza: al cancelarla, las unidades vendidas vuelven al stock.
    -- El FOR recorre uno a uno los productos de la venta
    IF NEW.estado_venta = 'Cancelada' AND OLD.estado_venta <> 'Cancelada' THEN
        FOR v_detalle IN SELECT id_producto, cantidad FROM DETALLESDEVENTAS WHERE id_venta = NEW.id_venta
        LOOP
            UPDATE PRODUCTOS
                SET stock = stock + v_detalle.cantidad
                WHERE id_producto = v_detalle.id_producto;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_ventas
    BEFORE INSERT OR UPDATE OR DELETE ON VENTAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_ventas();


-- DETALLESDEVENTAS. Registrar venta (productos de la venta)
-- Que un producto aparezca una sola vez lo resuelve la PK compuesta; cantidad y precio > 0, los CHECK;
-- que el descuento no supere el precio, CK_DETALLESVENTA_DESCUENTOVSPRECIO
CREATE OR REPLACE FUNCTION fn_detallesdeventas()
RETURNS TRIGGER AS $$
DECLARE v_estado_venta VARCHAR(20);
        v_stock INTEGER;
BEGIN
    -- Modificar y eliminar
    -- tg.restringe: los productos de una venta no se cambian ni se quitan; la venta se cancela
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        RAISE EXCEPTION USING MESSAGE = 'De la venta solo se puede modificar el estado.',
        ERRCODE = 'A0015';
    END IF;

    -- Adicionar
    -- tg.restringe: el producto debe estar registrado como ropa, calzado o accesorio
    IF NOT EXISTS (SELECT 1 FROM ROPA       WHERE id_producto = NEW.id_producto)
       AND NOT EXISTS (SELECT 1 FROM CALZADO    WHERE id_producto = NEW.id_producto)
       AND NOT EXISTS (SELECT 1 FROM ACCESORIOS WHERE id_producto = NEW.id_producto) THEN
        RAISE EXCEPTION USING MESSAGE = 'El producto no tiene tipo registrado (ropa, calzado o accesorio).',
        ERRCODE = 'A0012';
    END IF;

    -- tg.restringe: solo se pueden agregar productos mientras la venta esta 'Pendiente'
    SELECT estado_venta INTO v_estado_venta FROM VENTAS WHERE id_venta = NEW.id_venta;
    IF v_estado_venta <> 'Pendiente' THEN
        RAISE EXCEPTION USING MESSAGE = 'Solo se pueden agregar productos a una venta Pendiente.',
        ERRCODE = 'A0018';
    END IF;

    -- tg.restringe: no se pueden vender mas unidades de las que hay en stock
    SELECT stock INTO v_stock FROM PRODUCTOS WHERE id_producto = NEW.id_producto;
    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION USING MESSAGE = 'No hay stock suficiente del producto para esta venta.',
        ERRCODE = 'A0019';
    END IF;

    -- tg.automatiza: el stock del producto se descuenta con lo vendido
    -- (si llega a cero, fn_productos lo pasa a 'Agotado')
    UPDATE PRODUCTOS
        SET stock = stock - NEW.cantidad
        WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_detallesdeventas
    BEFORE INSERT OR UPDATE OR DELETE ON DETALLESDEVENTAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_detallesdeventas();


-- FACTURAS. Registrar factura
-- Adicionar: la fecha de emision y el estado 'Emitida' los pone el DEFAULT; el total se calcula
-- al asociar la factura a su venta o compra (FACTURASVENTA y FACTURASCOMPRA)
CREATE OR REPLACE FUNCTION fn_facturas()
RETURNS TRIGGER AS $$
BEGIN
    -- Eliminar
    -- tg.restringe: no se puede eliminar una factura pagada
    -- (si se elimina, su FACTURASVENTA o FACTURASCOMPRA se borra en cascada)
    IF TG_OP = 'DELETE' THEN
        IF OLD.estado_factura = 'Pagada' THEN
            RAISE EXCEPTION USING MESSAGE = 'Una factura pagada no se puede eliminar.',
            ERRCODE = 'A0022';
        END IF;

        RETURN OLD;
    END IF;

    -- Modificar
    -- tg.restringe: una factura pagada no se puede modificar
    IF OLD.estado_factura = 'Pagada' THEN
        RAISE EXCEPTION USING MESSAGE = 'Una factura pagada no se puede modificar.',
        ERRCODE = 'A0020';
    END IF;

    -- tg.restringe: solo se puede modificar el estado.
    -- El total lo cambian los disparadores de FACTURASVENTA y FACTURASCOMPRA (pg_trigger_depth() > 1)
    IF (NEW.id_factura, NEW.fecha_emision, NEW.observaciones)
       IS DISTINCT FROM (OLD.id_factura, OLD.fecha_emision, OLD.observaciones)
       OR (NEW.total <> OLD.total AND pg_trigger_depth() = 1) THEN
        RAISE EXCEPTION USING MESSAGE = 'De la factura solo se puede modificar el estado.',
        ERRCODE = 'A0021';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturas
    BEFORE UPDATE OR DELETE ON FACTURAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_facturas();


-- FACTURASVENTA. Registrar factura (factura de una venta)
-- Que una venta tenga maximo una factura lo resuelve UK_FACTURASVENTA_VENTA
CREATE OR REPLACE FUNCTION fn_facturasventa()
RETURNS TRIGGER AS $$
BEGIN
    -- Modificar y eliminar
    -- tg.restringe: la factura no cambia de venta ni se separa de ella; solo cambia su estado.
    -- Si se elimina la factura, esta fila se borra en cascada (pg_trigger_depth() > 1) y eso si se permite
    IF TG_OP = 'UPDATE' OR (TG_OP = 'DELETE' AND pg_trigger_depth() = 1) THEN
        RAISE EXCEPTION USING MESSAGE = 'De la factura solo se puede modificar el estado.',
        ERRCODE = 'A0021';
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    -- Adicionar
    -- tg.restringe: solo se facturan ventas que no esten canceladas y que tengan productos
    IF (SELECT estado_venta FROM VENTAS WHERE id_venta = NEW.id_venta) = 'Cancelada'
       OR NOT EXISTS (SELECT 1 FROM DETALLESDEVENTAS WHERE id_venta = NEW.id_venta) THEN
        RAISE EXCEPTION USING MESSAGE = 'Solo se pueden facturar ventas no canceladas y con productos.',
        ERRCODE = 'A0023';
    END IF;

    -- tg.automatiza: el total es la suma de (precio * cantidad - descuento) de los productos de la venta
    UPDATE FACTURAS
        SET total = (SELECT SUM(precio_venta * cantidad - COALESCE(descuento, 0))
                     FROM DETALLESDEVENTAS
                     WHERE id_venta = NEW.id_venta)
        WHERE id_factura = NEW.id_factura;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturasventa
    BEFORE INSERT OR UPDATE OR DELETE ON FACTURASVENTA
    FOR EACH ROW
    EXECUTE FUNCTION fn_facturasventa();


-- FACTURASCOMPRA. Registrar factura (factura de una compra)
-- Que una compra tenga maximo una factura lo resuelve UK_FACTURASCOMPRA_COMPRA
CREATE OR REPLACE FUNCTION fn_facturascompra()
RETURNS TRIGGER AS $$
BEGIN
    -- Modificar y eliminar
    -- tg.restringe: la factura no cambia de compra ni se separa de ella; solo cambia su estado.
    -- Si se elimina la factura, esta fila se borra en cascada (pg_trigger_depth() > 1) y eso si se permite
    IF TG_OP = 'UPDATE' OR (TG_OP = 'DELETE' AND pg_trigger_depth() = 1) THEN
        RAISE EXCEPTION USING MESSAGE = 'De la factura solo se puede modificar el estado.',
        ERRCODE = 'A0021';
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    -- Adicionar
    -- tg.restringe: solo se facturan compras que no esten canceladas y que tengan productos
    IF (SELECT estado_compra FROM COMPRAS WHERE id_compra = NEW.id_compra) = 'Cancelada'
       OR NOT EXISTS (SELECT 1 FROM DETALLESDECOMPRAS WHERE id_compra = NEW.id_compra) THEN
        RAISE EXCEPTION USING MESSAGE = 'Solo se pueden facturar compras no canceladas y con productos.',
        ERRCODE = 'A0024';
    END IF;

    -- tg.automatiza: el total es la suma de (precio * cantidad) de los productos de la compra
    UPDATE FACTURAS
        SET total = (SELECT SUM(precio_compra * cantidad)
                     FROM DETALLESDECOMPRAS
                     WHERE id_compra = NEW.id_compra)
        WHERE id_factura = NEW.id_factura;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturascompra
    BEFORE INSERT OR UPDATE OR DELETE ON FACTURASCOMPRA
    FOR EACH ROW
    EXECUTE FUNCTION fn_facturascompra();