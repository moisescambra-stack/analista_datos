# 🚢 Maritime Intelligence Dashboard

**Power BI · DAX · Star Schema · AIS Data · Scoring de Riesgo · Early Warning Indicators**

> 🚧 **En desarrollo.** Diseño del modelo y medidas en borrador; el README se actualizará con capturas al completarse.

---

## 📋 Descripción del Proyecto

Dashboard de inteligencia marítima para monitorización de rutas críticas globales y detección temprana de anomalías en cadena de suministro. Cubre **15 puertos de alto riesgo** con scoring de riesgo por ruta basado en sanciones internacionales y actividad AIS.

**Áreas de cobertura:** Estrecho de Ormuz · Mar Negro · África Occidental · Canal de Suez · Malacca

---

## 🏗️ Arquitectura del Modelo de Datos

**Tipo:** Star Schema

```
                ┌─────────────────┐
                │  Dim_Calendario │
                └────────┬────────┘
                         │
          ┌──────────────▼──────────────┐
          │      Fact_Movimientos       │
          │  Tráfico marítimo por ruta  │
          └──┬──────────┬──────────┬───┘
             │          │          │
    ┌─────────▼─┐  ┌────▼─────┐  ┌▼──────────┐
    │ Dim_Buque  │  │Dim_Puerto│  │Dim_Sancion│
    └────────────┘  └──────────┘  └───────────┘
```

---

## 🎯 Funcionalidades Planificadas

- [ ] Seguimiento de posición de buques en tiempo real (datos AIS)
- [ ] Detección de **dark activity** (gaps en señal AIS > umbral configurable)
- [ ] **Scoring de riesgo por ruta** con ponderación OFAC / UN / EU
- [ ] Early Warning Indicators con alertas DAX para anomalías de ruta
- [ ] Mapa geoespacial interactivo con heat map de riesgo por zona
- [ ] Historial de sanciones por naviera y país de bandera

---

## 🧮 Medidas DAX Planificadas

```dax
-- Scoring de riesgo por ruta (borrador)
-- RELATED necesita contexto de fila: se itera la tabla de hechos con AVERAGEX
Score Riesgo Ruta =
VAR _sanciones =
    AVERAGEX (
        Fact_Movimientos,
        RELATED ( Dim_Sancion[Score_OFAC] ) * 0.40
            + RELATED ( Dim_Sancion[Score_UN] ) * 0.30
            + RELATED ( Dim_Sancion[Score_EU] ) * 0.20
    )
RETURN
    _sanciones + [% Gaps AIS] * 0.10

-- EWI Alerta ruta crítica
EWI Ruta Critica =
IF([Score Riesgo Ruta] >= 0.75, "🔴 ALERTA CRÍTICA",
IF([Score Riesgo Ruta] >= 0.50, "🟡 Monitorizar",
"🟢 Normal"))

-- Rolling average actividad por puerto
Rolling 30D Transitos =
CALCULATE(
    COUNTROWS(Fact_Movimientos),
    DATESINPERIOD(Dim_Calendario[Fecha], LASTDATE(Dim_Calendario[Fecha]), -30, DAY)
)
```

---

## 📬 Seguimiento

Este proyecto está en desarrollo activo. El README se actualizará con capturas y código final al completarse.
