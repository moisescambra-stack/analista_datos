-- ═══════════════════════════════════════════════════════════════════
-- BASE DE DATOS ERP CORPORATIVO
-- Módulos: Compras · Ventas · Almacén · RRHH
-- Stack: SQL Server · T-SQL · Joins complejos · CTEs · Window Functions
-- ═══════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────
-- 1. MÓDULO MAESTROS
-- ───────────────────────────────────────────────────────────────────

CREATE TABLE empresas (
    id_empresa      INT PRIMARY KEY,
    nombre          VARCHAR(200),
    cif             VARCHAR(20),
    pais            VARCHAR(50),
    sector          VARCHAR(100)
);

CREATE TABLE departamentos (
    id_departamento INT PRIMARY KEY,
    id_empresa      INT REFERENCES empresas(id_empresa),
    nombre          VARCHAR(100),
    centro_coste    VARCHAR(20),
    responsable_id  INT
);

CREATE TABLE empleados (
    id_empleado     INT PRIMARY KEY,
    id_departamento INT REFERENCES departamentos(id_departamento),
    nombre          VARCHAR(100),
    apellidos       VARCHAR(200),
    puesto          VARCHAR(100),
    fecha_alta      DATE,
    fecha_baja      DATE,
    salario_base    DECIMAL(10,2),
    tipo_contrato   VARCHAR(50)     -- Indefinido, Temporal, Obra y Servicio
);

-- ───────────────────────────────────────────────────────────────────
-- 2. MÓDULO PROVEEDORES Y COMPRAS
-- ───────────────────────────────────────────────────────────────────

CREATE TABLE proveedores (
    id_proveedor    INT PRIMARY KEY,
    nombre          VARCHAR(200),
    pais            VARCHAR(50),
    categoria       VARCHAR(100),
    plazo_entrega_sla INT,          -- Días acordados contractualmente
    condiciones_pago VARCHAR(50),   -- 30 días, 60 días, contado
    rating          DECIMAL(3,1)    -- 1.0 a 5.0
);

CREATE TABLE ordenes_compra (
    id_orden        INT PRIMARY KEY,
    id_proveedor    INT REFERENCES proveedores(id_proveedor),
    id_empleado     INT REFERENCES empleados(id_empleado),
    fecha_orden     DATE,
    fecha_entrega_prometida DATE,
    fecha_entrega_real      DATE,
    estado          VARCHAR(30),    -- Pendiente, Recibida, Parcial, Cancelada
    importe_total   DECIMAL(12,2)
);

CREATE TABLE lineas_orden_compra (
    id_linea        INT PRIMARY KEY,
    id_orden        INT REFERENCES ordenes_compra(id_orden),
    id_producto     INT,
    cantidad_pedida DECIMAL(10,3),
    cantidad_recibida DECIMAL(10,3),
    precio_unitario DECIMAL(10,2)
);

-- ───────────────────────────────────────────────────────────────────
-- 3. MÓDULO CLIENTES Y VENTAS
-- ───────────────────────────────────────────────────────────────────

CREATE TABLE clientes (
    id_cliente      INT PRIMARY KEY,
    nombre          VARCHAR(200),
    tipo            VARCHAR(30),    -- Particular, Empresa, Distribuidor
    pais            VARCHAR(50),
    limite_credito  DECIMAL(12,2),
    comercial_asignado INT REFERENCES empleados(id_empleado)
);

CREATE TABLE pedidos_venta (
    id_pedido       INT PRIMARY KEY,
    id_cliente      INT REFERENCES clientes(id_cliente),
    id_empleado     INT REFERENCES empleados(id_empleado),
    fecha_pedido    DATE,
    fecha_entrega   DATE,
    estado          VARCHAR(30),    -- Borrador, Confirmado, Enviado, Entregado, Cancelado
    descuento_global DECIMAL(5,2),
    importe_bruto   DECIMAL(12,2),
    importe_neto    DECIMAL(12,2)
);

CREATE TABLE lineas_pedido_venta (
    id_linea        INT PRIMARY KEY,
    id_pedido       INT REFERENCES pedidos_venta(id_pedido),
    id_producto     INT,
    cantidad        DECIMAL(10,3),
    precio_unitario DECIMAL(10,2),
    descuento_linea DECIMAL(5,2),
    coste_unitario  DECIMAL(10,2)
);

-- ───────────────────────────────────────────────────────────────────
-- 4. MÓDULO ALMACÉN
-- ───────────────────────────────────────────────────────────────────

