-- ═══════════════════════════════════════════════════════════════════
-- MODELO RETAIL – LEROY MERLIN
-- Star Schema para análisis de rendimiento comercial en gran superficie
-- Stack: SQL Server · T-SQL · Window Functions · CTEs
-- ═══════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────
-- 1. CREACIÓN DEL ESQUEMA
-- ───────────────────────────────────────────────────────────────────

CREATE TABLE dim_producto (
    id_producto     INT PRIMARY KEY,
    sku             VARCHAR(20) NOT NULL,
    nombre          VARCHAR(200),
    categoria       VARCHAR(100),   -- Ej: Construcción, Jardín, Baño
    subcategoria    VARCHAR(100),
    marca           VARCHAR(100),
    precio_coste    DECIMAL(10,2),
    precio_pvp      DECIMAL(10,2),
    unidad_medida   VARCHAR(20)     -- Unidad, m2, litros, kg
);

CREATE TABLE dim_tienda (
    id_tienda       INT PRIMARY KEY,
    nombre_tienda   VARCHAR(100),
    ciudad          VARCHAR(100),
    region          VARCHAR(50),    -- Norte, Sur, Este, Oeste, Centro
    formato         VARCHAR(50),    -- Grande, Mediano, Compacto
    m2_superficie   INT,
    año_apertura    INT
);

CREATE TABLE dim_cliente (
    id_cliente      INT PRIMARY KEY,
    segmento        VARCHAR(50),    -- Particular, Profesional, Empresa
    canal           VARCHAR(50),    -- Tienda, Online, Click&Collect
    frecuencia      VARCHAR(20),    -- Ocasional, Recurrente, Fidelizado
    provincia       VARCHAR(100)
);

CREATE TABLE dim_tiempo (
    id_fecha        INT PRIMARY KEY,
    fecha           DATE NOT NULL,
    año             INT,
    trimestre       INT,
    mes             INT,
    semana_año      INT,
    dia_semana      VARCHAR(20),
    es_festivo      BIT,
    temporada       VARCHAR(20)     -- Primavera, Verano, Otoño, Invierno
);

CREATE TABLE fact_ventas (
    id_venta        INT PRIMARY KEY,
    id_producto     INT REFERENCES dim_producto(id_producto),
    id_tienda       INT REFERENCES dim_tienda(id_tienda),
    id_cliente      INT REFERENCES dim_cliente(id_cliente),
    id_fecha        INT REFERENCES dim_tiempo(id_fecha),
    cantidad        DECIMAL(10,3),
    precio_unitario DECIMAL(10,2),
    descuento_pct   DECIMAL(5,2),
    coste_unitario  DECIMAL(10,2),
    canal_venta     VARCHAR(50)
);

-- ───────────────────────────────────────────────────────────────────
-- 2. QUERIES DE ANÁLISIS DE NEGOCIO
-- ───────────────────────────────────────────────────────────────────

-- ── 2.1 Ranking de categorías por margen bruto (DENSE_RANK)
-- Identifica qué familias de producto generan más beneficio real
-- ──────────────────────────────────────────────────────────

SELECT
    p.categoria,
    p.subcategoria,
    COUNT(*)                                                    AS num_transacciones,
    ROUND(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)), 2)
                                                                AS ventas_netas,
    ROUND(SUM(f.cantidad * (f.precio_unitario * (1 - f.descuento_pct/100) - f.coste_unitario)), 2)
                                                                AS margen_bruto,
    ROUND(
        SUM(f.cantidad * (f.precio_unitario * (1 - f.descuento_pct/100) - f.coste_unitario))
        / NULLIF(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)), 0) * 100,
    2)                                                          AS margen_pct,
    DENSE_RANK() OVER (ORDER BY
        SUM(f.cantidad * (f.precio_unitario * (1 - f.descuento_pct/100) - f.coste_unitario))
    DESC)                                                       AS ranking_margen
FROM fact_ventas f
JOIN dim_producto p ON f.id_producto = p.id_producto
JOIN dim_tiempo t   ON f.id_fecha    = t.id_fecha
WHERE t.año = 2024
GROUP BY p.categoria, p.subcategoria
ORDER BY margen_bruto DESC;


-- ── 2.2 Ventas acumuladas YTD por tienda con SUM() OVER()
-- Permite ver el progreso acumulado sin subconsultas costosas
-- ──────────────────────────────────────────────────────────

SELECT
    t.nombre_tienda,
    t.region,
    ti.mes,
    ROUND(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)), 2) AS ventas_mes,
    ROUND(SUM(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)))
        OVER (PARTITION BY t.id_tienda ORDER BY ti.mes ROWS UNBOUNDED PRECEDING), 2) AS ventas_ytd
FROM fact_ventas f
JOIN dim_tienda t  ON f.id_tienda = t.id_tienda
JOIN dim_tiempo ti ON f.id_fecha  = ti.id_fecha
WHERE ti.año = 2024
GROUP BY t.id_tienda, t.nombre_tienda, t.region, ti.mes
ORDER BY t.nombre_tienda, ti.mes;


