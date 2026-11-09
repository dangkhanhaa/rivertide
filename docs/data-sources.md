# Khảo sát nguồn dữ liệu — kết quả P0-03

> Khảo sát ngày **2026-11-06** bằng truy cập trực tiếp (curl) từ máy dev.
> Fixtures đã lưu: `supabase/functions/*/__fixtures__/`, `tools/nchmf/fixtures/`, `tools/tide/fixtures/`.
> Nguyên tắc: chỉ dùng nguồn **truy cập công khai hợp lệ**. KHÔNG giả mạo trình duyệt, KHÔNG bỏ qua lỗi chứng chỉ, KHÔNG vượt cơ chế đăng nhập.

## 1. Tổng hợp

| Mã | Nguồn | Trạng thái | Dữ liệu dùng được | Tần suất | Vai trò |
|---|---|---|---|---|---|
| `ioc` | IOC Sea Level Monitoring | ✅ **Tốt** | Mực nước biển **thực đo** theo phút: **Vũng Tàu** (`vung`), **Quy Nhơn** (`quin`); lịch sử ≥ 2024 | ~1–5 phút | **Thực đo ven biển + fit hằng số triều** |
| `nchmf_tide` | KTTV Quốc gia: bản tin thủy triều 10 ngày (PDF) | ⚠ Dùng được, khó parse | Đỉnh/chân triều **dự báo** mỗi ngày, ~14 trạm ven biển | 1 lần/ngày | **Kiểm chứng triều** + dự báo trạm ven biển |
| `nchmf_tvhn` | KTTV Quốc gia: bản tin thủy văn hạn ngắn (PDF) | ⚠ Dùng được, khó parse | Mực nước **thực đo + dự báo**, mỗi 6 giờ hoặc đỉnh/chân ngày, khoảng 25 trạm sông chính | 1 lần/ngày | **Thực đo sông** (độ phân giải thấp) |
| `om_forecast` | Open-Meteo Forecast | ✅ Tốt | Mưa, gió, áp suất, mây, CAPE, mã thời tiết, mặt trời | Theo yêu cầu | Thời tiết, chỉ số câu cá |
| `om_marine` | Open-Meteo Marine | ✅ Tốt | Sóng, nhiệt độ mặt biển, **`sea_level_height_msl`** (mô hình triều toàn cầu) | Theo yêu cầu | Câu biển; **triều dự phòng** cho điểm ven biển |
| `om_elevation` | Open-Meteo Elevation | ⚠ Sai số lớn ở đồng bằng | Độ cao mặt đất | Theo yêu cầu | Chỉ hiển thị kèm cảnh báo |
| `om_flood` | Open-Meteo Flood (GloFAS) | ⚠ Sai nếu không chọn đúng ô | Lưu lượng dự báo | Theo yêu cầu | 🟡 Chỉ dùng với ô lưới chọn tay |
| `vietmap` | Vietmap | ✅ Gói Flutter có thật | `vietmap_flutter_gl` 4.1.1 (2026-08-05), `vietmap_flutter_plugin` 0.5.2 | — | Bản đồ |
| `mrc` | Ủy hội sông Mê Kông | ❌ Chưa dùng được | API `api.mrcmekong.org` trả **401 Unauthorized** | — | Cần **đăng ký quyền truy cập** chính thức |
| `vndms` | Cổng phòng chống thiên tai | ❌ Không dùng được | **Chứng chỉ SSL hết hạn** từ 06/10/2026 | — | Chờ họ sửa / liên hệ |
| `thuyloi` | thuyloivietnam.vn | ❌ Không dùng được | Chứng chỉ sai tên miền (`*.aceo.vn`), hết hạn 2024 | — | Bỏ |
| `kttvnb` | Đài KTTV Nam Bộ | ❌ Không dùng được | Chứng chỉ SSL hết hạn | — | Chờ / liên hệ |
| `siwrr` | Viện Khoa học Thủy lợi miền Nam | ⚠ Chỉ có bản tin tháng | Bản tin dự báo mặn ĐBSCL (trang bài viết) | Tháng | 🔵 Mặn |
| `uhslc` | UHSLC | ❌ Không kết nối được | Timeout từ máy dev | — | Không cần, đã có IOC |