CREATE TABLE productos (
    id_producto     INT PRIMARY KEY,
    referencia      VARCHAR(50),
    descripcion     VARCHAR(200),
    familia         VARCHAR(100),
    subfamilia      VARCHAR(100),
    unidad_medida   VARCHAR(20),
    stock_minimo    DECIMAL(10,3),
    stock_maximo    DECIMAL(10,3),
    coste_estandar  DECIMAL(10,2)
);

CREATE TABLE stock_actual (
    id_producto     INT REFERENCES productos(id_producto),
    almacen         VARCHAR(50),
    ubicacion       VARCHAR(20),
    cantidad        DECIMAL(10,3),
    fecha_actualizacion DATETIME,
    PRIMARY KEY (id_producto, almacen, ubicacion)
);

CREATE TABLE movimientos_stock (
    id_movimiento   INT PRIMARY KEY,
    id_producto     INT REFERENCES productos(id_producto),
    tipo_movimiento VARCHAR(30),    -- Entrada, Salida, Ajuste, Transferencia
    cantidad        DECIMAL(10,3),
    almacen_origen  VARCHAR(50),
    almacen_destino VARCHAR(50),
    fecha           DATETIME,
    referencia_doc  VARCHAR(50),    -- Nº orden compra o pedido venta
    id_empleado     INT REFERENCES empleados(id_empleado)
);

-- ───────────────────────────────────────────────────────────────────
-- 5. QUERIES ANALÍTICAS DE NIVEL SENIOR
-- ───────────────────────────────────────────────────────────────────

-- ── 5.1 Lead time real de proveedores vs SLA contractual
-- Detecta qué proveedores incumplen sistemáticamente sus plazos
-- ──────────────────────────────────────────────────────────────────

WITH lead_times AS (
    SELECT
        p.id_proveedor,
        p.nombre                                                AS proveedor,
        p.pais,
        p.plazo_entrega_sla,
        oc.id_orden,
        DATEDIFF(DAY, oc.fecha_orden, oc.fecha_entrega_real)    AS lead_time_real,
        DATEDIFF(DAY, oc.fecha_orden, oc.fecha_entrega_real)
            - p.plazo_entrega_sla                               AS desviacion_dias,
        CASE
            WHEN oc.fecha_entrega_real <= oc.fecha_entrega_prometida THEN 1
            ELSE 0
        END                                                     AS entrega_a_tiempo
    FROM ordenes_compra oc
    JOIN proveedores p ON oc.id_proveedor = p.id_proveedor
    WHERE oc.estado = 'Recibida'
      AND oc.fecha_entrega_real IS NOT NULL
)
SELECT
    proveedor,
    pais,
    plazo_entrega_sla,
    COUNT(id_orden)                                             AS num_ordenes,
    ROUND(AVG(CAST(lead_time_real AS FLOAT)), 1)                AS lead_time_medio_real,
    ROUND(AVG(CAST(desviacion_dias AS FLOAT)), 1)               AS desviacion_media_dias,
    ROUND(AVG(CAST(entrega_a_tiempo AS FLOAT)) * 100, 1)        AS otd_pct,
    MAX(desviacion_dias)                                        AS peor_desviacion
FROM lead_times
GROUP BY proveedor, pais, plazo_entrega_sla
HAVING COUNT(id_orden) >= 5
ORDER BY desviacion_media_dias DESC;


-- ── 5.2 Rotación de inventario y alertas de stock mínimo
-- KPI fundamental en cualquier ERP de gestión de almacén
-- ──────────────────────────────────────────────────────────────────

WITH consumo_anual AS (
    SELECT
        id_producto,
        SUM(ABS(cantidad)) AS unidades_consumidas
    FROM movimientos_stock
    WHERE tipo_movimiento = 'Salida'
      AND fecha >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY id_producto
),
stock_promedio AS (
    SELECT
        id_producto,
        AVG(cantidad) AS stock_medio
    FROM (
        SELECT id_producto, SUM(cantidad) AS cantidad
        FROM stock_actual
        GROUP BY id_producto
    ) s
    GROUP BY id_producto
)
SELECT
    p.referencia,
    p.descripcion,
    p.familia,
    sa.cantidad                                                 AS stock_actual,
    p.stock_minimo,
    p.stock_maximo,
    COALESCE(ca.unidades_consumidas, 0)                         AS consumo_anual,
    ROUND(
        COALESCE(ca.unidades_consumidas, 0)
        / NULLIF(COALESCE(sp.stock_medio, sa.cantidad), 0),
    2)                                                          AS rotacion,
    CASE
        WHEN sa.cantidad <= p.stock_minimo THEN '🔴 Stock crítico'
        WHEN sa.cantidad <= p.stock_minimo * 1.2 THEN '🟡 Stock bajo'
        ELSE '🟢 OK'
    END                                                         AS alerta_stock
