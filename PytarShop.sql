-- XTablas. CICLO 1.
DROP TABLE IF EXISTS FACTURASCOMPRA;
DROP TABLE IF EXISTS FACTURASVENTA;
DROP TABLE IF EXISTS FACTURAS;
DROP TABLE IF EXISTS DETALLESDEVENTAS;
DROP TABLE IF EXISTS DETALLESDECOMPRAS;
DROP TABLE IF EXISTS VENTAS;
DROP TABLE IF EXISTS COMPRAS;
DROP TABLE IF EXISTS ROPA;
DROP TABLE IF EXISTS CALZADO;
DROP TABLE IF EXISTS ACCESORIOS;
DROP TABLE IF EXISTS PRODUCTOS;
DROP TABLE IF EXISTS UBICACIONES;
DROP TABLE IF EXISTS CLIENTES;
DROP TABLE IF EXISTS PROVEEDORES;



-- Estructura Ciclo 1

-- Tablas. CRUD: Clientes
CREATE TABLE CLIENTES(
    id_cliente      INTEGER         NOT NULL,
    nombre          VARCHAR(50)     NOT NULL,
    telefono        VARCHAR(15)     NOT NULL,
    correo          VARCHAR(100)    NULL,
    fecha_registro  TIMESTAMP       NOT NULL,
    notas           VARCHAR(200)    NULL,
    id_ubicacion    INTEGER         NULL,   -- FK -> ubicacion
);

-- Tablas. CRUD: Proveedores
CREATE TABLE PROVEEDORES(
    id_proveedor    INTEGER         NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    telefono        VARCHAR(15)     NOT NULL,
    correo          VARCHAR(100)    NULL,
    fecha_registro  TIMESTAMP       NOT NULL,
    id_ubicacion    INTEGER         NULL    -- FK -> ubicacion
);

-- Tablas. CRUD: Ubicaciones
CREATE TABLE UBICACIONES(
    id_ubicacion    INTEGER         NOT NULL,
    calle           VARCHAR(50)     NOT NULL,
    barrio          VARCHAR(50)     NULL,
    ciudad          VARCHAR(50)     NOT NULL,
    departamento    VARCHAR(50)     NOT NULL,
    codigo_postal   VARCHAR(10)     NULL,
    es_principal    BOOLEAN         NULL
);

-- Tablas. CRUD: Productos
CREATE TABLE PRODUCTOS(
    id_producto         INTEGER         NOT NULL,
    nombre              VARCHAR(50)     NOT NULL,
    descripcion         VARCHAR(200)    NULL,
    precio_referencia   NUMERIC(12,2)   NOT NULL,
    marca               VARCHAR(30)     NULL,
    stock               INTEGER         NOT NULL,
    estado              VARCHAR(20)     NOT NULL,
    fecha_ingreso       TIMESTAMP       NOT NULL,
    imagen_url          VARCHAR(250)    NULL
);

CREATE TABLE ROPA(
    id_producto     INTEGER         NOT NULL,   
    talla           VARCHAR(5)      NOT NULL,
    genero          VARCHAR(10)     NOT NULL,
    categoria_ropa  VARCHAR(30)     NOT NULL,
    material        VARCHAR(50)     NULL
);

CREATE TABLE CALZADO(
    id_producto         INTEGER         NOT NULL,   
    talla               NUMERIC(4,1)    NOT NULL,
    genero              VARCHAR(10)     NOT NULL,
    categoria_calzado   VARCHAR(30)     NOT NULL,
    material            VARCHAR(50)     NULL
);

CREATE TABLE ACCESORIOS(
    id_producto     INTEGER         NOT NULL,   
    categoria       VARCHAR(30)     NOT NULL,
    material        VARCHAR(50)     NULL,
    dimensiones     VARCHAR(50)     NULL
);

