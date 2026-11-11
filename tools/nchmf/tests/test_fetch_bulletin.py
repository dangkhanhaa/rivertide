from pathlib import Path

import pytest

from export_bulletin import merge
from fetch_bulletin import find_pdf, find_post_url
from tvhn_parser import BulletinError, parse

FIX = Path(__file__).parents[1] / "fixtures"


def test_finds_post_and_pdf_links():
    post = find_post_url(
        (FIX / "nchmf_thuyvan_list_20261109.html").read_text(encoding="utf-8")
    )
    assert post.endswith("-post55069.html")
    url, day = find_pdf(
        (FIX / "nchmf_tvhn_post_20261109.html").read_text(encoding="utf-8")
    )
    assert (
        url
        == "https://kttv.gov.vn/upload/thuyvan2/2026/11/9/dbqg_tvhn_20261109_1030.pdf"
    )
    assert day == "20261109"


def test_finds_pdf_in_any_upload_folder():
    # 10/11/2026: KTTV moved the PDF from upload/thuyvan2 to upload/thuyvan1.
    url, day = find_pdf(
        (FIX / "nchmf_tvhn_post_20261110.html").read_text(encoding="utf-8")
    )
    assert (
        url
        == "https://kttv.gov.vn/upload/thuyvan1/2026/11/10/dbqg_tvhn_20261110_1030.pdf"
    )
    assert day == "20261110"


def test_missing_links_raise():
    with pytest.raises(BulletinError):
        find_post_url("<html></html>")
    with pytest.raises(BulletinError):
        find_pdf("<html></html>")


def test_merge_keeps_old_obs_and_newest_forecast():
    a = parse(FIX / "dbqg_tvhn_20261031_1030.pdf")
    b = parse(FIX / "dbqg_tvhn_20261106_1030.pdf")
    m = merge([b, a])  # order must not matter
    assert m["issued_utc"] == b["issued_utc"]
    hn = m["stations"]["HàNội"]["points"]
    obs = [p for p in hn if p["k"] == "o"]
    fc = [p for p in hn if p["k"] == "f"]
    assert len(obs) == 8  # 4 from each bulletin
    assert all(p["t"] > b["issued_utc"][:13] for p in fc)
    assert "TháiBìnhPhảLại" in m["daily"]
