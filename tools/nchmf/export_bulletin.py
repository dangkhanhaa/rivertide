"""Merge parsed TVHN bulletins into the compact JSON the app reads.

Observations: every bulletin within HISTORY_DAYS of the newest (deduplicated by time).
Forecasts and tidal-river extremes: newest bulletin only.
Writes ``app/assets/data/kttv_tvhn.json`` (bundled fallback) and, with
``--out``, the file published for the app to download.
"""

from __future__ import annotations

import argparse
import glob
import json
from datetime import datetime, timedelta
from pathlib import Path

HERE = Path(__file__).parent
ASSET = HERE.parents[1] / "app" / "assets" / "data" / "kttv_tvhn.json"
HISTORY_DAYS = 10


def _key(name: str) -> str:
    return name.replace(" ", "")


def merge(bulletins: list[dict]) -> dict:
    if not bulletins:
        raise ValueError("no bulletins")
    bulletins = sorted(bulletins, key=lambda b: b["issued_utc"])
    newest = bulletins[-1]
    cutoff = datetime.fromisoformat(newest["issued_utc"]) - timedelta(days=HISTORY_DAYS)
    stations: dict[str, dict] = {}
    for b in bulletins:
        is_newest = b is newest
        for st in b["stations"]:
            entry = stations.setdefault(
                _key(st["name"]), {"unit": st["unit"], "obs": {}, "fc": {}}
            )
            for p in st["points"]:
                t = datetime.fromisoformat(p["t"])
                if p["kind"] == "obs" and t >= cutoff:
                    entry["obs"][p["t"]] = p["v"]
                elif p["kind"] == "fc" and is_newest:
                    entry["fc"][p["t"]] = p["v"]
    out_st = {}
    for key, e in stations.items():
        pts = [{"t": t, "v": v, "k": "o"} for t, v in sorted(e["obs"].items())]
        pts += [
            {"t": t, "v": v, "k": "f"}
            for t, v in sorted(e["fc"].items())
            if t not in e["obs"]
        ]
        out_st[key] = {"unit": e["unit"], "points": pts}
    daily = {
        _key(x["label"]): {
            k: x[k] for k in ("window_h", "obs_max", "obs_min", "fc_max", "fc_min")
        }
        for x in newest["tidal_extremes"]
    }
    return {
        "version": 1,
        "source": "Trung tâm Dự báo KTTV quốc gia — bản tin dự báo thủy văn hạn ngắn",
        "issued_utc": newest["issued_utc"],
        "stations": out_st,
        "daily": daily,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in-dir", default=str(HERE / "output"))
    ap.add_argument("--out", default=str(ASSET))
    args = ap.parse_args()
    files = sorted(glob.glob(str(Path(args.in_dir) / "dbqg_tvhn_*.json")))
    data = merge([json.loads(Path(f).read_text(encoding="utf-8")) for f in files])
    Path(args.out).write_text(
        json.dumps(data, ensure_ascii=False, separators=(",", ":")), encoding="utf-8"
    )
    print(
        f"wrote {args.out}: {len(data['stations'])} stations, issued {data['issued_utc']}"
    )


if __name__ == "__main__":
    main()
