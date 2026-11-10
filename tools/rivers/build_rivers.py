"""Build river centre-lines with along-river distance (km from the mouth).

Input: Overpass JSON (``data/raw/ov_*.json``, ``way[waterway=river] ... out geom``),
fetched once — © OpenStreetMap contributors, ODbL.
Output: ``app/assets/data/rivers.json``::

    {"version": 1, "source": "...", "rivers": [
      {"id": "hong", "name": "Hồng", "mouth": "Ba Lạt",
       "points": [[lat, lon, km], ...],          # mouth first, km increasing upstream
       "stations": {"kttv-ha-noi": km, ...}}]}

Chainage is measured on the full OSM geometry, then the line is simplified
(Douglas-Peucker) keeping each kept vertex's true km.
"""

from __future__ import annotations

import itertools
import json
import math
from pathlib import Path

HERE = Path(__file__).parent
ASSET = HERE.parents[1] / "app" / "assets" / "data" / "rivers.json"
SIMPLIFY_M = 30.0
MAX_STATION_OFFSET_KM = 1.5  # a station farther from the line is not on this river

# Main stem only, listed from the mouth upstream (OSM way ids, checked 2026-11-10).
RIVERS = [
    {
        "id": "hong",
        "name": "Hồng",
        "mouth": "Ba Lạt",
        "raw": "ov_hong.json",
        "ways": [53504832, 654611724, 482022567],
        "mouth_point": (20.244, 106.589),
        "stations": {"kttv-ha-noi": (21.045, 105.860)},
    },
    {
        "id": "ca",
        "name": "Cả (Lam)",
        "mouth": "Cửa Hội",
        "raw": "ov_ca.json",
        "ways": [478435878, 478374820],
        "mouth_point": (18.764, 105.763),
        "stations": {"kttv-nam-dan": (18.700, 105.500)},
    },
]

Point = tuple[float, float]


def haversine_km(a: Point, b: Point) -> float:
    la1, lo1, la2, lo2 = map(math.radians, (*a, *b))
    h = (
        math.sin((la2 - la1) / 2) ** 2
        + math.cos(la1) * math.cos(la2) * math.sin((lo2 - lo1) / 2) ** 2
    )
    return 2 * 6371.0088 * math.asin(math.sqrt(min(1.0, h)))


def chain(ways: list[list[Point]], start: Point) -> list[Point]:
    """Join ways end to end starting at ``start``, flipping each as needed."""
    line: list[Point] = []
    end = start
    for w in ways:
        if haversine_km(w[-1], end) < haversine_km(w[0], end):
            w = w[::-1]
        if line and haversine_km(line[-1], w[0]) > 0.05:
            raise ValueError(
                f"gap of {haversine_km(line[-1], w[0]):.2f} km between ways"
            )
        line.extend(w[1:] if line else w)
        end = line[-1]
    return line


def chainage(line: list[Point]) -> list[float]:
    km = [0.0]
    for a, b in itertools.pairwise(line):
        km.append(km[-1] + haversine_km(a, b))
    return km


def _seg_dist_m(p: Point, a: Point, b: Point) -> float:
    kx = 111_320 * math.cos(math.radians(a[0]))
    ky = 110_574
    bx, by = (b[1] - a[1]) * kx, (b[0] - a[0]) * ky
    px, py = (p[1] - a[1]) * kx, (p[0] - a[0]) * ky
    l2 = bx * bx + by * by
    t = 0.0 if l2 == 0 else max(0.0, min(1.0, (px * bx + py * by) / l2))
    return math.hypot(px - t * bx, py - t * by)


def simplify(line: list[Point], tol_m: float) -> list[int]:
    """Indices kept by Douglas-Peucker (iterative)."""
    keep = {0, len(line) - 1}
    stack = [(0, len(line) - 1)]
    while stack:
        i, j = stack.pop()
        best, idx = 0.0, -1
        for k in range(i + 1, j):
            d = _seg_dist_m(line[k], line[i], line[j])
            if d > best:
                best, idx = d, k
        if best > tol_m:
            keep.add(idx)
            stack += [(i, idx), (idx, j)]
    return sorted(keep)


def project(line: list[Point], km: list[float], p: Point) -> tuple[float, float]:
    """(distance to the line, km along it) of the closest point."""
    best = (math.inf, 0.0)
    for i in range(len(line) - 1):
        a, b = line[i], line[i + 1]
        kx = 111.32 * math.cos(math.radians(a[0]))
        ky = 110.574
        bx, by = (b[1] - a[1]) * kx, (b[0] - a[0]) * ky
        px, py = (p[1] - a[1]) * kx, (p[0] - a[0]) * ky
        l2 = bx * bx + by * by
        t = 0.0 if l2 == 0 else max(0.0, min(1.0, (px * bx + py * by) / l2))
        d = math.hypot(px - t * bx, py - t * by)
        if d < best[0]:
            best = (d, km[i] + t * (km[i + 1] - km[i]))
    return best


def build_river(cfg: dict, raw: dict) -> dict:
    by_id = {e["id"]: e for e in raw["elements"]}
    ways = [[(p["lat"], p["lon"]) for p in by_id[w]["geometry"]] for w in cfg["ways"]]
    line = chain(ways, cfg["mouth_point"])
    km = chainage(line)
    stations = {}
    for sid, pos in cfg["stations"].items():
        off, at = project(line, km, pos)
        if off > MAX_STATION_OFFSET_KM:
            raise ValueError(f"{sid} is {off:.2f} km from the {cfg['id']} line")
        stations[sid] = round(at, 2)
    kept = simplify(line, SIMPLIFY_M)
    return {
        "id": cfg["id"],
        "name": cfg["name"],
        "mouth": cfg["mouth"],
        "points": [
            [round(line[i][0], 5), round(line[i][1], 5), round(km[i], 3)] for i in kept
        ],
        "stations": stations,
    }


def main() -> None:
    rivers = [
        build_river(
            c,
            json.loads((HERE / "data" / "raw" / c["raw"]).read_text(encoding="utf-8")),
        )
        for c in RIVERS
    ]
    out = {
        "version": 1,
        "source": "© OpenStreetMap contributors (ODbL), main stem only",
        "rivers": rivers,
    }
    ASSET.write_text(
        json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8"
    )
    for r in rivers:
        print(
            f"{r['id']}: {len(r['points'])} pts, {r['points'][-1][2]:.1f} km, stations {r['stations']}"
        )


if __name__ == "__main__":
    main()
