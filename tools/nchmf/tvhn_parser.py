"""Parse the KTTV short-range hydrology bulletin (``dbqg_tvhn_YYYYMMDD_HHMM.pdf``).

The station table is printed with rotated glyphs, so ``extract_text`` scrambles it.
We rebuild rows from the rotated characters' ``top`` and assign each value to the
nearest header column by x. Times in the bulletin are Vietnam time (UTC+7).

Output (all times UTC ISO-8601, levels in cm, discharge in m3/s):
{
  "issued_utc": "...",
  "stations": [{"river", "name", "unit": "cm"|"m3/s",
                "points": [{"t", "v", "kind": "obs"|"fc"}]}],
  "tidal_extremes": [{"river", "name", "window_h", "obs_max", "obs_min",
                      "fc_max", "fc_min"}]
}
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta, timezone
from pathlib import Path

import pdfplumber

VN = timezone(timedelta(hours=7))
ROW_TOL = 2.0  # pt: chars of one table row share `top` within this
CELL_GAP = 4.0  # pt: larger x gap starts a new cell
MAX_PAGES = 40  # untrusted input: refuse absurd documents

_HEADER_OBS = re.compile(r"^(\d{1,2})h-$")
_HEADER_FULL = re.compile(r"^(\d{1,2})h-(\d{2})/(\d{2})$")
_DATE = re.compile(r"^(\d{2})/(\d{2})$")
_INT = re.compile(r"^-?\d+$")
_ISSUED = re.compile(r"ngày\s+(\d{1,2})\s+tháng\s+(\d{1,2})\s+năm\s+(\d{4})")
_ISSUED_AT = re.compile(r"Tin phát lúc:\s*(\d{1,2})\s*giờ\s*(\d{1,2})")
# "Cầu Đáp Cầu 116 52 105 55" / "Thái Bình Phả Lại (**) 129 32 115 40"
_TIDAL_ROW = re.compile(r"^(?P<label>\D+?)\s+(?P<n>-?\d+\s+-?\d+\s+-?\d+\s+-?\d+)$")

# Plausibility bounds; anything outside is a parse error, not data.
LEVEL_RANGE_CM = (-500, 100_000)
FLOW_RANGE_M3S = (0, 100_000)


class BulletinError(ValueError):
    """Raised when the PDF does not look like a TVHN bulletin."""


@dataclass
class Cell:
    text: str
    x0: float
    x1: float

    @property
    def xc(self) -> float:
        return (self.x0 + self.x1) / 2


def _rows(chars: list[dict]) -> list[tuple[float, list[Cell]]]:
    rows: dict[float, list[dict]] = {}
    for c in chars:
        if not c["text"].strip():
            continue
        key = next((t for t in rows if abs(t - c["top"]) <= ROW_TOL), None)
        if key is None:
            key = c["top"]
            rows[key] = []
        rows[key].append(c)
    out = []
    for top in sorted(rows):
        cells: list[Cell] = []
        for c in sorted(rows[top], key=lambda c: c["x0"]):
            if cells and c["x0"] - cells[-1].x1 <= CELL_GAP:
                cells[-1].text += c["text"]
                cells[-1].x1 = c["x1"]
            else:
                cells.append(Cell(c["text"], c["x0"], c["x1"]))
        out.append((top, cells))
    return out


def _issued(text: str) -> datetime:
    d = _ISSUED.search(text)
    if not d:
        raise BulletinError("issue date not found")
    day, month, year = (int(g) for g in d.groups())
    hm = _ISSUED_AT.search(text)
    hour, minute = (int(g) for g in hm.groups()) if hm else (10, 30)
    return datetime(year, month, day, hour, minute, tzinfo=VN)


def _vn_time(hour: int, day: int, month: int, issued: datetime) -> datetime:
    year = issued.year
    # Bulletin of 01/01 shows 31/12 observations.
    if month == 12 and issued.month == 1:
        year -= 1
    return datetime(year, month, day, hour, tzinfo=VN)


def _columns(
    rows: list[tuple[float, list[Cell]]], issued: datetime
) -> list[tuple[float, datetime, str]]:
    """Header columns as (x centre, time, kind)."""
    cols: list[tuple[float, datetime, str]] = []
    obs_hours: list[tuple[float, int]] = []
    obs_dates: list[tuple[float, int, int]] = []
    for _, cells in rows:
        for c in cells:
            if m := _HEADER_FULL.match(c.text):
                h, d, mo = (int(g) for g in m.groups())
                cols.append((c.xc, _vn_time(h, d, mo, issued), "fc"))
            elif m := _HEADER_OBS.match(c.text):
                obs_hours.append((c.xc, int(m.group(1))))
            elif m := _DATE.match(c.text):
                obs_dates.append((c.xc, int(m.group(1)), int(m.group(2))))
    for x, h in obs_hours:
        near = min(obs_dates, key=lambda d: abs(d[0] - x), default=None)
        if near is None or abs(near[0] - x) > 10:
            raise BulletinError("observation header without date")
        cols.append((x, _vn_time(h, near[1], near[2], issued), "obs"))
    cols.sort()
    if len(cols) < 4:
        raise BulletinError("station table header not found")
    return cols


def _check(value: int, unit: str, station: str) -> int:
    lo, hi = FLOW_RANGE_M3S if unit == "m3/s" else LEVEL_RANGE_CM
    if not lo <= value <= hi:
        raise BulletinError(f"{station}: value {value} out of range")
    return value


def _table_rows(page) -> list[tuple[float, list[Cell]]]:
    """Rows of the station table; some days it is printed rotated, some days upright."""
    for upright in (False, True):
        rows = _rows([c for c in page.chars if bool(c["upright"]) == upright])
        if any(_HEADER_FULL.match(c.text) for _, cs in rows for c in cs):
            end = next(
                (
                    i
                    for i, (_, cs) in enumerate(rows)
                    if cs and cs[0].text.startswith("Ghi")
                ),
                len(rows),
            )
            return rows[:end]
    return []


def _station_table(page, issued: datetime) -> list[dict]:
    rows = _table_rows(page)
    cols = _columns(rows, issued)
    first_x = cols[0][0]
    stations = []
    for _, cells in rows:
        values = [c for c in cells if _INT.match(c.text) and c.xc > first_x - 20]
        labels = [c for c in cells if c not in values]
        if len(labels) < 2 or not values:
            continue
        river, name = labels[0].text, labels[1].text
        unit = "m3/s" if "(*)" in name else "cm"
        name = name.replace("(*)", "").strip()
        points = []
        used: set[int] = set()
        for v in values:
            i = min(range(len(cols)), key=lambda k: abs(cols[k][0] - v.xc))
            if abs(cols[i][0] - v.xc) > 25 or i in used:
                raise BulletinError(f"{name}: value {v.text} does not fit a column")
            used.add(i)
            t = cols[i][1].astimezone(UTC)
            points.append(
                {
                    "t": t.isoformat().replace("+00:00", "Z"),
                    "v": _check(int(v.text), unit, name),
                    "kind": cols[i][2],
                }
            )
        stations.append({"river": river, "name": name, "unit": unit, "points": points})
    if not stations:
        raise BulletinError("no station rows")
    return stations


def _tidal_extremes(text: str) -> list[dict]:
    out = []
    in_table = False
    for line in text.splitlines():
        if "Mực nước Mực nước" in line or line.startswith("Sông Trạm"):
            in_table = True
            continue
        if in_table and line.startswith("Ghi chú"):
            break
        if not in_table:
            continue
        m = _TIDAL_ROW.match(line.strip())
        if not m:
            continue
        label = m.group("label").strip()
        window = 36 if "(**)" in label else 24
        label = label.replace("(**)", "").strip()
        nums = [int(n) for n in m.group("n").split()]
        out.append(
            {
                "label": label,
                "window_h": window,
                "obs_max": nums[0],
                "obs_min": nums[1],
                "fc_max": nums[2],
                "fc_min": nums[3],
            }
        )
    return out


def parse(path: Path) -> dict:
    with pdfplumber.open(path) as pdf:
        if len(pdf.pages) > MAX_PAGES:
            raise BulletinError("too many pages")
        first = pdf.pages[0].extract_text() or ""
        if "THUỶ VĂN" not in first.upper() and "THỦY VĂN" not in first.upper():
            raise BulletinError("not a hydrology bulletin")
        full = "\n".join(p.extract_text() or "" for p in pdf.pages)
        issued = _issued(full)
        table_page = next((p for p in pdf.pages if _table_rows(p)), None)
        if table_page is None:
            raise BulletinError("station table not found")
        return {
            "issued_utc": issued.astimezone(UTC).isoformat().replace("+00:00", "Z"),
            "stations": _station_table(table_page, issued),
            "tidal_extremes": _tidal_extremes(full),
        }


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        sys.stdout.buffer.write(
            json.dumps(parse(Path(arg)), ensure_ascii=False, indent=1).encode("utf-8")
            + b"\n"
        )
