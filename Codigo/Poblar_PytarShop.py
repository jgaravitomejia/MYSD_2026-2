"""
Generador de datos de prueba para Pytar-Shop (PoblarOK).

Genera sentencias INSERT coherentes con las reglas del negocio:
  - Cada cliente tiene de 1 a 3 ubicaciones y exactamente una principal.
  - Algunos proveedores tienen ubicacion (maximo una, sin cliente).
  - Toda venta se entrega en una ubicacion de su propio cliente.
  - Las fechas son coherentes: registro del cliente <= venta,
    ingreso del producto <= compra <= venta.
  - El stock final de cada producto = unidades compradas (no canceladas)
    - unidades vendidas (no canceladas); nunca se vende mas de lo que hay.
  - Estados validos: ventas Pendiente / Completada / Cancelada,
    compras Recibida / Cancelada.
  - Tallas de calzado enteras y validas segun el genero.
  - Facturas solo de ventas completadas y compras recibidas, una por
    transaccion, con el total calculado a partir de sus detalles.

Uso (desde la carpeta Codigo):
    py Poblar_PytarShop.py > PoblarOK.sql
    py Poblar_PytarShop.py 625 > PoblarOK.sql     (625 = cantidad de clientes)

Con 625 clientes (valor por defecto) se generan 10 025 filas en total.
Los mensajes informativos salen por la consola (stderr), NO dentro del .sql.
"""

import random
import sys
from datetime import datetime, timedelta

sys.stdout.reconfigure(encoding='utf-8')

SEMILLA = 2026                      # misma semilla = mismos datos cada vez
HOY = datetime(2026, 11, 21, 12, 0, 0)
INICIO = datetime(2025, 1, 1, 8, 0, 0)


