# 05 — Kiểm tra bằng dữ liệu thật

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md).
> Từ 11/11/2026 chủ dự án quyết định **bỏ toàn bộ test tự động** (unit, widget, pytest).
> Mọi thay đổi được kiểm bằng **dữ liệu thật**, chạy app và xem tận mắt.

## 1. Trước khi đăng lên web

```powershell
cd app; dart format --set-exit-if-changed .; flutter analyze; flutter build web --release
```

Cả ba phải sạch. Sau đó mở `app/build/web` (máy chủ tĩnh cục bộ) **với nguồn thật**
(KTTV trên GitHub Pages, Open-Meteo, IOC) và kiểm:

- Đúng điểm/trạm/màn hình vừa sửa; ghi lại tọa độ đã thử.
- Đủ 4 trạng thái: đang tải · lỗi (tắt mạng) · rỗng · có dữ liệu (kể cả dữ liệu cũ).
- Điện thoại (430×932) và màn hình rộng; chế độ sáng/tối; cỡ chữ ×1.6.

## 2. Sau khi đăng

- `build.json` trên web trùng commit vừa đẩy.
- `data/kttv_tvhn.json` có `issued_utc` của bản tin mới nhất KTTV đã đăng.
- Mở lại các điểm đã kiểm trên bản web thật.

## 3. Công cụ dữ liệu (Python)

- `tools/nchmf/fetch_bulletin.py`: chạy với `--archive`/`--site` trỏ vào thư mục tạm để thử
  tải bản tin thật mà không sửa kho.
- `tools/tide/validate.py`: kiểm định mô hình triều với chuỗi IOC thật.
