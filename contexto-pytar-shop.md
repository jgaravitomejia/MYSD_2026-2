# Contexto del Proyecto Pytar-Shop

## 1. Identificación del Proyecto

- **Nombre:** Pytar-Shop
- **Materia:** Modelos y Servicios de Datos (MYSD)
- **Grupo:** MYSD-3
- **Profesor:** Juan Sebastián Frasica
- **Integrantes:** JUAN GARAVITO y LAILA ROMANO
- **Motor de base de datos:** PostgreSQL (cambiado de MySQL por instrucción del profesor)
- **Herramienta de modelado:** Astah
- **Alcance:** SOLO BASE DE DATOS. No hay interfaz web, no hay GUI, no hay pasarelas de pago.

## 2. Descripción del Negocio

Pytar-Shop es un negocio real de reventa de productos (bolsos, zapatos, ropa, accesorios) a través de Facebook Marketplace.

**Flujo del negocio:**
1. Se compra producto a un proveedor (precio de compra)
2. Se almacena el producto
3. Se publica en Facebook Marketplace
4. Un cliente lo compra (precio de venta)
5. El cliente paga el envío — el negocio NO tiene gastos de envío
6. La ganancia = precio_venta - precio_compra (se calcula, NO se almacena)

**Dato clave:** El único costo variable es el precio de compra del producto, que puede cambiar de un día a otro con el mismo proveedor.

## 3. Decisiones de Diseño

| # | Decisión | Justificación |
|---|----------|---------------|
| 1 | Ganancia NO es un concepto ni atributo | Es dato derivado (precio_venta - precio_compra). Se calcula con consulta SQL. |
| 2 | Gasto fue eliminado como concepto | El cliente paga el envío. El único "gasto" es el precio de compra, ya registrado en DetalleCompra. |
| 3 | Factura NO se agregó | No se emiten facturas en este negocio informal de Marketplace. |
| 4 | Método de pago es ATRIBUTO de Venta | No justifica ser concepto propio. Se guarda como atributo en Venta. |
| 5 | Se agregó lado simétrico de Compra | Si hay Venta (salida), debe haber Compra (entrada). Proveedor→Compra→DetalleCompra→Producto. |
| 6 | Proveedor se conecta a Compra, NO a Producto | El proveedor suministra una compra, no un producto directamente. |
| 7 | DetalleVenta y DetalleCompra son clases de asociación | Resuelven la relación muchos-a-muchos entre Producto↔Venta y Producto↔Compra. En Astah se representan con línea punteada colgando de la relación. |

## 4. Entregas Realizadas

### S03 — Formulación del Proyecto ✅
- Documento PDF con secciones A-F
- Presentación PowerPoint de 6 slides
- Guion de sustentación para 2 personas

### S05 — Diseño Conceptual General ✅
- Diagrama de ~20 conceptos en Astah
- 2 consultas gerenciales + 2 consultas operativas
- Corregido después de retroalimentación del profesor (pasó de 8 a 20 conceptos)

### S07 — Diseño Conceptual Extendido ✅ (en progreso al cierre del chat anterior)
Tiene 3 piezas:
1. **Conceptos extendidos** — Los 5 grandes conceptos con TODOS sus atributos
2. **Consultas operativas** — 5 consultas con formato COMO/QUIERO/PARA PODER
3. **Funciones** — 5 funciones (Mantener/Registrar) con colores por concepto

## 5. Los 5 Grandes Conceptos (con atributos)

### 🔵 Producto
| Atributo | Tipo | Mult. | Notas |
|----------|------|-------|-------|
| {id} idProducto | Integer | [1] | Identificador |
| <<U>> codigoProducto | String | [1] | Código único interno |
| nombre | String | [1] | |
| descripcion | String | [0..1] | Puede no tenerla |
| precioVenta | Real | [1] | Precio actual de venta |
| stock | Integer | [1] | Unidades disponibles |
| estado | String | [1] | Disponible/Agotado/Descontinuado |
| fechaRegistro | Date | [1] | |
| marca | String | [0..1] | |
| color | String | [0..1] | |
| talla | String | [0..1] | |
| categoria | String | [1] | Bolsos/Zapatos/Ropa/Accesorios |

### 🔴 Venta
| Atributo | Tipo | Mult. | Notas |
|----------|------|-------|-------|
| {id} idVenta | Integer | [1] | Identificador |
| <<U>> codigoVenta | String | [1] | Código único |
| fechaVenta | DateTime | [1] | |
| totalVenta | Real | [1] | Suma de subtotales |
| metodoPago | String | [1] | Nequi/Daviplata/Efectivo/Transferencia |
| estadoVenta | String | [1] | Pendiente/Completada/Cancelada |

