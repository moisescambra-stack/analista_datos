# 🏪 SQL – Modelo Retail Leroy Merlin

**SQL Server · T-SQL · Star Schema · Window Functions · CTEs · Segmentación RFM**

---

## 📋 Descripción

Modelado dimensional completo de un entorno retail de gran superficie basado en la estructura operativa de Leroy Merlin. Diseñado para demostrar queries de análisis de negocio reales utilizadas en entornos BI profesionales.

---

## 🏗️ Esquema Star Schema

```
                    ┌─────────────────┐
                    │   dim_tiempo    │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼──────┐   ┌────────▼────────┐   ┌──────▼───────┐
│ dim_producto  │   │   fact_ventas   │   │  dim_cliente │
│               ├───┤ +transacciones  ├───┤              │
└───────────────┘   └────────┬────────┘   └──────────────┘
                             │
                    ┌────────▼────────┐
                    │   dim_tienda    │
                    └─────────────────┘
```

---

## 📄 Queries Incluidas

| Query | Técnica SQL | Caso de negocio |
|-------|-------------|-----------------|
| Ranking categorías por margen | `DENSE_RANK()` | ¿Qué familias de producto son más rentables? |
| Ventas acumuladas YTD | `SUM() OVER()` | Progreso acumulado por tienda sin subconsultas |
| Detección caída YoY | `LAG()` + CTE | Alertas de tiendas con bajo rendimiento |
| Segmentación RFM | `NTILE()` + CTE | Clasificación de valor de cliente |
| Top 10 productos por tienda | `RANK()` + `%` sobre total | Decisiones de planograma y reposición |

---

## 🛠️ Técnicas Demostradas

- **Window Functions:** `DENSE_RANK()`, `RANK()`, `LAG()`, `SUM() OVER()`, `NTILE()`
- **CTEs:** Encadenamiento de CTEs para lógica compleja en pasos legibles
- **Agregaciones condicionales:** Margen bruto, ventas netas con descuento aplicado
- **Patrones YoY:** Comparativa año anterior con `LAG()` particionado por tienda y mes
- **Segmentación RFM:** Técnica estándar de CRM con scores ponderados

---

## 📁 Archivos

- [`queries.sql`](./queries.sql) — Todas las queries comentadas y documentadas
