# 🏢 SQL – Base de Datos ERP Corporativo

**SQL Server · T-SQL · Modelado Relacional · Joins Complejos · CTEs · Window Functions**

---

## 📋 Descripción

Modelo de base de datos relacional que replica la estructura de un ERP corporativo estándar con módulos de **Compras, Ventas, Almacén y RRHH**. Diseñado para practicar y demostrar queries de nivel analista senior sobre datos empresariales reales.

---

## 🏗️ Arquitectura del Modelo

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│  proveedores│────▶│  ordenes_compra  │     │   clientes  │
└─────────────┘     └──────────────────┘     └──────┬──────┘
                             │                      │
                    ┌────────▼─────────┐    ┌───────▼──────┐
                    │lineas_orden_compra│   │pedidos_venta │
                    └────────┬─────────┘    └───────┬──────┘
                             │                      │
                    ┌────────▼──────────────────────▼──────┐
                    │              productos                │
                    └────────────────────┬─────────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │    stock_actual      │
                              │  movimientos_stock   │
                              └─────────────────────┘
                                         
┌─────────────────┐    ┌──────────────┐    ┌──────────────┐
│  departamentos  │────│  empleados   │────│    nóminas   │
└─────────────────┘    └──────────────┘    └──────────────┘
```

---

## 📄 Módulos Implementados

| Módulo | Tablas | Descripción |
|--------|--------|-------------|
| **Maestros** | empresas, departamentos, empleados | Estructura organizativa |
| **Compras** | proveedores, ordenes_compra, lineas_orden_compra | Gestión de aprovisionamiento |
| **Ventas** | clientes, pedidos_venta, lineas_pedido_venta | Pipeline comercial |
| **Almacén** | productos, stock_actual, movimientos_stock | Control de inventario |

---

## 🧮 Queries Analíticas Incluidas

| Query | Técnicas | Caso de negocio |
|-------|----------|-----------------|
| Lead time proveedores vs SLA | CTE + `DATEDIFF` + agregaciones | ¿Qué proveedores incumplen plazos? |
| Rotación de inventario + alertas | CTE encadenada + `CASE` | KPI almacén: stock crítico vs óptimo |
| Rentabilidad real por cliente | CTE + `DENSE_RANK()` + clasificación ABC | ¿Qué clientes cuestan más de lo que aportan? |
| Pipeline de ventas con forecast | Probabilidad ponderada por estado | Proyección de ingresos por comercial |

---

## 🔑 Técnicas SQL Demostradas

- **CTEs encadenadas** para descomponer lógica compleja en pasos legibles
- **Window Functions:** `DENSE_RANK()`, `AVG() OVER()`, `SUM() OVER()`
- **Joins múltiples** entre 4-5 tablas con lógica de negocio real
- **Agregaciones condicionales** con `CASE WHEN` dentro de `SUM()`
- **`DATEDIFF`** para KPIs de tiempo: lead time, OTD, días de stock
- **`NULLIF`** para evitar divisiones por cero en métricas de ratio
- **Clasificación ABC** de clientes por rentabilidad real

---

## 📁 Archivos

- [`schema_and_queries.sql`](./schema_and_queries.sql) — DDL completo + queries analíticas documentadas
