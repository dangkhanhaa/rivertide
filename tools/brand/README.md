# Biểu tượng app "Con Nước"

Logo: vầng trăng khuyết **là** lưỡi câu (treo trên dây câu), cá trắm lao vào mồi trong lòng trăng, con nước bên dưới.
Màu: navy `#0B3954`, vàng trăng `#F2C14E`, xanh nước `#3FC1C9`, trắng ngà `#F4F1EA`.

Tạo lại toàn bộ biểu tượng (Android, iOS, web, ảnh Store) từ một bản vẽ gốc:

```powershell
python -m pip install pillow   # một lần
python tools/brand/make_icons.py D:\2026\CaNhan\RiverTide
```

Cần Google Chrome (dùng để vẽ SVG ra PNG 1024 px). Ảnh iOS và ảnh Store không có kênh alpha (App Store yêu cầu).
Bản SVG gốc từng biến thể nằm ở `docs/brand/icon-*.svg`; ảnh Store: `docs/brand/play-store-icon-512.png`, `docs/brand/app-store-icon-1024.png`.