## 2. Kết luận quan trọng (ảnh hưởng thiết kế)

### 2.1. Chưa có nguồn mực nước SÔNG thời gian thực công khai hợp lệ
- Nguồn chi tiết nhất (vndms, MRC, Đài KTTV Nam Bộ) đều **bị chặn**: chứng chỉ hết hạn hoặc phải đăng nhập.
- Nguồn dùng được là **bản tin PDF của KTTV Quốc gia**: khoảng 25 trạm sông chính, **4 mốc/ngày** hoặc đỉnh/chân ngày, cập nhật **1 lần/ngày** (khoảng 10:30).
- ➜ Bản dev: "thực đo" của trạm sông = số liệu bản tin (ghi rõ "cập nhật theo bản tin KTTV lúc …"). **Bỏ mục tiêu "cập nhật 15 phút cho trạm sông"**.
- ➜ Việc song song (không phải code): gửi đề nghị cấp quyền dữ liệu tới **MRC** (Mekong) và **Trung tâm KTTV / Cục Quản lý đê điều & PCTT** (vndms). Xem mục 4.

### 2.2. Thủy triều: có nền tảng tốt
- **IOC Vũng Tàu + Quy Nhơn**: thực đo theo phút, lịch sử ≥ 2 năm → **fit hằng số triều ngay** (đạt độ tin cậy "cao").
- **Bản tin triều 10 ngày KTTV**: ~14 trạm ven biển (Bạch Long Vĩ, Hòn Dấu, Sầm Sơn, Hòn Ngư, Cồn Cỏ, Sơn Trà, Hoàng Sa, Lý Sơn, Quy Nhơn, Trường Sa, Phú Quý, Vũng Tàu, DKI-7…) → dùng để **kiểm chứng** và làm **dữ liệu đỉnh/chân** cho các trạm này.
- **Open-Meteo Marine `sea_level_height_msl`**: mô hình triều cho mọi điểm ven biển → **dự phòng** cho điểm không có trạm (độ tin cậy "trung bình", cần kiểm chứng so với IOC).
- Trạm trong sông (Cần Thơ, Mỹ Thuận…): chưa có chuỗi thực đo dày → tạm dùng trạm tham chiếu + độ trễ (độ tin cậy "thấp") cho tới khi có dữ liệu.

### 2.3. Ingest PDF phải làm bằng Python, không phải Edge Function
- Bảng trong PDF bị **xô cột** và **lỗi bảng mã tiếng Việt** khi trích chữ thô (`pdftotext`) → cần thư viện đọc bảng theo tọa độ (`pdfplumber`) và bảng ánh xạ tên trạm.
- ➜ Kiến trúc: **GitHub Actions chạy Python mỗi ngày** (11:00 giờ VN) → parse PDF → ghi Supabase. Edge Functions chỉ ingest **IOC** (JSON, 15 phút/lần).

### 2.4. CAPE ở Việt Nam thường xuyên > 2000
- Cần Thơ ngày 06/11 (trời quang, mã thời tiết 0–2): CAPE **2070–2860**.
- ➜ Luật "CAPE > 2000 → chỉ số ≤ 2" sẽ **báo động giả gần như mỗi ngày**. Đã sửa (PROJECT.md 9.6): chỉ khóa điểm theo **mã thời tiết dông (95/96/99)** và gió giật; CAPE chỉ dùng cho **cảnh báo vàng** khi CAPE ≥ 3000 **và** xác suất mưa ≥ 50%.

### 2.5. Độ cao mặt đất mô hình bị lệch cao ở đồng bằng
- Open-Meteo Elevation: Cần Thơ **4 m**, Hà Nội (Hoàn Kiếm) **19 m**. Thực tế nội thành Cần Thơ chỉ khoảng 1–2 m.
- ➜ **Không** hiển thị kết luận "có thể ngập" trong bản dev. Chỉ hiện độ cao kèm cảnh báo sai số; so sánh ngập chuyển sang 🟡, khi người dùng tự nhập độ cao thật.

