"""One-time extraction of Vietnam's administrative units (after the 2025
reform: 34 provinces, ~3 300 wards/communes) with simplified boundaries.

Source: OpenStreetMap via Overpass (ODbL; the app credits OpenStreetMap).
Run by hand when boundaries change, never from the app. Output:
app/assets/data/admin.json =
  {"p": [[name, rings], ...],                               provinces
   "c": [[name, provinceIndex, lat, lon, rings], ...]}       wards/communes
where rings = [[lat, lon, lat, lon, ...], ...] (outer rings only, 4 decimals,
Douglas–Peucker simplified) — enough to tell which commune a point is in.
"""

import http.client
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ENDPOINT = "https://overpass-api.de/api/interpreter"
USER_AGENT = "RiverTide-places-extract/0.1 (+https://github.com/dangkhanhaa/rivertide)"
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "data" / "admin.json"

# ~110 m: borders stay where they are on a phone map, file stays small.
TOLERANCE_DEG = 0.001


def overpass(query: str, attempts: int = 5) -> list[dict]:
    data = urllib.parse.urlencode({"data": query}).encode()
    for i in range(attempts):
        try:
            req = urllib.request.Request(ENDPOINT, data=data, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=600) as r:
                return json.load(r)["elements"]
        except urllib.error.HTTPError as e:
            if e.code not in (429, 502, 503, 504) or i == attempts - 1:
                raise
            print(f"  HTTP {e.code}, retry in {60 * (i + 1)} s", file=sys.stderr)
            time.sleep(60 * (i + 1))
        except (http.client.IncompleteRead, ConnectionError, TimeoutError) as e:
            if i == attempts - 1:
                raise
            print(f"  cut off ({type(e).__name__}), retry in {30 * (i + 1)} s", file=sys.stderr)
            time.sleep(30 * (i + 1))
    return []


def stitch(ways: list[list[tuple[float, float]]]) -> list[list[tuple[float, float]]]:
    """Joins outer-member ways end to end into closed rings."""
    rings: list[list[tuple[float, float]]] = []
    pool = [w[:] for w in ways if len(w) >= 2]
    while pool:
        ring = pool.pop(0)
        changed = True
        while ring[0] != ring[-1] and changed:
            changed = False
            for k, w in enumerate(pool):
                if w[0] == ring[-1]:
                    ring += w[1:]
                elif w[-1] == ring[-1]:
                    ring += w[::-1][1:]
                elif w[-1] == ring[0]:
                    ring = w[:-1] + ring
                elif w[0] == ring[0]:
                    ring = w[::-1][:-1] + ring
                else:
                    continue
                pool.pop(k)
                changed = True
                break
        if len(ring) >= 4:
            rings.append(ring)
    return rings


def simplify(pts: list[tuple[float, float]], tol: float) -> list[tuple[float, float]]:
    """Douglas–Peucker, iterative."""
    if len(pts) < 3:
        return pts
    keep = [False] * len(pts)
    keep[0] = keep[-1] = True
    stack = [(0, len(pts) - 1)]
    while stack:
        a, b = stack.pop()
        (ay, ax), (by, bx) = pts[a], pts[b]
        dx, dy = bx - ax, by - ay
        norm = (dx * dx + dy * dy) ** 0.5
        best, idx = 0.0, -1
        for i in range(a + 1, b):
            py, px = pts[i]
            d = abs(dy * (px - ax) - dx * (py - ay)) / norm if norm else ((px - ax) ** 2 + (py - ay) ** 2) ** 0.5
            if d > best:
                best, idx = d, i
        if best > tol and idx > 0:
            keep[idx] = True
            stack += [(a, idx), (idx, b)]
    return [p for p, k in zip(pts, keep) if k]


def rings_of(rel: dict) -> list[list[float]]:
    ways = [
        [(round(g["lat"], 5), round(g["lon"], 5)) for g in m.get("geometry", [])]
        for m in rel.get("members", [])
        if m.get("type") == "way" and m.get("role", "outer") in ("outer", "")
    ]
    out = []
    for ring in stitch(ways):
        s = simplify(ring, TOLERANCE_DEG)
        if len(s) >= 4:
            out.append([v for lat, lon in s for v in (round(lat, 4), round(lon, 4))])
    return out


def inside(lat: float, lon: float, rings: list[list[float]]) -> bool:
    hit = False
    for r in rings:
        n = len(r) // 2
        for i in range(n):
            y1, x1, y2, x2 = r[2 * i], r[2 * i + 1], r[(2 * i + 2) % (2 * n)], r[(2 * i + 3) % (2 * n)]
            if (y1 > lat) != (y2 > lat) and lon < (x2 - x1) * (lat - y1) / (y2 - y1) + x1:
                hit = not hit
    return hit


def centre(rings: list[list[float]]) -> tuple[float, float]:
    r = max(rings, key=len)
    ys, xs = r[0::2], r[1::2]
    return round(sum(ys) / len(ys), 4), round(sum(xs) / len(xs), 4)


def main() -> int:
    area = 'area["ISO3166-1"="VN"][admin_level=2]->.vn;'
    provs = overpass(f'[out:json][timeout:600];{area}relation["boundary"="administrative"]["admin_level"="4"](area.vn);out geom;')
    provinces = [(p["tags"]["name"], rings_of(p)) for p in provs if p.get("tags", {}).get("name")]
    print(f"provinces: {len(provinces)}", file=sys.stderr)
    # Per province: one request for the whole country is >100 MB and gets cut.
    seen: set[int] = set()
    communes = []
    for k, p in enumerate(provs):
        time.sleep(5)
        comms = overpass(
            f'[out:json][timeout:600];rel({p["id"]});map_to_area->.p;'
            'relation["boundary"="administrative"]["admin_level"="6"](area.p);out geom;'
        )
        for c in comms:
            name = c.get("tags", {}).get("name")
            if c["id"] in seen or not name:
                continue
            rings = rings_of(c)
            if not rings:
                continue
            lat, lon = centre(rings)
            # Border communes come back for both neighbours: keep the one holding the centre.
            pi = next((i for i, (_, pr) in enumerate(provinces) if inside(lat, lon, pr)), -1)
            if pi < 0:
                continue
            seen.add(c["id"])
            communes.append([name, pi, lat, lon, rings])
        print(f"  {k + 1}/{len(provs)} {p['tags'].get('name')}: total {len(communes)}", file=sys.stderr)
    print(f"communes: {len(communes)} ({sum(1 for c in communes if c[1] < 0)} without province)", file=sys.stderr)
    OUT.write_text(
        json.dumps({"p": [[n, r] for n, r in provinces], "c": communes}, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    print(f"wrote {OUT.stat().st_size // 1024} KB -> {OUT}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
