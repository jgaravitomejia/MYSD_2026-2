--Trigger 1: Control de stock en dettales de venta
--Fn1: al vender, verifica si hay stock y lo descuenta
CREATE OR REPLACE FUNCTION fn_descontar_stock_venta()
RETURNS TRIGGER AS $$
DECLARE     
    v_stock INTEGER;
BEGIN
    --lee el stock actual del producto que se esta vendiendo
    SELECT stock INTO v_stock
    FROM PRODUCTOS
    WHERE id_producto = NEW.id_producto;
    --si no hay stock suficiente, se lanza un error
    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION 'No hay stock suficiente para el producto % (disponible: %, pedido: %)', NEW.id_producto, v_stock, NEW.cantidad;
    END IF;

    --descuenta el stock y si llega a 0 cambia el estado a 'Agotado'
    UPDATE PRODUCTOS
        SET stock = stock - NEW.cantidad,
            estado = CASE WHEN stock - NEW.cantidad = 0 THEN 'Agotado' ELSE estado END
        WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger 1
CREATE OR REPLACE TRIGGER tg_descontar_stock_venta
BEFORE INSERT ON DETALLESDEVENTAS
FOR EACH ROW
EXECUTE FUNCTION fn_descontar_stock_venta();


--Trigger 2: Control de stock en detalles de compra
--Fn2: al comprar, incrementa el stock
CREATE OR REPLACE FUNCTION fn_aumentar_stock_compra()
RETURNS TRIGGER AS $$
BEGIN
    --Suma la cantidad comprada al stock del producto
    --si estaba 'Agotado', lo pasa a 'Disponible'
    UPDATE PRODUCTOS
        SET stock = stock + NEW.cantidad,
            estado = CASE WHEN estado = 'Agotado' THEN 'Disponible' ELSE estado END
        WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger 2
CREATE OR REPLACE TRIGGER tg_aumentar_stock_compra
BEFORE INSERT ON DETALLESDECOMPRAS
FOR EACH ROW
EXECUTE FUNCTION fn_aumentar_stock_compra();


--Trigger 3: Solo facturar ventas validas
--Fn3: al insertar en FACTURASVENTA, verifica que la venta exista, no este cancelada y tenga productos
CREATE OR REPLACE FUNCTION fn_validar_venta_facturable()
RETURNS TRIGGER AS $$
DECLARE 
    v_estado VARCHAR(20);
    v_tiene_productos INTEGER;
BEGIN
    --busca el estado de la venta
    SELECT estado_venta INTO v_estado
    FROM VENTAS
    WHERE id_venta = NEW.id_venta;

    --si no se encontró el estado, significa que la venta no existe
    IF v_estado IS NULL THEN
        RAISE EXCEPTION 'La venta % no existe', NEW.id_venta;
    END IF;

    --si la venta está cancelada, se lanza un error
    IF v_estado = 'Cancelada' THEN
        RAISE EXCEPTION 'La venta % está cancelada', NEW.id_venta;
    END IF;

    --Verifica que la venta tenga al menos un producto en sus detalles
    SELECT COUNT(*) INTO v_tiene_productos
    FROM DETALLESDEVENTAS
    WHERE id_venta = NEW.id_venta;

    IF v_tiene_productos = 0 THEN
        RAISE EXCEPTION 'La venta % no tiene productos, por lo que no se puede facturar', NEW.id_venta;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger 3
CREATE OR REPLACE TRIGGER tg_validar_venta_facturable
BEFORE INSERT ON FACTURASVENTA
FOR EACH ROW
EXECUTE FUNCTION fn_validar_venta_facturable();


--Trigger 4: Solo facturar compras validas
--Fn4: al insertar en FACTURASCOMPRA, verifica que la compra exista, no este cancelada y tenga productos
CREATE OR REPLACE FUNCTION fn_validar_compra_facturable()
RETURNS TRIGGER AS $$
DECLARE 
    v_estado VARCHAR(20);
    v_tiene_productos INTEGER;
BEGIN
    --busca el estado de la compra
    SELECT estado_compra INTO v_estado
    FROM COMPRAS
    WHERE id_compra = NEW.id_compra;

    --si no se encontró el estado, significa que la compra no existe
    IF v_estado IS NULL THEN
        RAISE EXCEPTION 'La compra % no existe', NEW.id_compra;
    END IF;

    --si la compra está cancelada, se lanza un error
    IF v_estado = 'Cancelada' THEN
        RAISE EXCEPTION 'La compra % está cancelada, por lo que no se puede facturar', NEW.id_compra;
    END IF;

    --Verifica que la compra tenga al menos un producto en sus detalles
    SELECT COUNT(*) INTO v_tiene_productos
    FROM DETALLESDECOMPRAS
    WHERE id_compra = NEW.id_compra;

    IF v_tiene_productos = 0 THEN
        RAISE EXCEPTION 'La compra % no tiene productos, por lo que no se puede facturar', NEW.id_compra;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger 4