### 2.6. Lưu lượng GloFAS theo tọa độ bất kỳ không đáng tin
- Tọa độ Cần Thơ trả về khoảng **41 m³/s** (sông Hậu thực tế lên tới hàng nghìn m³/s) → ô lưới rơi vào kênh nhỏ.
- ➜ Chỉ dùng khi đã **chọn tay ô lưới đúng dòng chính** cho từng trạm (`stations.meta.glofas_lat/lon`). Giữ 🟡.

### 2.7. Độ liên tục (đo ngày 2026-11-06)

| Nguồn | Kết quả đo | Hệ quả thiết kế |
|---|---|---|
| IOC Vũng Tàu `ra2` | 30 ngày gần nhất: **98,1%** đầy đủ; 42 khoảng trống > 15 phút, dài nhất 76 phút. Tháng 11/2025: 98,4% | Ingest 15 phút, lấy lùi 6 giờ để tự lấp chỗ trống; nội suy khi trống ≤ 30 phút, còn dài hơn thì để trống |
| IOC Quy Nhơn `rad` | Trong cửa sổ 30 ngày, dữ liệu chỉ bắt đầu từ **14/10** (mất ~7 ngày); sau đó 97,2% | Có thể mất cả tuần → app phải hiện "mất dữ liệu" và dùng dự báo triều; cảnh báo admin khi trạm im > 6 giờ |
| Độ trễ IOC | Điểm mới nhất 07:25 UTC, lấy lúc ~07:30 UTC | Gần thời gian thực (≈ 5–10 phút) |
| Bản tin KTTV (PDF) | Ra **1 lần/ngày** (~10:30). Bài viết dùng **cùng 1 URL, nội dung bị thay mỗi ngày**. File PDF cũ vẫn còn trên `kttv.gov.vn/upload/...` nhưng **giờ trong tên file thay đổi** (tìm được 01/11 và 03/11, không đoán được 02, 04, 05/11) | Job hằng ngày **không được bỏ lỡ**: chạy 11:00, thử lại 13:00 và 16:00, lưu PDF gốc vào Storage. Bỏ lỡ 1 ngày = gần như mất số liệu ngày đó |
| Open-Meteo | Gọi theo yêu cầu, luôn có | Không lo; chỉ giới hạn ~10.000 lượt/ngày (gói miễn phí) → cache theo ô lưới |

## 3. Chi tiết từng nguồn

### `ioc` — IOC Sea Level Station Monitoring Facility

| Mục | Giá trị |
|---|---|
| Danh sách trạm | `GET https://www.ioc-sealevelmonitoring.org/service.php?query=stationlist&showall=all` (JSON ~2,4 MB, 2.344 bản ghi) |
| Dữ liệu | `GET https://www.ioc-sealevelmonitoring.org/service.php?query=data&code=<code>&timestart=YYYY-MM-DDTHH:MM&timestop=...&format=json` |
| Trạm VN | `vung`: Vũng Tàu (10.34, 107.071), cảm biến `ra2`, `ra3` (radar), `enc` (phao), `bat`, `sw1` (phụ) · `quin`: Quy Nhơn (13.7751, 109.2543), cảm biến `rad` |
| Định dạng | `[{ "slevel": 2.088, "stime": "2026-10-30 00:00:00", "sensor": "ra2" }, ...]` |
| Múi giờ | **UTC** (`UTCOffset: 0`) |
| Đơn vị | **mét**, mốc riêng của trạm |
| Biên độ quan sát (7 ngày) | Vũng Tàu 0,55 → 3,96 m · Quy Nhơn (1 ngày) 1,09 → 1,77 m |
| Lịch sử | Có dữ liệu 2024-06 và 2025-11 (đã thử) |
| Chất lượng | **Chưa QC** → phải lọc: chọn cảm biến chính (`ra2` cho vung, `rad` cho quin), so chéo `ra3`/`enc`, loại nhảy bất thường |
| Giới hạn | Mỗi yêu cầu nên ≤ 30 ngày; tôn trọng tần suất (15 phút/lần là đủ) |
| Điều khoản | ⚠ XÁC MINH trang điều khoản IOC; tối thiểu ghi nguồn "IOC Sea Level Station Monitoring Facility" |
| Kết luận | ✅ Nguồn chính cho thực đo ven biển + fit hằng số triều |