# ──────────────────────────────────────────────────────────────
#  Configuracion (todo escala a partir del numero de clientes)
# ──────────────────────────────────────────────────────────────
class Config:
    def __init__(self, num_clientes: int):
        self.num_clientes = num_clientes
        self.num_proveedores = max(10, num_clientes // 20)
        self.num_productos = max(50, (num_clientes * 5) // 6)
        self.num_compras = max(30, num_clientes // 3)
        self.num_ventas = num_clientes * 2


# ──────────────────────────────────────────────────────────────
#  Catalogos (los valores respetan los tipos de Dominios.sql)
# ──────────────────────────────────────────────────────────────
class Catalogos:
    NOMBRES = [
        "Sofia Garcia", "Valentina Rodriguez", "Isabella Martinez", "Camila Lopez",
        "Daniela Gonzalez", "Laura Perez", "Mariana Hernandez", "Paula Ramirez",
        "Andrea Torres", "Carolina Flores", "Santiago Vargas", "Sebastian Castro",
        "Mateo Moreno", "Nicolas Gutierrez", "Andres Sanchez", "Felipe Diaz",
        "Juan Rojas", "Carlos Mendoza", "David Reyes", "Diego Ortiz",
        "Monica Gomez", "Natalia Suarez", "Paola Parra", "Alejandra Correa",
        "Jorge Arias", "Ricardo Cardenas", "Gustavo Ospina", "Alejandro Montoya",
        "Miguel Velasquez", "Fernando Restrepo", "Lucia Castillo", "Diana Vargas",
        "Viviana Mejia", "Claudia Rincon", "Patricia Zapata", "Adriana Escobar",
        "Isabel Cardona", "Marcela Florez", "Silvia Medina", "Ana Rivera",
        "Mario Cortes", "Hector Marin", "Alberto Jimenez", "Roberto Muñoz",
        "Ernesto Romero", "Ivan Herrera", "Oscar Valencia", "Victor Quintero",
        "Jaime Giraldo", "Andres Morales",
    ]

    PROVEEDORES = [
        "Distribuciones Moda S.A.", "Textiles del Valle", "Calzado Express Ltda.",
        "Accesorios Premium Co.", "Importadora Fashion", "Confecciones Bogota",
        "Cuero y Estilo S.A.S.", "Sport Wear Colombia", "Moda Infantil S.A.",
        "Global Textiles", "Industrias Ropa Ltda.", "Calzatodo Mayoristas",
        "Accesorios del Norte", "Modas y Tendencias", "Fabricantes Asociados S.A.",
    ]

    CALLES = ["Calle", "Carrera", "Avenida", "Transversal", "Diagonal"]
    BARRIOS = ["Chapinero", "Suba", "Fontibon", "Kennedy", "Usaquen", "Bosa",
               "Engativa", "Teusaquillo", "Laureles", "El Poblado", "Belen",
               "Cedritos", "Niza", "Santa Teresita", None]
    CIUDADES = [("Bogota", "Cundinamarca"), ("Medellin", "Antioquia"),
                ("Cali", "Valle del Cauca"), ("Barranquilla", "Atlantico"),
                ("Bucaramanga", "Santander"), ("Pereira", "Risaralda"),
                ("Manizales", "Caldas"), ("Cartagena", "Bolivar")]

    MARCAS_ROPA = ["Zara", "H&M", "Mango", "Pull&Bear", "Bershka",
                   "Studio F", "Armi", "Koaj", "Ela", "Chevignon"]
    MARCAS_CALZADO = ["Nike", "Adidas", "Puma", "Reebok", "New Balance",
                      "Vans", "Converse", "Skechers", "Crocs", "Bosi"]
    MARCAS_ACCESORIO = ["Guess", "Michael Kors", "Coach", "Tommy Hilfiger",
                        "Arturo Calle", "Velez", "Totto", None]

    MATERIALES_TELA = ["Algodon", "Poliester", "Lino", "Lycra", "Denim", "Lana", None]
    MATERIALES_CALZADO = ["Cuero genuino", "Cuero sintetico", "Malla sintetica",
                          "Lona", "Gamuza", None]
    MATERIALES_ACCESORIO = ["Cuero genuino", "Cuero sintetico", "Tela", "Metal",
                            "Canvas", "Nylon", None]

    # TRopa, TCalzado, TAccesorio
    ROPA = {"Camisa": "Camisa", "Blusa": "Blusa", "Pantalon": "Pantalon",
            "Falda": "Falda", "Vestido": "Vestido", "Chaqueta": "Chaqueta",
            "Abrigo": "Abrigo", "Sudadera": "Sudadera", "Shorts": "Shorts", "Jean": "Jean"}
    CALZADO = {"Zapatilla": "Zapatilla", "Botin": "Botin", "Bota": "Bota",
               "Sandalia": "Sandalia", "Plataforma": "Plataforma",
               "Moccasin": "Moccasin", "Deportivo": "Tenis deportivo", "Chancla": "Chancla"}
    ACCESORIO = {"Bolso": "Bolso", "Cartera": "Cartera", "Mochila": "Mochila",
                 "Joyeria": "Collar", "Pulsera": "Pulsera", "Aretes": "Aretes",
                 "Anillo": "Anillo", "Cinturon": "Cinturon", "Gorra": "Gorra",
                 "Gafas": "Gafas de sol", "Reloj": "Reloj", "Billetera": "Billetera"}
    ESTILOS = ["Clasico", "Urbano", "Casual", "Elegante", "Basico", "Sport", "Vintage"]

    # TGenero, TTallaRopa, TTallaCalzado (talla segun genero)
    GENEROS = ["Mujer", "Hombre", "Unisex", "Niño", "Niña"]
    TALLAS_ROPA_ADULTO = ["XS", "S", "M", "L", "XL", "XXL"]
    TALLAS_ROPA_NINO = ["T2", "T4", "T6", "T8", "T10", "T12", "T14"]
    TALLAS_CALZADO = {
        "Mujer": list(range(35, 42)),
        "Hombre": list(range(38, 46)),
        "Unisex": list(range(35, 46)),
        "Niño": list(range(18, 35, 2)),
        "Niña": list(range(18, 35, 2)),
    }

    METODOS_PAGO = ["Efectivo", "Transferencia", "Transferencia", "Contraentrega"]
    MEDIOS_ENTREGA = ["Paqueteria", "Domicilio"]

    @staticmethod
    def sql(valor) -> str:
        if valor is None:
            return "NULL"
        if isinstance(valor, bool):
            return "TRUE" if valor else "FALSE"
        if isinstance(valor, (int, float)):
            return str(valor)
        if isinstance(valor, datetime):
            return f"'{valor:%Y-%m-%d %H:%M:%S}'"
        return "'" + str(valor).replace("'", "''") + "'"

    @staticmethod
    def telefono() -> str:
        return random.choice(["300", "301", "310", "311", "312", "315", "320", "350"]) \
            + str(random.randint(1000000, 9999999))

    @staticmethod
    def direccion() -> str:
        return (f"{random.choice(Catalogos.CALLES)} {random.randint(1, 150)} "
                f"#{random.randint(1, 99)}-{random.randint(1, 99)}")


def fecha_entre(desde: datetime, hasta: datetime) -> datetime:
    """Fecha aleatoria entre dos fechas, en horario comercial."""
    if hasta <= desde:
        return desde
    segundos = int((hasta - desde).total_seconds())
    f = desde + timedelta(seconds=random.randint(0, segundos))
    return f.replace(hour=random.randint(8, 19), minute=random.randint(0, 59),
                     second=random.randint(0, 59), microsecond=0)


def precio(minimo: int, maximo: int) -> float:
    """Precio redondeado a cientos de pesos."""
    return float(round(random.randint(minimo, maximo), -2))


# ──────────────────────────────────────────────────────────────
#  Generador
# ──────────────────────────────────────────────────────────────
class Generador:

    def __init__(self, cfg: Config):
        self.cfg = cfg
        self.lineas = []
        self.conteo = {}
        # datos en memoria para mantener la coherencia
        self.clientes = []          # (id, fecha_registro, [ids ubicaciones])
        self.proveedores = []       # (id, fecha_registro)
        self.productos = {}         # id -> dict(precio, fecha_ingreso, stock, tipo)
        self.compras = []           # (id, fecha, estado, [(id_producto, cantidad, precio)])
        self.ventas = []            # (id, fecha, estado, medio, [(id_producto, cantidad, precio, descuento)])
        self.id_ubicacion = 0

    def insert(self, tabla: str, columnas: str, valores: list):
        self.lineas.append(f"INSERT INTO {tabla} ({columnas}) VALUES "
                           f"({', '.join(Catalogos.sql(v) for v in valores)});")
        self.conteo[tabla] = self.conteo.get(tabla, 0) + 1

    def titulo(self, texto: str):
        self.lineas.append(f"\n-- PoblarOK. {texto}")

    def nueva_ubicacion(self, id_cliente, es_principal):
        self.id_ubicacion += 1
        ciudad, dpto = random.choice(Catalogos.CIUDADES)
        self.insert("UBICACIONES",
                    "id_ubicacion, calle, barrio, ciudad, departamento, codigo_postal, es_principal, id_cliente",
                    [self.id_ubicacion, Catalogos.direccion(), random.choice(Catalogos.BARRIOS),
                     ciudad, dpto, str(random.randint(100000, 999999)) if random.random() < 0.6 else None,
                     es_principal, id_cliente])
        return self.id_ubicacion

    # ── CLIENTES y sus UBICACIONES ────────────────────────────
    def generar_clientes(self):
        self.titulo("CRUD: Clientes")
        correos = set()
        for id_c in range(1, self.cfg.num_clientes + 1):
            nombre = random.choice(Catalogos.NOMBRES)
            correo = None
            if random.random() < 0.8:
                base = nombre.lower().replace(" ", ".").replace("ñ", "n")
                correo = f"{base}{id_c}@{random.choice(['gmail.com', 'hotmail.com', 'outlook.com'])}"
                correos.add(correo)
            registro = fecha_entre(INICIO, HOY - timedelta(days=20))
            self.insert("CLIENTES", "id_cliente, nombre, telefono, correo, fecha_registro, notas",
                        [id_c, nombre, Catalogos.telefono(), correo, registro,
                         random.choice(["Cliente frecuente", "Prefiere transferencia", None, None, None])])
            self.clientes.append([id_c, registro, []])

        self.titulo("CRUD: Ubicaciones de clientes (de 1 a 3 por cliente, una principal)")
        for cliente in self.clientes:
            for k in range(random.choice([1, 1, 2, 2, 3])):
                cliente[2].append(self.nueva_ubicacion(cliente[0], k == 0))

    # ── PROVEEDORES y sus UBICACIONES ─────────────────────────
    def generar_proveedores(self):
        self.titulo("CRUD: Ubicaciones de proveedores (opcional, maximo una)")
        ubic_prov = {}
        for id_p in range(1, self.cfg.num_proveedores + 1):
            if random.random() < 0.6:
                ubic_prov[id_p] = self.nueva_ubicacion(None, False)

        self.titulo("CRUD: Proveedores")
        for id_p in range(1, self.cfg.num_proveedores + 1):
            base = Catalogos.PROVEEDORES[(id_p - 1) % len(Catalogos.PROVEEDORES)]
            nombre = base if id_p <= len(Catalogos.PROVEEDORES) else f"{base} {id_p}"
            dominio = base.split()[0].lower().replace(".", "")
            registro = fecha_entre(INICIO - timedelta(days=730), INICIO - timedelta(days=1))
            self.insert("PROVEEDORES", "id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion",
                        [id_p, nombre, "601" + str(random.randint(1000000, 9999999)),
                         f"ventas{id_p}@{dominio}.co", registro, ubic_prov.get(id_p)])
            self.proveedores.append((id_p, registro))

    # ── PRODUCTOS y SUBTIPOS ──────────────────────────────────
    def generar_productos(self):
        n = self.cfg.num_productos
        tipos = ["Ropa"] * int(n * 0.40) + ["Calzado"] * int(n * 0.30)
        tipos += ["Accesorio"] * (n - len(tipos))
        random.shuffle(tipos)
        subtipos = {"Ropa": [], "Calzado": [], "Accesorio": []}

        for id_p, tipo in enumerate(tipos, start=1):
            if tipo == "Ropa":
                categoria = random.choice(list(Catalogos.ROPA))
                genero = random.choice(Catalogos.GENEROS)
                talla = random.choice(Catalogos.TALLAS_ROPA_NINO if genero in ("Niño", "Niña")
                                      else Catalogos.TALLAS_ROPA_ADULTO)
                marca = random.choice(Catalogos.MARCAS_ROPA)
                valor = precio(30000, 250000)
                nombre = f"{Catalogos.ROPA[categoria]} {random.choice(Catalogos.ESTILOS)}"
                subtipos["Ropa"].append([id_p, talla, genero, categoria,
                                         random.choice(Catalogos.MATERIALES_TELA)])
            elif tipo == "Calzado":
                categoria = random.choice(list(Catalogos.CALZADO))
                genero = random.choice(Catalogos.GENEROS)
                talla = random.choice(Catalogos.TALLAS_CALZADO[genero])
                marca = random.choice(Catalogos.MARCAS_CALZADO)
                valor = precio(60000, 450000)
                nombre = f"{Catalogos.CALZADO[categoria]} {random.choice(Catalogos.ESTILOS)}"
                subtipos["Calzado"].append([id_p, talla, genero, categoria,
                                            random.choice(Catalogos.MATERIALES_CALZADO)])
            else:
                categoria = random.choice(list(Catalogos.ACCESORIO))
                marca = random.choice(Catalogos.MARCAS_ACCESORIO)
                valor = precio(20000, 500000)
                nombre = f"{Catalogos.ACCESORIO[categoria]} {random.choice(Catalogos.ESTILOS)}"
                subtipos["Accesorio"].append([id_p, categoria,
                                              random.choice(Catalogos.MATERIALES_ACCESORIO),
                                              random.choice(["30x20x10 cm", "25x15x8 cm", "15x10x5 cm", None])])
            self.productos[id_p] = {
                "nombre": nombre, "marca": marca, "precio": valor, "tipo": tipo,
                "ingreso": fecha_entre(INICIO - timedelta(days=60), HOY - timedelta(days=60)),
                "stock": 0, "comprado": False,
            }
        self.subtipos = subtipos

    def escribir_productos(self):
        # Se escriben despues de simular compras y ventas, porque el stock y el estado
        # finales dependen de lo que se compro y se vendio.
        self.titulo("CRUD: Productos")
        for id_p, p in self.productos.items():
            if p["stock"] == 0:
                estado = "Agotado"
            else:
                estado = random.choices(["Disponible", "Reservado", "Descontinuado"], [90, 5, 5])[0]
            self.insert("PRODUCTOS",
                        "id_producto, nombre, descripcion, precio_referencia, marca, stock, estado, fecha_ingreso, imagen_url",
                        [id_p, p["nombre"], None, p["precio"], p["marca"], p["stock"], estado,
                         p["ingreso"], None])

        self.titulo("CRUD: Ropa")
        for fila in self.subtipos["Ropa"]:
            self.insert("ROPA", "id_producto, talla, genero, categoria_ropa, material", fila)
        self.titulo("CRUD: Calzado")
        for fila in self.subtipos["Calzado"]:
            self.insert("CALZADO", "id_producto, talla, genero, categoria_calzado, material", fila)
        self.titulo("CRUD: Accesorios")
        for fila in self.subtipos["Accesorio"]:
            self.insert("ACCESORIOS", "id_producto, categoria, material, dimensiones", fila)

    # ── SIMULACION EN ORDEN DE FECHA: compras y ventas ────────
    def simular(self):
        eventos = [("compra", fecha_entre(INICIO, HOY - timedelta(days=3)))
                   for _ in range(self.cfg.num_compras)]
        eventos += [("venta", fecha_entre(INICIO + timedelta(days=20), HOY))
                    for _ in range(self.cfg.num_ventas)]
        eventos.sort(key=lambda e: e[1])

        id_compra = id_venta = 0
        for tipo, fecha in eventos:
            if tipo == "compra":
                id_compra += 1
                self.registrar_compra(id_compra, fecha)
            else:
                if self.registrar_venta(id_venta + 1, fecha):
                    id_venta += 1

    def registrar_compra(self, id_compra, fecha):
        estado = "Cancelada" if random.random() < 0.08 else "Recibida"
        disponibles = [i for i, p in self.productos.items() if p["ingreso"] <= fecha]
        # se prioriza surtir productos que nunca se han comprado o que estan agotados
        prioridad = [i for i in disponibles if self.productos[i]["stock"] == 0]
        elegidos = set(random.sample(prioridad, min(len(prioridad), random.randint(3, 6))))
        while len(elegidos) < 5 and len(elegidos) < len(disponibles):
            elegidos.add(random.choice(disponibles))
        detalles = []
        for id_p in elegidos:
            cantidad = random.randint(3, 15)
            costo = float(round(self.productos[id_p]["precio"] * random.uniform(0.45, 0.65), -2))
            detalles.append((id_p, cantidad, costo))
            if estado == "Recibida":
                self.productos[id_p]["stock"] += cantidad
                self.productos[id_p]["comprado"] = True
        proveedor = random.choice([p for p in self.proveedores if p[1] <= fecha])
        self.compras.append((id_compra, fecha, estado, proveedor[0], detalles))

    def registrar_venta(self, id_venta, fecha):
        candidatos = [c for c in self.clientes if c[1] <= fecha]
        con_stock = [i for i, p in self.productos.items() if p["stock"] > 0]
        if not candidatos or not con_stock:
            return False
        cliente = random.choice(candidatos)
        # la mayoria de las veces se entrega en la ubicacion principal (la primera)
        ubicacion = cliente[2][0] if random.random() < 0.7 else random.choice(cliente[2])
        antiguedad = (HOY - fecha).days
        if random.random() < 0.08:
            estado = "Cancelada"
        elif antiguedad <= 10:
            estado = random.choice(["Pendiente", "Pendiente", "Completada"])
        else:
            estado = "Completada"

        detalles = []
        for id_p in random.sample(con_stock, min(len(con_stock), random.choice([1, 1, 2, 2, 3]))):
            p = self.productos[id_p]
            cantidad = random.randint(1, min(3, p["stock"]))
            valor = float(round(p["precio"] * random.uniform(0.95, 1.10), -2))
            descuento = float(round(valor * random.uniform(0.05, 0.20), -2)) if random.random() < 0.2 else None
            detalles.append((id_p, cantidad, valor, descuento))
            if estado != "Cancelada":
                p["stock"] -= cantidad
        self.ventas.append((id_venta, fecha, estado, cliente[0], ubicacion, detalles))
        return True

    def escribir_compras(self):
        self.titulo("CRUD: Compras")
        for id_c, fecha, estado, id_prov, _ in self.compras:
            self.insert("COMPRAS", "id_compra, fecha_compra, estado_compra, observacion, id_proveedor",
                        [id_c, fecha, estado,
                         random.choice(["Pedido urgente", "Reposicion de temporada", None, None, None]),
                         id_prov])
        self.titulo("CRUD: Detalles de Compras")
        for id_c, _, _, _, detalles in self.compras:
            for id_p, cantidad, costo in detalles:
                self.insert("DETALLESDECOMPRAS", "id_compra, id_producto, cantidad, precio_compra",
                            [id_c, id_p, cantidad, costo])

    def escribir_ventas(self):
        self.titulo("CRUD: Ventas")
        for id_v, fecha, estado, id_cl, id_ubic, _ in self.ventas:
            self.insert("VENTAS",
                        "id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, observaciones, id_cliente, id_ubicacion",
                        [id_v, fecha, random.choice(Catalogos.METODOS_PAGO), estado,
                         random.choice(Catalogos.MEDIOS_ENTREGA),
                         random.choice(["Entregar en la tarde", "Llamar antes de llegar", None, None, None]),
                         id_cl, id_ubic])
        self.titulo("CRUD: Detalles de Ventas")
        for id_v, _, _, _, _, detalles in self.ventas:
            for id_p, cantidad, valor, descuento in detalles:
                self.insert("DETALLESDEVENTAS", "id_venta, id_producto, cantidad, precio_venta, descuento",
                            [id_v, id_p, cantidad, valor, descuento])

    # ── FACTURAS ──────────────────────────────────────────────
    def escribir_facturas(self):
        facturas, f_venta, f_compra = [], [], []
        id_f = 0
        for id_v, fecha, estado, _, _, detalles in self.ventas:
            if estado == "Completada" and random.random() < 0.9:
                id_f += 1
                total = sum(c * v - (d or 0) for _, c, v, d in detalles)
                estado_f = "Pagada" if (HOY - fecha).days > 30 else random.choice(["Emitida", "Pagada"])
                facturas.append([id_f, fecha + timedelta(hours=random.randint(1, 48)),
                                 round(total, 2), estado_f, None])
                f_venta.append([id_f, id_v, f"GUIA-{id_v:06d}" if random.random() < 0.7 else None])
        for id_c, fecha, estado, _, detalles in self.compras:
            if estado == "Recibida" and random.random() < 0.9:
                id_f += 1
                total = sum(c * v for _, c, v in detalles)
                facturas.append([id_f, fecha + timedelta(hours=random.randint(1, 48)),
                                 round(total, 2), "Pagada" if (HOY - fecha).days > 30 else "Emitida", None])
                f_compra.append([id_f, id_c, f"REM-{id_c:06d}" if random.random() < 0.8 else None])

        self.titulo("CRUD: Facturas")
        for fila in facturas:
            self.insert("FACTURAS", "id_factura, fecha_emision, total, estado_factura, observaciones", fila)
        self.titulo("CRUD: Facturas de Venta")
        for fila in f_venta:
            self.insert("FACTURASVENTA", "id_factura, id_venta, numero_guia", fila)
        self.titulo("CRUD: Facturas de Compra")
        for fila in f_compra:
            self.insert("FACTURASCOMPRA", "id_factura, id_compra, numero_remision", fila)

    # ── EJECUCION ─────────────────────────────────────────────
    def poblar(self):
        random.seed(SEMILLA)
        self.generar_clientes()
        self.generar_proveedores()
        self.generar_productos()
        self.simular()

        # Orden de escritura: respeta las llaves foraneas
        cuerpo_clientes = self.lineas
        self.lineas = []
        self.escribir_productos()
        self.escribir_compras()
        self.escribir_ventas()
        self.escribir_facturas()

        total = sum(self.conteo.values())
        print("-- PoblarOK. Pytar-Shop")
        print(f"-- Datos generados con Poblar_PytarShop.py ({self.cfg.num_clientes} clientes, semilla {SEMILLA})")
        print(f"-- Total de filas: {total}")
        for tabla, n in self.conteo.items():
            print(f"--   {tabla:<18} {n}")
        print("\n".join(cuerpo_clientes))
        print("\n".join(self.lineas))
        return total


def main():
    try:
        n = int(sys.argv[1]) if len(sys.argv) > 1 else 625
        total = Generador(Config(n)).poblar()
        print(f"PoblarOK generado: {total} filas", file=sys.stderr)
    except ValueError:
        print("Error: la cantidad de clientes debe ser un numero entero", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
