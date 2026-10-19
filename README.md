# 📊 Portfolio de análisis de datos — Moisés Cambra

**Purchasing Data & Pricing Analyst · SQL · Power BI · DAX · Python**

Casos de análisis aplicados a problemas de negocio: control de precios, rendimiento de
proveedores, niveles de servicio y rentabilidad comercial. Cada proyecto parte de una pregunta
de negocio y termina en hallazgos y recomendaciones.

> Todos los proyectos usan **datos sintéticos o datasets públicos de práctica**. Ninguno contiene
> datos de empresas reales ni de mis empleadores.

📧 moises.cambra@gmail.com · 📍 Madrid, España

---

## ⭐ Proyecto destacado: control de precios en una central de compras

**SQL · Funciones ventana · Early Warning Indicators · Python** · [Ver proyecto →](./portfolio/06_control_precios_compras/)

Detección y priorización de errores en precios introducidos a mano, sobre 6.000 líneas de precio
y ≈ 60,7 M€ de volumen de compra previsto.

- **311 errores (5,2 %)** clasificados en 4 tipologías por su huella numérica, con un importe en riesgo de **≈ 7,1 M€**.
- Los errores más frecuentes no son los más caros: el **30 %** de los errores concentra el **98,8 %** del riesgo.
- **3 de 12 proveedores** generan el **56 %** de los errores.
- Un indicador de alerta temprana habría señalado al proveedor en deterioro **7 meses antes** de que escalara.
- Una regla de bloqueo automático en la entrada capturaría el **98,8 %** del riesgo **sin falsos positivos**.

---

## 🗂️ Proyectos

| # | Proyecto | Pregunta de negocio | Stack |
|---|----------|---------------------|-------|
| 06 | [Control de precios en compras](./portfolio/06_control_precios_compras/) | ¿Dónde se equivocan los precios, cuánto cuesta y qué control lo evita? | SQL · Python |
| 01 | [Dashboard ejecutivo – red de concesionarios](./portfolio/01_scania_dashboard/) | ¿Qué dealers, servicios y repuestos están fuera de objetivo? | Power BI · DAX · Constelación |
| 07 | [Niveles de servicio OLA & ANS/SLA](./ola_sla_project/) | ¿Qué contratos están en riesgo de penalización? | Power BI · DAX · Estrella |
| 02 | [Auditoría comercial – retail EE. UU.](./portfolio/02_conns_homeplus/) | ¿Por qué no se alcanza el objetivo de beneficio? | Power BI · DAX · Estrella |
| 04 | [SQL – Modelo retail de bricolaje](./portfolio/04_sql_leroy_merlin/) | ¿Qué tiendas caen y qué clientes valen más? | SQL · Funciones ventana · RFM |
| 05 | [SQL – Base de datos ERP](./portfolio/05_sql_erp_database/) | ¿Qué proveedores incumplen plazos y qué clientes no son rentables? | SQL · CTEs · Modelo relacional |

---

## 01 · Dashboard ejecutivo – red de concesionarios

**Power BI · DAX · Esquema en constelación (3 tablas de hechos, 6 dimensiones)**

Red ficticia de 54 concesionarios de vehículos industriales: ventas, servicio técnico y repuestos,
con indicadores de alerta temprana (First Time Fix Rate < 85 %, pedidos urgentes de repuestos).

![Executive Overview](./portfolio/01_scania_dashboard/capturas/executive_overview.jpg)

## 07 · Niveles de servicio OLA & ANS/SLA

**Power BI · DAX · Estrella · Datos incluidos para reproducirlo**

Cumplimiento de SLA por contrato y de OLA por equipo interno, con objetivos dinámicos según la
prioridad de la incidencia y alertas de brecha antes de la penalización.

## 02 · Auditoría comercial – retail EE. UU.

**Power BI · DAX · Estrella · 38.000 transacciones (dataset público)**

Diagnóstico de un déficit del 8 % frente al objetivo de beneficio: la política de descuentos
erosiona el margen sin aumentar el beneficio real.

## 04 · SQL – Modelo retail de bricolaje · 05 · SQL – ERP

Modelos relacionales con consultas de negocio: caída de ventas interanual con `LAG()`,
segmentación RFM con `NTILE()`, lead time de proveedores frente a SLA, clasificación ABC de
clientes y forecast ponderado del pipeline.

---

## 🛠️ Stack

| Área | Herramientas demostradas en este repositorio |
|------|---------------------------------------------|
| SQL | CTEs · Funciones ventana (`LAG`, `NTILE`, `SUM/AVG OVER`) · Vistas · Agregaciones condicionales |
| Power BI | DAX · Time intelligence · Formato condicional · Esquemas en estrella y constelación |
| Python | Generación de datos sintéticos · Automatización de consultas SQL (`sqlite3`) |

**En formación:** Microsoft Fabric (Lakehouse, Direct Lake) · Python para análisis de datos (pandas).
