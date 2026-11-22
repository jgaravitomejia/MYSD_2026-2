--ComponentesNoOK


-- Prueba 1: Mantener cliente, modificar un cliente que no existe
-- Error esperado: El cliente no existe. (el componente hace ROLLBACK)
CALL mantener_cliente.modificar(99999, 'Nadie', '3000000000');


-- Prueba 2: Mantener cliente, adicionar con una ubicacion que ya existe (id 1)
-- Error esperado: llave duplicada en UBICACIONES. El cliente tampoco debe quedar registrado 
CALL mantener_cliente.adicionar(97201, 'Cliente Incompleto', '3002220001', NULL, NULL,
                                1, 'Calle 1', NULL, 'Bogota', 'Cundinamarca', NULL);
SELECT COUNT(*) AS clientes_97201 FROM CLIENTES WHERE id_cliente = 97201; --verificar 0


-- Prueba 3: Mantener ubicacion, adicionar una ubicacion sin cliente
-- Error esperado: La ubicacion debe pertenecer a un cliente.
CALL mantener_ubicacion.adicionar(97201, NULL, 'Calle 2', NULL, 'Bogota', 'Cundinamarca', NULL, FALSE);


-- Prueba 4: Mantener producto, adicionar calzado de mujer talla 44 (mujer va de 35 a 41)
-- Error esperado: viola CK_CALZADO_TALLAVSGENERO. El producto tampoco debe quedar registrado 
CALL mantener_producto.adicionar_calzado(97201, 'Bota Prueba', NULL, 200000, 'Pytar', 5, NULL, 44, 'Mujer', 'Bota', NULL);
SELECT COUNT(*) AS productos_97201 FROM PRODUCTOS WHERE id_producto = 97201; --verificar 0


-- Prueba 5: Registrar venta, agregar productos a la venta 1 de PoblarOK, que ya esta Completada
-- Error esperado: Solo se pueden agregar productos a una venta Pendiente. (A0018, de tg_detallesdeventas)
CALL registrar_venta.adicionar_producto(1, 12, 1, 50000, NULL);


-- Prueba 6: Registrar factura, eliminar la factura 1 de PoblarOK, que esta Pagada
-- Error esperado: Una factura pagada no se puede eliminar. (A0022, de tg_facturas)
CALL registrar_factura.eliminar(1);