### `nchmf_tide` — Bản tin dự báo thủy triều 10 ngày

| Mục | Giá trị |
|---|---|
| Trang bài viết | `https://www.nchmf.gov.vn/kttv/vi-VN/1/ban-tin-du-bao-thuy-trieu-10-ngay-toi-tu-ngay-DD-MM-den-ngay-DD-MM-YYYY-post<id>.html` (id thay đổi mỗi ngày) |
| Tìm bài mới | Từ trang chủ `https://www.nchmf.gov.vn/kttv/` hoặc RSS `.../vi-VN/1/homerss.html` (⚠ chưa thử RSS) |
| File | PDF trong bài: `https://kttv.gov.vn//upload/haivan/YYYY/M/D/dbqg-tthv-YYYYMMDD_HHMM.pdf` |
| Nội dung | Mỗi trạm, mỗi ngày: `Hmax (cm)`, `Time_max`, `Hmin (cm)`, `Time_min` (có ngày 2 đỉnh/2 chân) |
| Múi giờ | Giờ VN (dạng `13h00`, `5h24`) |
| Đơn vị | cm |
| Khó khăn | Cột xô lệch khi trích chữ; font PDF làm hỏng dấu tiếng Việt → map tên trạm theo **thứ tự hàng** + bảng alias không dấu |
| robots.txt | Không chặn đường dẫn bài viết hoặc `kttv.gov.vn/upload` |
| Kết luận | ⚠ Dùng để kiểm chứng + bổ sung đỉnh/chân ven biển. Parser Python + test bằng fixture |

### `nchmf_tvhn` — Bản tin dự báo, cảnh báo thủy văn hạn ngắn

| Mục | Giá trị |
|---|---|
| Trang bài viết | `.../ban-tin-du-bao-thuy-van-han-ngan-post<id>.html` |
| File | `https://kttv.gov.vn//upload/thuyvan2/YYYY/M/D/dbqg_tvhn_YYYYMMDD_HHMM.pdf` |
| Nội dung | (I) Diễn biến bằng chữ theo lưu vực; (II) **Bảng mực nước thực đo** 4 mốc (13h, 19h, 1h, 7h) + **dự báo** 8 mốc tới, khoảng 12 trạm (Yên Bái, Phú Thọ, Tuyên Quang, Vụ Quang, Hà Nội, Nam Đàn, Thạnh Hòa, Tà Lài, Phước Hòa, Kon Tum, Giang Sơn, Krông Ana…; Hồ Hòa Bình là **lưu lượng**); bảng **đỉnh/chân 24–36 giờ** thực đo và dự báo các trạm triều (Đáp Cầu, Phủ Lạng Thương, Lục Nam, Phả Lại, Giàng, Linh Cảm, Mai Hóa, Kim Long, Câu Lâu, Trà Khúc, Phú Lâm…); bảng **đỉnh/chân ngày Tân Châu, Châu Đốc** (thực đo + dự báo 5 ngày) |
| Giờ phát hành | ~10:30 hằng ngày |
| Đơn vị | cm (lưu lượng m³/s có ghi chú `(*)`) |
| Khó khăn | Như trên + bảng nhiều tầng tiêu đề |
| Kết luận | ⚠ Nguồn thực đo sông duy nhất hiện có. Parser Python |

### `om_*` — Open-Meteo

| API | Endpoint đã thử | Kết quả |
|---|---|---|
| Forecast | `api.open-meteo.com/v1/forecast?...&hourly=temperature_2m,precipitation,precipitation_probability,weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_gusts_10m,wind_direction_10m,cape,is_day&daily=sunrise,sunset,precipitation_sum,wind_speed_10m_max,weather_code&timezone=Asia/Ho_Chi_Minh&forecast_days=7&past_days=1` | ✅ 200, 14 KB, đủ mọi trường |
| Flood | `flood-api.open-meteo.com/v1/flood?...&daily=river_discharge,river_discharge_max&forecast_days=7` | ✅ 200 nhưng số liệu sai dòng chính (xem 2.6) |
| Elevation | `api.open-meteo.com/v1/elevation?latitude=a,b,c&longitude=x,y,z` | ✅ nhiều điểm/lần gọi; lệch cao (2.5) |
| Marine | `marine-api.open-meteo.com/v1/marine?...&hourly=wave_height,wave_period,sea_surface_temperature,sea_level_height_msl` | ✅ có `sea_level_height_msl` dao động theo triều (1,79 → 0,11 m) |