CREATE OR REPLACE TRIGGER tg_validar_compra_facturable
BEFORE INSERT ON FACTURASCOMPRA
FOR EACH ROW
EXECUTE FUNCTION fn_validar_compra_facturable();


--Trigger 5: Fecha de emision automatica en FACTURAS
--Fn5: si se inserta una factura sin fecha, la llena con NOW()
CREATE OR REPLACE FUNCTION fn_fecha_factura_automatica()
RETURNS TRIGGER AS $$
BEGIN
    --si la fecha de emision es nula, se asigna la fecha y hora actual
    IF NEW.fecha_emision IS NULL THEN
        NEW.fecha_emision := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger5
CREATE OR REPLACE TRIGGER tg_fecha_factura_automatica
    BEFORE INSERT ON FACTURAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_fecha_factura_automatica();


--Trigger 6: Fecha de registro automatica en CLIENTES
--Fn6: si se inserta un cliente sin fecha de registro, la llena con NOW()
CREATE OR REPLACE FUNCTION fn_fecha_cliente_automatica()
RETURNS TRIGGER AS $$
BEGIN
    --si la fecha de registro es nula, se asigna la fecha y hora actual
    IF NEW.fecha_registro IS NULL THEN
        NEW.fecha_registro := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger6
CREATE OR REPLACE TRIGGER tg_fecha_cliente_automatica
    BEFORE INSERT ON CLIENTES
    FOR EACH ROW
    EXECUTE FUNCTION fn_fecha_cliente_automatica();


--Trigger 7: No permitir eliminar un cliente que tiene ventas asociadas
--Fn7: antes de eliminar un cliente, verifica que no tenga ventas asociadas
CREATE OR REPLACE FUNCTION fn_validar_eliminacion_cliente()
RETURNS TRIGGER AS $$
DECLARE 
    v_count INTEGER;
BEGIN
    --cuenta cuantas ventas tiene el cliente
    SELECT COUNT(*) INTO v_count FROM VENTAS WHERE id_cliente = OLD.id_cliente;
    --si tiene al menos una venta asociada, no permite la eliminacion
    IF v_count > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el cliente % porque tiene % venta(s) asociadas', OLD.id_cliente, v_count;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

--Trigger7
CREATE TRIGGER tg_validar_eliminacion_cliente
    BEFORE DELETE ON CLIENTES
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_eliminacion_cliente();


--Trigger 8: No permitir modificar o eliminar una factura que ya esta pagada
--Fn8: antes de actualizar o eliminar una factura, verifica que no este en estado 'Pagada'
CREATE OR REPLACE FUNCTION fn_validar_modificacion_factura()
RETURNS TRIGGER AS $$
BEGIN
    --si la factura ya esta pagada, no permite la modificacion ni eliminacion
    IF OLD.estado_factura = 'Pagada' THEN
        RAISE EXCEPTION 'No se puede modificar ni eliminar la factura % porque ya esta pagada', OLD.id_factura;
    END IF;

    --si es DELETE retorna OLD, si es UPDATE retorna NEW
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger8
CREATE TRIGGER tg_validar_modificacion_factura
    BEFORE UPDATE OR DELETE ON FACTURAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_modificacion_factura();


--Trigger 9: Cancelar venta devuelve stock
--Fn9: cuando una venta cambia a 'Cancelada', recorre sus detalles y devuelve las cantidades al stock
CREATE OR REPLACE FUNCTION fn_cancelar_venta_devuelve_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_detalle RECORD;
BEGIN
    --si la venta cambia a 'Cancelada', devuelve el stock
    IF NEW.estado_venta = 'Cancelada' AND OLD.estado_venta <> 'Cancelada' THEN
        --recorre cada detalle de la venta
        FOR v_detalle IN SELECT id_producto, cantidad FROM DETALLESDEVENTAS WHERE id_venta = NEW.id_venta 
        LOOP
            --devuelve la cantidad al stock del producto
            --si estaba 'Agotado', cambia a 'Disponible'
            UPDATE PRODUCTOS
            SET stock = stock + v_detalle.cantidad,
                estado = CASE WHEN estado = 'Agotado' THEN 'Disponible' ELSE estado END
            WHERE id_producto = v_detalle.id_producto;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger9
CREATE TRIGGER tg_cancelar_venta_devuelve_stock
    BEFORE UPDATE ON VENTAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_cancelar_venta_devuelve_stock();


--Trigger 10: Cancelar compra retira stock
--Fn10: cuando una compra cambia a 'Cancelada', recorre sus detalles y resta las cantidades al stock
CREATE OR REPLACE FUNCTION fn_cancelar_compra_retira_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_detalle RECORD;
    v_stock INTEGER;