-- Tablas. CRUD: Compras
CREATE TABLE COMPRAS(
    id_compra              INTEGER         NOT NULL,
    fecha_compra    TIMESTAMP       NOT NULL,
    estado_compra   VARCHAR(20)     NOT NULL,
    observacion     VARCHAR(200)    NULL,
    id_proveedor    INTEGER         NOT NULL    
);

CREATE TABLE DETALLESDECOMPRAS(
    id_compra       INTEGER         NOT NULL,   
    id_producto     INTEGER         NOT NULL,   
    cantidad        INTEGER         NOT NULL,
    precio_compra   NUMERIC(12,2)   NOT NULL
);

-- Tablas. CRUD: Ventas
CREATE TABLE VENTAS(
    id_venta        INTEGER         NOT NULL,
    fecha_venta     TIMESTAMP       NOT NULL,
    metodo_pago     VARCHAR(20)     NOT NULL,
    estado_venta    VARCHAR(20)     NOT NULL,
    medio_entrega   VARCHAR(30)     NOT NULL,
    observaciones   VARCHAR(200)    NULL,
    id_cliente      INTEGER         NOT NULL    
);

CREATE TABLE DETALLESDEVENTAS(
    id_venta        INTEGER         NOT NULL,   
    id_producto     INTEGER         NOT NULL,   
    cantidad        INTEGER         NOT NULL,
    precio_venta    NUMERIC(12,2)   NOT NULL,
    descuento       NUMERIC(12,2)   NULL
);

-- Tablas. CRUD: Facturas
-- Nota: en el diagrama estado_factura aparece con tipo 'Venta', es un typo. El tipo correcto es TEstadoFactura.
CREATE TABLE FACTURAS(
    id_factura      INTEGER         NOT NULL,
    fecha_emision   TIMESTAMP       NOT NULL,
    total           NUMERIC(12,2)   NOT NULL,
    estado_factura  VARCHAR(20)     NOT NULL,
    observaciones   VARCHAR(200)    NULL
);

CREATE TABLE FACTURASVENTA(
    id_factura      INTEGER         NOT NULL,   -- PK + FK -> FACTURAS
    id_venta        INTEGER         NOT NULL,   -- FK -> VENTAS (UK: una venta genera una factura)
    numero_guia     VARCHAR(30)     NULL
);

CREATE TABLE FACTURASCOMPRA(
    id_factura      INTEGER         NOT NULL,   -- PK + FK -> FACTURAS
    id_compra       INTEGER         NOT NULL,   -- FK -> COMPRAS (UK: una compra genera una factura)
    numero_remision VARCHAR(30)     NULL
);



-- PoblarOK. CRUD: Clientes
INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
    VALUES (1, 'Maria Lopez',   '3001234567', 'maria@mail.co',   '2026-01-10 09:00:00', NULL),
           (2, 'Carlos Ruiz',   '3109876543', 'carlos@mail.co',  '2026-02-15 14:30:00', 'Cliente frecuente'),
           (3, 'Ana Torres',    '3201112233', NULL,               '2026-03-01 10:00:00', NULL);

-- PoblarOK. CRUD: Proveedores
INSERT INTO PROVEEDORES (id_proveedor, nombre, telefono, correo, fecha_registro)
    VALUES (1, 'Distribuciones Moda S.A.', '6014567890', 'ventas@moda.co',    '2025-11-01 08:00:00'),
           (2, 'Accesorios del Valle',     '3155551234', 'info@accvalle.co',  '2026-01-05 10:00:00');

INSERT INTO UBICACIONES (id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente, id_proveedor)
    VALUES (1, 'Cra 15 #45-20',         'Chapinero', 'Bogota', 'Cundinamarca', '110231', true,  1, NULL),
           (2, 'Cll 80 #10-55 Apto 302','Suba',      'Bogota', 'Cundinamarca', '111101', true,  2, NULL),
           (3, 'Av Eldorado #68C-61',   'Fontibon',  'Bogota', 'Cundinamarca', '110931', true,  NULL, 1);

