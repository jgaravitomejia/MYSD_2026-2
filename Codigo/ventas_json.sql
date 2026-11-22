-- Tabla con columna JSONB
DROP TABLE IF EXISTS ventas_json;

CREATE TABLE ventas_json(
    id NUMERIC(2) NOT NULL,
    datos JSONB NOT NULL
);

ALTER TABLE ventas_json ADD CONSTRAINT PK_ventas_json
    PRIMARY KEY (id);



-- PoblarOK: INSERT con JSON válido

-- Venta 1: Efectivo, Completada, Domicilio, factura Pagada
INSERT INTO ventas_json(id, datos)
VALUES (1,
$$
{
    "id_venta": 70010,
    "fecha_venta": "2025-11-01",
    "metodo_pago": "Efectivo",
    "estado_venta": "Completada",
    "medio_entrega": "Domicilio",
    "observaciones": "Entregar en horario de tarde",
    "cliente": {
        "id_cliente": 93010,
        "nombre": "Juan Pérez",
        "telefono": "3101234567",
        "correo": "juan@mail.com"
    },
    "ubicacion_entrega": {
        "calle": "Calle 50 #20-30",
        "barrio": "Centro",
        "ciudad": "Bogotá",
        "departamento": "Cundinamarca"
    },
    "detalles": [
        {
            "producto": "Camiseta Negra",
            "tipo": "Ropa",
            "categoria": "Camisa",
            "talla": "M",
            "genero": "Hombre",
            "cantidad": 2,
            "precio_venta": 45000,
            "descuento": 5000
        },
        {
            "producto": "Bolso Cuero",
            "tipo": "Accesorio",
            "categoria": "Bolso",
            "cantidad": 1,
            "precio_venta": 120000,
            "descuento": 0
        }
    ],
    "factura": {
        "id_factura": 50010,
        "estado_factura": "Pagada",
        "numero_guia": "GUIA-001"
    }
}
$$::jsonb
);

-- Venta 2: Transferencia, Pendiente, Paqueteria, factura Emitida
INSERT INTO ventas_json(id, datos)
VALUES (2,
$$
{
    "id_venta": 70011,
    "fecha_venta": "2025-11-05",
    "metodo_pago": "Transferencia",
    "estado_venta": "Pendiente",
    "medio_entrega": "Paqueteria",
    "cliente": {
        "id_cliente": 93011,
        "nombre": "María López",
        "telefono": "3209876543",
        "correo": "maria@mail.com"
    },
    "ubicacion_entrega": {
        "calle": "Carrera 10 #15-40",
        "barrio": "Chapinero",
        "ciudad": "Bogotá",
        "departamento": "Cundinamarca"
    },
    "detalles": [
        {
            "producto": "Deportivo Nike",
            "tipo": "Calzado",
            "categoria": "Deportivo",
            "talla": 38,
            "genero": "Mujer",
            "cantidad": 1,
            "precio_venta": 250000,
            "descuento": 0
        },
        {
            "producto": "Gafas Ray-Ban",
            "tipo": "Accesorio",
            "categoria": "Gafas",
            "cantidad": 1,
            "precio_venta": 180000,
            "descuento": 20000
        }
    ],
    "factura": {
        "id_factura": 50011,
        "estado_factura": "Emitida",
        "numero_guia": "PKT-2025-001"
    }
}
$$::jsonb
);

-- Venta 3: Contraentrega, Cancelada, Domicilio, factura Anulada
INSERT INTO ventas_json(id, datos)
VALUES (3,
$$
{
    "id_venta": 70012,
    "fecha_venta": "2025-11-10",
    "metodo_pago": "Contraentrega",
    "estado_venta": "Cancelada",
    "medio_entrega": "Domicilio",
    "observaciones": "Cliente no recibió",
    "cliente": {
        "id_cliente": 93012,
        "nombre": "Carlos Ramírez",
        "telefono": "3155551234"
    },
    "ubicacion_entrega": {
        "calle": "Avenida 68 #45-12",
        "ciudad": "Medellín",
        "departamento": "Antioquia"
    },
    "detalles": [
        {
            "producto": "Jean Slim",
            "tipo": "Ropa",
            "categoria": "Jean",
            "talla": "L",
            "genero": "Hombre",
            "cantidad": 1,
            "precio_venta": 89000,
            "descuento": 10000
        },
        {
            "producto": "Cinturón Negro",
            "tipo": "Accesorio",
            "categoria": "Cinturon",
            "cantidad": 1,
            "precio_venta": 35000,
            "descuento": 0
        },
        {
            "producto": "Botin Café",
            "tipo": "Calzado",
            "categoria": "Botin",
            "talla": 42,
            "genero": "Hombre",
            "cantidad": 1,
            "precio_venta": 180000,
            "descuento": 15000
        }
    ],
    "factura": {
        "id_factura": 50012,
        "estado_factura": "Anulada"
    }
}
$$::jsonb
);
