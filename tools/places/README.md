# Địa danh cho ô tìm kiếm

`fetch_places.py` trích một lần ~21 000 địa danh Việt Nam (tỉnh/thành, phường/xã/làng, cầu, bến phà, bến) từ OpenStreetMap qua Overpass API, ghi ra `app/assets/data/places.json`. App tìm trên máy, không gọi dịch vụ ngoài, chạy được khi mất sóng.

- Giấy phép dữ liệu: ODbL; app đã ghi công OpenStreetMap.
- Không dùng Nominatim công khai: điều khoản cấm dùng nhiều (tối đa 1 yêu cầu/giây cho toàn bộ người dùng) và yêu cầu đổi được dịch vụ mà không cần cập nhật app.
- Chạy lại khi cần làm mới: `..\tide\.venv\Scripts\python.exe fetch_places.py` (mất vài phút, tự thử lại khi máy chủ bận).