-- PoblarOK. CRUD: Productos
INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
    VALUES (1, 'Camiseta Oversize',   'Camiseta de algodon oversize', 45000.00,  'Zara', 10, 'Disponible', '2026-01-15 11:00:00', NULL),
           (2, 'Zapatilla Deportiva', 'Zapatilla para correr',        180000.00, 'Nike',  5, 'Disponible', '2026-01-20 09:00:00', NULL),
           (3, 'Bolso de Cuero',      NULL,                           120000.00, NULL,    3, 'Disponible', '2026-02-01 10:00:00', NULL);

INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material)
    VALUES (1, 'M', 'Mujer', 'Camiseta', 'Algodon');

INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material)
    VALUES (2, 38.0, 'Mujer', 'Deportivo', 'Malla sintetica');

INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones)
    VALUES (3, 'Bolso', 'Cuero genuino', '30x20x10 cm');

-- PoblarOK. CRUD: Compras
INSERT INTO COMPRAS (id_compra, fecha_compra, estado_compra, observacion, id_proveedor)
    VALUES (1, '2026-01-14 10:00:00', 'Recibida', NULL,              1),
           (2, '2026-01-30 15:00:00', 'Recibida', 'Pedido urgente',  2);

INSERT INTO DETALLESDECOMPRAS (id_compra, id_producto, cantidad, precio_compra)
    VALUES (1, 1, 5,  25000.00),
           (1, 2, 3, 120000.00),
           (2, 3, 3,  70000.00);

-- PoblarOK. CRUD: Ventas
INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
    VALUES (1, '2026-02-20 16:00:00', 'Nequi',    'Completada', 'Domicilio',       NULL,                         1),
           (2, '2026-03-05 11:30:00', 'Efectivo', 'Completada', 'Recogida en punto','Cliente recoge en el punto', 2);

INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
    VALUES (1, 1, 1,  45000.00,    NULL),
           (1, 3, 1, 120000.00, 5000.00),
           (2, 2, 1, 180000.00,    NULL);

-- PoblarOK. CRUD: Facturas
INSERT INTO FACTURAS (id_factura, fecha_emision, total, estado_factura, observaciones)
    VALUES (1, '2026-02-20 16:05:00', 160000.00, 'Emitida', NULL),
           (2, '2026-03-05 11:35:00', 180000.00, 'Emitida', NULL),
           (3, '2026-01-14 10:05:00', 475000.00, 'Emitida', NULL);

INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia)
    VALUES (1, 1, 'SERV-2026-001'),
           (2, 2, NULL);

INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision)
    VALUES (3, 1, 'REM-2026-001');



-- PoblarNoOK
-- Caso 1: producto con stock negativo.
-- Deberia fallar porque stock no puede ser menor a 0.
-- Pero entra, porque aun no se ha declarado la restriccion CHECK sobre stock.
--INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
--    VALUES (99, 'Producto invalido', NULL, 50000.00, NULL, -5, 'Disponible', '2026-04-01 10:00:00', NULL);

-- Caso 2: venta con metodo_pago invalido ('Bitcoin').
-- Deberia fallar porque metodo_pago solo puede ser Nequi, Daviplata, Efectivo o Transferencia.
-- Pero entra, porque aun no se ha declarado la restriccion CHECK sobre metodo_pago.
--INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
--    VALUES (99, '2026-04-01 10:00:00', 'Bitcoin', 'Completada', 'Domicilio', NULL, 1);

-- Caso 3: cliente con id duplicado (id=1 ya existe).
-- Deberia fallar porque id_cliente es llave primaria y no puede repetirse.
-- Pero entra, porque aun no se ha declarado la restriccion de que es una PK.
--INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
--    VALUES (1, 'Duplicado', '3000000000', 'dup@mail.co', '2026-04-01 10:00:00', NULL);



-- Restricciones Declarativas. Ciclo 1.

