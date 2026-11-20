
-- Restricciones Declarativas. Ciclo 1.

-- Tipos
-- TEstadoProducto: estado del producto en el negocio
ALTER TABLE PRODUCTOS
    ADD CONSTRAINT CK_PRODUCTOS_ESTADO
    CHECK (estado IN ('Disponible', 'Agotado', 'Descontinuado', 'Reservado'));

-- TMetodoPago: formas de pago aceptadas
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_METODOPAGO
    CHECK (metodo_pago IN ('Efectivo', 'Transferencia', 'Contraentrega'));

-- TMedioEntrega: canales de entrega del negocio
ALTER TABLE VENTAS
    ADD CONSTRAINT CK_VENTAS_MEDIOENTREGA
    CHECK (medio_entrega IN ('Paqueteria','Domicilio'));

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
    CHECK (genero IN ('Hombre', 'Mujer', 'Niño', 'Niña', 'Unisex'));

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
    CHECK (categoria IN ('Bolso', 'Cartera', 'Mochila', 'Joyeria', 'Pulsera',
                     'Aretes', 'Anillo', 'Cinturon', 'Gorra',
                     'Gafas', 'Reloj', 'Billetera'));
