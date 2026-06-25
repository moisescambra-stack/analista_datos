# 📊 Business Intelligence Portfolio — Moisés Cambra

**Power BI · DAX · SQL · Microsoft Fabric · Star Schema**

Repositorio de proyectos reales de Business Intelligence: modelado dimensional, DAX avanzado, cuadros de mando ejecutivos y bases de datos relacionales orientadas a negocio.

📧 moises.cambra@gmail.com · 📍 Madrid, España

---

## 🗂️ Proyectos

| # | Proyecto | Stack | Estado |
|---|----------|-------|--------|
| 01 | [Dashboard Ejecutivo – Scania Ibérica](#01-dashboard-ejecutivo--scania-ibérica) | Power BI · DAX · Constellation Schema | ✅ Completado |
| 02 | [Auditoría Comercial – Conn's HomePlus](#02-auditoría-comercial--conns-homeplus) | Power BI · DAX · Star Schema | ✅ Completado |
| 03 | [Maritime Intelligence Dashboard](#03-maritime-intelligence-dashboard) | Power BI · DAX · AIS Data · EWI | 🚧 En construcción |
| 04 | [SQL – Modelo Retail Leroy Merlin](#04-sql--modelo-retail-leroy-merlin) | SQL Server · T-SQL · Star Schema | ✅ Completado |
| 05 | [SQL – Base de Datos ERP Corporativo](#05-sql--base-de-datos-erp-corporativo) | SQL Server · T-SQL · Modelado relacional | ✅ Completado |

---

## 01 Dashboard Ejecutivo – Scania Ibérica

**Stack:** Power BI · DAX avanzado · Constellation Schema · SQL  
**Modelo:** 3 tablas de hechos · 6 dimensiones · +16.000 registros

Cuadro de mando ejecutivo completo para la red de concesionarios Scania Ibérica. Analiza ventas de camiones, operaciones de servicio y cadena de suministro de repuestos en 54 dealers europeos.

**Páginas del dashboard:**
- **Executive Overview** — KPIs globales, semáforo de rendimiento, varianza YoY
- **Truck Sales** — Análisis de ventas por modelo, región y trimestre
- **Service Operations** — First Time Fix Rate, tiempos de intervención, eficiencia técnica
- **Spare Parts** — Gestión de repuestos, pedidos urgentes, riesgo en SC por país

**Técnicas DAX aplicadas:**
```dax
-- Varianza vs Target con semáforo de color
VAR _actual = [Total Ventas]
VAR _target = [Target Ventas]
VAR _varianza = DIVIDE(_actual - _target, _target)
RETURN
IF(_varianza >= 0, "🟢", IF(_varianza >= -0.05, "🟡", "🔴"))

-- Rolling 3 meses
Rolling3M Ventas =
CALCULATE(
    [Total Ventas],
    DATESINPERIOD(Calendario[Fecha], LASTDATE(Calendario[Fecha]), -3, MONTH)
)

-- RANKX por dealer
Ranking Dealer =
RANKX(ALL(Dim_Dealer[Dealer]), [Total Ventas], , DESC, DENSE)
```

**Early Warning Indicators implementados:**
- Alerta si First Time Fix Rate < 85%
- Alerta si pedidos urgentes de repuestos > umbral por país
- Semáforo de rendimiento vs target trimestral

📁 [Ver capturas del dashboard](./01_scania_dashboard/capturas/)

---

## 02 Auditoría Comercial – Conn's HomePlus

**Stack:** Power BI · DAX · Star Schema · Power Query  
**Modelo:** Star Schema · +38.000 transacciones · 4 macro-regiones · 2014–2018

Solución BI completa para auditoría de rendimiento comercial. Identificó un déficit del -8% respecto al objetivo de 2,5M€ y diagnosticó que la estrategia de descuentos masivos erosionaba el margen sin escalar el beneficio.

**Módulos del dashboard:**
- **Overview** — Ventas totales, beneficio real post-descuento, KPI mejor mes
- **Producto** — Ranking de categorías, anomalías de crecimiento por SKU, concentración de margen
- **Cliente** — Segmentación Consumer / Corporate / Home Office, comportamiento por segmento
- **Geoespacial** — Mapa de rentabilidad por ciudad, ciudades ancla vs zonas de fricción

**Hallazgos clave entregados al cliente:**
- Segmento Consumer: motor principal absoluto de beneficio real
- Región East: alto volumen, baja rentabilidad neta — requiere revisión de pricing
- Ciudades ancla (Chicago, Columbus): margen alto y recurrencia predecible
- SKUs con crecimiento interanual exponencial identificados para reposición prioritaria

**Técnicas DAX aplicadas:**
```dax
-- Beneficio real después de descuento
Beneficio Real =
SUMX(
    Ventas,
    Ventas[Cantidad] * Ventas[Precio_Unitario] * (1 - Ventas[Descuento])
    - Ventas[Cantidad] * Ventas[Coste_Unitario]
)

-- % Varianza vs Objetivo
Varianza Objetivo % =
DIVIDE([Beneficio Real] - [Objetivo Beneficio], [Objetivo Beneficio], 0)

-- Top N productos por margen
Top10 Productos =
RANKX(ALL(Dim_Producto[Nombre_Producto]), [Beneficio Real], , DESC, DENSE)
```

📁 [Ver capturas del dashboard](./02_conns_homeplus/capturas/)

---

## 03 Maritime Intelligence Dashboard

**Stack:** Power BI · DAX · Star Schema · Datos AIS · Scoring OFAC/UN/EU  
**Estado:** 🚧 En construcción — publicación prevista Q3 2026

Dashboard de inteligencia marítima para monitorización de rutas críticas y detección de anomalías en cadena de suministro global.

**Funcionalidades en desarrollo:**
- Seguimiento de buques en 15 puertos de alto riesgo (Ormuz, Mar Negro, África Occidental)
- Detección de dark activity (gaps en señal AIS)
- Scoring de riesgo por ruta con sanciones OFAC/UN/EU
- Early Warning Indicators con alertas DAX para rutas anómalas

📁 [Ver avance del proyecto](./03_maritime_intelligence/)

---

## 04 SQL – Modelo Retail Leroy Merlin

**Stack:** SQL Server · T-SQL · Star Schema · Window Functions · CTEs

Modelado dimensional completo de un entorno retail de gran superficie, basado en la estructura operativa de Leroy Merlin. Incluye queries de análisis de negocio reales utilizadas en entornos BI profesionales.

**Esquema implementado:**
- `fact_ventas` — Transacciones con precio, coste, descuento, cantidad
- `dim_producto` — Jerarquía categoría / subcategoría / SKU
- `dim_tienda` — Región, zona, formato de tienda
- `dim_cliente` — Segmento, canal, frecuencia de compra
- `dim_tiempo` — Calendario fiscal con semanas, trimestres, festivos

**Queries incluidas:**
- Ranking de productos por margen bruto con `DENSE_RANK()`
- Análisis de ventas acumuladas YTD con `SUM() OVER()`
- Detección de tiendas con caída de ventas vs mismo periodo año anterior
- Segmentación RFM básica con CTEs

📁 [Ver queries SQL](./04_sql_leroy_merlin/queries.sql)

---

## 05 SQL – Base de Datos ERP Corporativo

**Stack:** SQL Server · T-SQL · Modelado relacional · Joins complejos · CTEs

Modelo de base de datos relacional que replica la estructura de un ERP corporativo estándar (módulos de compras, ventas, almacén y RRHH). Diseñado para practicar queries de nivel analista senior.

**Módulos del esquema:**
- **Compras:** proveedores, órdenes de compra, recepciones, facturación
- **Ventas:** clientes, pedidos, líneas de pedido, facturación
- **Almacén:** productos, stock, movimientos, ubicaciones
- **RRHH:** empleados, departamentos, nóminas, ausencias

**Queries de nivel senior incluidas:**
- Lead time de proveedores con varianza respecto a SLA contractual
- Rotación de inventario por categoría con alertas de stock mínimo
- Análisis de rentabilidad por cliente con coste de servicio
- Pipeline de ventas con probabilidad de cierre y forecast

📁 [Ver esquema y queries](./05_sql_erp_database/)

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnologías |
|-----------|-------------|
| Visualización | Power BI Desktop · Power BI Service · Paginated Reports |
| Lenguajes | DAX · M (Power Query) · SQL · T-SQL · Python (básico) |
| Modelado | Star Schema · Constellation Schema · Modelado Dimensional |
| Microsoft Fabric | OneLake · Lakehouse · Direct Lake · Dataflow Gen2 |
| Buenas prácticas | Row-level Security · Incremental Refresh · Performance Analyzer |
| Base de datos | SQL Server · Joins · Window Functions · CTEs · Data Profiling |
| Colaboración | Git · GitHub · Documentación técnica |

---

## 📬 Contacto

**Moisés Cambra**  
Business Intelligence Analyst · Power BI · DAX · SQL · Microsoft Fabric  
📧 moises.cambra@gmail.com · 📍 Arganda del Rey, Madrid
