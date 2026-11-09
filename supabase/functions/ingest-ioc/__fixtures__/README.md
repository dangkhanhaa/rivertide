# Fixtures IOC Sea Level Monitoring

- `vung_20261104.json`: trạm Vũng Tàu (`vung`), 1 ngày 2026-11-04, mọi cảm biến (`ra2`, `ra3`, `enc`, `bat`, `sw1`).
- `quin_20261104.json`: trạm Quy Nhơn (`quin`), cảm biến `rad`.
- Nguồn: `https://www.ioc-sealevelmonitoring.org/service.php?query=data&code=<code>&timestart=...&timestop=...&format=json`
- Lấy ngày 2026-11-06. `stime` là UTC, `slevel` tính bằng mét (mốc riêng của trạm, chưa QC).
