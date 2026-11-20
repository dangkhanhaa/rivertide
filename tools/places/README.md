# Địa danh cho ô tìm kiếm

`fetch_places.py` trích một lần ~21 000 địa danh Việt Nam (tỉnh/thành, phường/xã/làng, cầu, bến phà, bến) từ OpenStreetMap qua Overpass API, ghi ra `app/assets/data/places.json`. App tìm trên máy, không gọi dịch vụ ngoài, chạy được khi mất sóng.

- Giấy phép dữ liệu: ODbL; app đã ghi công OpenStreetMap.
- Không dùng Nominatim công khai: điều khoản cấm dùng nhiều (tối đa 1 yêu cầu/giây cho toàn bộ người dùng) và yêu cầu đổi được dịch vụ mà không cần cập nhật app.
- Chạy lại khi cần làm mới: `..\tide\.venv\Scripts\python.exe fetch_places.py` (mất vài phút, tự thử lại khi máy chủ bận).

## Bờ biển (P2-48)

`build_coast.py` cắt đường bờ biển Natural Earth 1:10m (miền công cộng, tải `ne_10m_coastline.geojson` từ github.com/nvkelso/natural-earth-vector) quanh Việt Nam, đơn giản hóa ~300 m, ghi `app/assets/data/coast.json` (~80 KB). App dùng để tính "cách biển bao xa" khi đoán điểm có thủy triều hay không. Lưu ý: ở tỷ lệ này các cửa sông rộng (Soài Rạp, sông Hậu, sông Cấm) được tính như biển — hợp với mục đích "triều lên tới đâu".

- Chạy lại: `python build_coast.py <đường dẫn ne_10m_coastline.geojson>`.
