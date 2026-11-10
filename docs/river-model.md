# Mực nước sông từng giờ từ bản tin KTTV (V0-09) — 09/11/2026

> Chạy lại: `cd tools/nchmf; ..\tide\.venv\Scripts\python.exe river_backtest.py HàNội` (hoặc `NamĐàn om_honngu.json`).

## 1. Dữ liệu
- **Nguồn:** bản tin dự báo thủy văn hạn ngắn của Trung tâm Dự báo KTTV quốc gia (PDF, phát khoảng 10:30 mỗi ngày).
  - Có 11 trạm mực nước: mỗi trạm 4 mốc đo (1h, 7h, 13h, 19h) và 6–8 mốc dự báo.
  - Có 11 trạm sông ảnh hưởng triều: chỉ cho mức cao nhất và thấp nhất trong 24–36 giờ.
- **Bộ đọc:** [tools/nchmf/tvhn_parser.py](../tools/nchmf/tvhn_parser.py).
  - Tùy ngày, bảng in kiểu chữ xoay hoặc chữ thẳng; bộ đọc xử lý cả hai.
  - Số liệu nằm ngoài khoảng hợp lý thì báo lỗi, không nhận.
- **Lưu trữ:** trang KTTV không giữ danh sách bản tin cũ.
  - [fetch_bulletin.py](../tools/nchmf/fetch_bulletin.py) chạy hằng ngày qua GitHub Actions (`.github/workflows/pages.yml`).
  - Bản tin đã đọc được lưu dạng JSON trong `tools/nchmf/archive/`.

## 2. Thuật toán ([app/lib/core/calc/river/river_curve.dart](../app/lib/core/calc/river/river_curve.dart))
- **Trạm chịu ảnh hưởng triều** (Hà Nội, Nam Đàn):
  - Công thức: `h(t) = a + b·(t − t0) + g·S(t − lag)`.
  - `S` là mực nước biển từng giờ tại cửa sông (Open-Meteo Marine): Hòn Dấu cho trạm Hà Nội, Hòn Ngư cho trạm Nam Đàn.
  - Thuật toán thử độ trễ `lag` từ 0 đến 24 giờ và chọn bằng bình phương tối thiểu, với điều kiện `g > 0`.
  - Dữ liệu dùng để tính: các mốc đo trong 48 giờ trước mốc đo mới nhất, cộng các mốc dự báo của KTTV.
- **Trạm không có triều:** nội suy đơn điệu (Fritsch–Carlson) qua các mốc, nên không tạo ra đỉnh giả.
- **Trạm chỉ có cao nhất/thấp nhất:** chỉ hiển thị con số, **không vẽ đường**, vì bản tin không ghi giờ.
- **Không hiệu chỉnh theo mốc đo mới nhất:** đã thử, sai số tăng từ 8,9 lên 11,3 cm.
- **Điểm bất kỳ trên bản đồ:**
  - Nếu điểm có biển, dùng mô hình biển Open-Meteo tại chính điểm đó.
  - Nếu không, dùng trạm sông KTTV gần nhất trong vòng 40 km, có ghi tên trạm và khoảng cách. Xa hơn 10 km thì độ tin cậy hạ xuống "Thấp".
  - Không thỏa cả hai thì báo "chưa có dữ liệu".

## 3. Kiểm thử ngược (6 bản tin, 30/10 → 09/11/2026)
| Trạm | Nối các mốc 6 giờ | Mô hình triều | Lúc app chạy thật | Dự báo KTTV | Độ trễ tìm được |
|---|---|---|---|---|---|
| Hà Nội | 21,0 cm | **8,9 cm** | 11,7 cm | 12,2 cm | 9 giờ |
| Nam Đàn | 53,4 cm | **13,2 cm** | 11,4 cm | 11,6 cm | 4 giờ |

**Giới hạn:**
- Mẫu kiểm thử nhỏ (14–16 điểm).
- Chỉ đo được sai số tại các mốc 6 giờ; giờ đỉnh/chân chưa đối chiếu được với số đo từng giờ.
- Lũ về hoặc hồ thủy điện xả gấp giữa 2 bản tin thì mô hình không thấy được.
- Tọa độ các trạm KTTV là **gần đúng**, cần kiểm lại (P0-04).

## 4. Mực nước theo vị trí dọc sông (10/11/2026)

Mục tiêu: chạm vào chỗ nào trên sông Hồng hoặc sông Cả thì app ra số riêng cho chỗ đó, không chép số của trạm.

### 4.1. Dữ liệu (đều thật)
| Dữ liệu | Nguồn | Kết quả |
|---|---|---|
| Đường dòng chính sông Hồng, sông Cả (Lam) | OpenStreetMap, lấy qua Overpass ngày 10/11/2026 (`tools/rivers/data/raw`) | Hồng 309 km (Ba Lạt → trên Việt Trì), Cả 89 km (Cửa Hội → trên Nam Đàn) |
| Vị trí trạm trên sông | Chiếu tọa độ trạm lên đường sông (`build_rivers.py`) | Hà Nội km 165,6; Nam Đàn km 58,5 (cách đường sông dưới 1,5 km) |
| Triều Hòn Dấu so với cửa Ba Lạt | Open-Meteo Marine | Lệch 0 giờ, tương quan 0,995 → Hòn Dấu là đầu vào đúng cho cửa sông |
| Độ trễ triều tới Hà Nội | Khớp riêng trên từng bản tin KTTV, bước 15 phút | 8,46 ± 0,34 giờ (6 bản tin) |
| **Tốc độ con triều truyền ngược sông Hồng** | 165,6 km ÷ 8,46 giờ (`analyze_celerity.py`) | **≈ 19,6 km/giờ (5,4 m/s)**, hợp với sóng nước nông √(g·h) khi sông sâu 3–4 m |

