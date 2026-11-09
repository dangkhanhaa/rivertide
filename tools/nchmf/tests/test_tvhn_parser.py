from pathlib import Path

import numpy as np
import pytest

from river_backtest import fit_tide, predict_tide
from tvhn_parser import BulletinError, parse

FIX = Path(__file__).parents[1] / "fixtures"


def _station(d: dict, name: str) -> dict:
    return next(s for s in d["stations"] if s["name"].replace(" ", "") == name)


def test_rotated_table_bulletin_20261106():
    d = parse(FIX / "dbqg_tvhn_20261106_1030.pdf")
    assert d["issued_utc"] == "2026-11-06T03:30:00Z"
    assert len(d["stations"]) == 12
    hn = _station(d, "HàNội")
    assert hn["unit"] == "cm"
    obs = [(p["t"], p["v"]) for p in hn["points"] if p["kind"] == "obs"]
    # 13h 05/11 VN = 06:00 UTC
    assert obs == [
        ("2026-11-05T06:00:00Z", 150),
        ("2026-11-05T12:00:00Z", 181),
        ("2026-11-05T18:00:00Z", 165),
        ("2026-11-06T00:00:00Z", 143),
    ]
    assert len(hn["points"]) == 12
    hb = _station(d, "HồHòaBình")
    assert hb["unit"] == "m3/s"


def test_partial_row_keeps_column_alignment():
    d = parse(FIX / "dbqg_tvhn_20261106_1030.pdf")
    nd = _station(d, "NamĐàn")
    fc = [(p["t"], p["v"]) for p in nd["points"] if p["kind"] == "fc"]
    assert len(fc) == 6
    assert fc[-1] == ("2026-11-07T12:00:00Z", 45)  # 19h 07/11 VN


def test_upright_table_bulletin_20261031():
    d = parse(FIX / "dbqg_tvhn_20261031_1030.pdf")
    hn = _station(d, "HàNội")
    assert [p["v"] for p in hn["points"] if p["kind"] == "obs"] == [215, 173, 132, 125]


def test_tidal_extremes_table():
    d = parse(FIX / "dbqg_tvhn_20261106_1030.pdf")
    by = {e["label"]: e for e in d["tidal_extremes"]}
    assert by["Cầu Đáp Cầu"]["obs_max"] == 116
    assert by["Thái Bình Phả Lại"]["window_h"] == 36
    assert by["Mã Giàng"]["obs_min"] == -29


def test_rejects_other_pdf():
    with pytest.raises(BulletinError):
        parse(FIX / "dbqg-tthv-20261106_0930.pdf")


def test_tide_model_recovers_lag_and_gain():
    st = np.arange(0, 400, 1.0)
    sv = 80 * np.sin(2 * np.pi * st / 24.84)
    ts = np.arange(100, 300, 6.0)
    ys = 150 + 0.1 * (ts - ts.mean()) + 0.5 * np.interp(ts - 9, st, sv)
    m = fit_tide(ts, ys, st, sv)
    assert m[1] == 9
    assert (
        abs(
            predict_tide(m, 203.0, st, sv)
            - (150 + 0.1 * (203 - ts.mean()) + 0.5 * np.interp(194, st, sv))
        )
        < 1e-6
    )
