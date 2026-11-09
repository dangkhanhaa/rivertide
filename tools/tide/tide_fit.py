"""Load IOC 10-minute series, quality-control it, fit tidal constituents, predict.

Times are UTC everywhere; levels are integer-ish centimetres on the IOC sensor datum.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np
import pandas as pd
import utide
from scipy.signal import find_peaks

STEP = "10min"
MIN_SAMPLES_PER_BIN = 5  # of 10 one-minute samples
SPIKE_CM = 25
EXTREME_PROMINENCE_CM = 5
EXTREME_MIN_GAP_H = 2


@dataclass(frozen=True)
class Extreme:
    time: pd.Timestamp
    level_cm: float
    kind: str  # "H" or "L"


def load_series(csv_path: str, sensor: str) -> pd.Series:
    """10-minute level series (cm) for one sensor, QC applied, gaps left as NaN."""
    df = pd.read_csv(csv_path, parse_dates=["time"])
    df = df[(df["sensor"] == sensor) & (df["n"] >= MIN_SAMPLES_PER_BIN)]
    s = df.set_index("time")["level_cm"].astype(float).sort_index()
    s = s[~s.index.duplicated()]
    full_index = pd.date_range(s.index[0], s.index[-1], freq=STEP, tz="UTC")
    s = s.reindex(full_index)
    return remove_spikes(s)


def remove_spikes(s: pd.Series) -> pd.Series:
    """Drop points far from the local 1-hour median (sensor glitches)."""
    median = s.rolling(7, center=True, min_periods=4).median()
    return s.where((s - median).abs() <= SPIKE_CM)


def completeness(s: pd.Series) -> float:
    return float(s.notna().mean())


def _naive(index: pd.DatetimeIndex) -> np.ndarray:
    return index.tz_convert("UTC").tz_localize(None).to_numpy()


def fit(s: pd.Series, lat: float) -> utide.utilities.Bunch:
    s = s.dropna()
    return utide.solve(
        _naive(s.index),
        s.to_numpy(),
        lat=lat,
        method="ols",
        conf_int="linear",
        constit="auto",
        nodal=True,
        trend=False,
        verbose=False,
    )


def predict(coef: utide.utilities.Bunch, index: pd.DatetimeIndex) -> pd.Series:
    rec = utide.reconstruct(_naive(index), coef, verbose=False)
    return pd.Series(rec.h, index=index)


def find_extremes(s: pd.Series, smooth: bool = False) -> list[Extreme]:
    """Highs and lows; parabolic refinement gives sub-step timing."""
    values = s.interpolate(limit=3)
    if smooth:
        values = values.rolling(3, center=True, min_periods=2).mean()
    arr = values.to_numpy()
    step_s = (s.index[1] - s.index[0]).total_seconds()
    distance = int(EXTREME_MIN_GAP_H * 3600 / step_s)
    out: list[Extreme] = []
    for kind, sign in (("H", 1.0), ("L", -1.0)):
        filled = np.nan_to_num(sign * arr, nan=-1e9)
        peaks, _ = find_peaks(
            filled, prominence=EXTREME_PROMINENCE_CM, distance=distance
        )
        for i in peaks:
            if 0 < i < len(arr) - 1 and not np.isnan(arr[i - 1 : i + 2]).any():
                out.append(_refine(s.index[i], arr[i - 1 : i + 2], step_s, kind))
    return sorted(out, key=lambda e: e.time)


def _refine(t: pd.Timestamp, y: np.ndarray, step_s: float, kind: str) -> Extreme:
    denom = y[0] - 2 * y[1] + y[2]
    offset = 0.0 if denom == 0 else 0.5 * (y[0] - y[2]) / denom
    offset = float(np.clip(offset, -1, 1))
    level = y[1] - 0.25 * (y[0] - y[2]) * offset
    return Extreme(t + pd.Timedelta(seconds=offset * step_s), float(level), kind)
