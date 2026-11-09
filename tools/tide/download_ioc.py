"""Download IOC sea level data and keep 10-minute means of selected sensors.

IOC returns every sensor at 1-minute resolution and cannot filter by sensor,
so data is fetched in small chunks and reduced immediately to keep disk use low.

Usage:
    python download_ioc.py --code vung --sensors ra2,ra3 --start 2025-10-01 --end 2026-11-09
"""

from __future__ import annotations

import argparse
import time
from datetime import date, datetime, timedelta
from pathlib import Path

import pandas as pd
import requests

BASE_URL = "https://www.ioc-sealevelmonitoring.org/service.php"
CHUNK_DAYS = 10
PAUSE_S = 1.5  # be polite to a free public service
MAX_RESPONSE_BYTES = 40_000_000
VALID_RANGE_M = (-20.0, 20.0)
OUT_DIR = Path(__file__).parent / "data" / "raw"


def parse_records(records: object, sensors: set[str]) -> pd.DataFrame:
    """Validate raw IOC JSON records and return rows of the wanted sensors."""
    if not isinstance(records, list):
        raise TypeError("IOC response is not a list")
    rows = []
    for rec in records:
        if not isinstance(rec, dict) or rec.get("sensor") not in sensors:
            continue
        level, stime = rec.get("slevel"), rec.get("stime")
        if not isinstance(level, (int, float)) or not isinstance(stime, str):
            continue
        if not VALID_RANGE_M[0] < level < VALID_RANGE_M[1]:
            continue
        rows.append((stime, rec["sensor"], float(level)))
    df = pd.DataFrame(rows, columns=["time", "sensor", "level_m"])
    df["time"] = pd.to_datetime(df["time"], format="%Y-%m-%d %H:%M:%S", utc=True)
    return df


def to_10min(df: pd.DataFrame) -> pd.DataFrame:
    """Mean per sensor per 10-minute bin, in integer centimetres."""
    if df.empty:
        return pd.DataFrame(columns=["time", "sensor", "level_cm", "n"])
    df = df.set_index("time")
    out = (
        df.groupby("sensor")["level_m"]
        .resample("10min")
        .agg(["mean", "count"])
        .reset_index()
        .dropna()
    )
    out["level_cm"] = (out["mean"] * 100).round().astype(int)
    return out.rename(columns={"count": "n"})[["time", "sensor", "level_cm", "n"]]


def fetch_chunk(
    session: requests.Session, code: str, start: date, stop: date
) -> object:
    params = {
        "query": "data",
        "code": code,
        "timestart": f"{start.isoformat()}T00:00",
        "timestop": f"{stop.isoformat()}T00:00",
        "format": "json",
    }
    resp = session.get(BASE_URL, params=params, timeout=180)
    resp.raise_for_status()
    if len(resp.content) > MAX_RESPONSE_BYTES:
        raise ValueError(f"response too large: {len(resp.content)} bytes")
    return resp.json()


def download(code: str, sensors: set[str], start: date, end: date) -> Path:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"{code}_{start:%Y%m%d}_{end:%Y%m%d}_10min.csv"
    parts = []
    with requests.Session() as session:
        session.headers["User-Agent"] = "RiverTide-dev-tide-research/0.1"
        cursor = start
        while cursor < end:
            stop = min(cursor + timedelta(days=CHUNK_DAYS), end)
            for attempt in range(3):
                try:
                    part = to_10min(
                        parse_records(fetch_chunk(session, code, cursor, stop), sensors)
                    )
                    break
                except (requests.RequestException, ValueError, TypeError) as exc:
                    print(f"  retry {attempt + 1} {cursor}: {exc}")
                    time.sleep(10 * (attempt + 1))
            else:
                raise RuntimeError(f"failed chunk {cursor}..{stop}")
            print(f"{code} {cursor}..{stop}: {len(part)} rows")
            parts.append(part)
            cursor = stop
            time.sleep(PAUSE_S)
    result = (
        pd.concat(parts)
        .drop_duplicates(["time", "sensor"])
        .sort_values(["sensor", "time"])
    )
    result.to_csv(out_path, index=False, date_format="%Y-%m-%dT%H:%M:%SZ")
    return out_path


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--code", required=True)
    ap.add_argument("--sensors", required=True, help="comma separated, e.g. ra2,ra3")
    ap.add_argument("--start", required=True, type=date.fromisoformat)
    ap.add_argument("--end", required=True, type=date.fromisoformat)
    args = ap.parse_args()
    t0 = datetime.now()
    path = download(args.code, set(args.sensors.split(",")), args.start, args.end)
    print(f"saved {path} in {datetime.now() - t0}")


if __name__ == "__main__":
    main()
