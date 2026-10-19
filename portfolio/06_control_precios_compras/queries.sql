-- ═══════════════════════════════════════════════════════════════════
-- CONTROL DE PRECIOS EN UNA CENTRAL DE COMPRAS — Consultas analíticas
-- Pregunta de negocio: ¿dónde se producen los errores al introducir
-- precios a mano, cuánto dinero ponen en riesgo y a quién priorizar?
-- ═══════════════════════════════════════════════════════════════════


-- ───────────────────────────────────────────────────────────────────
-- 0. VISTA BASE: cada línea comparada con la tarifa acordada
--    Clasifica la tipología de error por su "huella" numérica.
--    El orden del CASE importa: las reglas más específicas van primero.
-- ───────────────────────────────────────────────────────────────────
DROP VIEW IF EXISTS v_control_precios;
CREATE VIEW v_control_precios AS
SELECT
    l.id_linea,
    l.fecha,
    SUBSTR(l.fecha, 1, 7)                                   AS mes,
    l.id_proveedor,
    pr.nombre_proveedor,
    p.ean,
    p.categoria,
    l.usuario,
    l.unidades_previstas,
    t.tarifa_acordada,
    l.precio_introducido,
    ROUND(l.precio_introducido - t.tarifa_acordada, 2)      AS diferencia_unitaria,
    ROUND((l.precio_introducido - t.tarifa_acordada)
          * l.unidades_previstas, 2)                        AS impacto_eur,
    CASE
        WHEN ABS(l.precio_introducido - t.tarifa_acordada) < 0.005
            THEN 'Correcto'
        WHEN ABS(l.precio_introducido - t.tarifa_anterior) < 0.005
            THEN 'Tarifa del año anterior'
        WHEN l.precio_introducido / t.tarifa_acordada BETWEEN 9.5  AND 10.5
          OR l.precio_introducido / t.tarifa_acordada BETWEEN 0.09 AND 0.115
            THEN 'Desplazamiento decimal'
        WHEN p.unidades_por_caja > 1
         AND ABS(l.precio_introducido / t.tarifa_acordada - p.unidades_por_caja)
             <= 0.02 * p.unidades_por_caja
            THEN 'Precio por caja, no por unidad'
        ELSE 'Error de tecleo'
    END                                                     AS tipologia
FROM fact_lineas_precio l
JOIN dim_producto  p  ON p.id_producto  = l.id_producto
JOIN dim_proveedor pr ON pr.id_proveedor = l.id_proveedor
JOIN tarifas       t  ON t.id_producto  = l.id_producto;


-- @Q1 Resumen por tipología: frecuencia e impacto económico
-- ¿Qué tipo de error es más frecuente y cuál cuesta más?
SELECT
    tipologia,
    COUNT(*)                                                AS lineas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)      AS pct_errores,
    ROUND(SUM(ABS(impacto_eur)), 0)                         AS impacto_abs_eur,
    ROUND(SUM(CASE WHEN impacto_eur > 0 THEN impacto_eur ELSE 0 END), 0)
                                                            AS sobrecoste_eur
FROM v_control_precios
WHERE tipologia <> 'Correcto'
GROUP BY tipologia
ORDER BY impacto_abs_eur DESC;


-- @Q2 Pareto de proveedores: ¿quién concentra los errores?
-- HAVING evita que un proveedor con pocas líneas encabece el ranking
WITH por_proveedor AS (
    SELECT
        nombre_proveedor,
        COUNT(*)                                                    AS lineas,
        SUM(CASE WHEN tipologia <> 'Correcto' THEN 1 ELSE 0 END)    AS errores
    FROM v_control_precios
    GROUP BY nombre_proveedor
    HAVING COUNT(*) >= 100
)
SELECT
    nombre_proveedor,
    lineas,
    errores,
    ROUND(100.0 * errores / lineas, 1)                              AS tasa_error_pct,
    ROUND(100.0 * SUM(errores) OVER (ORDER BY errores DESC, nombre_proveedor)
          / SUM(errores) OVER (), 1)                                AS pct_acumulado
FROM por_proveedor
ORDER BY errores DESC, nombre_proveedor;


-- @Q3 Cola de revisión priorizada: top 10 líneas por riesgo económico
-- Lo que un controller revisaría primero el lunes por la mañana
SELECT
    id_linea,
    fecha,
    nombre_proveedor,
    ean,
    tarifa_acordada,
    precio_introducido,
    tipologia,
    impacto_eur