### 4.2. Công thức ([river_reach.dart](../app/lib/core/calc/river/river_reach.dart))
Với điểm ở km x (tính từ cửa sông), trạm ở km X và f = x / X:
- độ trễ triều(x) = độ trễ trạm · f
- biên độ triều(x) = 1 + (biên độ trạm − 1) · f (ở cửa sông bằng 1, tức đúng triều biển)
- mực nước trung bình(x, t) = mực nước trung bình trạm(t) · f (ở cửa sông bằng 0 = mốc cao độ quốc gia ≈ mực biển trung bình Hòn Dấu)

Mô hình đi qua đúng **2 điều kiện biên có thật**: tại cửa sông ra đúng triều biển, tại trạm ra đúng mô hình của trạm. Có test kiểm tra cả hai.

Ví dụ dữ liệu thật ngày 09/11, lúc 15:00 giờ VN:
| Vị trí | Dọc sông | Chân nước | Đỉnh nước |
|---|---|---|---|
| Trạm Hà Nội | 0 | 23:49 · 1,18 m | 11:26 · 1,86 m |
| Cầu Thanh Trì | 5,7 km hạ lưu | 23:34 · 1,13 m | 11:10 · 1,86 m |
| Bãi Chèm | 10,3 km thượng lưu | 00:14 · 1,28 m | 12:00 · 1,86 m |

### 4.3. Phạm vi áp dụng và giới hạn
- **Chỉ áp dụng khi điểm chạm nằm trong vòng 1 km tính từ đường dòng chính**, từ 60 km hạ lưu tới 25 km thượng lưu của trạm. Ngoài phạm vi này app quay về cách cũ (lấy theo trạm gần nhất) và ghi rõ.
- **Giả định độ trễ, biên độ và mực nước trung bình thay đổi đều theo km.** Thực tế sóng triều tắt dần không đều.
- **Chưa kiểm chứng tại trạm thứ hai** vì đoạn sông này không có trạm khác trong bản tin. App ghi rõ điều này và hiện dải sai số đo tại trạm (±11,7 cm).
- **Sông Đuống, sông Luộc và các nhánh khác chưa có đường sông riêng**: điểm trên các sông này dùng cách cũ.

## 5. Dòng chảy (lưu lượng)
- **Nguồn:** Open-Meteo Flood (mô hình GloFAS), lưu lượng ngày, ô lưới khoảng 5 km. App gọi 3×3 ô quanh điểm và **chọn ô có lưu lượng trung bình lớn nhất, đó là dòng chính**. Ví dụ ngày 10/11 quanh trạm Hà Nội: ô ngay tại trạm chỉ ~3 m³/s (rơi vào kênh nhỏ), ô trên dòng chính ~2.170 m³/s.
- **Hiển thị:** lưu lượng hôm nay, ngày mai, xu hướng (thay đổi quá ±5% thì coi là tăng hoặc giảm), có nhãn "Ước tính".
- **Không có vận tốc dòng chảy đo thật (m/s).** Muốn tính vận tốc cần mặt cắt ngang sông (độ sâu), mà dữ liệu này không có nguồn miễn phí. App không tự đặt ra con số này.

## 6. Điểm không có trạm (10/11/2026)

Thứ tự nguồn cho một điểm bất kỳ ([point_tide_source.dart](../app/lib/features/stations/data/point_tide_source.dart)):

1. **Biển tại điểm**: Open-Meteo Marine, chỉ khi `elevation` (DEM 90 m tại điểm hỏi) ≤ 0 m **và** ô lưới trả về cách ≤ 8 km. Khảo sát 10/11/2026: TP Thái Bình (20.45, 106.34) có `elevation` 11 m nhưng vẫn nhận mực nước biển; TP Thanh Hóa (19.86, 105.80) bị dời sang ô biển cách 16 km. Biển ngoài Vũng Tàu: `elevation` 0.
2. **Dọc sông** (mục 4).
3. **Trạm KTTV gần nhất** ≤ 40 km.
4. **Triều ven bờ**: ô biển ≤ 25 km cho điểm đất liền/sông gần cửa biển, đánh dấu *ước tính*, độ tin cậy thấp.
5. **Không có nguồn mực nước**: không vẽ đường mực nước. Thẻ chính là lưu lượng dòng chính (mục 5): hôm nay, ngày mai, xu hướng lên/rút, 7 ngày; kèm giờ câu và thời tiết theo đúng vị trí.

Khảo sát lưu lượng GloFAS 10/11/2026 (trung bình 10 ngày của ô lớn nhất trong 3×3): sông Đà ở Hòa Bình ≈ 730 m³/s, sông Cầu ở Thái Nguyên ≈ 94, sông Thương ở Bắc Giang ≈ 81, sông Đồng Nai ở Biên Hòa ≈ 614, sông Đáy ở Phủ Lý ≈ 148. Riêng sông Tiền ở Cao Lãnh thì lưới 3×3 chỉ cho ≤ 25 m³/s, dưới ngưỡng 50, nên vùng đồng bằng sông Cửu Long chưa có lưu lượng. Đây là giới hạn đã biết.
