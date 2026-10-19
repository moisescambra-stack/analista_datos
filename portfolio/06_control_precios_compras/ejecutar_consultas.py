"""
Ejecuta queries.sql sobre compras.db y guarda los resultados en resultados.md.

Uso (desde esta carpeta):
    python data/generar_datos.py
    python ejecutar_consultas.py
"""
import re
import sqlite3
from pathlib import Path

AQUI = Path(__file__).parent
sql = (AQUI / "queries.sql").read_text(encoding="utf-8")

con = sqlite3.connect(AQUI / "compras.db")
vista, *bloques = re.split(r"^-- @", sql, flags=re.M)
con.executescript(vista)

salida = ["# Resultados de las consultas\n",
          "_Generado automáticamente por `ejecutar_consultas.py` sobre los datos sintéticos._\n"]
for bloque in bloques:
    titulo = bloque.splitlines()[0].strip()
    cur = con.execute(bloque.split("\n", 1)[1])
    cols = [c[0] for c in cur.description]
    filas = cur.fetchall()
    salida.append(f"\n## {titulo}\n")
    salida.append("| " + " | ".join(cols) + " |")
    salida.append("|" + "---|" * len(cols))
    for f in filas:
        salida.append("| " + " | ".join("" if v is None else str(v) for v in f) + " |")

(AQUI / "resultados.md").write_text("\n".join(salida) + "\n", encoding="utf-8")
print("\n".join(salida))
