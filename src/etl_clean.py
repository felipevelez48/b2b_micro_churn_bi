from pathlib import Path
import pandas as pd
import numpy as np

BASE_DIR = Path(__file__).resolve().parents[1]
RAW_XLS = BASE_DIR / "data" / "raw" / "Base_Muestra_B2B.xlsx"
OUT_CSV = BASE_DIR / "data" / "processed" / "fact_ventas_churn.csv"

def months_diff(d1, d2):
    if pd.isna(d1) or pd.isna(d2):
        return None
    return (d2.year - d1.year) * 12 + (d2.month - d1.month)

def main():
    df = pd.read_excel(RAW_XLS, sheet_name=0, dtype={"Msisdn":"string"})
    df.columns = df.columns.str.strip()

    for col in ["Fecha Evento","Fecha Churn"]:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")

    if "Periodo" in df.columns:
        p = pd.to_datetime(df["Periodo"], errors="coerce")
        df["Periodo_norm"] = p.dt.to_period("M").astype("string")
    else:
        df["Periodo_norm"] = df["Fecha Evento"].dt.to_period("M").astype("string")

    if all(c in df.columns for c in ["Fecha Evento","Fecha Churn"]):
        df["Mes Churn"] = [months_diff(a,b) for a,b in zip(df["Fecha Evento"], df["Fecha Churn"])]

    if "Tipo Transaccion" in df.columns:
        df["Tipo Transaccion"] = (
            df["Tipo Transaccion"].astype("string").str.strip().str.lower()
            .replace({"churn voluntario":"voluntario","churn x cartera":"cartera"})
            .fillna("desconocido")
        )

    keys = [c for c in ["Msisdn","Fecha Evento","Producto","Nombre Canal"] if c in df.columns]
    if keys:
        before = len(df)
        df = df.drop_duplicates(subset=keys, keep="first")
        print(f"Drop dups: {before - len(df)}")

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT_CSV, index=False)
    print(f"OK -> {OUT_CSV} ({len(df)} filas)")

if __name__ == "__main__":
    main()
