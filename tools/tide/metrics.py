"""Accuracy metrics for tide predictions against observations and KTTV bulletins."""

from __future__ import annotations

import numpy as np
import pandas as pd

from tide_fit import Extreme, find_extremes

VN_TZ = "Asia/Ho_Chi_Minh"
MATCH_WINDOW_H = 3
SLACK_CM_PER_H = 3
CORRECTION_HORIZON_H = 12
BOUNDARY_TIMES = {"00:00", "23:59"}  # bulletin daily max/min clipped at day edge


def rmse(a: pd.Series, b: pd.Series) -> float:
    d = (a - b).dropna()
    return float(np.sqrt((d**2).mean()))


def match_extremes(pred: list[Extreme], obs: list[Extreme]) -> pd.DataFrame:
    """Pair each predicted extreme with the nearest observed one of the same kind."""
    rows = []
    for p in pred:
        same = [o for o in obs if o.kind == p.kind]
        if not same:
            continue
        o = min(same, key=lambda e: abs((e.time - p.time).total_seconds()))
        dt_min = (o.time - p.time).total_seconds() / 60
        if abs(dt_min) <= MATCH_WINDOW_H * 60:
            rows.append(
                {"kind": p.kind, "dt_min": dt_min, "dh_cm": o.level_cm - p.level_cm}
            )
    return pd.DataFrame(rows, columns=["kind", "dt_min", "dh_cm"])


def direction_accuracy(pred: pd.Series, obs: pd.Series) -> float:
    """Share of hours where predicted rise/fall matches observed (slack hours skipped)."""
    p = pred.resample("1h").mean().diff()
    o = obs.resample("1h").mean().diff()
    mask = o.abs() >= SLACK_CM_PER_H
    both = pd.concat([p[mask], o[mask]], axis=1).dropna()
    return float((np.sign(both.iloc[:, 0]) == np.sign(both.iloc[:, 1])).mean())


def corrected_rmse_by_lead(pred: pd.Series, obs: pd.Series, leads_h: list[int]) -> dict:
    """RMSE of raw vs residual-corrected forecast (F-TIDE-07) at each lead time."""
    hourly_obs = obs.resample("1h").mean()
    hourly_pred = pred.resample("1h").mean()
    bias = (hourly_obs - hourly_pred).dropna()
    out = {}
    for lead in leads_h:
        target = bias.index + pd.Timedelta(hours=lead)
        decay = max(0.0, 1 - lead / CORRECTION_HORIZON_H)
        p = hourly_pred.reindex(target).to_numpy()
        o = hourly_obs.reindex(target).to_numpy()
        ok = ~np.isnan(p) & ~np.isnan(o)
        raw = o[ok] - p[ok]
        corr = raw - bias.to_numpy()[ok] * decay
        out[lead] = {
            "raw_cm": float(np.sqrt((raw**2).mean())),
            "corrected_cm": float(np.sqrt((corr**2).mean())),
        }
    return out


def _nearest_extreme(
    extremes: list[Extreme], t: pd.Timestamp, kind: str
) -> tuple[pd.Timestamp, float] | None:
    same = [e for e in extremes if e.kind == kind]
    if not same:
        return None
    best = min(same, key=lambda e: abs((e.time - t).total_seconds()))
    if abs((best.time - t).total_seconds()) > MATCH_WINDOW_H * 3600:
        return None
    return best.time, best.level_cm


def daily_extremes(
    s: pd.Series, day: str, kind: str
) -> tuple[pd.Timestamp, float] | None:
    """Highest or lowest value inside one local (VN) calendar day, like the bulletin."""
    start = pd.Timestamp(day, tz=VN_TZ).tz_convert("UTC")
    window = s[
        start : start + pd.Timedelta(hours=24) - pd.Timedelta(minutes=1)
    ].dropna()
    if len(window) < 130:  # need a nearly full day of 10-minute values
        return None
    idx = window.idxmax() if kind == "H" else window.idxmin()
    return idx, float(window[idx])


def compare_bulletin(s: pd.Series, bulletin: dict, dates: list[str]) -> pd.DataFrame:
    """Time (min) and height (cm) differences vs the KTTV daily max/min bulletin.

    Each bulletin value is paired with the nearest predicted high/low of the same kind
    (within 3 h). Comparing daily maxima directly is wrong for semidiurnal stations
    whose two highs are nearly equal: each side may pick a different one.
    """
    extremes = find_extremes(s)
    rows = []
    for i, day in enumerate(dates):
        for kind, hk, tk in (("H", "h_cm", "h_time"), ("L", "l_cm", "l_time")):
            b_time = pd.Timestamp(f"{day} {bulletin[tk][i]}", tz=VN_TZ)
            got = _nearest_extreme(extremes, b_time, kind)
            if got is None:
                continue
            rows.append(
                {
                    "date": day,
                    "kind": kind,
                    "boundary": bulletin[tk][i] in BOUNDARY_TIMES,
                    "dt_min": (got[0] - b_time).total_seconds() / 60,
                    "ours_cm": got[1],
                    "bulletin_cm": bulletin[hk][i],
                }
            )
    df = pd.DataFrame(rows)
    if not df.empty:
        offset = float((df["bulletin_cm"] - df["ours_cm"]).median())
        df["dh_cm"] = df["ours_cm"] + offset - df["bulletin_cm"]
        df.attrs["datum_offset_cm"] = offset
    return df
