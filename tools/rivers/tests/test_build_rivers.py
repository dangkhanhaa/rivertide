import json
from pathlib import Path

import pytest

from build_rivers import (
    RIVERS,
    build_river,
    chain,
    chainage,
    haversine_km,
    project,
    simplify,
)

RAW = Path(__file__).parents[1] / "data" / "raw"


def test_haversine_one_degree_latitude():
    assert haversine_km((10, 106), (11, 106)) == pytest.approx(111.2, abs=0.1)


def test_chain_flips_ways_and_rejects_gaps():
    a = [(0.0, 0.0), (0.0, 0.01)]
    b = [(0.0, 0.02), (0.0, 0.01)]  # stored backwards
    assert chain([a, b], (0.0, 0.0)) == [(0.0, 0.0), (0.0, 0.01), (0.0, 0.02)]
    with pytest.raises(ValueError):
        chain([a, [(1.0, 1.0), (1.0, 1.01)]], (0.0, 0.0))


def test_simplify_keeps_ends_and_corners():
    line = [(0.0, 0.0), (0.0, 0.005), (0.0, 0.01), (0.01, 0.01)]
    assert simplify(line, 30) == [0, 2, 3]


def test_project_midpoint():
    line = [(0.0, 0.0), (0.0, 0.1)]
    off, at = project(line, chainage(line), (0.001, 0.05))
    assert off == pytest.approx(0.111, abs=0.005)
    assert at == pytest.approx(5.56, abs=0.02)


@pytest.mark.skipif(
    not (RAW / "ov_hong.json").exists(), reason="raw OSM extract not present"
)
def test_red_river_from_ba_lat():
    r = build_river(
        RIVERS[0], json.loads((RAW / "ov_hong.json").read_text(encoding="utf-8"))
    )
    km = [p[2] for p in r["points"]]
    assert km == sorted(km) and km[0] == 0
    assert 300 < km[-1] < 320  # Ba Lạt → above Việt Trì
    assert r["stations"]["kttv-ha-noi"] == pytest.approx(165.6, abs=0.5)
