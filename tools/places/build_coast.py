"""One-time extraction of Vietnam's sea coast for "how far is the sea" (P2-48).

Source: Natural Earth 1:10m coastline (public domain, naturalearthdata.com),
file ne_10m_coastline.geojson from github.com/nvkelso/natural-earth-vector.
Run by hand, never from the app:

    python build_coast.py <path/to/ne_10m_coastline.geojson>

Output: app/assets/data/coast.json =
  {"source": ..., "lines": [[lat, lon, lat, lon, ...], ...]}
Lines are clipped to the Vietnam area (with the Gulf of Tonkin, Gulf of
Thailand and the islands) and Douglas–Peucker simplified to ~300 m, which is
plenty for thresholds of 10–15 km and keeps the file small.
"""

import json
import sys
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "data" / "coast.json"

# lat/lon box: mainland + Phú Quốc, Côn Đảo, Hoàng Sa, Trường Sa, with margin
# so the nearest coast of points near the border is never cut off.
MIN_LAT, MAX_LAT = 6.0, 24.5
MIN_LON, MAX_LON = 101.0, 117.5

TOLERANCE_DEG = 0.003


def _dp(points: list[tuple[float, float]], tol: float) -> list[tuple[float, float]]:
    """Douglas–Peucker on (lat, lon) pairs, iterative to avoid deep recursion."""
    if len(points) < 3:
        return points
    keep = [False] * len(points)
    keep[0] = keep[-1] = True
    stack = [(0, len(points) - 1)]
    while stack:
        a, b = stack.pop()
        (y1, x1), (y2, x2) = points[a], points[b]
        dx, dy = x2 - x1, y2 - y1
        norm = (dx * dx + dy * dy) ** 0.5
        best, idx = 0.0, -1
        for i in range(a + 1, b):
            y, x = points[i]
            d = abs(dy * x - dx * y + x2 * y1 - y2 * x1) / norm if norm else ((x - x1) ** 2 + (y - y1) ** 2) ** 0.5
            if d > best:
                best, idx = d, i
        if idx >= 0 and best > tol:
            keep[idx] = True
            stack += [(a, idx), (idx, b)]
    return [p for p, k in zip(points, keep) if k]


def _inside(lat: float, lon: float) -> bool:
    return MIN_LAT <= lat <= MAX_LAT and MIN_LON <= lon <= MAX_LON


def main(src: str) -> None:
    data = json.loads(Path(src).read_text(encoding="utf-8"))
    lines: list[list[float]] = []
    for f in data["features"]:
        g = f["geometry"]
        parts = g["coordinates"] if g["type"] == "MultiLineString" else [g["coordinates"]]
        for part in parts:
            run: list[tuple[float, float]] = []
            for lon, lat in part:
                if _inside(lat, lon):
                    run.append((lat, lon))
                    continue
                if len(run) >= 2:
                    lines.append(run)
                run = []
            if len(run) >= 2:
                lines.append(run)
    out = []
    for run in lines:
        simple = _dp(run, TOLERANCE_DEG)
        out.append([round(v, 4) for p in simple for v in p])
    OUT.write_text(
        json.dumps(
            {"source": "Natural Earth 1:10m coastline (public domain)", "lines": out},
            separators=(",", ":"),
        ),
        encoding="utf-8",
    )
    print(f"{len(out)} lines, {sum(len(l) // 2 for l in out)} points -> {OUT}")


if __name__ == "__main__":
    main(sys.argv[1])