FROM v_control_precios
WHERE tipologia <> 'Correcto'
ORDER BY ABS(impacto_eur) DESC
LIMIT 10;


-- @Q4 Early Warning Indicator: ¿cuándo habría saltado la alerta?
-- Regla: media móvil 3M del proveedor >= 2x la tasa media de referencia
--        y >= 1,5x su propia media móvil de 3 meses antes (aceleración).
-- La referencia es la tasa global ACUMULADA hasta ese mes: solo usa
-- información disponible en ese momento (sin sesgo de anticipación).
WITH mensual AS (
    SELECT
        nombre_proveedor,
        mes,
        SUM(CASE WHEN tipologia <> 'Correcto' THEN 1 ELSE 0 END) AS errores,
        COUNT(*)                                                 AS lineas
    FROM v_control_precios
    GROUP BY nombre_proveedor, mes
),
referencia AS (
    SELECT
        mes,
        1.0 * SUM(SUM(errores)) OVER (ORDER BY mes)
            / SUM(SUM(lineas))  OVER (ORDER BY mes)              AS tasa_ref
    FROM mensual
    GROUP BY mes
),
tendencia AS (
    SELECT
        m.nombre_proveedor,
        m.mes,
        r.tasa_ref,
        AVG(1.0 * m.errores / m.lineas) OVER (
            PARTITION BY m.nombre_proveedor ORDER BY m.mes
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)            AS tasa_3m
    FROM mensual m
    JOIN referencia r ON r.mes = m.mes
),
alertas AS (
    SELECT *,
        LAG(tasa_3m, 3) OVER (PARTITION BY nombre_proveedor ORDER BY mes) AS tasa_3m_previa
    FROM tendencia
),
primera_alerta AS (
    SELECT nombre_proveedor, MIN(mes) AS mes_primera_alerta
    FROM alertas
    WHERE tasa_3m >= 2 * tasa_ref
      AND tasa_3m >= 1.5 * tasa_3m_previa
    GROUP BY nombre_proveedor
)
SELECT
    p.nombre_proveedor,
    p.mes_primera_alerta,
    ROUND(100 * a.tasa_3m, 1)        AS tasa_3m_en_alerta_pct,
    ROUND(100 * a.tasa_ref, 1)       AS tasa_referencia_pct,
    ROUND(100 * hoy.tasa_3m, 1)      AS tasa_3m_diciembre_pct
FROM primera_alerta p
JOIN alertas a   ON a.nombre_proveedor   = p.nombre_proveedor AND a.mes = p.mes_primera_alerta
JOIN alertas hoy ON hoy.nombre_proveedor = p.nombre_proveedor
                AND hoy.mes = (SELECT MAX(mes) FROM mensual)
ORDER BY p.mes_primera_alerta;


-- @Q5 Errores por usuario: ¿problema de formación o de proceso?
-- Si la tasa es similar entre usuarios, el problema es el proceso, no las personas
SELECT
    usuario,
    COUNT(*)                                                        AS lineas,
    SUM(CASE WHEN tipologia <> 'Correcto' THEN 1 ELSE 0 END)        AS errores,
    ROUND(100.0 * SUM(CASE WHEN tipologia <> 'Correcto' THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS tasa_error_pct
FROM v_control_precios
GROUP BY usuario
ORDER BY tasa_error_pct DESC;


-- @Q6 Simulación de una regla de control automática
-- Propuesta: bloquear en la entrada cualquier precio fuera del rango
-- [0,5x – 2x] de la tarifa acordada. ¿Qué parte del riesgo capturaría?
SELECT
    CASE
        WHEN precio_introducido / tarifa_acordada NOT BETWEEN 0.5 AND 2
            THEN 'Bloqueado por la regla'
        ELSE 'Requiere otro control'
    END                                                         AS resultado_regla,
    COUNT(*)                                                    AS errores,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_errores,
    ROUND(SUM(ABS(impacto_eur)), 0)                             AS impacto_abs_eur,
    ROUND(100.0 * SUM(ABS(impacto_eur))
          / SUM(SUM(ABS(impacto_eur))) OVER (), 1)              AS pct_impacto
FROM v_control_precios
WHERE tipologia <> 'Correcto'
GROUP BY resultado_regla
ORDER BY impacto_abs_eur DESC;