-- ── 2.3 Tiendas con caída de ventas vs mismo período año anterior
-- Patrón YoY con LAG() para detección temprana de bajo rendimiento
-- ──────────────────────────────────────────────────────────────────

WITH ventas_por_tienda_mes AS (
    SELECT
        t.id_tienda,
        t.nombre_tienda,
        t.region,
        ti.año,
        ti.mes,
        ROUND(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)), 2) AS ventas
    FROM fact_ventas f
    JOIN dim_tienda t  ON f.id_tienda = t.id_tienda
    JOIN dim_tiempo ti ON f.id_fecha  = ti.id_fecha
    GROUP BY t.id_tienda, t.nombre_tienda, t.region, ti.año, ti.mes
),
comparativa_yoy AS (
    SELECT
        id_tienda,
        nombre_tienda,
        region,
        año,
        mes,
        ventas AS ventas_actual,
        LAG(ventas) OVER (PARTITION BY id_tienda, mes ORDER BY año) AS ventas_año_anterior,
        ROUND(
            (ventas - LAG(ventas) OVER (PARTITION BY id_tienda, mes ORDER BY año))
            / NULLIF(LAG(ventas) OVER (PARTITION BY id_tienda, mes ORDER BY año), 0) * 100,
        2) AS variacion_pct
    FROM ventas_por_tienda_mes
)
SELECT *
FROM comparativa_yoy
WHERE año = 2024
  AND variacion_pct < -5.0   -- Alerta: caída superior al 5%
ORDER BY variacion_pct ASC;


-- ── 2.4 Segmentación RFM de clientes (Recency, Frequency, Monetary)
-- Técnica estándar de CRM para clasificar valor de cliente
-- ──────────────────────────────────────────────────────────────────

WITH rfm_base AS (
    SELECT
        c.id_cliente,
        c.segmento,
        c.canal,
        DATEDIFF(DAY, MAX(t.fecha), GETDATE())                  AS recency_dias,
        COUNT(DISTINCT f.id_venta)                              AS frequency,
        ROUND(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)), 2) AS monetary
    FROM fact_ventas f
    JOIN dim_cliente c ON f.id_cliente = c.id_cliente
    JOIN dim_tiempo  t ON f.id_fecha   = t.id_fecha
    GROUP BY c.id_cliente, c.segmento, c.canal
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_dias ASC)  AS score_r,  -- Menor = más reciente = mejor
        NTILE(5) OVER (ORDER BY frequency DESC)    AS score_f,
        NTILE(5) OVER (ORDER BY monetary DESC)     AS score_m
    FROM rfm_base
)
SELECT
    id_cliente,
    segmento,
    canal,
    recency_dias,
    frequency,
    monetary,
    score_r,
    score_f,
    score_m,
    (score_r + score_f + score_m)                               AS rfm_total,
    CASE
        WHEN (score_r + score_f + score_m) >= 13 THEN 'Champions'
        WHEN (score_r + score_f + score_m) >= 10 THEN 'Loyal Customers'
        WHEN (score_r + score_f + score_m) >= 7  THEN 'Potential Loyalists'
        WHEN score_r >= 4 AND (score_f + score_m) <= 4 THEN 'New Customers'
        WHEN score_r <= 2 AND (score_f + score_m) >= 8 THEN 'At Risk'
        ELSE 'Need Attention'
    END                                                         AS segmento_rfm
FROM rfm_scores
ORDER BY rfm_total DESC;


-- ── 2.5 Top 10 productos por tienda con porcentaje sobre total
-- Útil para planogramas y decisiones de reposición prioritaria
-- ──────────────────────────────────────────────────────────────────

WITH ventas_producto_tienda AS (
    SELECT
        ti.nombre_tienda,
        p.categoria,
        p.nombre    AS producto,
        ROUND(SUM(f.cantidad * f.precio_unitario * (1 - f.descuento_pct/100)), 2) AS ventas
    FROM fact_ventas f
    JOIN dim_producto p ON f.id_producto = p.id_producto
    JOIN dim_tienda  ti ON f.id_tienda   = ti.id_tienda
    JOIN dim_tiempo  t  ON f.id_fecha    = t.id_fecha
    WHERE t.año = 2024
    GROUP BY ti.nombre_tienda, p.categoria, p.nombre
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY nombre_tienda ORDER BY ventas DESC) AS rk,
        ROUND(ventas / SUM(ventas) OVER (PARTITION BY nombre_tienda) * 100, 2) AS pct_sobre_tienda
    FROM ventas_producto_tienda
)
SELECT nombre_tienda, rk, categoria, producto, ventas, pct_sobre_tienda
FROM ranked
WHERE rk <= 10
ORDER BY nombre_tienda, rk;
