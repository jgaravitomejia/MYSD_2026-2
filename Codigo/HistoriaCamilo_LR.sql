--Historia: Los regalos de diciembre de Camilo
-- Es diciembre en Pytar-Shop y empieza la temporada de regalos. El Encargado de inventario prepara la
-- mercancia de temporada, el Vendedor atiende a Camilo, que compra regalos para el y para su mamá en Cali,
-- y el Administrador se encarga de las facturas. No todo sale bien: llegan productos danados, una direccion
-- esta mal escrita y Camilo pide cambiar una factura.



-- La manana: la mercancia de temporada

-- Paso 1. El Encargado registra los dos productos de temporada: un bolso navideno y una camisa estampada.
-- Todavia no hay unidades, asi que quedan Agotados
SET ROLE encargado_inventario;
CALL mantener_producto.adicionar_accesorio(97801, 'Bolso Navideno', 'Bolso rojo de temporada', 189000, 'Totto', 0, NULL,
                                           'Bolso', 'Lona', '30x25 cm');
CALL mantener_producto.adicionar_ropa(97802, 'Camisa Estampada', 'Camisa con estampado navideno', 59900, 'Pytar', 0, NULL,
                                      'M', 'Unisex', 'Camisa', 'Algodon');
SELECT id_producto, nombre, precio_referencia, stock, estado FROM PRODUCTOS WHERE id_producto IN (97801, 97802) ORDER BY id_producto;

-- Paso 2. Por error registro el bolso dos veces; como el repetido no tiene compras ni ventas, lo elimina
CALL mantener_producto.adicionar_accesorio(97803, 'Bolso Navideno', 'Bolso rojo de temporada', 189000, 'Totto', 0, NULL,
                                           'Bolso', 'Lona', '30x25 cm');
CALL mantener_producto.eliminar(97803);
SELECT COUNT(*) AS bolsos_repetidos FROM PRODUCTOS WHERE id_producto = 97803; --0: se borro junto con su tipo

-- Paso 3. Llega el primer pedido del proveedor de siempre (el 1): 8 bolsos y 12 camisas.
-- El stock sube solo y los productos pasan a Disponible
CALL registrar_compra.adicionar(97801, 1, 'Mercancia de temporada');
CALL registrar_compra.adicionar_producto(97801, 97801, 8, 95000);
CALL registrar_compra.adicionar_producto(97801, 97802, 12, 25000);
SELECT id_producto, nombre, stock, estado FROM PRODUCTOS WHERE id_producto IN (97801, 97802) ORDER BY id_producto;

-- Paso 4. Llega un segundo pedido con 5 bolsos mas, pero al revisarlos tienen la cremallera danada.
-- El Encargado cancela esa compra y las 5 unidades salen del stock (de 13 vuelve a 8)
CALL registrar_compra.adicionar(97802, 1, 'Refuerzo de bolsos');
CALL registrar_compra.adicionar_producto(97802, 97801, 5, 95000);
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 97801;
CALL registrar_compra.cancelar(97802);
SELECT id_compra, estado_compra FROM COMPRAS WHERE id_compra IN (97801, 97802) ORDER BY id_compra;
SELECT id_producto, stock FROM PRODUCTOS WHERE id_producto = 97801;
RESET ROLE;

-- Paso 5. El Administrador factura el primer pedido: total = 8 * 95000 + 12 * 25000 = 1060000
SET ROLE administrador;
CALL registrar_factura.adicionar_de_compra(97801, 97801, 'REM-97801', NULL);
SELECT id_factura, fecha_emision, total, estado_factura FROM FACTURAS WHERE id_factura = 97801;
RESET ROLE;


-- El mediodia: llega Camilo

-- Paso 6. Camilo es cliente nuevo; el Vendedor lo registra con su apartamento en Chapinero
SET ROLE vendedor;
CALL mantener_cliente.adicionar(97801, 'Camilo Herrera', '3209876543', 'camilo.herrera@mail.com', 'Compra regalos de fin de ano',
                                97801, 'Calle 63 #9-45 Apto 302', 'Chapinero', 'Bogota', 'Cundinamarca', '110231');
SELECT c.id_cliente, c.nombre, u.id_ubicacion, u.calle, u.es_principal
FROM CLIENTES c JOIN UBICACIONES u ON u.id_cliente = c.id_cliente
WHERE c.id_cliente = 97801;

-- Paso 7. Uno de los regalos es para su mamá, que vive en Cali; el Vendedor agrega esa direccion
-- sin cambiar la principal
CALL mantener_ubicacion.adicionar(97802, 97801, 'Carrera 100 #11-60', 'Ciudad Jardin', 'Cali', 'Valle', NULL, FALSE);
SELECT id_ubicacion, calle, ciudad, es_principal FROM UBICACIONES WHERE id_cliente = 97801 ORDER BY id_ubicacion;

-- Paso 8. Primera venta: una camisa para Camilo. No se indica direccion, asi que se entrega en su apartamento
CALL registrar_venta.adicionar(97801, 97801, 'Transferencia', 'Domicilio', NULL, NULL);
CALL registrar_venta.adicionar_producto(97801, 97802, 1, 59900, NULL);
SELECT id_venta, estado_venta, id_ubicacion FROM VENTAS WHERE id_venta = 97801;

