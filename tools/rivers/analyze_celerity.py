"""Tide-wave speed up the Red River, from real data only (run from tools/rivers).

1. Phase of the sea tide at Hòn Dấu vs the Ba Lạt mouth (Open-Meteo Marine).
2. Hà Nội lag per KTTV bulletin on a 0.25 h grid (bulletins + Hòn Dấu sea tide).
3. Hà Nội gauge position (km) along the OSM main stem from Ba Lạt.

Needs tools/nchmf/output/dbqg_tvhn_*.json and tools/nchmf/data/raw/om_hondau.json,
om_balat.json (see docs/river-model.md for the download commands).
Result 2026-11-10: Hòn Dấu → Ba Lạt 0 h (r 0,995); Hà Nội lag 8,46 ± 0,34 h;
gauge at 165,6 km from Ba Lạt → ≈ 19,6 km/h.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent / "nchmf"))

from river_backtest import load_bulletins, sea_tide, series

from build_rivers import RIVERS, build_river


def mouth_phase_lag() -> tuple[float, float]:
    t1, v1 = sea_tide("om_hondau.json")
    t2, v2 = sea_tide("om_balat.json")
    best = (-2.0, 0.0)
    for lag in np.arange(-3, 3.01, 0.05):
        a = np.interp(t2 - lag, t1, v1)
        m = ~np.isnan(a) & ~np.isnan(v2)
        r = float(np.corrcoef(a[m], v2[m])[0, 1])
        if r > best[0]:
            best = (r, float(lag))
    return best[1], best[0]


def hanoi_lags() -> list[float]:
    obs, fcs = series(load_bulletins(), "HàNội")
    st, sv = sea_tide("om_hondau.json")
    lags = []
    for issued, fc in fcs:
        pts = {
            **{
                t: v
                for t, v in obs.items()
                if t <= issued and (issued - t).total_seconds() <= 48 * 3600
            },
            **fc,
        }
        ts = np.array([t.timestamp() / 3600 for t in sorted(pts)])
        ys = np.array([pts[t] for t in sorted(pts)], float)
        best = None
        for lag in np.arange(0, 24.01, 0.25):
            s = np.interp(ts - lag, st, sv)
            a = np.column_stack([np.ones_like(ts), ts - ts.mean(), s])
            c, *_ = np.linalg.lstsq(a, ys, rcond=None)
            if c[2] <= 0:
                continue
            e = float(np.sum((a @ c - ys) ** 2))
            if best is None or e < best[0]:
                best = (e, float(lag))
        if best:
            lags.append(best[1])
            print(f"{issued.date()} lag {best[1]:.2f} h")
    return lags


def main() -> None:
    lag0, r = mouth_phase_lag()
    print(f"Hòn Dấu → Ba Lạt: {lag0:+.2f} h (r {r:.4f})")
    lags = hanoi_lags()
    mean, std = float(np.mean(lags)), float(np.std(lags))
    hong = build_river(
        RIVERS[0],
        json.loads(
            (HERE / "data" / "raw" / RIVERS[0]["raw"]).read_text(encoding="utf-8")
        ),
    )
    km = hong["stations"]["kttv-ha-noi"]
    print(
        f"Hà Nội lag {mean:.2f} ± {std:.2f} h over {len(lags)} bulletins; gauge at {km:.1f} km"
    )
    print(f"tide-wave speed ≈ {km / (mean - lag0):.1f} km/h")


if __name__ == "__main__":
    main()
