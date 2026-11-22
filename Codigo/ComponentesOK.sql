--ComponentesOK


-- Prueba 1: Mantener cliente. El cliente se registra con su primera ubicacion, que queda como principal
DO $$
BEGIN
    CALL mantener_cliente.adicionar(97101, 'Cliente Prueba', '3001110001', NULL, NULL,
                                    97101, 'Calle 10 #5-20', NULL, 'Bogota', 'Cundinamarca', NULL);
    ASSERT (SELECT es_principal FROM UBICACIONES WHERE id_ubicacion = 97101), 'La ubicacion no quedo como principal';
    RAISE NOTICE 'Prueba 1 OK: el cliente 97101 quedo registrado con su ubicacion principal 97101';
END $$;


-- Prueba 2: Mantener ubicacion. Al marcar otra ubicacion como principal, la anterior deja de serlo
DO $$
BEGIN
    CALL mantener_ubicacion.adicionar(97102, 97101, 'Carrera 7 #40-10', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE);
    CALL mantener_ubicacion.marcar_principal(97102);
    ASSERT (SELECT es_principal FROM UBICACIONES WHERE id_ubicacion = 97102), 'La ubicacion 97102 no quedo como principal';
    ASSERT NOT (SELECT es_principal FROM UBICACIONES WHERE id_ubicacion = 97101), 'La ubicacion 97101 sigue como principal';
    RAISE NOTICE 'Prueba 2 OK: la ubicacion principal del cliente 97101 paso de la 97101 a la 97102';
END $$;


-- Prueba 3: Mantener proveedor. El proveedor se registra junto con su ubicacion
DO $$
BEGIN
    CALL mantener_proveedor.adicionar(97101, 'Proveedor Prueba', '6011110001', NULL,
                                      97103, 'Avenida 30 #12-40', NULL, 'Bogota', 'Cundinamarca', NULL);
    ASSERT (SELECT id_ubicacion FROM PROVEEDORES WHERE id_proveedor = 97101) = 97103, 'El proveedor no quedo con su ubicacion';
    RAISE NOTICE 'Prueba 3 OK: el proveedor 97101 quedo registrado con la ubicacion 97103';
END $$;


-- Prueba 4: Mantener producto. El producto se registra con su tipo y, sin stock, queda Agotado
DO $$
BEGIN
    CALL mantener_producto.adicionar_ropa(97101, 'Chaqueta Prueba', NULL, 180000, 'Pytar', 0, NULL, 'M', 'Hombre', 'Chaqueta', NULL);
    ASSERT (SELECT COUNT(*) FROM ROPA WHERE id_producto = 97101) = 1, 'No quedo registrado como ropa';
    ASSERT (SELECT estado FROM PRODUCTOS WHERE id_producto = 97101) = 'Agotado', 'Sin stock deberia quedar Agotado';
    RAISE NOTICE 'Prueba 4 OK: la chaqueta 97101 quedo registrada como ropa y Agotado';
END $$;


-- Prueba 5: Registrar compra. Al comprar, el stock aumenta y el producto pasa a Disponible
DO $$
BEGIN
    CALL registrar_compra.adicionar(97101, 97101, NULL);
    CALL registrar_compra.adicionar_producto(97101, 97101, 10, 50000);
    ASSERT (SELECT stock FROM PRODUCTOS WHERE id_producto = 97101) = 10, 'El stock no aumento a 10';
    ASSERT (SELECT estado FROM PRODUCTOS WHERE id_producto = 97101) = 'Disponible', 'El producto no paso a Disponible';
    RAISE NOTICE 'Prueba 5 OK: la compra 97101 subio el stock de la chaqueta a 10 y quedo Disponible';
END $$;


-- Prueba 6: Registrar venta. Se entrega en la ubicacion principal, descuenta el stock y se completa
DO $$
BEGIN
    CALL registrar_venta.adicionar(97101, 97101, 'Transferencia', 'Domicilio', NULL, NULL);
    CALL registrar_venta.adicionar_producto(97101, 97101, 4, 80000, 5000);
    CALL registrar_venta.completar(97101);
    ASSERT (SELECT id_ubicacion FROM VENTAS WHERE id_venta = 97101) = 97102, 'No se uso la ubicacion principal';
    ASSERT (SELECT stock FROM PRODUCTOS WHERE id_producto = 97101) = 6, 'El stock no bajo a 6';
    ASSERT (SELECT estado_venta FROM VENTAS WHERE id_venta = 97101) = 'Completada', 'La venta no quedo Completada';
    RAISE NOTICE 'Prueba 6 OK: la venta 97101 se entrega en la ubicacion 97102, dejo el stock en 6 y quedo Completada';
END $$;


-- Prueba 7: Registrar factura. El total se calcula con los productos de la venta: 4 * 80000 - 5000 = 315000
DO $$
BEGIN
    CALL registrar_factura.adicionar_de_venta(97101, 97101, 'GUIA-97101', NULL);
    ASSERT (SELECT total FROM FACTURAS WHERE id_factura = 97101) = 315000, 'El total no es 315000';
    RAISE NOTICE 'Prueba 7 OK: la factura 97101 quedo Emitida con total %', (SELECT total FROM FACTURAS WHERE id_factura = 97101);
END $$;




-- CO4: ventas del cliente 97101 (debe mostrar la venta 97101 Completada con total 315000)
BEGIN;
SELECT registrar_venta.consultar_ventas_cliente(97101);
FETCH ALL IN cur_ventas_cliente;
COMMIT;

-- CO5: detalle de la venta 97101 (producto, direccion de entrega y factura)
BEGIN;
SELECT registrar_venta.consultar_venta(97101);
FETCH ALL IN cur_venta;
COMMIT;