-- Tipos
-- TEstadoProducto: estado del producto en el negocio
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_ESTADO
    CHECK (estado IN ('Disponible', 'Agotado', 'Descontinuado'));

-- TMetodoPago: formas de pago aceptadas
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_METODOPAGO
    CHECK (metodo_pago IN ('Efectivo', 'Transferencia'));

-- TMedioEntrega: canales de entrega del negocio
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_MEDIOENTREGA
    CHECK (medio_entrega IN ('Paqueteria','Domicilio', 'Recogida en punto'));

-- TEstadoVenta: ciclo de vida de una venta
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_ESTADOVENTA
    CHECK (estado_venta IN ('Pendiente', 'Completada', 'Cancelada','En devolucion'));

-- TEstadoCompra: ciclo de vida de una compra
ALTER TABLE COMPRAS
    ADD CONSTRAINT CK_COMPRAS_ESTADOCOMPRA
    CHECK (estado_compra IN ('Pendiente', 'Recibida', 'Cancelada','Parcial'));

-- TEstadoFactura: ciclo de vida de una factura
ALTER TABLE FACTURAS
    ADD CONSTRAINT CK_FACTURAS_ESTADOFACTURA
    CHECK (estado_factura IN ('Emitida', 'Anulada', 'Pagada'));

-- TGenero: genero al que aplica la prenda o calzado
ALTER TABLE ROPA
    ADD CONSTRAINT CK_ROPA_GENERO
    CHECK (genero IN ('Hombre', 'Mujer', 'Niño', 'Niña', 'Unisex'));

ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_GENERO
    CHECK (genero IN ('Hombre', 'Mujer', 'Nino', 'Nina', 'Unisex'));

-- TTallaRopa: tallas estandar de ropa
ALTER TABLE ROPA
    ADD CONSTRAINT CK_ROPA_TALLA
    CHECK (talla IN ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'T2','T4','T6', 'T8', 'T10', 'T12', 'T14'));

-- TTallaCalzado: rango numerico de tallas de calzado (nino a adulto)
ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_TALLA
    CHECK (talla BETWEEN 18 AND 45);

-- TTipoRopa: categorias de prendas de vestir
ALTER TABLE ROPA
    ADD CONSTRAINT CK_ROPA_CATEGORIA
    CHECK (categoria_ropa IN ('Camisa', 'Blusa', 'Pantalon', 'Falda', 'Vestido',
                              'Chaqueta', 'Abrigo', 'Sudadera', 'Shorts', 'Jean'));

-- TTipoCalzado: categorias de calzado
ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_CATEGORIA
    CHECK (categoria_calzado IN ('Zapatilla', 'Botin','Bota', 'Sandalia', 'Plataforma',
                                 'Moccasin', 'Deportivo', 'Chancla'));

-- TTipoAccesorio: categorias de accesorios
ALTER TABLE ACCESORIOS
    ADD CONSTRAINT CK_ACCESORIOS_CATEGORIA
    CHECK (categoria IN ('Bolso', 'Cartera', 'Cinturon', 'Gorra',
                         'Gafas', 'Joyeria', 'Reloj', 'Mochila', 'Billetera'));


-- Atributos
-- Stock no puede ser negativo
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_STOCK
    CHECK (stock >= 0);

-- Precio de referencia siempre positivo
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_PRECIOREFERENCIA
    CHECK (precio_referencia > 0);

-- Cantidades en detalles siempre positivas
ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT CK_DETALLESCOMPRA_CANTIDAD
    CHECK (cantidad > 0);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_CANTIDAD
    CHECK (cantidad > 0);

-- Precios en detalles siempre positivos
ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT CK_DETALLESCOMPRA_PRECIOCOMPRA
    CHECK (precio_compra > 0);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_PRECIOVENTA
    CHECK (precio_venta > 0);

-- Descuento no puede ser negativo
ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_DESCUENTO
    CHECK (descuento >= 0);

-- Total de factura siempre positivo
ALTER TABLE FACTURAS
    ADD CONSTRAINT CK_FACTURAS_TOTAL
    CHECK (total > 0);

