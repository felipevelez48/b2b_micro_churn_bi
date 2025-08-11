# 🛠️ b2b_micro_churn_bi — Micro/Small B2B.
---

## 📖 Descripción 
Análisis end-to-end de ventas y churn en el segmento Micro/Small B2B.
Incluye pipeline reproducible (Python), dataset limpio, Power BI con KPIs ejecutivos, retención/cohortes, geografía y resolución de la Parte 2 (SQL) y Parte 3 (PL/SQL) de la prueba.
```
Diferenciador: aunque no era requisito, se construyó un pipeline de datos completo (EDA → limpieza → normalización → export), priorizando calidad y trazabilidad.
```

---
## 1) Qué resuelve este proyecto
Preguntas de negocio:

    - ¿Cuánto vendemos? (Altas por mes/segmento/región/canal/producto).

    - ¿Cuánto perdemos? (Churn total y por tipo: voluntario vs cartera).

    - ¿La base crece? (Net Adds y Churn Rate).

    - ¿Dónde y cuándo sucede? (Mapa por departamento y cohortes/retención).

    - ¿Qué lo explica? (Pareto dinámico de motivos de churn).

**Entregables**

    - Dataset limpio para BI (data/processed/*.csv).

    - Power BI con páginas: Overview y Pareto Motivos.

    - SQL estándar y PL/SQL explicados para la Parte 2 y Parte 3.

---

## 2) Estructura del repositorio 📂
```
b2b_micro_churn_bi/
  ├─ data/
  │   ├─ raw/                # Excel fuente
  │   └─ processed/          # CSV limpios
  ├─ notebooks/
  │   └─ 01_eda_y_limpieza.ipynb        #Exploración del df y conclusiones.
  ├─ src/
  │   └─ etl_clean.py        # Limpieza/normalización (rutas fijas)
  ├─ powerbi/
  │   ├─ tema_tigo.json      # Tema visual Tigo
  │   └─ imagenes/           # usadas en la contrucción del dashboard
  ├─ sql/
  │   ├─ 01_sql_estandar.sql
  │   └─ 02_plsql_oracle.md
  ├─ readme
.gitignore excluye data/raw/*, data/processed/*.csv, .venv/, *.pbix

```
---
##  3) Requisitos 🚀

| Herramienta        | Versión mínima |
| ------------------ | -------------- |
| Python             | 3.11           |
| Power BI Desktop   | Actual         |
| Git                | Cualquiera     |
| (Opcional) Jupyter | Actual         |

Windows + Git Bash: activar venv con source .venv/Scripts/activate.

---

## 4) Instalación rápida ⚙️
``` bash
# Clonar
git clone https://github.com/felipevelez48/b2b_micro_churn_bi.git
cd b2b_micro_churn_bi

# Ambiente
python -m venv .venv
source .venv/Scripts/activate
pip install -r requirements.txt

# Colocar el Excel fuente
# data/raw/Base_Muestra_B2B.xlsx

# Generar dataset limpio
python src/etl_clean.py
```
---

## 5) Pipeline de datos (resumen) 🔬
**EDA (notebook 01_eda_y_limpieza.ipynb)**

    - Tipos, nulos, duplicados (Msisdn + Fecha Evento + Producto + Nombre Canal).

    - Histogramas/boxplots de Cantidad.

    - Validación de Periodo (acepta YYYY-MM y YYYYMM).

**Limpieza / Normalización (src/etl_clean.py)**

    - Fecha Evento / Fecha Churn → datetime.

    - Periodo_norm (mes estándar; fallback por fecha de evento).

    - Mes Churn = meses entre venta y churn.

    - Tipo Transaccion normalizado: voluntario / cartera / desconocido.

    - Deduplicación.

    - Export: data/processed/fact_ventas_churn.csv.

**KPIs mensuales (generados en notebook)**

    - kpis_mensuales.csv con altas, churn, net_adds, base_prev, churn_rate, etc.

Este flujo garantiza consistencia y facilita auditoría del análisis.

---

## 6) Parte I — BI (KPIs & Visualizaciones) 📊

**KPIs (definiciones)**

    - Altas (Ventas Líneas): SUM(Cantidad) por Fecha Evento.

    - Líneas Churn: SUM(Cantidad) por Fecha Churn (relación inactiva activada en la medida).

    - Net Adds: Altas − Líneas Churn.

    - Base Cierre: Altas Acum − Churn Acum.

    - Base Prev: Base Cierre del mes anterior.

    - Churn Rate: Líneas Churn / Base Prev.

    - Desglose: Desconexión vs Suspensión.

    - Retención: distribución por Mes Churn (1–3, 4–6, 7–9, 10–12 meses).

**Páginas del dashboard**
**Overview**

    - Tarjetas: Cantidad ventas, Líneas churn, Churn rate, Net mes, Net total / Net rate.

    - Histórico mensual: Altas vs Churn vs Net Adds con variación (mes actual, anterior, diferencia).

    - Desconexión vs Suspensión (donut).

    - Retención por tramos (1–3, 4–6, 7–9, 10–12).

    - Mapa con clusters y mapa de calor por departamento.

**Pareto de Motivos de Churn**

    - Barras ordenadas + línea acumulada con slider de umbral (p. ej., 80%).

    - Tabla detalle (Rank, %GT, valor acumulado).

    - Slicers: Año, Mes, Regional, Nivel, Canales.

---

## 7) Parte II — SQL estándar 🧩

Archivo: sql/01_sql_estandar.sql

Incluye consultas para:

    - Arrendatarios que arriendan una casa específica (calle/número/comuna).

    - Deuda total a nombre de María Pérez.

    - Deuda total por dueño (incluyendo dueños sin deuda).

    - Listado de todas las personas (dueños ∪ arrendatarios, sin duplicados).

    - Dueños con tres o más casas.

    - Dueños con deudores en todas sus casas.

    - Estadísticas del # de arrendatarios por casa: promedio, varianza, max, min, moda y mediana.

---

## 8) Parte III — PL/SQL 💬

Archivo: sql/02_plsql_oracle.md

    - NVL = “plan B” si un dato viene vacío (NULL). Para varios casos, usar CASE o COALESCE.

    - LEFT JOIN vs INNER JOIN: LEFT conserva todo el universo de la izquierda (p. ej., “todos los clientes, compren o no”); INNER trae solo coincidencias.

    - ROW_NUMBER(): ranking dentro de un grupo (quedarse con el último estado por cliente/línea).

    - Cursores: recorrer fila a fila cuando de verdad se necesita una acción por registro (notificaciones, procesos).

    - ETL en Oracle: viable (ingesta, transformación, scheduler) cuando fuente/destino viven en Oracle y se busca rendimiento y simplicidad.

---

## 9) Supuestos clave ✅

    - Base Prev se calcula dentro del alcance Micro/Small del dataset.

    - Si no hay base previa en un mes inicial, Churn Rate no se muestra (evita distorsión).

    - Tipo Transaccion nulo → desconocido (no se infiere).

    - Deduplicación por Msisdn + Fecha Evento + Producto + Nombre Canal.

    - Periodo corrige automáticamente YYYYMM y YYYY-MM.

---

# 💡 Autor 📊🤖
## John Felipe Vélez
### Data Engineer

