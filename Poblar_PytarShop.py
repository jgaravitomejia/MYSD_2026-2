"""
Generador de datos de prueba para Pytar-Shop.
Genera sentencias INSERT de SQL para poblar la base de datos.

Escala aproximada con n=500 clientes:
  UBICACIONES       ~650
  CLIENTES          ~500
  PROVEEDORES        ~50
  PRODUCTOS        ~1000
  ROPA              ~350   (subclase)
  CALZADO           ~300   (subclase)
  ACCESORIOS        ~350   (subclase)
  COMPRAS           ~166
  DETALLESDECOMPRAS ~650
  VENTAS           ~2000
  DETALLESDEVENTAS ~3500
  FACTURAS         ~2166
  FACTURASVENTA    ~2000
  FACTURASCOMPRA    ~166
  ─────────────────────
  TOTAL           ~13 848 filas
"""

import random
from dataclasses import dataclass
from typing import List, Set


# ──────────────────────────────────────────────────────────────
#  Configuración
# ──────────────────────────────────────────────────────────────
@dataclass
class DatabaseConfig:
    num_clientes: int

    @property
    def num_proveedores(self) -> int:
        return max(10, self.num_clientes // 10)

    @property
    def num_productos(self) -> int:
        return self.num_clientes * 2

    @property
    def num_compras(self) -> int:
        return max(50, self.num_clientes // 3)

    @property
    def num_ventas(self) -> int:
        return self.num_clientes * 4


# ──────────────────────────────────────────────────────────────
#  Catálogos de datos aleatorios
# ──────────────────────────────────────────────────────────────
class Catalogos:
    NOMBRES_COMPLETOS = [
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
        "Jaime Giraldo", "Andres Morales"
    ]

    NOMBRES_PROVEEDORES = [
        "Distribuciones Moda S.A.", "Textiles del Valle", "Calzado Express Ltda.",
        "Accesorios Premium Co.", "Importadora Fashion", "Confecciones Bogota",
        "Cuero y Estilo S.A.S.", "Sport Wear Colombia", "Moda Infantil S.A.",
        "Global Textiles", "Industrias Ropa Ltda.", "Calzatodo Mayoristas",
        "Accesorios del Norte", "Modas y Tendencias", "Fabricantes Asociados S.A."
    ]

    CALLES_TIPO = ["Calle", "Carrera", "Avenida", "Transversal", "Diagonal"]

    BARRIOS = [
        "Chapinero", "Suba", "Fontibon", "Kennedy", "Usaquen", "Bosa",
        "Engativa", "Teusaquillo", "Rafael Uribe", "Antonio Narino",
        "Laureles", "El Poblado", "Belen", "Estadio", "Conquistadores",
        "La Castellana", "Santa Teresita", "Chicala", "Cedritos", "Niza"
    ]

    CIUDADES_DPTO = [
        ("Bogota", "Cundinamarca"),
        ("Medellin", "Antioquia"),
        ("Cali", "Valle del Cauca"),
        ("Barranquilla", "Atlantico"),
        ("Bucaramanga", "Santander"),
        ("Pereira", "Risaralda"),
        ("Manizales", "Caldas"),
        ("Cartagena", "Bolivar"),
    ]

    MARCAS_ROPA = ["Zara", "H&M", "Mango", "Pull&Bear", "Bershka",
                   "Studio F", "Armi", "Koaj", "Ela", "Chevignon"]

    MARCAS_CALZADO = ["Nike", "Adidas", "Puma", "Reebok", "New Balance",
                      "Vans", "Converse", "Skechers", "Crocs", "Bosi"]

    MARCAS_ACCESORIO = ["Guess", "Michael Kors", "Coach", "Kate Spade",
                        "Tommy Hilfiger", "Arturo Calle", "Velez", "Samsonite",
                        "Totto", None]

    MATERIALES_TELA = ["Algodon", "Poliester", "Lino", "Lycra",
                       "Viscosa", "Denim", "Lana", "Nylon", None]

    MATERIALES_CALZADO = ["Cuero genuino", "Cuero sintetico", "Malla sintetica",
                           "Lona", "Gamuza", "Neopreno", None]

    MATERIALES_ACCESORIO = ["Cuero genuino", "Cuero sintetico", "Tela",
                             "Plastico duro", "Metal", "Canvas", "Nylon", None]

    ESTADOS_PRODUCTO = ["Disponible", "Disponible", "Disponible", "Agotado", "Descontinuado"]

    TALLAS_ROPA = ["XS", "S", "M", "L", "XL", "XXL",
                   "T2", "T4", "T6", "T8", "T10", "T12", "T14"]
    
    GENEROS_ROPA = ["Hombre", "Mujer", "Niño", "Niña", "Unisex"]

    CATEGORIAS_ROPA = ["Camisa", "Blusa", "Pantalon", "Falda", "Vestido",
                       "Chaqueta", "Abrigo", "Sudadera", "Shorts", "Jean"]

    GENEROS_CALZADO = ["Hombre", "Mujer", "Nino", "Nina", "Unisex"]
    
    CATEGORIAS_CALZADO = ["Zapatilla", "Botin", "Bota", "Sandalia", "Plataforma",
                           "Moccasin", "Deportivo", "Chancla"]

    CATEGORIAS_ACCESORIO = ["Bolso", "Cartera", "Cinturon", "Gorra",
                             "Gafas", "Joyeria", "Reloj", "Mochila", "Billetera"]

    METODOS_PAGO = ["Efectivo", "Transferencia"]
    MEDIOS_ENTREGA = ["Paqueteria", "Domicilio", "Recogida en punto"]
    ESTADOS_VENTA = ["Pendiente", "Completada", "Completada", "Completada",
                     "Cancelada", "En devolucion"]
    ESTADOS_COMPRA = ["Pendiente", "Recibida", "Recibida", "Recibida",
                      "Cancelada", "Parcial"]
    ESTADOS_FACTURA = ["Emitida", "Emitida", "Emitida", "Pagada", "Anulada"]

    @staticmethod
    def sql_str(valor) -> str:
        if valor is None:
            return "NULL"
        return f"'{valor}'"

    @staticmethod
    def telefono() -> str:
        prefijo = random.choice(["300", "301", "302", "310", "311", "312",
                                 "313", "314", "315", "316", "320", "321",
                                 "322", "350"])
        return prefijo + str(random.randint(1000000, 9999999))

    @staticmethod
    def correo(nombre: str, sufijo: int) -> str:
        base = nombre.lower().replace(" ", "").replace("ñ", "n")
        dominio = random.choice(["gmail.com", "hotmail.com", "yahoo.com", "outlook.com"])
        return f"{base}{sufijo}@{dominio}"

    @staticmethod
    def direccion() -> str:
        tipo = random.choice(Catalogos.CALLES_TIPO)
        n1 = random.randint(1, 150)
        n2 = random.randint(1, 99)
        n3 = random.randint(1, 99)
        apto = f" Apto {random.randint(100, 999)}" if random.random() < 0.2 else ""
        return f"{tipo} {n1} #{n2}-{n3}{apto}"

    @staticmethod
    def codigo_postal() -> str:
        return str(random.randint(100000, 999999))

    @staticmethod
    def timestamp(año_ini=2023, año_fin=2026) -> str:
        a = random.randint(año_ini, año_fin)
        m = random.randint(1, 12)
        d = random.randint(1, 28)
        h = random.randint(7, 20)
        mi = random.randint(0, 59)
        s = random.randint(0, 59)
        return f"{a}-{m:02d}-{d:02d} {h:02d}:{mi:02d}:{s:02d}"


# ──────────────────────────────────────────────────────────────
#  Generador principal
# ──────────────────────────────────────────────────────────────
class PytarShopPopulator:

    def __init__(self, config: DatabaseConfig):
        self.cfg = config
        self.ids_ubicaciones: List[int] = []
        self.ids_clientes: List[int] = []
        self.ids_proveedores: List[int] = []
        self.ids_productos: List[int] = []
        self.ids_ropa: List[int] = []
        self.ids_calzado: List[int] = []
        self.ids_accesorio: List[int] = []
        self.ids_compras: List[int] = []
        self.ids_ventas: List[int] = []
        self._correos_usados: Set[str] = set()
        self._id_factura = 0

    def _nueva_factura(self) -> int:
        self._id_factura += 1
        return self._id_factura

    # ── UBICACIONES ───────────────────────────────────────────
    # Se generan primero porque CLIENTES y PROVEEDORES las referencian
    def generar_ubicaciones(self):
        print("\n-- PoblarOK. CRUD: Ubicaciones")
        # una ubicacion por cada cliente + una por cada proveedor (aprox)
        total = self.cfg.num_clientes + self.cfg.num_proveedores
        for i in range(1, total + 1):
            calle = Catalogos.direccion()
            barrio = random.choice(Catalogos.BARRIOS)
            ciudad, dpto = random.choice(Catalogos.CIUDADES_DPTO)
            cp = Catalogos.codigo_postal() if random.random() < 0.7 else None
            es_principal = "true"
            print(f"INSERT INTO UBICACIONES "
                  f"(id_ubicacion, calle, barrio, ciudad, departamento, "
                  f"codigo_postal, es_principal) "
                  f"VALUES ({i}, '{calle}', '{barrio}', '{ciudad}', '{dpto}', "
                  f"{Catalogos.sql_str(cp)}, {es_principal});")
            self.ids_ubicaciones.append(i)

    # ── CLIENTES ─────────────────────────────────────────────
    def generar_clientes(self):
        print("\n-- PoblarOK. CRUD: Clientes")
        nombres_usados: Set[str] = set()
        generados = 0
        id_c = 1
        # pool de ubicaciones para clientes (primeras num_clientes ubicaciones)
        pool_ubic = self.ids_ubicaciones[:self.cfg.num_clientes]

        while generados < self.cfg.num_clientes:
            nombre = random.choice(Catalogos.NOMBRES_COMPLETOS)
            if nombre in nombres_usados:
                continue
            nombres_usados.add(nombre)

            correo = Catalogos.correo(nombre, id_c)
            if correo in self._correos_usados:
                correo = None
            else:
                self._correos_usados.add(correo)

            telefono = Catalogos.telefono()
            fecha_reg = Catalogos.timestamp(2020, 2025)
            notas = Catalogos.sql_str(random.choice(
                ["Cliente frecuente", "Preferencial", None, None, None]))

            # id_ubicacion: la mayoria tiene, algunos no
            id_ubic = pool_ubic[generados] if random.random() < 0.85 else None

            print(f"INSERT INTO CLIENTES "
                  f"(id_cliente, nombre, telefono, correo, fecha_registro, notas, id_ubicacion) "
                  f"VALUES ({id_c}, '{nombre}', '{telefono}', {Catalogos.sql_str(correo)}, "
                  f"'{fecha_reg}', {notas}, {Catalogos.sql_str(id_ubic)});")

            self.ids_clientes.append(id_c)
            id_c += 1
            generados += 1

    # ── PROVEEDORES ───────────────────────────────────────────
    def generar_proveedores(self):
        print("\n-- PoblarOK. CRUD: Proveedores")
        nombres = (Catalogos.NOMBRES_PROVEEDORES * 10)[:self.cfg.num_proveedores]
        # pool de ubicaciones para proveedores (ultimas num_proveedores ubicaciones)
        pool_ubic = self.ids_ubicaciones[self.cfg.num_clientes:]

        for i, nombre in enumerate(nombres, start=1):
            correo = f"ventas{i}@{nombre.split()[0].lower().replace('.','')}.co"
            if correo in self._correos_usados:
                correo = None
            else:
                self._correos_usados.add(correo)

            telefono = Catalogos.telefono()
            fecha_reg = Catalogos.timestamp(2018, 2024)
            id_ubic = pool_ubic[i - 1] if (i - 1) < len(pool_ubic) else None

            print(f"INSERT INTO PROVEEDORES "
                  f"(id_proveedor, nombre, telefono, correo, fecha_registro, id_ubicacion) "
                  f"VALUES ({i}, '{nombre}', '{telefono}', {Catalogos.sql_str(correo)}, "
                  f"'{fecha_reg}', {Catalogos.sql_str(id_ubic)});")
            self.ids_proveedores.append(i)

    # ── PRODUCTOS ─────────────────────────────────────────────
    def generar_productos(self):
        print("\n-- PoblarOK. CRUD: Productos")
        n = self.cfg.num_productos
        n_ropa = int(n * 0.35)
        n_calzado = int(n * 0.30)
        n_acc = n - n_ropa - n_calzado

        tipos = (["ropa"] * n_ropa) + (["calzado"] * n_calzado) + (["accesorio"] * n_acc)
        random.shuffle(tipos)

        NOMBRES_ROPA = ["Camiseta Clasica", "Blusa Floral", "Jean Slim", "Vestido Casual",
                        "Chaqueta Denim", "Sudadera Oversize", "Shorts Verano",
                        "Pantalon Formal", "Abrigo Invierno", "Falda Midi"]
        NOMBRES_CALZADO = ["Zapatilla Running", "Botin Tacon", "Bota Cuero",
                           "Sandalia Plana", "Plataforma Negra", "Moccasin Casual",
                           "Tenis Deportivo", "Chancla Verano"]
        NOMBRES_ACC = ["Bolso Bandolera", "Cartera Mini", "Cinturon Cuero",
                       "Gorra Visera", "Gafas Sol", "Collar Dorado",
                       "Reloj Clasico", "Mochila Urbana", "Billetera Bifold"]

        for i, tipo in enumerate(tipos, start=1):
            if tipo == "ropa":
                nombre = random.choice(NOMBRES_ROPA)
                marca = random.choice(Catalogos.MARCAS_ROPA)
                precio = round(random.uniform(25000, 250000), 2)
                self.ids_ropa.append(i)
            elif tipo == "calzado":
                nombre = random.choice(NOMBRES_CALZADO)
                marca = random.choice(Catalogos.MARCAS_CALZADO)
                precio = round(random.uniform(80000, 450000), 2)
                self.ids_calzado.append(i)
            else:
                nombre = random.choice(NOMBRES_ACC)
                marca = random.choice(Catalogos.MARCAS_ACCESORIO)
                precio = round(random.uniform(20000, 600000), 2)
                self.ids_accesorio.append(i)

            stock = random.randint(0, 100)
            estado = "Agotado" if stock == 0 else random.choice(Catalogos.ESTADOS_PRODUCTO)
            fecha_ing = Catalogos.timestamp(2022, 2026)

            print(f"INSERT INTO PRODUCTOS "
                  f"(id_producto, nombre, descripcion, precio_referencia, marca, "
                  f"stock, estado, fecha_ingreso, imagen_url) "
                  f"VALUES ({i}, '{nombre}', NULL, {precio}, {Catalogos.sql_str(marca)}, "
                  f"{stock}, '{estado}', '{fecha_ing}', NULL);")
            self.ids_productos.append(i)

    # ── SUBCLASES ─────────────────────────────────────────────
    def generar_ropa(self):
        print("\n-- PoblarOK. CRUD: Ropa")
        for id_p in self.ids_ropa:
            talla = random.choice(Catalogos.TALLAS_ROPA)
            genero = random.choice(Catalogos.GENEROS_ROPA)
            categoria = random.choice(Catalogos.CATEGORIAS_ROPA)
            material = random.choice(Catalogos.MATERIALES_TELA)
            print(f"INSERT INTO ROPA (id_producto, talla, genero, categoria_ropa, material) "
                  f"VALUES ({id_p}, '{talla}', '{genero}', '{categoria}', "
                  f"{Catalogos.sql_str(material)});")

    def generar_calzado(self):
        print("\n-- PoblarOK. CRUD: Calzado")
        for id_p in self.ids_calzado:
            talla = round(random.uniform(18.0, 45.0), 1)
            genero = random.choice(Catalogos.GENEROS_CALZADO)
            categoria = random.choice(Catalogos.CATEGORIAS_CALZADO)
            material = random.choice(Catalogos.MATERIALES_CALZADO)
            print(f"INSERT INTO CALZADO (id_producto, talla, genero, categoria_calzado, material) "
                  f"VALUES ({id_p}, {talla}, '{genero}', '{categoria}', "
                  f"{Catalogos.sql_str(material)});")

    def generar_accesorios(self):
        print("\n-- PoblarOK. CRUD: Accesorios")
        DIMS = ["30x20x10 cm", "25x15x8 cm", "40x30x15 cm", "15x10x5 cm", None]
        for id_p in self.ids_accesorio:
            categoria = random.choice(Catalogos.CATEGORIAS_ACCESORIO)
            material = random.choice(Catalogos.MATERIALES_ACCESORIO)
            dim = random.choice(DIMS)
            print(f"INSERT INTO ACCESORIOS (id_producto, categoria, material, dimensiones) "
                  f"VALUES ({id_p}, '{categoria}', {Catalogos.sql_str(material)}, "
                  f"{Catalogos.sql_str(dim)});")

    # ── COMPRAS ───────────────────────────────────────────────
    def generar_compras(self):
        print("\n-- PoblarOK. CRUD: Compras")
        for i in range(1, self.cfg.num_compras + 1):
            fecha = Catalogos.timestamp(2023, 2026)
            estado = random.choice(Catalogos.ESTADOS_COMPRA)
            obs = Catalogos.sql_str(random.choice(
                ["Pedido urgente", "Entrega parcial", None, None, None]))
            id_prov = random.choice(self.ids_proveedores)
            print(f"INSERT INTO COMPRAS "
                  f"(id_compra, fecha_compra, estado_compra, observacion, id_proveedor) "
                  f"VALUES ({i}, '{fecha}', '{estado}', {obs}, {id_prov});")
            self.ids_compras.append(i)

    def generar_detalles_compra(self):
        print("\n-- PoblarOK. CRUD: Detalles de Compras")
        for id_c in self.ids_compras:
            vistos: Set[int] = set()
            for _ in range(random.randint(2, 6)):
                id_p = random.choice(self.ids_productos)
                if id_p in vistos:
                    continue
                vistos.add(id_p)
                cantidad = random.randint(5, 50)
                precio = round(random.uniform(15000, 300000), 2)
                print(f"INSERT INTO DETALLESDECOMPRAS "
                      f"(id_compra, id_producto, cantidad, precio_compra) "
                      f"VALUES ({id_c}, {id_p}, {cantidad}, {precio});")

    # ── VENTAS ────────────────────────────────────────────────
    def generar_ventas(self):
        print("\n-- PoblarOK. CRUD: Ventas")
        for i in range(1, self.cfg.num_ventas + 1):
            fecha = Catalogos.timestamp(2023, 2026)
            metodo = random.choice(Catalogos.METODOS_PAGO)
            estado = random.choice(Catalogos.ESTADOS_VENTA)
            medio = random.choice(Catalogos.MEDIOS_ENTREGA)
            obs = Catalogos.sql_str(random.choice(
                ["Entregar en horario de la tarde", None, None, None, None]))
            id_cl = random.choice(self.ids_clientes)
            print(f"INSERT INTO VENTAS "
                  f"(id_venta, fecha_venta, metodo_pago, estado_venta, medio_entrega, "
                  f"observaciones, id_cliente) "
                  f"VALUES ({i}, '{fecha}', '{metodo}', '{estado}', '{medio}', "
                  f"{obs}, {id_cl});")
            self.ids_ventas.append(i)

    def generar_detalles_venta(self):
        print("\n-- PoblarOK. CRUD: Detalles de Ventas")
        for id_v in self.ids_ventas:
            vistos: Set[int] = set()
            for _ in range(random.randint(1, 4)):
                id_p = random.choice(self.ids_productos)
                if id_p in vistos:
                    continue
                vistos.add(id_p)
                cantidad = random.randint(1, 5)
                precio = round(random.uniform(20000, 500000), 2)
                desc = round(random.uniform(5000, 50000), 2) if random.random() < 0.25 else None
                print(f"INSERT INTO DETALLESDEVENTAS "
                      f"(id_venta, id_producto, cantidad, precio_venta, descuento) "
                      f"VALUES ({id_v}, {id_p}, {cantidad}, {precio}, "
                      f"{Catalogos.sql_str(desc)});")

    # ── FACTURAS ──────────────────────────────────────────────
    def generar_facturas_venta(self):
        print("\n-- PoblarOK. CRUD: Facturas de Venta")
        for id_v in self.ids_ventas:
            id_f = self._nueva_factura()
            fecha = Catalogos.timestamp(2023, 2026)
            total = round(random.uniform(20000, 1500000), 2)
            estado = random.choice(Catalogos.ESTADOS_FACTURA)
            guia = f"GUIA-{id_f:06d}" if random.random() < 0.7 else None
            print(f"INSERT INTO FACTURAS "
                  f"(id_factura, fecha_emision, total, estado_factura, observaciones) "
                  f"VALUES ({id_f}, '{fecha}', {total}, '{estado}', NULL);")
            print(f"INSERT INTO FACTURASVENTA (id_factura, id_venta, numero_guia) "
                  f"VALUES ({id_f}, {id_v}, {Catalogos.sql_str(guia)});")

    def generar_facturas_compra(self):
        print("\n-- PoblarOK. CRUD: Facturas de Compra")
        for id_c in self.ids_compras:
            id_f = self._nueva_factura()
            fecha = Catalogos.timestamp(2023, 2026)
            total = round(random.uniform(100000, 5000000), 2)
            estado = random.choice(Catalogos.ESTADOS_FACTURA)
            remision = f"REM-{id_f:06d}" if random.random() < 0.8 else None
            print(f"INSERT INTO FACTURAS "
                  f"(id_factura, fecha_emision, total, estado_factura, observaciones) "
                  f"VALUES ({id_f}, '{fecha}', {total}, '{estado}', NULL);")
            print(f"INSERT INTO FACTURASCOMPRA (id_factura, id_compra, numero_remision) "
                  f"VALUES ({id_f}, {id_c}, {Catalogos.sql_str(remision)});")

    # ── EJECUCIÓN ─────────────────────────────────────────────
    def poblar(self):
        print("-- Script de población Pytar-Shop")
        print(f"-- Generando datos para {self.cfg.num_clientes} clientes base\n")

        # Orden respeta las FKs: primero tablas sin dependencias
        self.generar_ubicaciones()       # sin dependencias
        self.generar_clientes()          # depende de UBICACIONES
        self.generar_proveedores()       # depende de UBICACIONES
        self.generar_productos()         # sin dependencias
        self.generar_ropa()              # depende de PRODUCTOS
        self.generar_calzado()           # depende de PRODUCTOS
        self.generar_accesorios()        # depende de PRODUCTOS
        self.generar_compras()           # depende de PROVEEDORES
        self.generar_detalles_compra()   # depende de COMPRAS, PRODUCTOS
        self.generar_ventas()            # depende de CLIENTES
        self.generar_detalles_venta()    # depende de VENTAS, PRODUCTOS
        self.generar_facturas_venta()    # depende de VENTAS
        self.generar_facturas_compra()   # depende de COMPRAS

        print("\n-- Población completada exitosamente")


# ──────────────────────────────────────────────────────────────
#  Main
# ──────────────────────────────────────────────────────────────
def main():
    print("Cantidad de clientes a generar:")
    try:
        import sys
        if len(sys.argv) > 1:
            n = int(sys.argv[1])
        else:
            n = int(input())
        config = DatabaseConfig(num_clientes=n)
        PytarShopPopulator(config).poblar()
    except ValueError:
        print("Error: debe ingresar un número entero válido")
    except KeyboardInterrupt:
        print("\nOperación cancelada")
    except Exception as e:
        print(f"Error inesperado: {e}")


if __name__ == "__main__":
    main()