**DetalleVenta** (clase de asociación Producto↔Venta):
| Atributo | Tipo | Mult. |
|----------|------|-------|
| cantidad | Integer | [1] |
| precioUnitario | Real | [1] |
| subtotal | Real | [1] |

### 🟠 Compra
| Atributo | Tipo | Mult. | Notas |
|----------|------|-------|-------|
| {id} idCompra | Integer | [1] | Identificador |
| <<U>> codigoCompra | String | [1] | Código único |
| fechaCompra | DateTime | [1] | |
| totalCompra | Real | [1] | |
| estadoCompra | String | [1] | Pendiente/Recibida/Cancelada |

**DetalleCompra** (clase de asociación Producto↔Compra):
| Atributo | Tipo | Mult. |
|----------|------|-------|
| cantidad | Integer | [1] |
| precioUnitario | Real | [1] |
| subtotal | Real | [1] |

### 🟢 Cliente
| Atributo | Tipo | Mult. | Notas |
|----------|------|-------|-------|
| {id} idCliente | Integer | [1] | Identificador |
| nombre | String | [1] | |
| apellido | String | [1] | |
| <<U>> correo | String | [0..1] | Puede no tenerlo |
| telefono | String | [1] | |
| direccion | String | [0..1] | |
| ciudad | String | [1] | |
| fechaRegistro | Date | [1] | |

### 🟣 Proveedor
| Atributo | Tipo | Mult. | Notas |
|----------|------|-------|-------|
| {id} idProveedor | Integer | [1] | Identificador |
| nombre | String | [1] | |
| <<U>> correo | String | [0..1] | |
| telefono | String | [1] | |
| empresa | String | [0..1] | Puede ser persona natural |
| ciudad | String | [1] | |
| fechaRegistro | Date | [1] | |

## 6. Relaciones entre Conceptos

```
Cliente ──genera──> Venta (1 a muchos)
Venta ──tiene──> DetalleVenta (1 a muchos)
DetalleVenta ──aparece en──> Producto (muchos a 1)
    [DetalleVenta es clase de asociación de Producto↔Venta]

Proveedor ──suministra──> Compra (1 a muchos)
Compra ──tiene──> DetalleCompra (1 a muchos)
DetalleCompra ──aparece en──> Producto (muchos a 1)
    [DetalleCompra es clase de asociación de Producto↔Compra]
```

## 7. Consultas Gerenciales (2 seleccionadas)

### CG1 — Rentabilidad por categoría
**COMO** administrador del negocio
**QUIERO** conocer la rentabilidad (ingresos por ventas menos costos de compra) de cada categoría de producto en los últimos 6 meses
**PARA PODER** decidir en qué categorías invertir más y cuáles reducir

### CG2 — Inversión vs Ingresos por proveedor
**COMO** administrador del negocio
**QUIERO** comparar cuánto he invertido en compras vs cuánto he generado en ventas por cada proveedor en el último año
**PARA PODER** identificar qué proveedores me dan mejor margen de ganancia

## 8. Consultas Operativas (5)

### CO1 — Stock actual
**COMO** vendedor
**QUIERO** consultar los productos disponibles con su stock actual y precio de venta
**PARA PODER** informar al cliente qué productos puedo ofrecerle

### CO2 — Ventas del mes
**COMO** vendedor
**QUIERO** consultar las ventas realizadas en el mes anterior con su detalle (productos, cantidades, totales)
**PARA PODER** llevar control de lo vendido

### CO3 — Historial de compras a proveedor
**COMO** administrador
**QUIERO** consultar el historial de compras realizadas a un proveedor específico en los últimos 6 meses
**PARA PODER** negociar precios y planificar próximos pedidos

### CO4 — Productos agotados
**COMO** administrador
**QUIERO** consultar los productos con stock en cero o estado "Agotado"
**PARA PODER** gestionar el reabastecimiento oportuno

### CO5 — Datos de cliente
**COMO** vendedor
**QUIERO** consultar los datos de un cliente específico y su historial de compras
**PARA PODER** brindar atención personalizada

## 9. Funciones (5)

| Función | Verbo | Usuario | Color (concepto) |
|---------|-------|---------|------------------|
| F1: Mantener Producto | Mantener | Administrador | 🔵 Azul |
| F2: Registrar Venta | Registrar | Vendedor | 🔴 Rojo |
| F3: Registrar Compra | Registrar | Administrador | 🟠 Naranja |
| F4: Mantener Cliente | Mantener | Vendedor | 🟢 Verde |
| F5: Mantener Proveedor | Mantener | Administrador | 🟣 Morado |

