"""Backtest hourly river-level reconstruction from 6-hourly KTTV points.

Models compared at held-out observations (leave-one-out, ±48 h window):
  pchip   — monotone cubic through the remaining 6-hourly points (no physics)
  tide    — a + b·t + g·S(t − lag): sea tide S at Hòn Dấu (Open-Meteo Marine),
            propagated up-river with gain g and lag (grid 0..24 h)
Also scores the KTTV forecast itself against later observations.

Usage: python river_backtest.py [station_name]   (default HàNội)
"""

from __future__ import annotations

import glob
import json
import sys
from datetime import UTC, datetime
from pathlib import Path

import numpy as np
from scipy.interpolate import PchipInterpolator

HERE = Path(__file__).parent
WINDOW_H = 48
LAGS_H = range(25)


def _t(s: str) -> datetime:
    return datetime.fromisoformat(s)


def load_bulletins() -> list[dict]:
    return [
        json.loads(Path(f).read_text(encoding="utf-8"))
        for f in sorted(glob.glob(str(HERE / "output" / "dbqg_tvhn_*.json")))
    ]


def series(
    bulletins: list[dict], name: str
) -> tuple[dict[datetime, int], list[tuple[datetime, dict[datetime, int]]]]:
    obs: dict[datetime, int] = {}
    fcs = []
    for b in bulletins:
        st = next(
            (s for s in b["stations"] if s["name"].replace(" ", "") == name), None
        )
        if st is None:
            continue
        fc = {}
        for p in st["points"]:
            (obs if p["kind"] == "obs" else fc)[_t(p["t"])] = p["v"]
        fcs.append((_t(b["issued_utc"]), fc))
    return obs, fcs


def sea_tide(file: str = "om_hondau.json") -> tuple[np.ndarray, np.ndarray]:
    d = json.loads((HERE / "data" / "raw" / file).read_text(encoding="utf-8"))
    t = np.array(
        [
            datetime.fromisoformat(x).replace(tzinfo=UTC).timestamp() / 3600
            for x in d["hourly"]["time"]
        ]
    )
    v = np.array(
        [np.nan if x is None else x * 100 for x in d["hourly"]["sea_level_height_msl"]]
    )
    return t, v


def fit_tide(ts: np.ndarray, ys: np.ndarray, st: np.ndarray, sv: np.ndarray):
    best = None
    t0 = ts.mean()
    for lag in LAGS_H:
        s = np.interp(ts - lag, st, sv)
        a = np.column_stack([np.ones_like(ts), ts - t0, s])
        coef, *_ = np.linalg.lstsq(a, ys, rcond=None)
        if coef[2] <= 0:
            continue  # tide cannot be inverted up-river
        err = float(np.sum((a @ coef - ys) ** 2))
        if best is None or err < best[0]:
            best = (err, lag, coef, t0)
    return best


def predict_tide(model, t: float, st, sv) -> float:
    _, lag, coef, t0 = model
    return float(coef[0] + coef[1] * (t - t0) + coef[2] * np.interp(t - lag, st, sv))


def main(name: str = "HàNội", sea_file: str = "om_hondau.json") -> None:
    bulletins = load_bulletins()
    obs, fcs = series(bulletins, name)
    st, sv = sea_tide(sea_file)
    times = sorted(obs)
    th = np.array([t.timestamp() / 3600 for t in times])
    y = np.array([obs[t] for t in times], dtype=float)
    err_p, err_t, lags = [], [], []
    for i in range(len(times)):
        near = np.where((np.abs(th - th[i]) <= WINDOW_H) & (np.arange(len(th)) != i))[0]
        if len(near) < 5:
            continue
        inside = th[near].min() < th[i] < th[near].max()
        if inside:
            err_p.append(PchipInterpolator(th[near], y[near])(th[i]) - y[i])
        m = fit_tide(th[near], y[near], st, sv)
        if m and inside:
            err_t.append(predict_tide(m, th[i], st, sv) - y[i])
            lags.append(m[1])
    fc_err = []
    for issued, fc in fcs:
        for t, v in fc.items():
            if t in obs:
                fc_err.append((round((t - issued).total_seconds() / 3600), v - obs[t]))

    # Real-time mode (what the app does): at issue time fit on past obs + KTTV forecast,
    # then score the curve at later observation times.
    rt_err, raw_err = [], []
    for issued, fc in fcs:
        past = {
            t: v
            for t, v in obs.items()
            if t <= issued and (issued - t).total_seconds() <= WINDOW_H * 3600
        }
        pts = {**past, **fc}
        if len(pts) < 6:
            continue
        pt = np.array([t.timestamp() / 3600 for t in sorted(pts)])
        py = np.array([pts[t] for t in sorted(pts)], dtype=float)
        m = fit_tide(pt, py, st, sv)
        if not m:
            continue
        for t, v in obs.items():
            if t > issued and t in fc:
                rt_err.append(predict_tide(m, t.timestamp() / 3600, st, sv) - v)
                raw_err.append(fc[t] - v)

    def mae(e):
        return round(float(np.mean(np.abs(e))), 1) if len(e) else None

    out = {
        "station": name,
        "obs_points": len(times),
        "leave_one_out": {
            "pchip_mae_cm": mae(err_p),
            "tide_model_mae_cm": mae(err_t),
            "n": len(err_t),
            "lag_h_median": float(np.median(lags)) if lags else None,
        },
        "realtime": {
            "tide_model_mae_cm": None,
            "kttv_raw_mae_cm": None,
            "n": len(rt_err),
        },
        "kttv_forecast": {
            "mae_cm": mae([e for _, e in fc_err]),
            "n": len(fc_err),
            "by_lead": sorted(fc_err),
        },
    }
    out["realtime"]["tide_model_mae_cm"] = mae(rt_err)
    out["realtime"]["kttv_raw_mae_cm"] = mae(raw_err)
    (HERE / "output").mkdir(exist_ok=True)
    (HERE / "output" / f"backtest_{name}.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8"
    )
    out["kttv_forecast"].pop("by_lead")
    sys.stdout.buffer.write(
        json.dumps(out, ensure_ascii=False, indent=1).encode("utf-8") + b"\n"
    )


if __name__ == "__main__":
    main(*sys.argv[1:])