BEGIN
    --si la compra cambia a 'Cancelada', resta el stock
    IF NEW.estado_compra = 'Cancelada' AND OLD.estado_compra <> 'Cancelada' THEN
        --recorre cada detalle de la compra
        FOR v_detalle IN SELECT id_producto, cantidad FROM DETALLESDECOMPRAS WHERE id_compra = NEW.id_compra 
        LOOP
            --lee el stock actual del producto para verificar que se pueda retirar
            SELECT stock INTO v_stock FROM PRODUCTOS WHERE id_producto = v_detalle.id_producto;
            -- si no hay suficiente stock para retirar, aborta
            IF v_stock < v_detalle.cantidad THEN
                RAISE EXCEPTION 'No se puede retirar la compra %:No hay suficiente stock para el producto % (disponible: %, necesario: %)', NEW.id_compra, v_detalle.id_producto, v_stock, v_detalle.cantidad;
            END IF;

            --resta la cantidad al stock del producto
            --si estaba 'Disponible', cambia a 'Agotado'
            UPDATE PRODUCTOS
            SET stock = stock - v_detalle.cantidad,
                estado = CASE WHEN stock - v_detalle.cantidad = 0 THEN 'Agotado' ELSE estado END
            WHERE id_producto = v_detalle.id_producto;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger10
CREATE TRIGGER tg_cancelar_compra_retira_stock
    BEFORE UPDATE ON COMPRAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_cancelar_compra_retira_stock();


--Trigger 11: Total de la factura de venta
--Fn11: al insertar en FACTURASVENTA, calcula el total sumando (precio_venta * cantidad) - descuento
CREATE OR REPLACE FUNCTION fn_calcula_total_factura_venta()
RETURNS TRIGGER AS $$
DECLARE
    v_total NUMERIC(12,2);
BEGIN
    --suma todos los detalles de venta: (precio_venta * cantidad) - descuento
    --COALESCE se usa para manejar valores nulos en el descuento para manejarlos como 0, y para que el valor no sea null total es NOT NULL)
    SELECT COALESCE(SUM((precio_venta * cantidad) - COALESCE(descuento, 0)), 0)
    INTO v_total
    FROM DETALLESDEVENTAS
    WHERE id_venta = NEW.id_venta;

    --actualiza el total en la factura de venta correspondiente
    UPDATE FACTURAS
    SET total = v_total
    WHERE id_factura = NEW.id_factura;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger11
CREATE TRIGGER tg_calcula_total_factura_venta
    BEFORE INSERT ON FACTURASVENTA
    FOR EACH ROW
    EXECUTE FUNCTION fn_calcula_total_factura_venta();


--Trigger 12: Total de la factura de compra 
--Fn12: al insertar en FACTURASCOMPRA, calcula el total sumando (precio_compra * cantidad)
CREATE OR REPLACE FUNCTION fn_calcula_total_factura_compra()
RETURNS TRIGGER AS $$
DECLARE
    v_total NUMERIC(12,2);
BEGIN
    --suma todos los detalles de compra: (precio_compra * cantidad)
    --COALESCE se usa para manejar valores nulos en la suma para que el total no sea null (total es NOT NULL)
    SELECT COALESCE(SUM(precio_compra * cantidad), 0)
    INTO v_total
    FROM DETALLESDECOMPRAS
    WHERE id_compra = NEW.id_compra;

    --actualiza el total en la factura de compra correspondiente
    UPDATE FACTURAS
    SET total = v_total
    WHERE id_factura = NEW.id_factura;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger12
CREATE TRIGGER tg_calcula_total_factura_compra
    AFTER INSERT ON FACTURASCOMPRA
    FOR EACH ROW
    EXECUTE FUNCTION fn_calcula_total_factura_compra();


--Trigger 13: Validar subtipo de producto
--Fn13: antes de insertar en DETALLESDEVENTAS o DETALLESDECOMPRAS, verifica que el producto tenga un subtipo registrado (ropa, calzado o accesorio)
CREATE OR REPLACE FUNCTION fn_validar_subtipo_producto()
RETURNS TRIGGER AS $$
BEGIN
    --verifica si el producto existe en alguna de las tablas de subtipo
    IF NOT EXISTS (SELECT 1 FROM ROPA WHERE id_producto = NEW.id_producto)
       AND NOT EXISTS (SELECT 1 FROM CALZADO WHERE id_producto = NEW.id_producto)
       AND NOT EXISTS (SELECT 1 FROM ACCESORIOS WHERE id_producto = NEW.id_producto) THEN
        --si no esta en ninguna, rechaza la insercion
        RAISE EXCEPTION 'El producto % no tiene subtipo registrado (ropa, calzado o accesorio)', NEW.id_producto;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger13 en DETALLESDEVENTAS
CREATE TRIGGER tg_validar_subtipo_venta
    BEFORE INSERT ON DETALLESDEVENTAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_subtipo_producto();

--Trigger13 en DETALLESDECOMPRAS
CREATE TRIGGER tg_validar_subtipo_compra
    BEFORE INSERT ON DETALLESDECOMPRAS
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_subtipo_producto();