-- Restricciones Declarativas. Ciclo 1.

-- Tipos (los mismos del detalle de tipos del diagrama conceptual extendido)

-- TTelefono: texto de minimo 7 caracteres
ALTER TABLE CLIENTES
    ADD CONSTRAINT CK_CLIENTES_TELEFONO
    CHECK (LENGTH(telefono) >= 7);

ALTER TABLE PROVEEDORES
    ADD CONSTRAINT CK_PROVEEDORES_TELEFONO
    CHECK (LENGTH(telefono) >= 7);

-- TCorreo: debe contener '@' y '.'
ALTER TABLE CLIENTES
    ADD CONSTRAINT CK_CLIENTES_CORREO
    CHECK (correo LIKE '%@%.%');

ALTER TABLE PROVEEDORES
    ADD CONSTRAINT CK_PROVEEDORES_CORREO
    CHECK (correo LIKE '%@%.%');

-- TPrecio: valor numerico mayor que cero
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_PRECIOREFERENCIA
    CHECK (precio_referencia > 0);

ALTER TABLE DETALLESDECOMPRAS
    ADD CONSTRAINT CK_DETALLESCOMPRA_PRECIOCOMPRA
    CHECK (precio_compra > 0);

ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_PRECIOVENTA
    CHECK (precio_venta > 0);

ALTER TABLE FACTURAS
    ADD CONSTRAINT CK_FACTURAS_TOTAL
    CHECK (total > 0);

-- TDescuento: valor numerico mayor o igual a cero
ALTER TABLE DETALLESDEVENTAS
    ADD CONSTRAINT CK_DETALLESVENTA_DESCUENTO
    CHECK (descuento >= 0);

-- TEstadoProducto: estado del producto en el negocio
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_ESTADO
    CHECK (estado IN ('Disponible', 'Agotado', 'Descontinuado', 'Reservado'));

-- TGenero: genero al que aplica la prenda o el calzado
ALTER TABLE ROPA
    ADD CONSTRAINT CK_ROPA_GENERO
    CHECK (genero IN ('Mujer', 'Hombre', 'Unisex', 'Niño', 'Niña'));

ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_GENERO
    CHECK (genero IN ('Mujer', 'Hombre', 'Unisex', 'Niño', 'Niña'));

-- TTallaRopa: tallas de adulto y de niño (numero en años)
ALTER TABLE ROPA
    ADD CONSTRAINT CK_ROPA_TALLA
    CHECK (talla IN ('XS', 'S', 'M', 'L', 'XL', 'XXL',
                     'T2', 'T4', 'T6', 'T8', 'T10', 'T12', 'T14'));

-- TTallaCalzado: tallas validas de calzado (pares de 18 a 34 para niños, 35 a 45 para adultos)
-- La talla segun el genero se valida en Tuplas (CK_CALZADO_TALLAVSGENERO)
ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_TALLA
    CHECK ((talla BETWEEN 18 AND 34 AND talla % 2 = 0) OR (talla BETWEEN 35 AND 45));

-- TRopa: categorias de prendas de vestir
ALTER TABLE ROPA
    ADD CONSTRAINT CK_ROPA_CATEGORIA
    CHECK (categoria_ropa IN ('Camisa', 'Blusa', 'Pantalon', 'Falda', 'Vestido',
                              'Chaqueta', 'Abrigo', 'Sudadera', 'Shorts', 'Jean'));

-- TCalzado: categorias de calzado
ALTER TABLE CALZADO
    ADD CONSTRAINT CK_CALZADO_CATEGORIA
    CHECK (categoria_calzado IN ('Zapatilla', 'Botin', 'Bota', 'Sandalia', 'Plataforma',
                                 'Moccasin', 'Deportivo', 'Chancla'));

-- TAccesorio: categorias de accesorios
ALTER TABLE ACCESORIOS
    ADD CONSTRAINT CK_ACCESORIOS_CATEGORIA
    CHECK (categoria IN ('Bolso', 'Cartera', 'Mochila', 'Joyeria', 'Pulsera',
                         'Aretes', 'Anillo', 'Cinturon', 'Gorra',
                         'Gafas', 'Reloj', 'Billetera'));

-- TMetodoPago: formas de pago aceptadas
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_METODOPAGO
    CHECK (metodo_pago IN ('Efectivo', 'Transferencia', 'Contraentrega'));

-- TMedioEntrega: canales de entrega del negocio
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_MEDIOENTREGA
    CHECK (medio_entrega IN ('Paqueteria', 'Domicilio'));

-- TEstadoVenta: ciclo de vida de una venta
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_ESTADOVENTA
    CHECK (estado_venta IN ('Pendiente', 'Completada', 'Cancelada'));

-- TEstadoCompra: ciclo de vida de una compra
ALTER TABLE COMPRAS
    ADD CONSTRAINT CK_COMPRAS_ESTADOCOMPRA
    CHECK (estado_compra IN ('Recibida', 'Cancelada'));

-- TEstadoFactura: ciclo de vida de una factura
ALTER TABLE FACTURAS
    ADD CONSTRAINT CK_FACTURAS_ESTADOFACTURA
    CHECK (estado_factura IN ('Emitida', 'Pagada', 'Anulada'));