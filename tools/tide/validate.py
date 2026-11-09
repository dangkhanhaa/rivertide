"""P0-05: fit on 12 months, test on the following weeks, compare with KTTV bulletin.

Usage: python validate.py  (expects data/raw/<code>_*_10min.csv from download_ioc.py)
Writes output/validation.json and prints a summary.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pandas as pd

import metrics
import tide_fit

HERE = Path(__file__).parent
TRAIN_END = pd.Timestamp("2026-10-01", tz="UTC")
LEADS_H = [1, 3, 6, 12]

STATIONS = {
    "vung": {"sensor": "ra2", "lat": 10.34},
    "quin": {"sensor": "rad", "lat": 13.77},
}


def summarize_pairs(df: pd.DataFrame) -> dict:
    if df.empty:
        return {"n": 0}
    return {
        "n": len(df),
        "mean_abs_dt_min": round(float(df["dt_min"].abs().mean()), 1),
        "p90_abs_dt_min": round(float(df["dt_min"].abs().quantile(0.9)), 1),
        "mean_abs_dh_cm": round(float(df["dh_cm"].abs().mean()), 1),
        "p90_abs_dh_cm": round(float(df["dh_cm"].abs().quantile(0.9)), 1),
    }


def bulletin_block(series: pd.Series, bulletin: dict, dates: list[str]) -> dict:
    df = metrics.compare_bulletin(series, bulletin, dates)
    if df.empty:
        return {"n": 0}
    inner = df[~df["boundary"]]
    return {
        "datum_offset_cm": round(df.attrs["datum_offset_cm"], 1),
        "all": summarize_pairs(df),
        "excluding_day_edge": summarize_pairs(inner),
        "rows": df.round(1).to_dict(orient="records"),
    }


def run_station(code: str, cfg: dict, bulletin_doc: dict) -> dict:
    csv = next((HERE / "data" / "raw").glob(f"{code}_*_10min.csv"))
    obs = tide_fit.load_series(str(csv), cfg["sensor"])
    train, test = obs[obs.index < TRAIN_END], obs[obs.index >= TRAIN_END]
    coef = tide_fit.fit(train, cfg["lat"])
    test_pred = tide_fit.predict(coef, test.index)
    pairs = metrics.match_extremes(
        tide_fit.find_extremes(test_pred), tide_fit.find_extremes(test, smooth=True)
    )
    future_index = pd.date_range("2026-11-06", "2026-11-17", freq="10min", tz="UTC")
    future_pred = tide_fit.predict(coef, future_index)
    bulletin = bulletin_doc["stations"][code]
    dates = bulletin_doc["dates"]
    return {
        "sensor": cfg["sensor"],
        "train": [str(train.index[0]), str(train.index[-1])],
        "train_completeness": round(tide_fit.completeness(train), 3),
        "test": [str(test.index[0]), str(test.index[-1])],
        "test_completeness": round(tide_fit.completeness(test), 3),
        "constituents": len(coef.name),
        "test_rmse_cm": round(metrics.rmse(test, test_pred), 1),
        "test_extremes_vs_observed": summarize_pairs(pairs),
        "test_direction_accuracy": round(
            metrics.direction_accuracy(test_pred, test), 3
        ),
        "corrected_rmse_by_lead_h": metrics.corrected_rmse_by_lead(
            test_pred, test, LEADS_H
        ),
        "ours_vs_bulletin": bulletin_block(future_pred, bulletin, dates),
        "observed_vs_bulletin": bulletin_block(obs, bulletin, dates),
    }


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    bulletin_doc = json.loads(
        (HERE / "fixtures" / "nchmf_tide_20261106.json").read_text("utf-8")
    )
    raw = HERE / "data" / "raw"
    results = {
        code: run_station(code, cfg, bulletin_doc)
        for code, cfg in STATIONS.items()
        if any(raw.glob(f"{code}_*_10min.csv"))
    }
    out = HERE / "output"
    out.mkdir(exist_ok=True)
    (out / "validation.json").write_text(
        json.dumps(results, indent=2, default=str), "utf-8"
    )
    for code, r in results.items():
        brief = {
            k: v
            for k, v in r.items()
            if k not in ("ours_vs_bulletin", "observed_vs_bulletin")
        }
        print(code, json.dumps(brief, indent=1, default=str))
        for key in ("ours_vs_bulletin", "observed_vs_bulletin"):
            b = r[key]
            print(f"  {key}: offset={b.get('datum_offset_cm')} all={b.get('all')}")
            print(f"     excl_day_edge={b.get('excluding_day_edge')}")


if __name__ == "__main__":
    main()
