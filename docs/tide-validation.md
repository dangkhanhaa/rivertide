# Kiểm chứng dự báo thủy triều (P0-05) — 09/11/2026

> Chạy lại: `cd tools/tide; .\.venv\Scripts\python.exe download_ioc.py ...; python validate.py; python compare_open_meteo.py; python export_asset.py --years 2026 2027`.
> Số liệu thô (`data/raw/`) và kết quả (`output/`) không commit; con số dưới đây chép từ `output/validation.json` và `output/open_meteo_marine.json`.

## 1. Cách làm

| Bước | Chi tiết |
|---|---|
| Dữ liệu | IOC Sea Level Monitoring, 01/10/2025 → 09/11/2026, gộp trung bình 10 phút. Vũng Tàu cảm biến `ra2` (đủ 90,9% giai đoạn fit), Quy Nhơn `rad` (88,9%) |
| QC | Bỏ bin < 5 mẫu/10 phút; bỏ điểm lệch > 25 cm so với trung vị 1 giờ |
| Fit | `utide.solve` (OLS, nodal, `constit='auto'`), **12 tháng** 01/10/2025 → 30/09/2026 |
| Kiểm thử ngược | Dự báo **01/10 → 08/11/2026 (39 ngày, không dùng để fit)**, so với thực đo IOC |
| So với KTTV | Bản tin thủy triều 10 ngày phát 06/11/2026 (`tools/tide/fixtures/nchmf_tide_20261106.json`); ghép mỗi mốc bản tin với đỉnh/chân gần nhất cùng loại (±3 h), trừ chênh mốc cao độ (trung vị) |
| Open-Meteo Marine | `sea_level_height_msl` 30 ngày gần nhất tại tọa độ trạm IOC, so với thực đo theo giờ sau khi trừ chênh mốc |

## 2. Kết quả

| Chỉ số | Vũng Tàu | Quy Nhơn | Ngưỡng PROJECT.md 9.1 |
|---|---|---|---|
| Sai số mực nước (RMSE, 39 ngày) | **10,4 cm** | **6,5 cm** | < 10 cm → "Cao" |
| Lệch giờ đỉnh/chân, trung bình (p90) | **9,5 phút** (20) | **14,2 phút** (31) | < 20 phút ✅ |
| Lệch độ cao đỉnh/chân, trung bình (p90) | **8,5 cm** (16) | **5,9 cm** (10,6) | < 15 cm ✅ |
| Đúng chiều lên/xuống theo giờ | **99,3%** | **99,9%** | — |
| Sau hiệu chỉnh theo thực đo: +1 h / +3 h / +6 h | 3,4 / 7,3 / 8,9 cm | 1,4 / 2,7 / 4,1 cm | — |
| So bản tin KTTV: giờ / độ cao | 10 phút / 5,8 cm | 51 phút / 10 cm | — |
| Thực đo so bản tin KTTV (đối chứng) | 10 phút / 4,0 cm | 30 phút / 9,1 cm | — |
| Chênh mốc IOC → số 0 hải đồ (bản tin) | +6,6 cm | +10,9 cm | — |
| Open-Meteo Marine so thực đo: RMSE / giờ / độ cao | 7,9 cm / 9,3 phút / 9,4 cm | 4,4 cm / 14,8 phút / 3,3 cm | — |

**Độ tin cậy gán vào file dự báo:** Vũng Tàu = **Trung bình** (RMSE 10,4 cm, sát ngưỡng 10), Quy Nhơn = **Cao**.

## 3. Nhận xét

1. **Đạt ngưỡng 9.1** về giờ và độ cao đỉnh/chân ở cả 2 trạm.
2. **Quy Nhơn lệch bản tin KTTV ~50 phút nhưng chính bản tin cũng lệch thực đo ~30 phút**: Quy Nhơn triều nhật triều không đều, đỉnh/chân rất bẹt (đổi vài cm trong 1–2 giờ) và bản tin hay ghi giờ tròn ("21h00"). Dự báo của mình bám thực đo tốt hơn bản tin (14 phút).
3. **Hiệu chỉnh theo thực đo (F-TIDE-07) rất hiệu quả trong vài giờ tới** — app đã áp dụng (giảm tuyến tính về 0 trong 12 h).
4. **Open-Meteo Marine tốt bất ngờ tại 2 điểm này** (≤ 8 cm) → dùng được làm nguồn "mô hình" cho các điểm ven biển không có máy đo, **nhưng chỉ mới kiểm chứng tại 2 điểm**; các điểm khác để độ tin cậy "Trung bình" và ghi "Chưa đo được sai số tại điểm này".
5. Mốc cao độ: dự báo trạm IOC đã cộng chênh mốc để hiển thị **so với số 0 hải đồ** như bản tin KTTV (ước lượng từ 10 ngày bản tin — ⚠ nên kiểm lại với nhiều bản tin hơn). Điểm "mô hình" hiển thị so với mực nước biển trung bình của mô hình.

## 4. Giới hạn

- Mới 1 bản tin KTTV (10 ngày) để so; nên lưu thêm bản tin để có thống kê dài hơn.
- Dữ liệu fit chỉ 12–13 tháng: các sóng dài kỳ (Sa, Ssa) ước lượng kém hơn so với fit nhiều năm.
- Chưa kiểm chứng trạm sông (cần nguồn dữ liệu sông — xem docs/data-sources.md).