**Regla de verbos:**
- **Mantener** = objetos/roles (CRUD: Crear, Leer, Actualizar, Eliminar)
- **Registrar** = eventos que ocurren (Venta, Compra)

## 10. Estructura del Archivo .astah

```
Pytar-Shop.astah
├── Conceptos/
│   ├── General (diagrama con ~20 conceptos)
│   └── Extendido (diagrama con 5 grandes + atributos + clases de asociación)
├── Usuarios/
│   └── Usuarios (diagrama con actores: Administrador, Vendedor)
├── Consultas/
│   ├── Gerenciales (diagrama de casos de uso: CG1, CG2)
│   └── Operativas (diagrama de casos de uso: CO1-CO5)
└── Funciones/
    └── Funciones (diagrama de casos de uso: F1-F5, coloreadas)
```

## 11. Archivos Generados

| Archivo | Descripción |
|---------|-------------|
| Pytar-Shop.pptx | Presentación de formulación (6 slides) |
| Formulacion_Pytar-Shop.pdf | Documento de formulación (3 páginas, secciones A-F) |
| gen_pptx.js | Script Node.js para generar la presentación |
| gen_formulacion.py | Script Python para generar el PDF |

## 12. Calendario de Entregas

| Semana | Fecha | Entrega | Estado |
|--------|-------|---------|--------|
| S03 | 22 ago | Formulación del proyecto | ✅ |
| S05 | 5 sep | Diseño conceptual general | ✅ |
| S07 | 19 sep | Diseño conceptual extendido (ciclo 1) | ✅ |
| S09 | 26 sep | Diseño lógico: Estructura + Restricciones declarativas | ⬅️ SIGUIENTE |
| S11 | 17 oct | Diseño lógico: Restricciones dinámicas + Consultas/funciones | |
| S13 | 31 oct | Diseño físico: Creación BD + Carga de datos (~2000 filas con Faker) | |
| S15 | 14 nov | Diseño físico: Restricciones + Consultas/funciones implementadas | |
| S17 | 28 nov | Entrega final + sustentación | |

## 13. Conceptos Clave Aprendidos

- **PK (Primary Key):** Identificador único de cada fila en una tabla
- **FK (Foreign Key):** Columna que conecta una tabla con otra, referenciando su PK
- **Normalización:** No almacenar datos derivados (ej: ganancia = venta - compra, se calcula)
- **Clase de asociación:** Resuelve relaciones muchos-a-muchos, representada con línea punteada en UML
- **Mantener vs Registrar:** Mantener = CRUD de objetos, Registrar = eventos
- **Consulta gerencial:** Estratégica/analítica, cruza datos, para toma de decisiones
- **Consulta operativa:** Del día a día, datos puntuales, para operación
- **Multiplicidad de atributos:** [1] = obligatorio, [0..1] = puede ser null
- **{id}** marca identificadores, **<<U>>** marca valores únicos
- **Tipos conceptuales:** Integer, Real, String, Date, DateTime, Boolean (NO usar tipos custom como TCorreo)

## 14. Errores Corregidos

1. "DetallaCompra" → "DetalleCompra" (typo en Astah)
2. "Generar informa" → "Generar informe" (typo en caso de uso)
3. Producto→Venta directo → debe ser Producto→DetalleVenta→Venta
4. "Cliente realiza Venta" → "Cliente genera Venta"
5. "Proveedor realiza Compra" → "Proveedor suministra Compra"
6. Diagrama general con 8 conceptos → expandido a ~20 por retroalimentación del profesor
7. Rangos de fechas "2026-01-01 a 2026-03-31" → cambio a períodos relativos ("últimos 6 meses")
8. Tipos custom (TCorreo, TNombre) → tipos estándar (String, Integer, Real, Date)

## 15. Notas para el Siguiente Chat

- La entrega S09 (26 sep) es **diseño lógico: estructura + restricciones declarativas**
- Se adjuntaron PDFs de clase S03, S04, S08 y S09 como material de referencia
- El profesor pedirá ~2,000 filas de datos para S13 (usar Faker en Python)
- El negocio es REAL pero se pueden inventar conceptos coherentes para enriquecer
- Todo se modela en Astah y se entrega como archivo .astah
- Los colores de los conceptos deben mantenerse consistentes en todos los diagramas
