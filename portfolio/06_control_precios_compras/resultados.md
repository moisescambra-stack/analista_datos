# Resultados de las consultas

_Generado automáticamente por `ejecutar_consultas.py` sobre los datos sintéticos._


## Q1 Resumen por tipología: frecuencia e impacto económico

| tipologia | lineas | pct_errores | impacto_abs_eur | sobrecoste_eur |
|---|---|---|---|---|
| Precio por caja, no por unidad | 27 | 8.7 | 3606804.0 | 3606804.0 |
| Desplazamiento decimal | 66 | 21.2 | 3362831.0 | 3037104.0 |
| Error de tecleo | 115 | 37.0 | 44578.0 | 19720.0 |
| Tarifa del año anterior | 103 | 33.1 | 41147.0 | 0.0 |

## Q2 Pareto de proveedores: ¿quién concentra los errores?

| nombre_proveedor | lineas | errores | tasa_error_pct | pct_acumulado |
|---|---|---|---|---|
| Cuidado Personal Lumen | 558 | 62 | 11.1 | 19.9 |
| Droguería Mediterránea | 500 | 62 | 12.4 | 39.9 |
| Limpieza Hogar Brillo | 455 | 50 | 11.0 | 55.9 |
| Higiene Total Ibérica | 498 | 33 | 6.6 | 66.6 |
| Panificadora Castilla | 593 | 24 | 4.0 | 74.3 |
| Aceites Campo Real | 502 | 14 | 2.8 | 78.8 |
| Lácteos del Norte S.A. | 615 | 14 | 2.3 | 83.3 |
| Congelados Polar | 504 | 13 | 2.6 | 87.5 |
| Bebidas Sierra Alta | 480 | 12 | 2.5 | 91.3 |
| Conservas Atlántico | 508 | 12 | 2.4 | 95.2 |
| Café y Cacao Andes | 442 | 8 | 1.8 | 97.7 |
| Snacks & Co Europa | 345 | 7 | 2.0 | 100.0 |

## Q3 Cola de revisión priorizada: top 10 líneas por riesgo económico

| id_linea | fecha | nombre_proveedor | ean | tarifa_acordada | precio_introducido | tipologia | impacto_eur |
|---|---|---|---|---|---|---|---|
| 4460 | 2025-07-11 | Panificadora Castilla | 8463097799677 | 15.95 | 382.8 | Precio por caja, no por unidad | 582557.8 |
| 3305 | 2025-03-05 | Higiene Total Ibérica | 8426397962004 | 16.92 | 406.08 | Precio por caja, no por unidad | 570119.4 |
| 5373 | 2025-08-16 | Aceites Campo Real | 8451286959612 | 18.33 | 219.96 | Precio por caja, no por unidad | 400235.55 |
| 4324 | 2025-08-09 | Limpieza Hogar Brillo | 8479898700408 | 15.97 | 383.28 | Precio por caja, no por unidad | 357025.32 |
| 2203 | 2025-03-19 | Cuidado Personal Lumen | 8407519171627 | 12.6 | 151.2 | Precio por caja, no por unidad | 254192.4 |
| 856 | 2025-11-16 | Cuidado Personal Lumen | 8462791406058 | 14.94 | 149.4 | Desplazamiento decimal | 241086.78 |
| 2836 | 2025-07-10 | Limpieza Hogar Brillo | 8435066399089 | 13.56 | 135.6 | Desplazamiento decimal | 198559.08 |
| 630 | 2025-04-09 | Conservas Atlántico | 8452189559855 | 11.59 | 115.9 | Desplazamiento decimal | 197145.9 |
| 2456 | 2025-07-11 | Cuidado Personal Lumen | 8419281309269 | 12.55 | 125.5 | Desplazamiento decimal | 188400.6 |
| 5775 | 2025-02-16 | Droguería Mediterránea | 8457339622366 | 11.85 | 142.2 | Precio por caja, no por unidad | 181968.6 |

## Q4 Early Warning Indicator: ¿cuándo habría saltado la alerta?

| nombre_proveedor | mes_primera_alerta | tasa_3m_en_alerta_pct | tasa_referencia_pct | tasa_3m_diciembre_pct |
|---|---|---|---|---|
| Limpieza Hogar Brillo | 2025-05 | 10.6 | 5.0 | 15.2 |
| Cuidado Personal Lumen | 2025-09 | 12.5 | 4.8 | 11.5 |
| Droguería Mediterránea | 2025-12 | 15.6 | 5.2 | 15.6 |

## Q5 Errores por usuario: ¿problema de formación o de proceso?

| usuario | lineas | errores | tasa_error_pct |
|---|---|---|---|
| U05 | 766 | 53 | 6.9 |
| U04 | 755 | 46 | 6.1 |
| U03 | 797 | 43 | 5.4 |
| U06 | 729 | 39 | 5.3 |
| U01 | 733 | 37 | 5.0 |
| U07 | 799 | 38 | 4.8 |
| U08 | 701 | 28 | 4.0 |
| U02 | 720 | 27 | 3.8 |

## Q6 Simulación de una regla de control automática

| resultado_regla | errores | pct_errores | impacto_abs_eur | pct_impacto |
|---|---|---|---|---|
| Bloqueado por la regla | 95 | 30.5 | 6971548.0 | 98.8 |
| Requiere otro control | 216 | 69.5 | 83812.0 | 1.2 |
