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
