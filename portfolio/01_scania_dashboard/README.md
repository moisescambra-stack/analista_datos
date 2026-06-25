# 📊 Dashboard Ejecutivo – Scania Ibérica

**Power BI · DAX Avanzado · Constellation Schema · Early Warning Indicators**

---

## 📋 Descripción del Proyecto

Cuadro de mando ejecutivo completo para la red de concesionarios Scania Ibérica. Analiza ventas de camiones, operaciones de servicio técnico y cadena de suministro de repuestos en **54 dealers europeos**, con alertas automáticas de rendimiento.

---

## 🏗️ Arquitectura del Modelo de Datos

**Tipo:** Constellation Schema (esquema constelación)  
**Motivo:** 3 procesos de negocio independientes que comparten dimensiones

```
                    ┌─────────────────┐
                    │  Dim_Calendario │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│  Fact_Ventas    │ │  Fact_Servicio  │ │  Fact_Repuestos │
│  Camiones       │ │  Operaciones    │ │  Supply Chain   │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │Dim_Modelo│        │Dim_Taller│        │Dim_Pieza│
    └─────────┘         └─────────┘         └─────────┘
              \              │              /
               └──────┬──────┘─────────────┘
                      │
                 ┌────▼────┐
                 │Dim_Dealer│
                 └──────────┘
```

**Tablas:**
| Tabla | Tipo | Registros | Descripción |
|-------|------|-----------|-------------|
| Fact_Ventas_Camiones | Hechos | ~8.000 | Transacciones de venta por modelo y dealer |
| Fact_Servicio_Operaciones | Hechos | ~5.000 | Órdenes de trabajo y tiempos de reparación |
| Fact_Repuestos | Hechos | ~3.500 | Pedidos de repuestos, urgentes vs planificados |
| Dim_Dealer | Dimensión | 54 | Concesionarios europeos con región y país |
| Dim_Modelo | Dimensión | ~30 | Modelos de camión con serie y segmento |
| Dim_Calendario | Dimensión | 1.096 | 3 años con semanas fiscales y trimestres |

---

## 📄 Páginas del Dashboard

### 1. Executive Overview
KPIs globales de la red: ventas totales, ingresos de servicio, fill rate de repuestos. Semáforo de rendimiento vs target trimestral. Comparativa YoY.

### 2. Truck Sales
Análisis de ventas por modelo de camión, dealer, región y trimestre. RANKX de dealers por volumen. Tendencia de ventas rolling 3 meses.

### 3. Service Operations
First Time Fix Rate por taller. Tiempo medio de intervención. Eficiencia técnica por tipo de avería. Alertas EWI si FTFR cae por debajo del 85%.

### 4. Spare Parts – Supply Chain
Ratio pedidos urgentes vs planificados por país. Detección de patrones de rotura de stock. Riesgo en cadena de suministro por dealer y región.

---

## 🧮 Medidas DAX Destacadas

```dax
-- ─────────────────────────────────────────
-- VENTAS Y RENDIMIENTO
-- ─────────────────────────────────────────

Total Ventas =
SUMX(Fact_Ventas_Camiones, Fact_Ventas_Camiones[Precio_Venta])

Varianza vs Target =
VAR _actual = [Total Ventas]
VAR _target = [Target Ventas Trimestre]
RETURN DIVIDE(_actual - _target, _target, 0)

Semaforo Rendimiento =
VAR _var = [Varianza vs Target]
RETURN
    IF(_var >= 0, "🟢 En objetivo",
    IF(_var >= -0.05, "🟡 Atención",
    "🔴 Por debajo"))

-- ─────────────────────────────────────────
-- TIME INTELLIGENCE
-- ─────────────────────────────────────────

Ventas YoY % =
VAR _actual = [Total Ventas]
VAR _anterior = CALCULATE([Total Ventas], SAMEPERIODLASTYEAR(Dim_Calendario[Fecha]))
RETURN DIVIDE(_actual - _anterior, _anterior, 0)

Rolling 3M Ventas =
CALCULATE(
    [Total Ventas],
    DATESINPERIOD(Dim_Calendario[Fecha], LASTDATE(Dim_Calendario[Fecha]), -3, MONTH)
)

-- ─────────────────────────────────────────
-- SERVICE OPERATIONS
-- ─────────────────────────────────────────

First Time Fix Rate =
VAR _resueltos_primera =
    CALCULATE(
        COUNTROWS(Fact_Servicio_Operaciones),
        Fact_Servicio_Operaciones[Intentos_Reparacion] = 1
    )
VAR _total = COUNTROWS(Fact_Servicio_Operaciones)
RETURN DIVIDE(_resueltos_primera, _total, 0)

EWI FTFR Alerta =
IF([First Time Fix Rate] < 0.85, "⚠️ FTFR bajo umbral", "✅ OK")

-- ─────────────────────────────────────────
-- RANKING
-- ─────────────────────────────────────────

Ranking Dealer Ventas =
RANKX(ALL(Dim_Dealer[Nombre_Dealer]), [Total Ventas], , DESC, DENSE)

-- ─────────────────────────────────────────
-- SUPPLY CHAIN REPUESTOS
-- ─────────────────────────────────────────

% Pedidos Urgentes =
VAR _urgentes = CALCULATE(COUNTROWS(Fact_Repuestos), Fact_Repuestos[Tipo_Pedido] = "Urgente")
VAR _total = COUNTROWS(Fact_Repuestos)
RETURN DIVIDE(_urgentes, _total, 0)

EWI Riesgo Repuestos =
IF([% Pedidos Urgentes] > 0.30, "🔴 Riesgo SC elevado",
IF([% Pedidos Urgentes] > 0.15, "🟡 Monitorizar",
"🟢 Normal"))
```

---

## 📸 Capturas

> Ver carpeta [`/capturas`](./capturas/)

---

## 🔑 Aprendizajes Técnicos

- **Constellation Schema** vs Star Schema: cuándo usar múltiples tablas de hechos que comparten dimensiones
- **USERELATIONSHIP** para activar relaciones inactivas entre tablas de hechos y el calendario
- **Row-level Security** por región de dealer
- **Performance Analyzer** para optimizar medidas lentas en tablas de +16.000 filas
