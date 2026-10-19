-- ═══════════════════════════════════════════════════════════════════
-- CONTROL DE PRECIOS EN UNA CENTRAL DE COMPRAS — Esquema en estrella
-- SQL estándar (probado en SQLite 3.45; compatible con PostgreSQL)
-- Datos 100 % sintéticos: proveedores, productos y EAN ficticios
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE dim_proveedor (
    id_proveedor      TEXT PRIMARY KEY,
    nombre_proveedor  TEXT NOT NULL
);

CREATE TABLE dim_producto (
    id_producto        INTEGER PRIMARY KEY,
    ean                TEXT    NOT NULL UNIQUE,   -- EAN-13 con dígito de control válido
    id_proveedor       TEXT    NOT NULL REFERENCES dim_proveedor (id_proveedor),
    categoria          TEXT    NOT NULL,
    unidades_por_caja  INTEGER NOT NULL
);

-- Tarifa negociada vigente y tarifa del año anterior, por producto
CREATE TABLE tarifas (
    id_producto      INTEGER PRIMARY KEY REFERENCES dim_producto (id_producto),
    tarifa_anterior  NUMERIC NOT NULL,
    tarifa_acordada  NUMERIC NOT NULL
);

-- Hechos: cada precio introducido manualmente en el sistema
CREATE TABLE fact_lineas_precio (
    id_linea            INTEGER PRIMARY KEY,
    fecha               TEXT    NOT NULL,          -- ISO 8601 (AAAA-MM-DD)
    id_producto         INTEGER NOT NULL REFERENCES dim_producto (id_producto),
    id_proveedor        TEXT    NOT NULL REFERENCES dim_proveedor (id_proveedor),
    usuario             TEXT    NOT NULL,
    precio_introducido  NUMERIC NOT NULL,
    unidades_previstas  INTEGER NOT NULL           -- volumen previsto de compra
);

CREATE INDEX ix_lineas_producto  ON fact_lineas_precio (id_producto);
CREATE INDEX ix_lineas_proveedor ON fact_lineas_precio (id_proveedor, fecha);
