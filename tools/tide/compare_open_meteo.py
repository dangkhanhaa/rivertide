"""P0-05 part 2: how good is Open-Meteo Marine `sea_level_height_msl` vs IOC observations?

Decides whether coastal stations without a gauge may use it as a fallback (PROJECT.md 6.2).
Usage: python compare_open_meteo.py   (needs data/raw/<code>_*_10min.csv)
"""

from __future__ import annotations

import json
import sys

import pandas as pd
import requests

import metrics
import tide_fit
from validate import HERE, STATIONS

URL = "https://marine-api.open-meteo.com/v1/marine"
COORDS = {"vung": (10.34, 107.071), "quin": (13.775, 109.254)}  # IOC station list
PAST_DAYS = 30


def fetch_marine(lat: float, lon: float) -> pd.Series:
    params = {
        "latitude": lat,
        "longitude": lon,
        "hourly": "sea_level_height_msl",
        "past_days": PAST_DAYS,
        "forecast_days": 1,
        "timezone": "GMT",
    }
    resp = requests.get(URL, params=params, timeout=60)
    resp.raise_for_status()
    hourly = resp.json()["hourly"]
    index = pd.to_datetime(hourly["time"], utc=True)
    values = pd.to_numeric(
        pd.Series(hourly["sea_level_height_msl"], index=index), errors="coerce"
    )
    return values * 100  # m -> cm


def compare(code: str) -> dict:
    csv = next((HERE / "data" / "raw").glob(f"{code}_*_10min.csv"))
    obs = tide_fit.load_series(str(csv), STATIONS[code]["sensor"]).resample("1h").mean()
    model = fetch_marine(*COORDS[code])
    both = pd.concat([obs, model], axis=1, keys=["obs", "model"]).dropna()
    # Datums differ (sensor zero vs MSL): compare after removing the mean offset.
    offset = float((both["obs"] - both["model"]).mean())
    model_adj = both["model"] + offset
    pairs = metrics.match_extremes(
        tide_fit.find_extremes(model_adj),
        tide_fit.find_extremes(both["obs"], smooth=True),
    )
    obs_range = float(both["obs"].max() - both["obs"].min())
    model_range = float(both["model"].max() - both["model"].min())
    return {
        "hours": len(both),
        "rmse_cm_after_offset": round(metrics.rmse(both["obs"], model_adj), 1),
        "range_obs_cm": round(obs_range),
        "range_model_cm": round(model_range),
        "extremes_n": len(pairs),
        "mean_abs_dt_min": round(float(pairs["dt_min"].abs().mean()), 1)
        if len(pairs)
        else None,
        "mean_abs_dh_cm": round(float(pairs["dh_cm"].abs().mean()), 1)
        if len(pairs)
        else None,
    }


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    codes = [c for c in COORDS if any((HERE / "data" / "raw").glob(f"{c}_*_10min.csv"))]
    result = {code: compare(code) for code in codes}
    (HERE / "output").mkdir(exist_ok=True)
    (HERE / "output" / "open_meteo_marine.json").write_text(
        json.dumps(result, indent=2), "utf-8"
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
