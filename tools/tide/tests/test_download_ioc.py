import json
from pathlib import Path

import pytest

from download_ioc import parse_records, to_10min

FIXTURES = (
    Path(__file__).parents[3] / "supabase" / "functions" / "ingest-ioc" / "__fixtures__"
)


def test_parse_keeps_only_wanted_sensors():
    records = json.loads((FIXTURES / "vung_20261104.json").read_text(encoding="utf-8"))
    df = parse_records(records, {"ra2"})
    assert set(df["sensor"]) == {"ra2"}
    assert len(df) > 1000  # 1-minute data for one day
    assert str(df["time"].dt.tz) == "UTC"


def test_parse_rejects_non_list():
    with pytest.raises(TypeError):
        parse_records({"error": "x"}, {"ra2"})


def test_parse_drops_bad_rows():
    records = [
        {"slevel": 1.5, "stime": "2026-11-04 00:01:00", "sensor": "ra2"},
        {"slevel": "abc", "stime": "2026-11-04 00:02:00", "sensor": "ra2"},
        {"slevel": 999.0, "stime": "2026-11-04 00:03:00", "sensor": "ra2"},
        {"slevel": 1.0, "stime": None, "sensor": "ra2"},
        "garbage",
    ]
    assert len(parse_records(records, {"ra2"})) == 1


def test_to_10min_means_in_cm():
    records = [
        {"slevel": 1.00, "stime": "2026-11-04 00:01:00", "sensor": "ra2"},
        {"slevel": 1.02, "stime": "2026-11-04 00:05:00", "sensor": "ra2"},
        {"slevel": 2.00, "stime": "2026-11-04 00:11:00", "sensor": "ra2"},
    ]
    out = to_10min(parse_records(records, {"ra2"}))
    assert out["level_cm"].tolist() == [101, 200]
    assert out["n"].tolist() == [2, 1]
