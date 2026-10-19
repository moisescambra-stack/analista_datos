# 📊 Auditoría Comercial – Cadena retail de EE. UU.

**Power BI · DAX · Star Schema · Análisis de Rentabilidad · Segmentación Geoespacial**

---

## 📋 Descripción del Proyecto

> **Dataset público de práctica** (ventas retail de EE. UU., 2014–2018). Ejercicio de análisis
> planteado como una auditoría comercial; no es un encargo para ninguna empresa real.

Solución BI para auditar el rendimiento comercial de una cadena retail de consumo masivo. El análisis cubrió **+38.000 transacciones**, **4 macro-regiones** y el periodo **2014–2018**, con un objetivo de beneficio fijado en 2,5 M (supuesto del ejercicio).

**Hallazgo principal:** Déficit del **-8%** respecto al objetivo. Causa raíz identificada: la estrategia de descuentos masivos erosiona el margen sin escalar el beneficio real.

---

## 🏗️ Arquitectura del Modelo de Datos

**Tipo:** Star Schema

```
                    ┌─────────────────┐
                    │  Dim_Calendario │
                    └────────┬────────┘
                             │
              ┌──────────────▼──────────────┐
              │        Fact_Ventas          │
              │  +38.000 transacciones      │
              └──┬──────────┬──────────┬───┘
                 │          │          │
        ┌────────▼──┐ ┌─────▼─────┐ ┌─▼──────────┐
        │Dim_Producto│ │Dim_Cliente│ │Dim_Geografía│
        └────────────┘ └───────────┘ └────────────┘
```

**Tablas:**
| Tabla | Tipo | Registros |
|-------|------|-----------|
| Fact_Ventas | Hechos | 38.000+ |
| Dim_Producto | Dimensión | ~1.800 SKUs |
| Dim_Cliente | Dimensión | ~800 clientes |
| Dim_Geografía | Dimensión | ~500 ciudades / 4 regiones |
| Dim_Calendario | Dimensión | 1.826 días (2014–2018) |

---

## 📄 Módulos del Dashboard

### 1. Overview Ejecutivo
Ventas totales, beneficio real post-descuento, KPI mejor mes (Diciembre: 148K€). Semáforo vs objetivo 2,5M€. Evolución YoY por región.

### 2. Análisis de Producto
Ranking de categorías por margen bruto. Identificación de SKUs con crecimiento exponencial interanual. Concentración de margen en Technology y Office Supplies.

### 3. Segmentación de Cliente
Comportamiento por segmento (Consumer / Corporate / Home Office). Consumer como motor principal de beneficio real. Radar chart de comparación entre segmentos.

### 4. Diagnóstico Geoespacial
Mapa de rentabilidad por ciudad. Ciudades ancla (Chicago, Columbus) vs zonas de fricción (región East). Recomendaciones de asignación de presupuesto logístico.

---

## 🧮 Medidas DAX Destacadas

```dax
-- ─────────────────────────────────────────
-- RENTABILIDAD REAL
-- ─────────────────────────────────────────

Beneficio Real Post-Descuento =
SUMX(
    Fact_Ventas,
    (Fact_Ventas[Precio_Unitario] * (1 - Fact_Ventas[Descuento]) - Fact_Ventas[Coste_Unitario])
    * Fact_Ventas[Cantidad]
)

Margen % Real =
DIVIDE([Beneficio Real Post-Descuento], [Ventas Brutas], 0)

-- ─────────────────────────────────────────
-- ANÁLISIS DE DESCUENTOS
-- ─────────────────────────────────────────

Impacto Descuento € =
SUMX(
    Fact_Ventas,
    Fact_Ventas[Precio_Unitario] * Fact_Ventas[Descuento] * Fact_Ventas[Cantidad]
)

% Ventas Afectadas por Descuento =
DIVIDE(
    CALCULATE(COUNTROWS(Fact_Ventas), Fact_Ventas[Descuento] > 0),
    COUNTROWS(Fact_Ventas),
    0
)

-- ─────────────────────────────────────────
-- VARIANZA VS OBJETIVO
-- ─────────────────────────────────────────

Varianza vs Objetivo =
VAR _beneficio = [Beneficio Real Post-Descuento]
VAR _objetivo = 2500000
RETURN _beneficio - _objetivo

Varianza vs Objetivo % =
DIVIDE([Varianza vs Objetivo], 2500000, 0)

Semaforo Objetivo =
IF([Varianza vs Objetivo %] >= 0, "🟢",
IF([Varianza vs Objetivo %] >= -0.05, "🟡", "🔴"))

-- ─────────────────────────────────────────
-- RANKING Y SEGMENTACIÓN
-- ─────────────────────────────────────────

Ranking Producto Margen =
RANKX(ALL(Dim_Producto[Nombre_Producto]), [Beneficio Real Post-Descuento], , DESC, DENSE)

Beneficio por Segmento % =
DIVIDE(
    [Beneficio Real Post-Descuento],
    CALCULATE([Beneficio Real Post-Descuento], ALL(Dim_Cliente[Segmento])),
    0
)

-- ─────────────────────────────────────────
-- TIME INTELLIGENCE
-- ─────────────────────────────────────────

Mejor Mes =
MAXX(
    VALUES(Dim_Calendario[Mes_Año]),
    CALCULATE([Beneficio Real Post-Descuento])
)

Ventas YoY % =
VAR _actual = [Beneficio Real Post-Descuento]
VAR _anterior = CALCULATE([Beneficio Real Post-Descuento], SAMEPERIODLASTYEAR(Dim_Calendario[Fecha]))
RETURN DIVIDE(_actual - _anterior, _anterior, 0)
```

---

## 🔍 Conclusiones del Análisis

| Área | Hallazgo | Recomendación |
|------|----------|---------------|
| Descuentos | 1M€ de ventas impactadas por descuentos erosionan margen | Auditar política de descuentos en región East |
| Segmento | Consumer genera el mayor beneficio real absoluto | Priorizar retención y upselling en Consumer |
| Geografía | East: alto volumen, rentabilidad baja | Revisar estrategia de pricing por ciudad |
| Producto | Technology y Office Supplies concentran el beneficio | Priorizar reposición en mercados West y Central |
| Ciudades | Chicago y Columbus: margen alto y recurrencia estable | Aumentar agresividad promocional en nodos ancla |

---

## 📸 Capturas

_Pendiente de añadir._
