# 🧾 Control de precios en una central de compras

**SQL · Funciones ventana · CTEs · Esquema en estrella · Early Warning Indicators · Python**

> **Datos 100 % sintéticos.** Proveedores, productos y EAN ficticios, generados con
> [`data/generar_datos.py`](./data/generar_datos.py). El caso está inspirado en un problema
> real y habitual de las centrales de compras: los errores al introducir precios a mano.

---

## 1. Contexto de negocio

Una central de compras gestiona miles de precios negociados con sus proveedores. Una parte
se introduce manualmente en el sistema y cada error tiene consecuencias económicas:

- un precio inflado se paga de más si llega a pedido y factura;
- un precio infravalorado genera reclamaciones del proveedor y falsea el cálculo de margen.

## 2. Preguntas de análisis

1. ¿Qué tipos de error se producen y cuánto dinero ponen en riesgo?
2. ¿Qué proveedores concentran los errores?
3. ¿Qué líneas hay que revisar primero?
4. ¿Podemos **anticipar** qué proveedor empieza a deteriorarse?
5. ¿Es un problema de las personas o del proceso?
6. ¿Qué control automático tendría más impacto?

## 3. Datos y modelo

| Tabla | Tipo | Filas | Contenido |
|-------|------|-------|-----------|
| `fact_lineas_precio` | Hechos | 6.000 | Precios introducidos a mano en 2025, con volumen previsto |
| `dim_producto` | Dimensión | 400 | EAN-13 (dígito de control válido), categoría, unidades por caja |
| `dim_proveedor` | Dimensión | 12 | Proveedores ficticios |
| `tarifas` | Referencia | 400 | Tarifa acordada vigente y tarifa del año anterior |

Volumen de compra previsto analizado: **≈ 60,7 M€**.

## 4. Técnica clave: clasificar el error por su "huella" numérica

Cada tipo de error deja un patrón reconocible en el cociente `precio introducido / tarifa acordada`:

```sql
CASE
    WHEN ABS(precio_introducido - tarifa_acordada) < 0.005          THEN 'Correcto'
    WHEN ABS(precio_introducido - tarifa_anterior) < 0.005          THEN 'Tarifa del año anterior'
    WHEN precio_introducido / tarifa_acordada BETWEEN 9.5  AND 10.5
      OR precio_introducido / tarifa_acordada BETWEEN 0.09 AND 0.115 THEN 'Desplazamiento decimal'
    WHEN unidades_por_caja > 1
     AND ABS(precio_introducido / tarifa_acordada - unidades_por_caja)
         <= 0.02 * unidades_por_caja                                 THEN 'Precio por caja, no por unidad'
    ELSE 'Error de tecleo'
END
```

Las reglas más específicas van primero: en un `CASE`, la primera condición verdadera gana.

Todas las consultas están en [`queries.sql`](./queries.sql) y los resultados completos en
[`resultados.md`](./resultados.md).

## 5. Hallazgos

**311 errores en 6.000 líneas (5,2 %)**, con un importe en riesgo de **≈ 7,1 M€** sobre el volumen previsto.

| Tipología | Errores | % errores | Importe en riesgo |
|-----------|--------:|----------:|------------------:|
| Precio por caja, no por unidad | 27 | 8,7 % | 3,61 M€ |
| Desplazamiento decimal | 66 | 21,2 % | 3,36 M€ |
| Error de tecleo | 115 | 37,0 % | 0,04 M€ |
| Tarifa del año anterior | 103 | 33,1 % | 0,04 M€ |

1. **Los errores más frecuentes no son los más caros.** Tecleo y tarifa antigua suponen el
   70 % de los errores, pero solo el 1,2 % del importe en riesgo. Caja y decimales son el 30 %
   de los errores y el **98,8 % del riesgo**.
2. **Concentración en pocos proveedores.** 3 de 12 proveedores (25 %) generan el **56 %** de los
   errores, con tasas del 11–12 % frente a una media del 5,2 %.
3. **La alerta temprana habría funcionado.** El indicador habría marcado a *Limpieza Hogar Brillo*
   en **mayo**, con una tasa del 10,6 %; en diciembre ya estaba en el 15,2 %. Siete meses de margen
   para actuar.
4. **Es un problema de proceso, no de personas.** Los 8 usuarios tienen tasas de entre el 3,8 % y
   el 6,9 %, sin ningún caso atípico. Formar a una persona concreta no resolvería el problema.
5. **La tarifa antigua no genera sobrecoste, pero sí conflicto.** Al ser inferior a la vigente,
   provoca reclamaciones del proveedor y distorsiona el margen calculado.

## 6. Recomendaciones

| Prioridad | Acción | Impacto esperado |
|-----------|--------|------------------|
| 1 | **Bloqueo automático en la entrada** de precios fuera del rango 0,5x–2x de la tarifa acordada | Captura el **98,8 %** del riesgo económico con **0 falsos positivos** en los datos analizados |
| 2 | Validar contra la tabla de tarifas **versionada** al cargar precios | Elimina los errores de tarifa anterior |
| 3 | Cola semanal de revisión ordenada por impacto económico | El controller revisa primero lo que más cuesta |
| 4 | Indicador mensual de alerta temprana por proveedor | Detecta el deterioro meses antes de que escale |
| 5 | Revisión del proceso con los 3 proveedores que concentran los errores | Ataca la causa raíz, no el síntoma |

## 7. Técnicas SQL demostradas

| Técnica | Dónde | Para qué |
|---------|-------|----------|
| Vista con `CASE` jerárquico | `v_control_precios` | Clasificar tipologías una sola vez y reutilizarlas |
| `SUM() OVER ()` | Q1, Q2, Q6 | Porcentajes sobre el total sin subconsultas |
| `SUM() OVER (ORDER BY …)` | Q2 | Pareto acumulado |
| `AVG() OVER (ROWS BETWEEN 2 PRECEDING …)` | Q4 | Media móvil de 3 meses |
| `LAG(…, 3)` | Q4 | Comparar con la tendencia de 3 meses antes |
| `SUM(SUM()) OVER (ORDER BY mes)` | Q4 | Referencia acumulada, sin sesgo de anticipación |
| `HAVING` con volumen mínimo | Q2 | Evitar rankings engañosos por muestras pequeñas |

## 8. Cómo reproducirlo

```bash
python data/generar_datos.py     # crea los CSV y compras.db (semilla fija: resultados reproducibles)
python ejecutar_consultas.py     # ejecuta queries.sql y regenera resultados.md
```

SQL estándar, probado en SQLite 3.45 y compatible con PostgreSQL.