-- Telefono con longitud minima de 7 digitos
ALTER TABLE CLIENTES
    ADD CONSTRAINT CK_CLIENTES_TELEFONO
    CHECK (LENGTH(telefono) >= 7);

ALTER TABLE PROVEEDORES
    ADD CONSTRAINT CK_PROVEEDORES_TELEFONO
    CHECK (LENGTH(telefono) >= 7);

-- Correo debe contener @ (TTCorreo)
ALTER TABLE CLIENTES
    ADD CONSTRAINT CK_CLIENTES_CORREO
    CHECK (correo LIKE '%@%.%');

ALTER TABLE PROVEEDORES
    ADD CONSTRAINT CK_PROVEEDORES_CORREO
    CHECK (correo LIKE '%@%.%');


-- Primarias
-- Clientes
ALTER TABLE CLIENTES
    ADD CONSTRAINT PK_CLIENTES PRIMARY KEY (id_cliente);

-- Proveedores
ALTER TABLE PROVEEDORES
    ADD CONSTRAINT PK_PROVEEDORES PRIMARY KEY (id_proveedor);

-- Ubicaciones
ALTER TABLE UBICACIONES
    ADD CONSTRAINT PK_UBICACIONES PRIMARY KEY (id_ubicacion);

-- Productos
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT PK_PRODUCTOS PRIMARY KEY (id_producto);

ALTER TABLE ROPA
    ADD CONSTRAINT PK_ROPA PRIMARY KEY (id_producto);

ALTER TABLE CALZADO
    ADD CONSTRAINT PK_CALZADO PRIMARY KEY (id_producto);

ALTER TABLE ACCESORIOS
    ADD CONSTRAINT PK_ACCESORIOS PRIMARY KEY (id_producto);

-- Compras
ALTER TABLE COMPRAS
    ADD CONSTRAINT PK_COMPRAS PRIMARY KEY (id_compra);

ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT PK_DETALLESDECOMPRAS PRIMARY KEY (id_compra, id_producto);

-- Ventas
ALTER TABLE VENTAS
    ADD CONSTRAINT PK_VENTAS PRIMARY KEY (id_venta);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT PK_DETALLESDEVENTAS PRIMARY KEY (id_venta, id_producto);

-- Facturas
ALTER TABLE FACTURAS
    ADD CONSTRAINT PK_FACTURAS PRIMARY KEY (id_factura);

ALTER TABLE FACTURASVENTA
    ADD CONSTRAINT PK_FACTURASVENTA PRIMARY KEY (id_factura,id_venta);

ALTER TABLE FACTURASCOMPRA
    ADD CONSTRAINT PK_FACTURASCOMPRA PRIMARY KEY (id_factura,id_compra);


-- Unicas
ALTER TABLE CLIENTES
    ADD CONSTRAINT UK_CLIENTES_CORREO UNIQUE (correo);

ALTER TABLE PROVEEDORES
    ADD CONSTRAINT UK_PROVEEDORES_CORREO UNIQUE (correo);



-- Foraneas
-- Clientes
ALTER TABLE CLIENTES
    ADD CONSTRAINT FK_CLIENTES_UBICACIONES FOREIGN KEY (id_ubicacion)
    REFERENCES UBICACIONES (id_ubicacion);

-- Proveedores
ALTER TABLE PROVEEDORES
    ADD CONSTRAINT FK_PROVEEDORES_UBICACIONES FOREIGN KEY (id_ubicacion)
    REFERENCES UBICACIONES (id_ubicacion);

-- Productos 
ALTER TABLE ROPA
    ADD CONSTRAINT FK_ROPA_PRODUCTOS FOREIGN KEY (id_producto)
    REFERENCES PRODUCTOS (id_producto);

ALTER TABLE CALZADO
    ADD CONSTRAINT FK_CALZADO_PRODUCTOS FOREIGN KEY (id_producto)
    REFERENCES PRODUCTOS (id_producto);

