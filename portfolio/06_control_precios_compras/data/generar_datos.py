"""
Generador de datos sintéticos para el caso "Control de precios en una central de compras".

Todos los proveedores, productos y EAN son ficticios. Los patrones de error
(desplazamiento decimal, tarifa del año anterior, precio por caja en vez de por
unidad, errores de tecleo) están inspirados en problemas habituales en la
introducción manual de precios en centrales de compras.

Uso:
    python generar_datos.py        -> crea los CSV en esta carpeta y compras.db
"""
import csv
import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
OUT = Path(__file__).parent

PROVEEDORES = [
    ("P01", "Lácteos del Norte S.A."),
    ("P02", "Higiene Total Ibérica"),
    ("P03", "Conservas Atlántico"),
    ("P04", "Bebidas Sierra Alta"),
    ("P05", "Droguería Mediterránea"),
    ("P06", "Snacks & Co Europa"),
    ("P07", "Cuidado Personal Lumen"),
    ("P08", "Panificadora Castilla"),
    ("P09", "Congelados Polar"),
    ("P10", "Café y Cacao Andes"),
    ("P11", "Limpieza Hogar Brillo"),
    ("P12", "Aceites Campo Real"),
]
CATEGORIAS = {
    "P01": "Lácteos", "P02": "Higiene", "P03": "Alimentación seca",
    "P04": "Bebidas", "P05": "Droguería", "P06": "Alimentación seca",
    "P07": "Perfumería", "P08": "Panadería", "P09": "Congelados",
    "P10": "Alimentación seca", "P11": "Droguería", "P12": "Alimentación seca",
}
# Tasa base de error por proveedor (algunos concentran errores -> Pareto)
TASA_ERROR = {p: 0.025 for p, _ in PROVEEDORES}
TASA_ERROR.update({"P05": 0.14, "P07": 0.10, "P02": 0.06})
PROVEEDOR_EN_DETERIORO = "P11"   # su tasa de error crece mes a mes -> EWI
USUARIOS = [f"U{i:02d}" for i in range(1, 9)]


def ean13(base12: str) -> str:
    """Calcula el dígito de control GS1 de un EAN-13."""
    s = sum(int(d) * (3 if i % 2 else 1) for i, d in enumerate(base12))
    return base12 + str((10 - s % 10) % 10)


# ── Productos y tarifas ──────────────────────────────────────────────
productos, tarifas = [], []
for n in range(1, 401):
    prov = random.choice(PROVEEDORES)[0]
    pack = random.choice([1, 1, 6, 6, 12, 24])
    tarifa_ant = round(random.uniform(0.45, 18.0), 2)
    subida = random.uniform(0.0, 0.08)            # subida anual negociada 0–8 %
    tarifa_act = round(tarifa_ant * (1 + subida), 2)
    if tarifa_act == tarifa_ant:
        tarifa_act = round(tarifa_ant + 0.01, 2)
    ean = ean13("84" + f"{random.randint(0, 10**10 - 1):010d}")
    productos.append({
        "id_producto": n, "ean": ean, "id_proveedor": prov,
        "categoria": CATEGORIAS[prov], "unidades_por_caja": pack,
    })
    tarifas.append({
        "id_producto": n, "tarifa_anterior": tarifa_ant, "tarifa_acordada": tarifa_act,
    })

tarifa_por_prod = {t["id_producto"]: t for t in tarifas}
prod_por_id = {p["id_producto"]: p for p in productos}


def introducir_con_error(p, t):
    """Devuelve un precio erróneo según una tipología realista."""
    acordada, anterior, pack = t["tarifa_acordada"], t["tarifa_anterior"], p["unidades_por_caja"]
    tipo = random.choices(
        ["anterior", "decimal", "caja", "tecleo"], weights=[35, 25, 15, 25]
    )[0]
    if tipo == "caja" and pack == 1:
        tipo = "tecleo"
    if tipo == "anterior":
        return anterior
    if tipo == "decimal":
        return round(acordada * random.choice([10, 0.1]), 2)
    if tipo == "caja":
        return round(acordada * pack, 2)
    # tecleo: transposición de dígitos o desviación pequeña
    txt = f"{acordada:.2f}".replace(".", "")
    if len(txt) >= 3 and txt[-1] != txt[-2]:
        txt = txt[:-2] + txt[-1] + txt[-2]
        return round(int(txt) / 100, 2)
    return round(acordada * random.uniform(1.01, 1.09), 2)


# ── Líneas de precio introducidas manualmente (año 2025) ─────────────
lineas = []
inicio = date(2025, 1, 1)
for i in range(1, 6001):
    p = prod_por_id[random.randint(1, 400)]
    t = tarifa_por_prod[p["id_producto"]]
    fecha = inicio + timedelta(days=random.randint(0, 364))
    tasa = TASA_ERROR[p["id_proveedor"]]
    if p["id_proveedor"] == PROVEEDOR_EN_DETERIORO:
        tasa = 0.02 + 0.013 * (fecha.month - 1)    # de 2 % en enero a ~16 % en diciembre
    precio = introducir_con_error(p, t) if random.random() < tasa else t["tarifa_acordada"]
    lineas.append({
        "id_linea": i, "fecha": fecha.isoformat(), "id_producto": p["id_producto"],
        "id_proveedor": p["id_proveedor"], "usuario": random.choice(USUARIOS),
        "precio_introducido": precio,
        "unidades_previstas": random.randint(50, 2000),
    })


# ── Escritura CSV + base SQLite ──────────────────────────────────────
def to_csv(nombre, filas):
    with open(OUT / f"{nombre}.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=filas[0].keys())
        w.writeheader()
        w.writerows(filas)


proveedores = [{"id_proveedor": p, "nombre_proveedor": n} for p, n in PROVEEDORES]
to_csv("dim_proveedor", proveedores)
to_csv("dim_producto", productos)
to_csv("tarifas", tarifas)
to_csv("fact_lineas_precio", lineas)

db = OUT.parent / "compras.db"
db.unlink(missing_ok=True)
con = sqlite3.connect(db)
con.executescript((OUT.parent / "schema.sql").read_text(encoding="utf-8"))
for tabla, filas in [("dim_proveedor", proveedores), ("dim_producto", productos),
                     ("tarifas", tarifas), ("fact_lineas_precio", lineas)]:
    cols = list(filas[0].keys())
    con.executemany(
        f"INSERT INTO {tabla} ({', '.join(cols)}) VALUES ({', '.join('?' * len(cols))})",
        [tuple(r[c] for c in cols) for r in filas],
    )
con.commit()
con.close()
print("Datos generados:", len(productos), "productos ·", len(lineas), "líneas de precio")