FROM productos p
LEFT JOIN (SELECT id_producto, SUM(cantidad) AS cantidad FROM stock_actual GROUP BY id_producto) sa
    ON p.id_producto = sa.id_producto
LEFT JOIN consumo_anual ca ON p.id_producto = ca.id_producto
LEFT JOIN stock_promedio sp ON p.id_producto = sp.id_producto
ORDER BY rotacion DESC;


-- ── 5.3 Rentabilidad real por cliente incluyendo coste de servicio
-- Va más allá de las ventas brutas: detecta clientes que cuestan más de lo que aportan
-- ──────────────────────────────────────────────────────────────────

WITH margen_cliente AS (
    SELECT
        pv.id_cliente,
        SUM(lpv.cantidad * lpv.precio_unitario * (1 - lpv.descuento_linea/100)) AS ventas_netas,
        SUM(lpv.cantidad * lpv.coste_unitario)                                  AS coste_producto,
        SUM(lpv.cantidad * lpv.precio_unitario * (1 - lpv.descuento_linea/100))
            - SUM(lpv.cantidad * lpv.coste_unitario)                            AS margen_bruto,
        COUNT(DISTINCT pv.id_pedido)                                            AS num_pedidos,
        AVG(pv.importe_neto)                                                    AS ticket_medio
    FROM pedidos_venta pv
    JOIN lineas_pedido_venta lpv ON pv.id_pedido = lpv.id_pedido
    WHERE pv.estado = 'Entregado'
      AND YEAR(pv.fecha_pedido) = 2024
    GROUP BY pv.id_cliente
)
SELECT
    c.nombre                                                    AS cliente,
    c.tipo,
    mc.ventas_netas,
    mc.coste_producto,
    mc.margen_bruto,
    ROUND(mc.margen_bruto / NULLIF(mc.ventas_netas, 0) * 100, 2) AS margen_pct,
    mc.num_pedidos,
    ROUND(mc.ticket_medio, 2)                                   AS ticket_medio,
    -- Clasificación de valor
    CASE
        WHEN mc.margen_bruto > 50000 THEN 'A – Estratégico'
        WHEN mc.margen_bruto > 20000 THEN 'B – Importante'
        WHEN mc.margen_bruto > 5000  THEN 'C – Estándar'
        ELSE                              'D – Revisar rentabilidad'
    END                                                         AS clasificacion,
    DENSE_RANK() OVER (ORDER BY mc.margen_bruto DESC)           AS ranking_margen
FROM margen_cliente mc
JOIN clientes c ON mc.id_cliente = c.id_cliente
ORDER BY mc.margen_bruto DESC;


-- ── 5.4 Pipeline de ventas con forecast por comercial
-- Proyección de ingresos esperados según probabilidad por estado
-- ──────────────────────────────────────────────────────────────────

WITH pipeline AS (
    SELECT
        e.nombre + ' ' + e.apellidos                            AS comercial,
        d.nombre                                                AS departamento,
        pv.estado,
        COUNT(pv.id_pedido)                                     AS num_oportunidades,
        SUM(pv.importe_bruto)                                   AS importe_total,
        -- Ponderación estándar por estado del pipeline
        CASE pv.estado
            WHEN 'Borrador'    THEN 0.20
            WHEN 'Confirmado'  THEN 0.60
            WHEN 'Enviado'     THEN 0.90
            WHEN 'Entregado'   THEN 1.00
            ELSE 0
        END                                                     AS probabilidad,
        SUM(pv.importe_bruto) * CASE pv.estado
            WHEN 'Borrador'    THEN 0.20
            WHEN 'Confirmado'  THEN 0.60
            WHEN 'Enviado'     THEN 0.90
            WHEN 'Entregado'   THEN 1.00
            ELSE 0
        END                                                     AS forecast_ponderado
    FROM pedidos_venta pv
    JOIN empleados e    ON pv.id_empleado     = e.id_empleado
    JOIN departamentos d ON e.id_departamento = d.id_departamento
    WHERE pv.estado != 'Cancelado'
      AND YEAR(pv.fecha_pedido) = 2024
    GROUP BY e.nombre, e.apellidos, d.nombre, pv.estado
)
SELECT
    comercial,
    departamento,
    estado,
    num_oportunidades,
    ROUND(importe_total, 2)         AS importe_pipeline,
    probabilidad,
    ROUND(forecast_ponderado, 2)    AS forecast_ponderado
FROM pipeline
ORDER BY comercial, probabilidad DESC;
