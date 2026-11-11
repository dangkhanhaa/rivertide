"""One-time extraction of Vietnamese place names for the in-app search.

Source: OpenStreetMap via the Overpass API (ODbL; the app credits
OpenStreetMap). One query per kind, run by hand when the list needs a
refresh, never from the app. Output: app/assets/data/places.json as
[[name, kind, lat, lon], ...] with lat/lon rounded to 4 decimals (~11 m).
"""

import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ENDPOINT = "https://overpass-api.de/api/interpreter"
USER_AGENT = "RiverTide-places-extract/0.1 (+https://github.com/dangkhanhaa/rivertide)"
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "data" / "places.json"

# kind -> Overpass selector inside the Vietnam area.
QUERIES = {
    "city": 'node["place"~"^(city|town)$"]["name"](area.vn);',
    "ward": 'node["place"~"^(suburb|quarter|village)$"]["name"](area.vn);',
    "bridge": 'way["bridge"="yes"]["name"~"^Cầu "]["highway"~"^(motorway|trunk|primary|secondary|tertiary|unclassified|residential)$"](area.vn);',
    "ferry": 'nwr["amenity"="ferry_terminal"]["name"](area.vn);',
    "wharf": 'nwr["name"~"^Bến "](area.vn);',
}


def run(selector: str, attempts: int = 4) -> list[dict]:
    for i in range(attempts):
        try:
            return _run_once(selector)
        except urllib.error.HTTPError as e:
            # 429/502/504: the shared server is busy; back off and retry.
            if e.code not in (429, 502, 503, 504) or i == attempts - 1:
                raise
            print(f"  HTTP {e.code}, retry in {60 * (i + 1)} s", file=sys.stderr)
            time.sleep(60 * (i + 1))
    return []


def _run_once(selector: str) -> list[dict]:
    q = f'[out:json][timeout:300];area["ISO3166-1"="VN"][admin_level=2]->.vn;({selector});out center tags;'
    data = urllib.parse.urlencode({"data": q}).encode()
    req = urllib.request.Request(ENDPOINT, data=data, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=400) as r:
        return json.load(r)["elements"]


def main() -> int:
    seen: set[tuple[str, float, float]] = set()
    rows: list[list] = []
    for kind, sel in QUERIES.items():
        elements = run(sel)
        n = 0
        for e in elements:
            name = (e.get("tags") or {}).get("name", "").strip()
            lat = e.get("lat", (e.get("center") or {}).get("lat"))
            lon = e.get("lon", (e.get("center") or {}).get("lon"))
            if not name or lat is None or lon is None or len(name) > 80:
                continue
            if not (8.0 <= lat <= 23.5 and 102.0 <= lon <= 110.0):
                continue
            # Bridges are split into many road segments: keep one per ~1 km.
            key = (name, round(lat, 2), round(lon, 2))
            if key in seen:
                continue
            seen.add(key)
            rows.append([name, kind, round(lat, 4), round(lon, 4)])
            n += 1
        print(f"{kind}: {len(elements)} elements -> {n} places", file=sys.stderr)
        time.sleep(10)  # be gentle with the shared Overpass server
    rows.sort(key=lambda r: (r[0], r[1]))
    OUT.write_text(json.dumps(rows, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"wrote {len(rows)} places, {OUT.stat().st_size // 1024} KB -> {OUT}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
