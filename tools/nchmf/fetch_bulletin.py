"""Daily job: find today's TVHN bulletin on nchmf.gov.vn, download, parse, archive.

KTTV keeps one post URL and replaces its content daily, and old PDFs cannot be
listed, so every missed day is lost: the job runs several times a day and
archives the parsed JSON (small) under ``archive/``.

Usage: python fetch_bulletin.py [--archive DIR] [--site DIR]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import tempfile
import urllib.request
from pathlib import Path

from export_bulletin import merge
from tvhn_parser import BulletinError, parse

HERE = Path(__file__).parent
LIST_URL = "https://www.nchmf.gov.vn/kttv/vi-VN/1/thuy-van-12-18.html"
HOME_URL = "https://www.nchmf.gov.vn/kttv/"
# KTTV reuses one post URL and replaces its content daily (docs/data-sources.md);
# the list page only shows the 10 newest posts, so remember the URL that worked.
STATE_FILE = "state.json"
POST_RE = re.compile(
    r'href="(https://www\.nchmf\.gov\.vn/kttv/vi-VN/1/ban-tin-du-bao-canh-bao-thuy-van-thoi-han-ngan-post\d+\.html)"'
)
PDF_RE = re.compile(
    r"(upload/thuyvan2/\d{4}/\d{1,2}/\d{1,2}/dbqg_tvhn_(\d{8})_\d{4}\.pdf)"
)
USER_AGENT = "RiverTide-bulletin-archiver/0.1 (+https://github.com/dangkhanhaa)"
MAX_PDF_BYTES = 20 * 1024 * 1024
MAX_HTML_BYTES = 2 * 1024 * 1024


def _get(url: str, limit: int) -> bytes:
    if not url.startswith("https://"):
        raise ValueError("only https")
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as resp:
        body = resp.read(limit + 1)
    if len(body) > limit:
        raise ValueError(f"{url}: response too large")
    return body


def find_post_url(list_html: str) -> str:
    m = POST_RE.search(list_html)
    if not m:
        raise BulletinError("TVHN post link not found on the list page")
    return m.group(1)


def find_pdf(post_html: str) -> tuple[str, str]:
    """(absolute PDF URL, YYYYMMDD) of the bulletin linked from the post."""
    m = PDF_RE.search(post_html)
    if not m:
        raise BulletinError("TVHN PDF link not found in the post")
    return "https://kttv.gov.vn/" + m.group(1), m.group(2)


def _locate_pdf(state_path: Path) -> tuple[str, str]:
    candidates: list[str] = []
    if state_path.exists():
        candidates.append(
            json.loads(state_path.read_text(encoding="utf-8"))["post_url"]
        )
    # The list is paged 10 per page (?pageindex=N); a day has ~15 hydrology posts.
    for page in (HOME_URL, *(f"{LIST_URL}?pageindex={i}" for i in range(1, 4))):
        try:
            candidates.append(
                find_post_url(_get(page, MAX_HTML_BYTES).decode("utf-8", "replace"))
            )
        except (BulletinError, OSError) as e:
            print(f"no post link on {page}: {e}")
    best: tuple[str, str, str] | None = None
    for post in dict.fromkeys(candidates):  # unique, in order
        try:
            url, day = find_pdf(_get(post, MAX_HTML_BYTES).decode("utf-8", "replace"))
        except (BulletinError, OSError) as e:
            print(f"no PDF in {post}: {e}")
            continue
        if best is None or day > best[1]:
            best = (url, day, post)
    if best is None:
        raise BulletinError("no TVHN bulletin found")
    state_path.write_text(json.dumps({"post_url": best[2]}), encoding="utf-8")
    return best[0], best[1]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--archive", default=str(HERE / "archive"))
    ap.add_argument("--site", default=str(HERE.parents[1] / "site" / "data"))
    args = ap.parse_args()
    archive, site = Path(args.archive), Path(args.site)
    archive.mkdir(parents=True, exist_ok=True)

    pdf_url, day = _locate_pdf(archive / STATE_FILE)
    target = archive / f"dbqg_tvhn_{day}.json"
    if not target.exists():
        with tempfile.TemporaryDirectory() as tmp:
            pdf = Path(tmp) / "b.pdf"
            pdf.write_bytes(_get(pdf_url, MAX_PDF_BYTES))
            target.write_text(
                json.dumps(parse(pdf), ensure_ascii=False, indent=1), encoding="utf-8"
            )
        print(f"archived {target.name} from {pdf_url}")
    else:
        print(f"{target.name} already archived")

    bulletins = [
        json.loads(p.read_text(encoding="utf-8"))
        for p in sorted(archive.glob("dbqg_tvhn_*.json"))
    ]
    site.mkdir(parents=True, exist_ok=True)
    (site / "kttv_tvhn.json").write_text(
        json.dumps(merge(bulletins), ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    print(f"published {site / 'kttv_tvhn.json'} from {len(bulletins)} bulletins")
    return 0


if __name__ == "__main__":
    sys.exit(main())