Điều khoản: miễn phí cho **phi thương mại**, ghi nguồn CC BY 4.0.

### `mrc` — Mekong River Commission

- Trang công khai `monitoring.mrcmekong.org` (Angular) gọi `https://api.mrcmekong.org/api/v1/time-series/telemetry/recent` (+ `/station`), có luồng `/login`.
- Gọi trực tiếp: **401 Unauthorized**. Mình không thử vượt qua.
- Việc cần làm: tìm cổng dữ liệu / đăng ký API key chính thức của MRC (⚠ XÁC MINH quy trình), hoặc gửi email đề nghị.

### `vndms`, `thuyloi`, `kttvnb` — Không dùng được

| Host | Lỗi | Chi tiết chứng chỉ |
|---|---|---|
| `vndms.dmc.gov.vn` | `SEC_E_CERT_EXPIRED` | Let's Encrypt, hết hạn **2026-10-06** |
| `thuyloivietnam.vn` | `SEC_E_CERT_EXPIRED` | Chứng chỉ của `*.aceo.vn`, hết hạn 2024-11-30 |
| `kttvnb.vn` | `SEC_E_CERT_EXPIRED` | — |

Không bỏ qua kiểm tra chứng chỉ (rủi ro bảo mật, Edge Function cũng sẽ từ chối). Kiểm tra lại mỗi tháng.

### `vietmap`

- `vietmap_flutter_gl` **4.1.1** (pub.dev, 2026-08-05): bản đồ.
- `vietmap_flutter_plugin` **0.5.2** (2025-10-27): API tìm kiếm, địa chỉ. Theo kiến trúc, gọi API này **qua Edge Function**, không gọi từ app.
- `maps.vietmap.vn` truy cập được. ⚠ XÁC MINH bảng giá & hạn mức khi đăng ký.

## 4. Đề nghị cấp dữ liệu (việc của chủ dự án)

| Nơi | Nội dung xin | Ghi chú |
|---|---|---|
| MRC (Ủy hội sông Mê Kông) | Quyền truy cập API mực nước trạm Tân Châu, Châu Đốc, Cần Thơ, Mỹ Thuận… (15 phút) | Nêu mục đích phi thương mại, cộng đồng |
| Trung tâm Dự báo KTTV Quốc gia | Dữ liệu mực nước giờ các trạm thủy văn, định dạng máy đọc được | Hỏi luôn điều kiện sử dụng lại |
| Cục Quản lý đê điều & PCTT (vndms) | Báo lỗi chứng chỉ; hỏi API công khai | |
| IOC | Xác nhận điều khoản dùng lại dữ liệu trong app | |

## 5. Danh mục trạm khả thi cho bản dev (đầu vào P0-04)

| Nhóm | Số trạm | Nguồn | Loại dữ liệu |
|---|---|---|---|
| Triều ven biển có thực đo | 2 (Vũng Tàu, Quy Nhơn) | IOC | Thực đo phút + dự báo triều (fit) |
| Triều ven biển chỉ dự báo | ~12 | nchmf_tide (+ Open-Meteo Marine) | Đỉnh/chân dự báo |
| Sông chính (thực đo 6 giờ) | ~12 | nchmf_tvhn | Thực đo + dự báo |
| Trạm triều trong sông (đỉnh/chân ngày) | ~11 + Tân Châu, Châu Đốc | nchmf_tvhn | Đỉnh/chân thực đo + dự báo |
| **Tổng** | **~38–40** | | |

➜ Mục tiêu P0-04 sửa từ "≥ 50 trạm" thành **"~40 trạm từ nguồn hợp lệ hiện có"**. Mở rộng khi được cấp dữ liệu (mục 4).
