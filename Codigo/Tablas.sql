-- Estructura Ciclo 1

-- Tablas. CRUD: Clientes
CREATE TABLE CLIENTES(
    id_cliente      INTEGER         NOT NULL,
    nombre          VARCHAR(50)     NOT NULL,
    telefono        VARCHAR(15)     NOT NULL,
    correo          VARCHAR(100)    NULL, -- UK
    fecha_registro  TIMESTAMP       NOT NULL,
    notas           VARCHAR(200)    NULL
);

-- Tablas. CRUD: Proveedores
CREATE TABLE PROVEEDORES(
    id_proveedor    INTEGER         NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    telefono        VARCHAR(15)     NOT NULL,
    correo          VARCHAR(100)    NULL, -- UK
    fecha_registro  TIMESTAMP       NOT NULL,
    id_ubicacion    INTEGER         NULL        -- FK -> UBICACIONES (UK: maximo un proveedor por ubicacion)
);

-- Tablas. CRUD: Ubicaciones
-- Un cliente puede tener varias ubicaciones; cada una dice de que cliente es
CREATE TABLE UBICACIONES(
    id_ubicacion    INTEGER         NOT NULL,
    calle           VARCHAR(50)     NOT NULL,
    barrio          VARCHAR(50)     NULL,
    ciudad          VARCHAR(50)     NOT NULL,
    departamento    VARCHAR(50)     NOT NULL,
    codigo_postal   VARCHAR(10)     NULL,
    es_principal    BOOLEAN         NOT NULL    DEFAULT FALSE,
    id_cliente      INTEGER         NULL        -- FK -> CLIENTES (NULL si es la ubicacion de un proveedor)
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
    id_producto     INTEGER         NOT NULL,   -- PK + FK -> PRODUCTOS
    talla           VARCHAR(5)      NOT NULL,
    genero          VARCHAR(10)     NOT NULL,
    categoria_ropa  VARCHAR(30)     NOT NULL,
    material        VARCHAR(50)     NULL
);

CREATE TABLE CALZADO(
    id_producto         INTEGER         NOT NULL,   -- PK + FK -> PRODUCTOS
    talla               INTEGER         NOT NULL,
    genero              VARCHAR(10)     NOT NULL,
    categoria_calzado   VARCHAR(30)     NOT NULL,
    material            VARCHAR(50)     NULL
);

CREATE TABLE ACCESORIOS(
    id_producto     INTEGER         NOT NULL,   -- PK + FK -> PRODUCTOS
    categoria       VARCHAR(30)     NOT NULL,
    material        VARCHAR(50)     NULL,
    dimensiones     VARCHAR(50)     NULL
);

-- Tablas. CRUD: Compras
CREATE TABLE COMPRAS(
    id_compra       INTEGER         NOT NULL,
    fecha_compra    TIMESTAMP       NOT NULL,
    estado_compra   VARCHAR(20)     NOT NULL,
    observacion     VARCHAR(200)    NULL,
    id_proveedor    INTEGER         NOT NULL    -- FK -> PROVEEDORES
);

CREATE TABLE DETALLESDECOMPRAS(
    id_compra       INTEGER         NOT NULL,   -- PK + FK -> COMPRAS
    id_producto     INTEGER         NOT NULL,   -- PK + FK -> PRODUCTOS
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
    id_cliente      INTEGER         NOT NULL,   -- FK -> CLIENTES
    id_ubicacion    INTEGER         NOT NULL    -- FK -> UBICACIONES (direccion de entrega)
);

CREATE TABLE DETALLESDEVENTAS(
    id_venta        INTEGER         NOT NULL,   -- PK + FK -> VENTAS
    id_producto     INTEGER         NOT NULL,   -- PK + FK -> PRODUCTOS
    cantidad        INTEGER         NOT NULL,
    precio_venta    NUMERIC(12,2)   NOT NULL,
    descuento       NUMERIC(12,2)   NULL
);

-- Tablas. CRUD: Facturas
CREATE TABLE FACTURAS(
    id_factura      INTEGER         NOT NULL,
    fecha_emision   TIMESTAMP       NOT NULL,
    total           NUMERIC(12,2)   NOT NULL,
    estado_factura  VARCHAR(20)     NOT NULL,
    observaciones   VARCHAR(200)    NULL
);

CREATE TABLE FACTURASVENTA(
    id_factura      INTEGER         NOT NULL,   -- PK + FK -> FACTURAS
    id_venta        INTEGER         NOT NULL,   -- UK + FK -> VENTAS (una venta tiene maximo una factura)
    numero_guia     VARCHAR(30)     NULL
);

CREATE TABLE FACTURASCOMPRA(
    id_factura      INTEGER         NOT NULL,   -- PK + FK -> FACTURAS
    id_compra       INTEGER         NOT NULL,   -- UK + FK -> COMPRAS (una compra tiene maximo una factura)
    numero_remision VARCHAR(30)     NULL
);