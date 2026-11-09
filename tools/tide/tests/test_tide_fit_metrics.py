import numpy as np
import pandas as pd
import pytest

import metrics
import tide_fit

M2_HOURS = 12.4206012


def synthetic(days: int = 60, amp: float = 100.0, mean: float = 200.0) -> pd.Series:
    index = pd.date_range("2025-01-01", periods=days * 144, freq="10min", tz="UTC")
    hours = (index - index[0]).total_seconds() / 3600
    return pd.Series(mean + amp * np.cos(2 * np.pi * hours / M2_HOURS), index=index)


def test_fit_recovers_m2_and_predicts():
    s = synthetic()
    coef = tide_fit.fit(s, lat=10.0)
    m2 = list(coef.name).index("M2")
    # Nodal correction reports the 18.6-year mean amplitude; M2 factor f≈0.96 in 2025.
    assert coef.A[m2] == pytest.approx(100.0 / 0.963, rel=0.01)
    assert metrics.rmse(s, tide_fit.predict(coef, s.index)) < 1.0


def test_find_extremes_timing_is_refined_below_step():
    s = synthetic(days=2)
    highs = [e for e in tide_fit.find_extremes(s) if e.kind == "H"]
    expected = s.index[0] + pd.Timedelta(hours=M2_HOURS)
    assert abs((highs[0].time - expected).total_seconds()) < 60
    assert highs[0].level_cm == pytest.approx(300.0, abs=0.5)


def test_remove_spikes_drops_glitch():
    s = synthetic(days=1)
    s.iloc[50] += 80
    assert np.isnan(tide_fit.remove_spikes(s).iloc[50])


def test_match_extremes_reports_shift():
    s = synthetic(days=3)
    shifted = s.shift(2)  # observed 20 minutes later
    pairs = metrics.match_extremes(
        tide_fit.find_extremes(s), tide_fit.find_extremes(shifted)
    )
    assert pairs["dt_min"].median() == pytest.approx(20.0, abs=1.0)


def test_direction_accuracy_perfect_for_identical_series():
    s = synthetic(days=3)
    assert metrics.direction_accuracy(s, s) == 1.0


def test_correction_helps_constant_bias():
    s = synthetic(days=5)
    obs = s + 30
    out = metrics.corrected_rmse_by_lead(s, obs, [1, 12])
    assert out[1]["corrected_cm"] < out[1]["raw_cm"]
    assert out[12]["corrected_cm"] == pytest.approx(out[12]["raw_cm"])


def test_compare_bulletin_removes_datum_offset():
    index = pd.date_range("2026-11-05", periods=3 * 144, freq="10min", tz="UTC")
    s = pd.Series(np.zeros(len(index)), index=index)
    peak = pd.Timestamp("2026-11-06 10:00", tz="Asia/Ho_Chi_Minh").tz_convert("UTC")
    trough = pd.Timestamp("2026-11-06 16:00", tz="Asia/Ho_Chi_Minh").tz_convert("UTC")
    s[peak], s[trough] = 50.0, -50.0
    bulletin = {"h_cm": [150], "h_time": ["10:00"], "l_cm": [50], "l_time": ["16:00"]}
    df = metrics.compare_bulletin(s, bulletin, ["2026-11-06"])
    assert df.attrs["datum_offset_cm"] == pytest.approx(100.0)
    assert df["dt_min"].abs().max() == 0
    assert df["dh_cm"].abs().max() == 0
