# Dữ liệu dùng cho test — đều là bản lưu nguyên văn từ nguồn thật

Không có file nào được tự đặt số liệu. Mỗi file là phản hồi gốc của nguồn tại thời điểm tải, lưu lại để test chạy lặp lại được.

| File | Nguồn | Tải lúc | Ghi chú |
|---|---|---|---|
| `vung_20261104.json` | IOC Sea Level Monitoring, trạm `vung` | 04/11/2026 | Thực đo theo phút |
| `marine_vungtau_20261106.json` | Open-Meteo Marine, Vũng Tàu | 06/11/2026 | `sea_level_height_msl` |
| `marine_land_hanoi_20261110.json` | Open-Meteo Marine tại 21.045, 105.860 (Hà Nội, đất liền) | 10/11/2026 | Nguồn trả toàn giá trị rỗng: điểm không có biển |
| `om_hondau_20261025_20261112.json` | Open-Meteo Marine, Hòn Dấu | 10/11/2026 | Triều cửa sông Hồng |
| `forecast_cantho_20261106.json` | Open-Meteo Forecast, Cần Thơ | 06/11/2026 | Thời tiết |
| `kttv_tvhn_20261109.json` | Bản tin thủy văn KTTV 09/11/2026, đọc bằng `tools/nchmf/tvhn_parser.py` | 09/11/2026 | |
| `flood_hanoi_3x3_20261110.json` | Open-Meteo Flood (GloFAS), 3×3 ô quanh trạm Hà Nội | 10/11/2026 | Lưu lượng ngày |
| `openfreemap_liberty_20261109.json` | Kiểu bản đồ OpenFreeMap "liberty" | 09/11/2026 | |

Test thuật toán thuần (`test/core/calc/**`) có dùng tín hiệu hình sin tự tính để kiểm tra công thức; đó là phép tính kiểm chứng, không phải dữ liệu hiển thị cho người dùng.
