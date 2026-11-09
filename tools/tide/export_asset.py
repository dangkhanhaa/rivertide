"""Fit on all downloaded data and write per-year prediction assets for the app.

Output: app/assets/tide/<station_id>_<year>.json.gz (format: PROJECT.md 8.5).
Levels are shifted to KTTV chart datum using the offset measured in validate.py.

Usage: python export_asset.py --years 2026 2027
"""

from __future__ import annotations

import argparse
import json

import pandas as pd

import tide_fit
from validate import HERE, STATIONS

ASSET_DIR = HERE.parents[1] / "app" / "assets" / "tide"
MODEL_VERSION = "utide-1"


def confidence(rmse_cm: float, train_days: float) -> str:
    # Rule from PROJECT.md 9.1.
    if rmse_cm < 10 and train_days >= 180:
        return "high"
    return "medium" if rmse_cm < 20 else "low"


def build_year(code: str, coef, year: int, offset_cm: float, model: dict) -> dict:
    index = pd.date_range(
        f"{year}-01-01", f"{year + 1}-01-01", freq="10min", tz="UTC", inclusive="left"
    )
    pred = tide_fit.predict(coef, index) + offset_cm
    extremes = [
        [e.time.strftime("%Y-%m-%dT%H:%M:%SZ"), round(e.level_cm), e.kind]
        for e in tide_fit.find_extremes(pred)
    ]
    return {
        "station_id": f"ioc-{code}",
        "year": year,
        "datum": "KTTV chart datum (offset from bulletin comparison)",
        "tz": "UTC",
        "start": index[0].strftime("%Y-%m-%dT%H:%M:%SZ"),
        "step_minutes": 10,
        "levels_cm": [round(v) for v in pred.to_numpy()],
        "extremes": extremes,
        "model": model,
        "confidence": model["confidence"],
        # The app adds this to raw IOC observations so they share the prediction datum.
        "obs_datum_offset_cm": round(offset_cm, 1),
    }


def export_station(code: str, cfg: dict, validation: dict, years: list[int]) -> None:
    csv = next((HERE / "data" / "raw").glob(f"{code}_*_10min.csv"))
    obs = tide_fit.load_series(str(csv), cfg["sensor"])
    coef = tide_fit.fit(obs, cfg["lat"])
    v = validation[code]
    rmse_cm = v["test_rmse_cm"]
    train_days = (obs.index[-1] - obs.index[0]).days
    model = {
        "version": MODEL_VERSION,
        "constituents": len(coef.name),
        "fit_from": obs.index[0].strftime("%Y-%m-%d"),
        "fit_to": obs.index[-1].strftime("%Y-%m-%d"),
        "rmse_cm": rmse_cm,
        "extreme_time_err_min": v["test_extremes_vs_observed"]["mean_abs_dt_min"],
        "extreme_height_err_cm": v["test_extremes_vs_observed"]["mean_abs_dh_cm"],
        "confidence": confidence(rmse_cm, train_days),
    }
    offset = v["ours_vs_bulletin"]["datum_offset_cm"]
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    for year in years:
        doc = build_year(code, coef, year, offset, model)
        # Plain JSON: APK and web servers compress assets themselves, and the app then
        # needs no gzip package (dart:io is unavailable on web).
        path = ASSET_DIR / f"ioc-{code}_{year}.json"
        path.write_text(json.dumps(doc, separators=(",", ":")), "utf-8")
        print(
            f"{path.name}: {path.stat().st_size // 1024} KB, {len(doc['extremes'])} extremes"
        )


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--years", nargs="+", type=int, required=True)
    args = ap.parse_args()
    validation = json.loads((HERE / "output" / "validation.json").read_text("utf-8"))
    for code, cfg in STATIONS.items():
        if code in validation:
            export_station(code, cfg, validation, args.years)


if __name__ == "__main__":
    main()