-- Paso 9. Segunda venta: 2 bolsos y una camisa para la mamá, enviados por paqueteria a Cali y pagados
-- contraentrega. Aqui si se indica la direccion de entrega (la de Cali)
CALL registrar_venta.adicionar(97802, 97801, 'Contraentrega', 'Paqueteria', 'Regalo, no incluir precios', 97802);
CALL registrar_venta.adicionar_producto(97802, 97801, 2, 189000, NULL);
CALL registrar_venta.adicionar_producto(97802, 97802, 1, 59900, NULL);
SELECT v.id_venta, v.metodo_pago, v.medio_entrega, u.ciudad
FROM VENTAS v JOIN UBICACIONES u ON u.id_ubicacion = v.id_ubicacion
WHERE v.id_cliente = 97801 ORDER BY v.id_venta;
SELECT id_producto, nombre, stock FROM PRODUCTOS WHERE id_producto IN (97801, 97802) ORDER BY id_producto;

-- Paso 10. Camilo se entusiasma y quiere 10 bolsos mas para regalar en su oficina, pero solo quedan 6
-- debe fallar: no hay stock suficiente (tg_detallesdeventas)
CALL registrar_venta.adicionar_producto(97801, 97801, 10, 189000, NULL);

-- Paso 11. Para convencerlo, el Vendedor intenta bajarle el precio de referencia al bolso
-- debe fallar: permiso denegado, los precios los maneja el Encargado de inventario
CALL mantener_producto.modificar(97801, 150000, 6);
RESET ROLE;


-- La tarde: las facturas

-- Paso 12. El Administrador factura las dos ventas; el total de la de Cali es 2 * 189000 + 59900 = 437900
SET ROLE administrador;
CALL registrar_factura.adicionar_de_venta(97802, 97801, 'GUIA-97801', NULL);
CALL registrar_factura.adicionar_de_venta(97803, 97802, 'GUIA-97802', NULL);
SELECT fv.id_venta, f.id_factura, f.total, f.estado_factura
FROM FACTURAS f JOIN FACTURASVENTA fv ON fv.id_factura = f.id_factura
WHERE fv.id_venta IN (97801, 97802) ORDER BY fv.id_venta;

-- Paso 13. Camilo paga por transferencia su camisa y el Administrador marca esa factura como Pagada
CALL registrar_factura.modificar_estado(97802, 'Pagada');
SELECT id_factura, estado_factura FROM FACTURAS WHERE id_factura = 97802;

-- Paso 14. Camilo pide que la factura de los regalos de su mamá salga a nombre de su empresa.
-- Como todavia no esta pagada, el Administrador la elimina y la vuelve a generar con la observacion
CALL registrar_factura.eliminar(97803);
CALL registrar_factura.adicionar_de_venta(97804, 97802, 'GUIA-97802', 'A nombre de Herrera Diseno S.A.S.');
SELECT fv.id_venta, f.id_factura, f.total, f.observaciones
FROM FACTURAS f JOIN FACTURASVENTA fv ON fv.id_factura = f.id_factura
WHERE fv.id_venta = 97802;

-- Paso 15. Camilo tambien quiere cambiar la factura de su camisa
-- debe fallar: esa factura ya esta pagada y no se puede eliminar (tg_facturas)
CALL registrar_factura.eliminar(97802);
RESET ROLE;


-- Al dia siguiente: las entregas

-- Paso 16. Los dos pedidos se entregan y el Vendedor los marca como Completados
SET ROLE vendedor;
CALL registrar_venta.completar(97801);
CALL registrar_venta.completar(97802);
SELECT id_venta, estado_venta FROM VENTAS WHERE id_cliente = 97801 ORDER BY id_venta;

-- Paso 17. La mamá de Camilo avisa que su casa es la 11-62 y no la 11-60, y el Vendedor intenta corregirla
-- debe fallar: esa direccion ya se uso en una venta y no se puede modificar (tg_ubicaciones)
CALL mantener_ubicacion.modificar(97802, 'Carrera 100 #11-62', 'Ciudad Jardin', 'Cali', 'Valle', NULL);
RESET ROLE;

-- Paso 18. El Encargado quiere devolverle al proveedor el primer pedido para pedirlo en otro color
-- debe fallar: ya se vendieron bolsos de esa compra y el stock no alcanza para devolverlos (tg_compras)
SET ROLE encargado_inventario;
CALL registrar_compra.cancelar(97801);
SELECT id_producto, nombre, stock FROM PRODUCTOS WHERE id_producto IN (97801, 97802) ORDER BY id_producto;
RESET ROLE;

-- Paso 19. Camilo pide que borren sus datos y el Vendedor lo intenta
-- debe fallar: tiene ventas registradas (FK_VENTAS_CLIENTES)
SET ROLE vendedor;
CALL mantener_cliente.eliminar(97801);

-- Paso 20. El Vendedor revisa el historial de Camilo (CO4): dos ventas completadas
BEGIN;
SELECT registrar_venta.consultar_ventas_cliente(97801);
FETCH ALL IN cur_ventas_cliente;
COMMIT;
RESET ROLE;

-- Paso 21. El Administrador revisa con la vista de informes cuanto ha comprado Camilo en la temporada
SET ROLE administrador;
SELECT cc.nombre, cc.ciudad, COUNT(DISTINCT lv.id_venta) AS compras, SUM(lv.subtotal) AS total_comprado
FROM VW_LINEAS_VENTA lv JOIN VW_CLIENTES_CONTACTO cc ON cc.id_cliente = lv.id_cliente
WHERE lv.id_cliente = 97801
GROUP BY cc.nombre, cc.ciudad;
RESET ROLE;