ALTER TABLE ACCESORIOS
    ADD CONSTRAINT FK_ACCESORIOS_PRODUCTOS FOREIGN KEY (id_producto)
    REFERENCES PRODUCTOS (id_producto);

-- Compras
ALTER TABLE COMPRAS
    ADD CONSTRAINT FK_COMPRAS_PROVEEDORES FOREIGN KEY (id_proveedor)
    REFERENCES PROVEEDORES (id_proveedor);

ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT FK_DETALLESCOMPRA_COMPRAS FOREIGN KEY (id_compra)
    REFERENCES COMPRAS (id_compra);

ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT FK_DETALLESCOMPRA_PRODUCTOS FOREIGN KEY (id_producto)
    REFERENCES PRODUCTOS (id_producto);

-- Ventas
ALTER TABLE VENTAS
    ADD CONSTRAINT FK_VENTAS_CLIENTES FOREIGN KEY (id_cliente)
    REFERENCES CLIENTES (id_cliente);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT FK_DETALLESVENTA_VENTAS FOREIGN KEY (id_venta)
    REFERENCES VENTAS (id_venta);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT FK_DETALLESVENTA_PRODUCTOS FOREIGN KEY (id_producto)
    REFERENCES PRODUCTOS (id_producto);

-- Facturas
ALTER TABLE FACTURASVENTA
    ADD CONSTRAINT FK_FACTURASVENTA_FACTURAS FOREIGN KEY (id_factura)
    REFERENCES FACTURAS (id_factura);

ALTER TABLE FACTURASVENTA
    ADD CONSTRAINT FK_FACTURASVENTA_VENTAS FOREIGN KEY (id_venta)
    REFERENCES VENTAS (id_venta);

ALTER TABLE FACTURASCOMPRA
    ADD CONSTRAINT FK_FACTURASCOMPRA_FACTURAS FOREIGN KEY (id_factura)
    REFERENCES FACTURAS (id_factura);

ALTER TABLE FACTURASCOMPRA
    ADD CONSTRAINT FK_FACTURASCOMPRA_COMPRAS FOREIGN KEY (id_compra)
    REFERENCES COMPRAS (id);



-- Caso 1: producto con stock negativo (-5).
-- Debe fallar porque stock no puede ser menor a 0.
-- Restriccion que lo protege: CK_PRODUCTOS_STOCK
--INSERT INTO PRODUCTOS (id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url)
--    VALUES (99, 'Producto invalido', NULL, 50000.00, NULL, -5, 'Disponible', '2026-04-01 10:00:00', NULL);

-- Caso 2: venta con metodo_pago invalido ('Bitcoin').
-- Debe fallar porque metodo_pago solo acepta: Nequi, Daviplata, Efectivo, Transferencia.
-- Restriccion que lo protege: CK_VENTAS_METODOPAGO
--INSERT INTO VENTAS (id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente)
--    VALUES (99, '2026-04-01 10:00:00', 'Bitcoin', 'Completada', 'Domicilio', NULL, 1);

-- Caso 3: cliente con id_cliente duplicado (id=1 ya existe).
-- Debe fallar porque id_cliente es llave primaria.
-- Restriccion que lo protege: PK_CLIENTES
--INSERT INTO CLIENTES (id_cliente, nombre, telefono, correo, fecha_registro, notas)
--    VALUES (1, 'Duplicado', '3000000000', 'dup@mail.co', '2026-04-01 10:00:00', NULL);

-- Caso 4: detalle de venta apuntando a una venta inexistente (id_venta=99).
-- Debe fallar porque id_venta=99 no existe en VENTAS.
-- Restriccion que lo protege: FK_DETALLESVENTA_VENTAS
--INSERT INTO DETALLESDEVENTAS (id_venta, id_producto, cantidad, precio_venta, descuento)
--    VALUES (99, 1, 1, 45000.00, NULL);



