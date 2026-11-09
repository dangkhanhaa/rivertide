# FEATURES.md — Mô tả sản phẩm & đặc tả tính năng RiverTide

> **File này trả lời: app làm GÌ, cho AI, hoạt động THẾ NÀO, và thế nào là ĐÚNG.**
> Kỹ thuật (CSDL, API, thuật toán, roadmap): [PROJECT.md](PROJECT.md) · Luật code: [CLAUDE.md](CLAUDE.md)
>
> Mỗi tính năng có mã `F-xxx` (khớp PROJECT.md mục 11) và **Tiêu chí chấp nhận (AC)** — AI phải code đạt đủ AC, người dùng dùng AC để nghiệm thu.
> Ưu tiên: 🟢 MVP (bản dev) · 🟡 Bản 2 · 🔵 Bản 3 · ⚪ Để sau

---

## Mục lục

**Phần A — Sản phẩm**
1. [Tầm nhìn & vấn đề](#1-tầm-nhìn--vấn-đề)
2. [Người dùng & hành trình](#2-người-dùng--hành-trình)
3. [Khái niệm nền (đọc trước)](#3-khái-niệm-nền)
4. [Quy tắc nghiệp vụ chung](#4-quy-tắc-nghiệp-vụ-chung)
5. [Cách đọc đặc tả](#5-cách-đọc-đặc-tả)

**Phần B — Đặc tả tính năng**
6. [Khởi động & khung app](#6-khởi-động--khung-app)
7. [Bản đồ](#7-bản-đồ)
8. [Mực nước](#8-mực-nước)
9. [Thủy triều & con nước](#9-thủy-triều--con-nước)
10. [Điểm bất kỳ](#10-điểm-bất-kỳ)
11. [Theo dõi (yêu thích)](#11-theo-dõi-yêu-thích)
12. [Câu cá](#12-câu-cá)
13. [An toàn](#13-an-toàn)
14. [Cảnh báo & thông báo](#14-cảnh-báo--thông-báo)
15. [Thời tiết](#15-thời-tiết)
16. [Nông nghiệp & ghe thuyền](#16-nông-nghiệp--ghe-thuyền)
17. [Tài khoản & đồng bộ](#17-tài-khoản--đồng-bộ)
18. [Cài đặt & thông tin](#18-cài-đặt--thông-tin)
19. [Quản trị](#19-quản-trị)
20. [Ngoài phạm vi](#20-ngoài-phạm-vi)

---

# PHẦN A — SẢN PHẨM

## 1. Tầm nhìn & vấn đề

### 1.1. Vấn đề
- Người dân ven sông, dân câu cá, nông dân cần biết **nước đang lên hay xuống, bao giờ đổi con nước, có ngập không** — nhưng thông tin nằm rải rác trên nhiều trang web nhà nước, khó xem trên điện thoại, không có thông báo, không dùng được khi mất mạng.
- Bảng thủy triều in sẵn chỉ có ở vài trạm ven biển, khó tra.
- Dân câu dựa vào kinh nghiệm "con nước", "trăng" — chưa có app tiếng Việt gom đủ **con nước + trăng + thời tiết + áp suất** thành một chỉ số dễ hiểu.

### 1.2. Giải pháp
Một app di động **miễn phí, tiếng Việt, toàn quốc** gồm:
1. Mực nước **thực đo** tại các trạm, kèm mức báo động.
2. **Dự báo thủy triều** tính sẵn trên máy, xem được khi mất mạng.
3. **Con nước theo âm lịch** + **trăng** + **thời tiết** → **chỉ số câu cá** và **giờ vàng**.
4. **Cảnh báo** khi nước lên cao, dông sét, nước sắp ngập chỗ đứng câu.
5. **Bấm vào bất kỳ đâu trên bản đồ** để xem ước tính tại điểm đó.

### 1.3. Giá trị cốt lõi (thứ tự ưu tiên khi phải đánh đổi)
1. **Đúng & trung thực** — thà nói "không có dữ liệu" còn hơn hiện số sai; luôn ghi nguồn & nhãn ước tính.
2. **An toàn người dùng** — cảnh báo nguy hiểm luôn được ưu tiên hiển thị.
3. **Nhanh & nhẹ** — mở là thấy số, máy yếu vẫn mượt, mất mạng vẫn dùng.
4. **Dễ hiểu** — người lớn tuổi đọc được, dùng từ quen thuộc.
5. **Nhiều tính năng** — chỉ thêm khi không phá 4 điều trên.

### 1.4. Mục tiêu bản dev (Giai đoạn 1)
- ~40 trạm từ nguồn hợp lệ hiện có (xem [docs/data-sources.md](docs/data-sources.md)): trạm ven biển IOC cập nhật 15 phút; trạm sông cập nhật theo bản tin KTTV 1 lần/ngày (ghi rõ trên UI).
- Vũng Tàu & Quy Nhơn có dự báo triều đạt chuẩn sai lệch (PROJECT.md 9.1); ~12 trạm ven biển có đỉnh/chân dự báo từ bản tin.
- Đủ tính năng 🟢 trong file này, đạt toàn bộ AC.
- 3–5 người quen cài thử được.

---

## 2. Người dùng & hành trình

### 2.1. Chân dung người dùng

| Mã | Chân dung | Bối cảnh | Cần nhất | Nỗi lo |
|---|---|---|---|---|
| **U1** | **Dân câu cá cuối tuần**, 25–55 tuổi, ở thành phố, đi câu sông/kênh/cửa sông | Lên kế hoạch tối thứ 6, kiểm tra lại sáng sớm tại chỗ câu (mạng yếu) | Hôm nào, giờ nào câu ngon; con nước; thời tiết | Đi xa mà không có cá; bị dông; nước lên ngập bãi |
| **U2** | **Dân câu chuyên / câu lure**, ghi chép kỹ | Câu nhiều điểm, muốn rút kinh nghiệm | Nhật ký, thống kê, điểm câu bí mật | Lộ điểm câu |
| **U3** | **Người dân ven sông / đô thị triều cường** (Cần Thơ, TP.HCM…), 35–70 tuổi | Mùa triều cường, mùa lũ | Bao giờ nước lớn nhất, có ngập nhà không | Ngập bất ngờ ban đêm |
| **U4** | **Nông dân / nuôi thủy sản** ĐBSCL | Lấy nước vào ruộng/ao theo con nước, lo mặn | Giờ nước lớn, con nước tuần tới, mặn | Lấy nhầm nước mặn |
| **U5** | **Chủ ghe / tàu sông** | Đi qua cầu thấp, luồng cạn | Giờ nước ròng/lớn | Kẹt cầu, mắc cạn |
| **U6** | **Người miền Trung / miền Bắc vùng lũ** | Mùa mưa bão | Mực nước so với báo động, mưa | Lũ lên nhanh |

### 2.2. Hành trình chính (phải mượt nhất)

**J1 — U1 lên kế hoạch đi câu (tối thứ 6)**
1. Mở app → tab **Câu cá** → chọn điểm câu đã lưu (hoặc vị trí hiện tại).
2. Xem dải **7 ngày** → thấy Thứ 7 điểm 8.2, Chủ nhật 5.1.
3. Chạm Thứ 7 → thấy **Giờ vàng 05:10–07:00** (bình minh + nước ròng) và **16:30–18:20**.
4. Bấm 🔔 "Nhắc tôi trước giờ vàng" → nhận thông báo 04:30 sáng thứ 7.
⏱ Mục tiêu: < 30 giây, ≤ 5 lần chạm.

**J2 — U3 kiểm tra triều cường (chiều tối)**
1. Mở app → tab **Theo dõi** → thẻ trạm gần nhà: "1,92 m · Đang lên · Đỉnh triều 18:40 (còn 1 giờ 20 phút) · dự kiến 2,05 m — **vượt BĐ II**".
2. Chạm thẻ → xem biểu đồ: đường dự báo vượt vạch BĐ II.
3. Bấm **Đặt cảnh báo** khi vượt BĐ II.
⏱ Mục tiêu: thông tin chính thấy được **ngay trên thẻ**, không cần mở chi tiết.

**J3 — U1 tại bãi câu (mạng yếu)**
1. Mở app (offline) → tab Câu cá vẫn hiện chỉ số (phần triều/trăng tính trên máy; thời tiết dùng bản lưu, có nhãn "cập nhật lúc …").
2. Bật **"Nước sắp ngập bãi"** 🟡 → nhập "chỗ đứng cao hơn mặt nước 40 cm" → app báo trước 45 & 15 phút.

**J4 — U4 tra lịch con nước tháng**
1. Tab **Thêm → Lịch triều** → chọn trạm → lưới tháng có ngày âm, chấm màu nước rong/kém.
2. Chạm ngày → giờ đỉnh/chân trong ngày.

**J5 — Ai đó bấm vào bản đồ ở vị trí ruộng nhà**
1. Tab **Bản đồ** → nhấn giữ vị trí → bottom sheet: địa danh, trạm gần nhất, **ước tính** mực nước & giờ triều, độ cao đất, thời tiết.
2. Bấm **Lưu điểm** → chọn loại "Ruộng" → điểm xuất hiện trong tab Theo dõi.

---

## 3. Khái niệm nền

> AI và người đọc PHẢI hiểu các khái niệm này trước khi code tính năng liên quan.

| Khái niệm | Giải thích | Trong app |
|---|---|---|
| **Mực nước** | Độ cao mặt nước so với **mốc cao độ** của trạm (không phải độ sâu) | Hiển thị mét, 2 chữ số thập phân; nội bộ cm |
| **Mốc cao độ** | Mức "0" của trạm. Mỗi trạm/nguồn có thể khác nhau (Hòn Dấu, Mũi Nai, hải đồ…) | **Không so sánh** mực nước giữa 2 trạm khác mốc |
| **Báo động I/II/III** | Ngưỡng lũ chính thức theo trạm; III nguy hiểm nhất | Màu vàng/cam/đỏ |
| **Thủy triều** | Nước lên xuống theo chu kỳ do mặt trăng/mặt trời; ảnh hưởng sâu vào sông vùng hạ lưu | Chỉ trạm `has_tide` |
| **Bán nhật triều / nhật triều** | 2 lần lên xuống/ngày (phổ biến Nam Bộ, có thể không đều) / 1 lần/ngày (vùng Hòn Dấu, Bắc Bộ) | Thuật toán xử lý chung, không giả định số đỉnh/ngày |
| **Đỉnh / chân triều** | Điểm cao nhất / thấp nhất của 1 chu kỳ | Giờ + độ cao |
| **Nước đứng** | Quanh lúc đổi chiều, nước gần như không lên xuống | Tốc độ < 3 cm/giờ |
| **Con nước** | Cách gọi dân gian chu kỳ ~15 ngày: **nước rong** (biên độ lớn, quanh mùng 1 & rằm), **nước kém** (biên độ nhỏ, quanh mùng 8 & 23), **nước nhảy** (con nước mới, khoảng mùng 10 & 25) | Nhãn + màu trên lịch |
| **Triều cường** | Nước lớn bất thường (nước rong + gió + lũ) gây ngập đô thị | Cảnh báo theo ngưỡng |
| **Thực đo / Dự báo / Ước tính** | Số đo thật từ trạm / tính bằng mô hình triều / nội suy tại điểm không có trạm | 3 kiểu hiển thị khác nhau (mục 4.3) |
| **Solunar** | Lý thuyết dân câu: cá hoạt động mạnh khi trăng lên đỉnh/xuống chân (giờ chính), trăng mọc/lặn (giờ phụ) | Một thành phần của chỉ số câu cá |
| **Chỉ số câu cá** | Điểm 0–10 tổng hợp con nước, solunar, áp suất, thời điểm, thời tiết, mùa | Luôn ghi "tham khảo" |

---

## 4. Quy tắc nghiệp vụ chung

Áp dụng cho **mọi** tính năng. Code tập trung trong `core/` để dùng chung.

### 4.1. Trạng thái trạm (màu marker, thẻ)

Xét theo thứ tự, gặp điều kiện đầu tiên thì dừng:

| # | Điều kiện | Trạng thái | Màu | Chữ |
|---|---|---|---|---|
| 1 | Không có thực đo trong **6 giờ** | `stale` | xám | "Mất dữ liệu" |
| 2 | `level ≥ alarm3` | `alarm3` | đỏ | "Báo động III" |
| 3 | `level ≥ alarm2` | `alarm2` | cam | "Báo động II" |
| 4 | `level ≥ alarm1` | `alarm1` | vàng | "Báo động I" |
| 5 | còn lại | `normal` | xanh | "Bình thường" |

Trạm không có ngưỡng báo động → chỉ `stale` hoặc `normal`.

### 4.2. Xu hướng (thực đo)

`rate` = thay đổi trong ~1 giờ gần nhất (cm/giờ), lấy từ `delta_1h_cm`.

| Điều kiện | Xu hướng | Biểu tượng |
|---|---|---|
| `rate ≥ +2` | Đang lên | ▲ |
| `rate ≤ −2` | Đang xuống | ▼ |
| `|rate| < 2` | Đứng | ■ |
| `rate ≥ +20` | **Lên nhanh** (kèm cảnh báo) | ⏫ đỏ |

> Ngưỡng trạng thái *dự báo triều* dùng 3 cm/giờ (PROJECT.md 9.1) — khác thực đo vì dữ liệu mượt hơn.

### 4.3. Phân biệt loại số liệu

| Loại | Biểu đồ | Thẻ số | Nhãn bắt buộc |
|---|---|---|---|
| Thực đo | Nét liền, màu `water` | Chữ đậm | "Thực đo · <nguồn> · <x phút trước>" |
| Dự báo triều | Nét đứt, màu `tidePred` | Chữ thường | "Dự báo (tham khảo)" |
| Ước tính tại điểm | Nền sọc | `EstimateBadge` | "Ước tính · độ tin cậy: cao/trung bình/thấp" |
| Dữ liệu cũ (cache) | Như loại gốc | Như loại gốc | `StaleBanner` "Ngoại tuyến · cập nhật lúc HH:mm" |

### 4.4. Độ mới dữ liệu

| Tuổi dữ liệu | Hiển thị |
|---|---|
| < 1 giờ | "x phút trước" |
| 1–6 giờ | "x giờ trước" (chữ màu cảnh báo nhẹ) |
| > 6 giờ | Trạng thái `stale`, ẩn xu hướng, chỉ hiện "Số liệu cuối: HH:mm dd/MM" |

### 4.5. Định dạng

| Loại | Quy tắc | Ví dụ |
|---|---|---|
| Mực nước | mét, 2 chữ số, dấu phẩy | `2,85 m` (cài đặt có thể chọn cm: `285 cm`) |
| Tốc độ | dấu +/−, cm/giờ | `+6 cm/giờ` |
| Giờ | 24h | `05:10` |
| Ngày | thứ viết tắt + ngày/tháng + âm lịch | `T7, 08/11 (18/9 ÂL)` |
| Đếm ngược | < 1 giờ: "x phút"; ≥ 1 giờ: "x giờ y phút"; ≥ 24 giờ: "x ngày y giờ" | `2 giờ 15 phút` |
| Khoảng cách | < 1 km: m; ≥ 1 km: 1 chữ số | `850 m`, `8,2 km` |
| Nhiệt độ, gió, mưa | | `29 °C`, `15 km/h`, `12 mm` |
| Chỉ số câu cá | 1 chữ số + mức | `8,2 · Tốt` |

Mức chỉ số câu cá: `≥ 8` **Rất tốt** · `6.5–7.9` **Tốt** · `4.5–6.4` **Trung bình** · `2.5–4.4` **Kém** · `< 2.5` **Rất kém / Nguy hiểm** (nếu do luật an toàn).

### 4.6. Ghi nguồn
Mọi khối số liệu có dòng `SourceAttribution` nhỏ: "Nguồn: <tên nguồn>" (lấy `sources.attribution`). Thời tiết: "Open-Meteo.com". Bản đồ: logo/ghi nguồn Vietmap theo yêu cầu của họ.

### 4.7. Thời gian & múi giờ
Mọi giờ hiển thị theo **giờ Việt Nam (UTC+7)** bất kể múi giờ của điện thoại. Ngày âm lịch tính theo UTC+7.

### 4.8. Khi thiếu dữ liệu
| Thiếu | Xử lý |
|---|---|
| Không có ngưỡng báo động | Ẩn `AlarmLevelBar` |
| Trạm không triều | Ẩn mọi khối triều, chỉ số câu cá dùng thành phần dòng chảy |
| Chưa có file triều năm | Khối triều hiện "Chưa có dự báo triều cho trạm này" |
| Thời tiết lỗi, không cache | Chỉ số câu cá tính với các thành phần còn lại + nhãn "thiếu dữ liệu thời tiết" |
| Không có vị trí (chưa cấp quyền) | Dùng vùng mặc định (toàn VN), gợi ý cấp quyền 1 lần, không hỏi lại liên tục |

---

## 5. Cách đọc đặc tả

Mỗi tính năng viết theo khung:

- **Mục đích** — vì sao có tính năng này, cho ai (U1–U6).
- **Mô tả** — tính năng làm gì.
- **Luồng** — các bước người dùng.
- **Quy tắc** — logic nghiệp vụ bắt buộc.
- **Trạng thái** — tải / lỗi / rỗng / offline.
- **AC** — Tiêu chí chấp nhận, đánh số `AC-<mã>-n`. Viết dạng **"Khi … thì …"**. Đây là thứ để kiểm tra "xong".
- **Ngoại lệ** — tình huống đặc biệt.

---

# PHẦN B — ĐẶC TẢ TÍNH NĂNG

## 6. Khởi động & khung app

### F-UX-03 · Onboarding chọn vai trò 🟢
**Mục đích:** Cá nhân hóa màn hình đầu cho đúng nhu cầu (U1–U6).
**Luồng:**
1. Trang 1: Logo + "Mực nước, thủy triều và giờ câu cá — cho cả nước." + nút **Bắt đầu**.
2. Trang 2: "Bạn dùng app để làm gì?" — chọn nhiều: 🎣 Câu cá · 🏠 Theo dõi nước gần nhà · 🌾 Nông nghiệp / nuôi trồng · ⛴ Ghe thuyền · 🌊 Theo dõi lũ.
3. Trang 3: Giải thích quyền vị trí ("Để tìm trạm gần bạn. App chỉ dùng vị trí khi bạn đang mở app.") → **Cho phép** / **Để sau**.
4. Vào app.

**Quy tắc:**
- Chọn 🎣 → tab mặc định khi mở app là **Câu cá**; không chọn → **Theo dõi** (nếu có mục theo dõi) hoặc **Bản đồ**.
- Lựa chọn lưu cục bộ, sửa được trong Cài đặt.
- Có nút **Bỏ qua** ở mọi trang.

**AC:**
- AC-UX03-1: Khi mở app lần đầu thì hiện onboarding; lần sau không hiện.
- AC-UX03-2: Khi chọn "Câu cá" và hoàn tất thì app mở vào tab Câu cá ở mọi lần mở sau.
- AC-UX03-3: Khi bấm "Để sau" ở quyền vị trí thì không có hộp thoại xin quyền của hệ thống xuất hiện.
- AC-UX03-4: Khi bấm "Bỏ qua" ở bất kỳ trang nào thì vào app với cài đặt mặc định.

### F-UX-01 · Giao diện sáng/tối, tiếng Việt, cỡ chữ lớn 🟢
**Quy tắc:** Mặc định theo hệ thống; Cài đặt cho chọn Sáng/Tối/Theo máy. Toàn bộ chữ tiếng Việt từ file l10n. Tôn trọng cỡ chữ hệ thống tới ×1.6; Cài đặt có thêm tùy chọn "Chữ lớn" (×1.3 cộng dồn, trần ×2.0).
**AC:**
- AC-UX01-1: Khi đổi chế độ tối trong máy thì app đổi theo ngay, không cần khởi động lại.
- AC-UX01-2: Khi cỡ chữ hệ thống lớn nhất thì các màn hình S02–S06 không bị tràn chữ (không có vạch sọc vàng-đen overflow).
- AC-UX01-3: Không có chuỗi tiếng Anh nào hiện ra cho người dùng (trừ tên riêng, đơn vị).

### F-UX-02 · Offline-first 🟢
**Mô tả:** App dùng được khi mất mạng với dữ liệu đã lưu; phần tính toán (triều, âm lịch, trăng, mặt trời) luôn chạy.
**Quy tắc:**
- Mở app offline: hiện ngay dữ liệu lưu gần nhất + `StaleBanner`.
- Có mạng lại: tự làm mới màn hình đang xem (không làm mới tất cả).
- File triều của trạm trong Theo dõi được tải sẵn **năm hiện tại + năm sau**.
- Dung lượng cache tối đa mặc định 100 MB; vượt → xóa dữ liệu ít dùng nhất (trừ file triều trạm theo dõi).

**AC:**
- AC-UX02-1: Khi đã xem trạm A lúc có mạng, bật chế độ máy bay, mở lại app thì trạm A hiện mực nước cuối + banner "Ngoại tuyến · cập nhật lúc …".
- AC-UX02-2: Khi offline, đếm ngược đỉnh/chân triều của trạm theo dõi vẫn chạy đúng.
- AC-UX02-3: Khi offline và mở trạm chưa từng xem thì hiện `ErrorView` "Chưa có dữ liệu ngoại tuyến cho trạm này" + nút Thử lại.
- AC-UX02-4: Khi có mạng trở lại thì banner tự biến mất sau lần làm mới thành công.

### Khung điều hướng 🟢
5 tab: 🗺 **Bản đồ** · ⭐ **Theo dõi** · 🎣 **Câu cá** · 🔔 **Cảnh báo** · ☰ **Thêm**.
- Mỗi tab giữ trạng thái (vị trí cuộn, vùng bản đồ) khi chuyển qua lại.
- Nhấn lại tab đang mở → cuộn lên đầu / về vị trí của tôi (bản đồ).
- Nút Back Android: trong tab con → lùi; ở gốc tab khác "Bản đồ"/tab mặc định → về tab mặc định; ở tab mặc định → thoát.

---

## 7. Bản đồ

### F-MAP-01 · Bản đồ trạm 🟢
**Mục đích:** Tìm trạm trực quan, thấy ngay vùng nào nước đang cao.
**Mô tả:** Bản đồ Vietmap toàn VN, marker cho mỗi trạm.
**Quy tắc:**
- Marker = chấm tròn màu theo **4.1** + mũi tên xu hướng nhỏ (**4.2**) + biểu tượng sóng nhỏ nếu `has_tide`.
- **Gom cụm** khi nhiều trạm gần nhau ở mức zoom thấp; cụm hiện số lượng và **màu của trạm nghiêm trọng nhất** trong cụm.
- Chỉ tải trạm trong khung nhìn (+10% lề), debounce 400 ms.
- Mở lần đầu: có quyền vị trí → zoom vào vị trí (bán kính ~30 km); không → toàn VN.
- Bộ lọc (nút phễu): ☐ Chỉ trạm có triều · ☐ Chỉ trạm đang báo động · ☐ Ẩn trạm mất dữ liệu.
- Chú giải màu (nút ⓘ).

**Trạng thái:** đang tải → bản đồ hiện, marker hiện dần + thanh tiến trình mảnh trên cùng; lỗi → snackbar "Không tải được danh sách trạm" + Thử lại; offline → marker từ cache + `StaleBanner`.

**AC:**
- AC-MAP01-1: Khi mở tab Bản đồ thì thấy marker các trạm trong vùng nhìn trong ≤ 2 giây (có mạng 4G).
- AC-MAP01-2: Khi một trạm có mực nước ≥ BĐ II thì marker màu cam và chú giải ghi "Báo động II".
- AC-MAP01-3: Khi trạm không có số liệu > 6 giờ thì marker màu xám.
- AC-MAP01-4: Khi thu nhỏ bản đồ ra toàn quốc thì marker gom cụm, bản đồ vẫn kéo mượt (không giật rõ rệt trên máy tầm thấp).
- AC-MAP01-5: Khi bật lọc "Chỉ trạm đang báo động" thì chỉ còn trạm vàng/cam/đỏ.

### F-MAP-02 · Bottom sheet trạm 🟢
**Luồng:** Chạm marker → sheet nấc thấp hiện: tên trạm · sông · mực nước lớn · xu hướng · trạng thái · (nếu triều) "Đỉnh triều 14:40 · còn 2 giờ 15 phút" · nút **Xem chi tiết** · ⭐.
- Kéo sheet lên nấc giữa: thêm biểu đồ mini 24h.
**AC:**
- AC-MAP02-1: Khi chạm marker thì sheet hiện trong ≤ 300 ms với dữ liệu đã có (không chờ mạng nếu có cache).
- AC-MAP02-2: Khi bấm ⭐ thì trạm được thêm vào Theo dõi và biểu tượng đổi trạng thái ngay.
- AC-MAP02-3: Khi bấm "Xem chi tiết" thì mở màn hình Chi tiết trạm đúng trạm đó.

### F-MAP-03 · Nhấn giữ điểm bất kỳ 🟢
**Luồng:** Nhấn giữ 0,5 giây trên bản đồ → rung nhẹ → thả ghim → sheet **Chi tiết điểm** (xem F-POINT-01).
**Quy tắc:** Điểm ngoài biên VN (PROJECT.md 8.3) → snackbar "Vị trí nằm ngoài vùng hỗ trợ". Chỉ 1 ghim tạm tại một thời điểm; ghim mới thay ghim cũ.
**AC:**
- AC-MAP03-1: Khi nhấn giữ vào một điểm ở Cần Thơ thì ghim xuất hiện và sheet hiện tên địa danh + ít nhất 1 trạm gần nhất.
- AC-MAP03-2: Khi nhấn giữ ngoài biển xa (ngoài biên) thì không gọi API và hiện thông báo ngoài vùng.

### F-MAP-04 · Định vị & tìm kiếm 🟢
**Mô tả:**
- Nút ◎: về vị trí hiện tại (xin quyền nếu chưa, kèm giải thích).
- Ô tìm kiếm: tìm **tên trạm** (cục bộ, tức thì) và **địa danh** (qua Edge Function `geocode`, debounce 500 ms, tối thiểu 2 ký tự). Kết quả nhóm: "Trạm" trước, "Địa điểm" sau.
- Tìm không dấu vẫn khớp ("can tho" → "Cần Thơ").
**AC:**
- AC-MAP04-1: Khi gõ "tan chau" thì trạm Tân Châu (nếu có trong danh mục) xuất hiện ở nhóm Trạm.
- AC-MAP04-2: Khi chọn một địa điểm thì bản đồ bay tới đó và thả ghim tạm.
- AC-MAP04-3: Khi từ chối quyền vị trí vĩnh viễn thì nút ◎ mở hộp thoại hướng dẫn vào Cài đặt hệ thống.

### F-MAP-05 · Lớp vệ tinh 🟡
Nút lớp bản đồ: **Thường / Vệ tinh** (nếu Vietmap hỗ trợ). Lưu lựa chọn.

### F-MAP-06 · Thanh trượt thời gian 🟡
Thanh trượt −24 giờ → +48 giờ dưới bản đồ: marker trạm có triều đổi màu/số theo **dự báo** tại thời điểm chọn (nét đứt/viền rỗng để phân biệt với thực đo). Nút ▶ phát hoạt ảnh.

### F-MAP-07 · Lớp mưa 🟡
Lớp tô màu lượng mưa dự báo theo giờ (lưới từ Open-Meteo, độ phân giải thô) — kèm chú giải mm/giờ.

### F-MAP-08 · Lớp nguy cơ ngập 🔵
Tô vùng có độ cao đất thấp hơn mực nước dự báo tối đa 24 giờ tới (nhãn "tham khảo", độ phân giải thô).

### F-MAP-09 · Đo khoảng cách, vẽ vùng 🔵
Chạm lần lượt các điểm → hiện tổng khoảng cách / diện tích (ha).

---

## 8. Mực nước

### F-WL-01 · Mực nước hiện tại 🟢
**Mục đích:** Câu hỏi số 1 của mọi người: "Nước giờ bao nhiêu, lên hay xuống?"
**Mô tả (khối `LevelHero` trên Chi tiết trạm & thẻ Theo dõi):**
- Số lớn: `2,85 m`.
- Xu hướng: "▲ Đang lên · +6 cm/giờ" (theo **4.2**).
- Trạng thái: chip màu "Bình thường" / "Báo động I"…
- Dòng nguồn: "Thực đo · Nguồn: … · 5 phút trước".

**AC:**
- AC-WL01-1: Khi `level_cm = 285` thì hiển thị "2,85 m" (cài đặt mét) hoặc "285 cm" (cài đặt cm).
- AC-WL01-2: Khi `delta_1h_cm = 25` thì hiển thị "Lên nhanh" màu đỏ.
- AC-WL01-3: Khi số liệu cuối cách đây 7 giờ thì không hiện xu hướng, hiện "Mất dữ liệu · Số liệu cuối: HH:mm dd/MM".
- AC-WL01-4: Trình đọc màn hình đọc được: "Mực nước 2,85 mét, đang lên 6 xăng-ti-mét mỗi giờ, bình thường".

### F-WL-02 · Thanh báo động 🟢
**Mô tả:** Thanh ngang thể hiện mực nước hiện tại so với BĐ I/II/III; dưới thanh: "Còn 0,65 m tới Báo động I" hoặc "Vượt Báo động II 0,12 m".
**Quy tắc:** Thang thanh từ `min(level, alarm1 − 100 cm)` đến `max(level, alarm3 + 50 cm)`. Ẩn nếu trạm không có ngưỡng.
**AC:**
- AC-WL02-1: Khi level 285, BĐ I 350 thì hiện "Còn 0,65 m tới Báo động I".
- AC-WL02-2: Khi level 412, BĐ II 400, BĐ III 450 thì hiện "Vượt Báo động II 0,12 m · còn 0,38 m tới Báo động III".

### F-WL-03 · Biểu đồ mực nước 🟢 (24h–30 ngày) / 🟡 (1 năm)
**Mô tả:** Biểu đồ đường; nút chọn khoảng: **24 giờ · 3 ngày · 7 ngày · 30 ngày** (· 1 năm 🟡).
**Quy tắc:**
- Thực đo: nét liền. Dự báo triều (trạm có triều): nét đứt, từ thời điểm hiện tại tới +24 giờ (24h), +3 ngày (3 ngày/7 ngày); 30 ngày không vẽ dự báo.
- Vạch ngang mờ BĐ I/II/III (nếu có) có nhãn.
- Vạch dọc "Bây giờ".
- Đánh dấu đỉnh/chân triều trên đường dự báo (chấm nhỏ + giờ).
- Bước dữ liệu: 24h → 15 phút; 3 ngày → 30 phút; 7 ngày → 1 giờ; 30 ngày → 3 giờ (dùng `get_series` với `p_step_min`). Tối đa 500 điểm/đường.
- Chạm/giữ: tooltip "14:40 · 2,91 m (thực đo)" hoặc "(dự báo)".
- Phóng to 2 ngón + kéo ngang trong khoảng đã tải.
- Có khoảng trống dữ liệu > 2 bước → **đứt nét** (không nối thẳng qua khoảng trống).
**AC:**
- AC-WL03-1: Khi chọn "7 ngày" thì biểu đồ hiện ≤ 500 điểm, tải ≤ 1 giây nếu đã cache.
- AC-WL03-2: Khi trạm mất dữ liệu 3 giờ ở giữa thì đường thực đo bị đứt tại đó.
- AC-WL03-3: Khi chạm vào đường dự báo thì tooltip ghi "(dự báo)".
- AC-WL03-4: Khi trạm không có triều thì không có đường nét đứt.

### F-WL-04 · So sánh năm trước & kỷ lục 🟡
Dòng: "Cùng ngày năm ngoái: 2,60 m (▲ 0,25 m)" (từ `observations_hourly`); "Kỷ lục: 5,06 m (2000)" (từ `stations.record_cm`). Biểu đồ: tùy chọn chồng đường năm trước (màu nhạt).

### F-WL-05 · Độ mặn 🔵
Trạm có `salinity_gl`: số g/l + mức (Ngọt < 1 · Lợ 1–4 · Mặn > 4 — ⚠ ngưỡng cần xác minh theo khuyến cáo nông nghiệp) + biểu đồ 7 ngày.

---

## 9. Thủy triều & con nước

### F-TIDE-01 · Dự báo triều theo trạm 🟢
**Mô tả:** Với trạm `has_tide`, app có đường dự báo mực nước theo thời gian, tính **trên máy** từ file năm (PROJECT.md 8.5).
**Quy tắc:**
- Tải file năm hiện tại khi mở trạm lần đầu (hoặc khi thêm Theo dõi); tải sẵn năm sau từ ngày 1/12.
- Hiển thị độ tin cậy (`high/medium/low` → Cao/Trung bình/Thấp) ở tab Thông tin và khi chạm ⓘ cạnh khối triều.
- Mọi giờ/độ cao dự báo có nhãn "(tham khảo)" ít nhất 1 lần trên mỗi khối.
**AC:**
- AC-TIDE01-1: Khi mở trạm có triều lần đầu (có mạng) thì file triều được tải và lưu; lần sau mở offline vẫn có dự báo.
- AC-TIDE01-2: Khi trạm có `tide_confidence = low` thì khối triều có dòng "Độ tin cậy dự báo: Thấp".
- AC-TIDE01-3: Khi chưa có file triều cho năm hiện tại thì hiện "Chưa có dự báo triều cho trạm này" (không crash, không hiện số 0).

### F-TIDE-02 · Đếm ngược & trạng thái triều 🟢
**Mô tả:** Thẻ `TideCountdownCard`:
```
⏱ Đỉnh triều sau 2 giờ 15 phút
   14:40 · dự kiến 3,02 m
⏬ Chân triều kế tiếp: 21:10 · 1,95 m
Trạng thái: Đang lên (+8 cm/giờ)
```
**Quy tắc:**
- Lấy cực trị kế tiếp sau "bây giờ" từ `extremes`.
- Trạng thái theo tốc độ dự báo (`rateAt`): `|rate| < 3` → "Nước đứng".
- Cập nhật mỗi phút (căn đầu phút). Khi qua cực trị → tự chuyển sang cực trị tiếp theo.
- Trong 20 phút quanh cực trị: hiện "Đang đổi con nước".
**AC:**
- AC-TIDE02-1: Khi bây giờ 12:25 và đỉnh kế tiếp 14:40 thì hiện "sau 2 giờ 15 phút".
- AC-TIDE02-2: Khi đồng hồ qua 14:40 thì trong vòng 1 phút thẻ chuyển sang chân triều tiếp theo.
- AC-TIDE02-3: Khi cực trị kế tiếp rơi vào ngày hôm sau (qua nửa đêm) thì ghi "Mai 01:15".
- AC-TIDE02-4: Khi bây giờ cách đỉnh 10 phút thì hiện "Đang đổi con nước".

### F-TIDE-03 · Lịch triều theo ngày 🟢
Tab **Lịch triều** của trạm: danh sách 7 ngày tới, mỗi ngày: tiêu đề `T7, 08/11 (18/9 ÂL) · Nước rong 🌕`, các dòng `▲ 03:20 · 3,12 m` / `▼ 09:50 · 0,45 m`, biên độ ngày. Hôm nay đánh dấu, cực trị đã qua mờ đi.
**AC:**
- AC-TIDE03-1: Khi mở tab thì thấy đúng 7 ngày bắt đầu từ hôm nay (giờ VN).
- AC-TIDE03-2: Các cực trị trong danh sách khớp với chấm cực trị trên biểu đồ.

### F-TIDE-04 · Lịch triều tháng 🟢
**Mô tả:** Màn hình lưới tháng (S09): mỗi ô = ngày dương lớn, ngày âm nhỏ (mùng 1 & 15 ghi kèm tháng âm), biểu tượng pha trăng (8 pha), chấm màu con nước (rong = xanh đậm, kém = xám, nhảy = viền), thanh biên độ nhỏ.
**Luồng:** Vuốt trái/phải đổi tháng; chạm ô → panel dưới: các cực trị + biểu đồ ngày.
**Quy tắc:** Cho xem từ tháng hiện tại −1 đến +12 (giới hạn bởi file triều có sẵn; tháng không có file → ô vẫn có âm lịch, trăng; triều để trống + ghi chú).
**AC:**
- AC-TIDE04-1: Khi mở tháng 2/2026 thì ô 17/2/2026 hiện "1/1" âm lịch (Tết Bính Ngọ).
- AC-TIDE04-2: Ngày có biên độ ≥ 120% trung bình tháng được đánh dấu "rong".
- AC-TIDE04-3: Khi chạm 1 ô thì panel hiện các cực trị của đúng ngày đó.

### F-TIDE-05 · Con nước 🟢
**Mô tả:** Nhãn con nước hôm nay & mỗi ngày: **Nước rong / Nước kém / Nước nhảy / Trung bình**.
**Quy tắc:** Theo PROJECT.md 9.3 — kết hợp ngày âm + biên độ thực tế của trạm. Trạm không triều → không hiện nhãn con nước (chỉ hiện ngày âm & trăng).
Thuật ngữ theo vùng (`region`): Nam Bộ dùng "nước rong/kém/nhảy"; vùng khác dùng "triều cường/triều kém" (bảng `tide_terms.json`).
**AC:**
- AC-TIDE05-1: Khi trạm ở Cần Thơ và ngày rằm có biên độ lớn thì nhãn "Nước rong".
- AC-TIDE05-2: Khi nhãn âm lịch và biên độ mâu thuẫn thì nhãn theo biên độ, kèm chú thích nhỏ ngày âm.

### F-TIDE-06 · Tốc độ dòng chảy ước tính 🟡
Từ tốc độ thay đổi mực nước: "Nước chảy mạnh / vừa / yếu / đứng" (ngưỡng theo trạm, mặc định |rate| > 15 / 6–15 / 3–6 / < 3 cm/giờ). Nhãn "ước tính".

### F-TIDE-07 · Hiệu chỉnh dự báo theo thực đo 🟡
Khi có thực đo mới, tính độ lệch = thực đo − dự báo; đường dự báo vài giờ tới được cộng độ lệch giảm dần về 0 trong 12 giờ (PROJECT.md 9.1). Hiện "Đã hiệu chỉnh theo thực đo (lệch +18 cm)". Quan trọng mùa lũ ĐBSCL.

### F-TIDE-09 · Dòng thời gian theo giờ 🟢
**Mục đích:** Trả lời "10h nước đang lên hay xuống, 11h thế nào, mấy giờ đổi chiều" cho từng giờ (U1, U3, U4, U5).
**Mô tả:** Tab **Theo giờ** trong Chi tiết trạm (và khối rút gọn trong Chi tiết điểm, tab Câu cá):
- Danh sách theo giờ, từ **−6 giờ đến +18 giờ** quanh hiện tại (cuộn thêm được tới +72 giờ). Mỗi dòng: giờ · mực nước · thay đổi (cm/giờ) · trạng thái (▲ Đang lên / ▲ Lên nhanh / ■ Nước đứng / ▼ Đang xuống / ▼ Xuống nhanh).
- Chèn dòng đặc biệt cho **đỉnh triều ★** và **chân triều ★** đúng thời điểm (không làm tròn theo giờ).
- Vạch **"◄ Bây giờ"** cố định; giờ đã qua = **thực đo** (chữ đậm, nhãn "Thực đo"); giờ tới = **dự báo** (chữ thường, nhãn "Dự báo · tham khảo"); ở trạm/điểm không có thực đo = **ước tính**.
- Biểu đồ phía trên đồng bộ với danh sách: **chạm vào một giờ trên biểu đồ** → cuộn danh sách tới giờ đó + hiện **khung chi tiết giờ**: loại số liệu · mực nước · tốc độ & trạng thái · thời gian còn lại tới đỉnh/chân kế tiếp · chỉ số câu cá giờ đó · nhiệt độ/gió/mưa giờ đó · (giờ đã qua) độ lệch thực đo − dự báo.
**Quy tắc:**
- Mực nước từng giờ = trung bình 10 phút quanh mốc giờ (thực đo) hoặc giá trị dự báo đã hiệu chỉnh (F-TIDE-07) tại mốc giờ.
- Ngưỡng trạng thái theo tốc độ: |rate| < 3 → Nước đứng; 3–20 → Đang lên/xuống; > 20 → Lên/Xuống nhanh (ngưỡng cấu hình theo trạm).
- Có số thực đo mới → danh sách và biểu đồ tự làm mới (khi đang mở màn hình), vạch "Bây giờ" dịch theo phút.
- Trạm chỉ có bản tin 1 lần/ngày: phía trên danh sách ghi "Thực đo theo bản tin KTTV lúc HH:mm"; giờ không có thực đo hiển thị dự báo/ước tính, KHÔNG giả làm thực đo.
- Mỗi trạm hiện **độ tin cậy** dự báo (Cao/Trung bình/Thấp) và **sai số đo được** gần nhất (vd "sai số 30 ngày qua: ±12 cm, ±18 phút").
**AC:**
- AC-TIDE09-1: Khi bây giờ 11:05 thì dòng 11:00 trở về trước ghi "Thực đo" (nếu trạm có thực đo), từ 12:00 ghi "Dự báo".
- AC-TIDE09-2: Khi đỉnh triều lúc 09:32 thì có dòng "★ Đỉnh triều 09:32" chèn giữa 09:00 và 10:00.
- AC-TIDE09-3: Khi chạm điểm 13:00 trên biểu đồ thì danh sách cuộn tới 13:00 và khung chi tiết hiện đủ các mục ở Mô tả.
- AC-TIDE09-4: Khi có số thực đo mới lúc 11:15 thì không cần thao tác, trong ≤ 1 phút dòng 11:00 và biểu đồ cập nhật.
- AC-TIDE09-5: Trạng thái mỗi dòng có cả chữ và biểu tượng (không chỉ màu).

### F-TIDE-08 · Dự báo kết hợp 7 ngày 🔵
Kết hợp triều + mưa + lưu lượng dự báo → dải "khả năng nước cao hơn bình thường" theo ngày (Thấp/Vừa/Cao), nhãn "tham khảo".

---

## 10. Điểm bất kỳ

### F-POINT-01 · Chi tiết điểm (S04) 🟢
> Thuộc F-MAP-03; tách riêng vì phức tạp.

**Mục đích:** U3, U4, U1 muốn biết tình hình **tại chỗ mình** dù không có trạm.
**Bố cục (từ trên xuống):**
1. Địa danh (xã/phường, huyện, tỉnh) · tọa độ (chạm để sao chép) · nút **Chỉ đường** (mở app bản đồ ngoài).
2. **Trạm gần nhất** (tối đa 3): tên, khoảng cách, mực nước, xu hướng → chạm mở trạm.
3. **Khối ước tính** (nền sọc, `EstimateBadge`): mực nước ước tính, trạng thái lên/xuống, đỉnh/chân kế tiếp đã cộng độ trễ. Độ tin cậy theo PROJECT.md 9.7.
4. **Độ cao mặt đất**: "khoảng 1,6 m (mô hình, sai số có thể vài mét)" + nút "Tôi biết độ cao thật" (nhập tay, chỉ khi lưu điểm).
5. **So sánh tham khảo** 🟡 (chỉ khi người dùng **tự nhập độ cao thật** của điểm đã lưu và cùng mốc cao độ với trạm): "Đỉnh triều hôm nay cao hơn mặt đất ~0,4 m — có thể ngập (tham khảo)". Bản dev **không** kết luận ngập từ độ cao mô hình (lệch cao vài mét ở đồng bằng — data-sources 2.5).
6. **Thời tiết** tóm tắt + **chỉ số câu cá** tại điểm.
7. Nút: ⭐ **Lưu điểm** · 🔔 **Theo dõi điểm này** (🟡).

**Quy tắc:**
- `confidence = none` (> 50 km) → ẩn khối ước tính, hiện "Không có trạm đủ gần để ước tính".
- Kết quả cache 10 phút theo ô ~1 km.
**AC:**
- AC-POINT01-1: Khi điểm cách trạm gần nhất 3 km cùng sông thì độ tin cậy "Cao".
- AC-POINT01-2: Khi điểm cách trạm gần nhất 60 km thì không hiện mực nước ước tính.
- AC-POINT01-3: Mọi số trong khối ước tính có nhãn "ước tính".
- AC-POINT01-4: Khi bấm Lưu điểm, nhập tên "Ruộng nhà", loại Ruộng thì điểm xuất hiện trong tab Theo dõi.

---

## 11. Theo dõi (yêu thích)

### F-UX-04 · Danh sách theo dõi 🟢
**Mục đích:** Màn hình "mở là thấy" cho người dùng hằng ngày (J2).
**Mô tả:** Danh sách thẻ, mỗi thẻ:
- **Trạm:** tên · mực nước · xu hướng · trạng thái · (triều) đếm ngược cực trị kế tiếp + độ cao dự kiến · cảnh báo nếu cực trị kế tiếp vượt BĐ ("Đỉnh 18:40 dự kiến vượt BĐ II").
- **Điểm đã lưu:** tên + loại (biểu tượng) · mực nước ước tính · đếm ngược · (loại "điểm câu") chỉ số câu cá giờ hiện tại.
**Luồng:** Kéo xuống làm mới · giữ & kéo để sắp xếp · vuốt trái để xóa (có Hoàn tác 5 giây) · nút ➕ thêm (mở tìm kiếm trạm / bản đồ).
**Quy tắc:** Tối đa 30 mục. Lưu cục bộ (không cần đăng nhập). Trống → `EmptyView`: "Bạn chưa theo dõi trạm nào" + nút **Thêm trạm gần bạn** (dùng vị trí → 3 trạm gần nhất).
**AC:**
- AC-UX04-1: Khi thêm trạm từ bản đồ thì xuất hiện cuối danh sách Theo dõi ngay lập tức.
- AC-UX04-2: Khi vuốt xóa rồi bấm Hoàn tác thì mục trở lại đúng vị trí cũ.
- AC-UX04-3: Khi khởi động lại app thì thứ tự danh sách giữ nguyên.
- AC-UX04-4: Khi cực trị kế tiếp dự kiến ≥ BĐ I thì thẻ có dòng cảnh báo màu tương ứng.

---

## 12. Câu cá

> Module trọng tâm cho U1, U2. Công thức: PROJECT.md 9.5 – 9.6.

### F-FISH-01 · Chỉ số câu cá 🟢
**Mô tả:** Điểm 0–10 theo **giờ** và theo **ngày** tại điểm được chọn.
**Chọn điểm:** dropdown trên cùng: "📍 Vị trí hiện tại" · các điểm câu đã lưu · các trạm theo dõi. Mặc định: điểm câu dùng gần nhất.
**Quy tắc:**
- Điểm đặt tại vị trí không phải trạm → dùng trạm triều gần nhất (theo `point`) cho thành phần triều; nếu > 50 km → bỏ thành phần triều (chuẩn hóa trọng số).
- Hiển thị mức chữ (**4.5**) + màu + "tham khảo".
- Bấm ⓘ → giải thích: các thành phần, điểm từng thành phần giờ hiện tại (vd "Con nước 1.0 · Solunar 0.75 · Áp suất 0.8 · Thời điểm 0.6 · Thời tiết 1.0").
- Chọn loài cá mục tiêu (tùy chọn, 🟢 danh sách cơ bản trong `species.json`) → thêm thành phần mùa.
**AC:**
- AC-FISH01-1: Khi có dông trong giờ đó thì điểm giờ đó ≤ 2,0 và hiện "Nguy hiểm — dông sét".
- AC-FISH01-2: Khi bấm ⓘ thì thấy điểm từng thành phần và tổng khớp công thức.
- AC-FISH01-3: Khi offline và thời tiết đã cũ > 6 giờ thì ghi "Thiếu dữ liệu thời tiết mới" và vẫn tính với thành phần còn lại.
- AC-FISH01-4: Chỉ số luôn kèm chữ "tham khảo".

### F-FISH-02 · Giờ vàng 🟢
**Mô tả:** Tối đa 3 khoảng giờ có điểm ≥ 7,0 trong ngày, mỗi khoảng: giờ bắt đầu–kết thúc · điểm cao nhất · **lý do** (ghép từ 2–3 thành phần cao nhất: "Bình minh + Nước ròng + Solunar chính").
**Quy tắc:** Gộp khoảng cách nhau < 30 phút. Không có khoảng ≥ 7 → hiện 1 khoảng tốt nhất trong ngày với nhãn "Tốt nhất hôm nay" (không gọi là giờ vàng). Khoảng đã qua → mờ.
**AC:**
- AC-FISH02-1: Khi có 2 khoảng ≥ 7 cách nhau 20 phút thì hiển thị là 1 khoảng.
- AC-FISH02-2: Khi cả ngày không giờ nào ≥ 7 thì hiện "Tốt nhất hôm nay: …".
- AC-FISH02-3: Mỗi khoảng có ít nhất 1 lý do bằng chữ.

### F-FISH-03 · Mặt trời, mặt trăng, Solunar 🟢
**Mô tả:** Khối "Trời & trăng": bình minh/hoàng hôn · trăng mọc/lặn · trăng lên đỉnh/xuống chân · pha trăng (biểu tượng + % sáng + tên: Trăng non, Lưỡi liềm đầu tháng, Bán nguyệt đầu tháng, Trăng khuyết đầu tháng, Trăng tròn, …) · khung **Solunar chính/phụ** trong ngày.
**Quy tắc:** Ngày không có trăng mọc/lặn → ghi "Không có". Câu đêm: hiện "Đêm nay trăng sáng 98% — đêm sáng".
**AC:**
- AC-FISH03-1: Giờ mặt trời mọc tại Cần Thơ lệch ≤ 2 phút so với nguồn tham chiếu.
- AC-FISH03-2: Khung solunar chính dài 2 giờ, phụ dài 1 giờ, căn giữa sự kiện trăng.

### F-FISH-04 · Điều kiện thời tiết cho câu 🟢
Khối: nhiệt độ · gió (tốc độ + hướng bằng chữ "Đông Nam") · mây % · mưa mm · **áp suất + xu hướng 3 giờ** ("1008 hPa · giảm nhẹ ✓ tốt cho câu"). Nguồn Open-Meteo.

### F-FISH-05 · Dự báo câu cá 7 ngày 🟢
Dải 7 ô ngày: thứ · ngày · điểm ngày + màu · biểu tượng thời tiết · biểu tượng pha trăng · nhãn con nước. Chạm → toàn bộ màn hình chuyển sang ngày đó.
**AC:**
- AC-FISH05-1: Khi chạm ô Thứ 7 thì giờ vàng, biểu đồ, thời tiết đều đổi sang Thứ 7.
- AC-FISH05-2: Ngày 4–7 (thời tiết dự báo kém tin cậy hơn) có ghi chú "dự báo xa".

### Biểu đồ 24 giờ của tab Câu cá 🟢
Cột điểm mỗi giờ (màu theo mức) + đường mực nước dự báo chồng lên (trục phải) + biểu tượng ☀ mọc/lặn, 🌙 mọc/lặn + dải nền solunar. Chạm cột → tooltip điểm & lý do.

### F-FISH-06 · Nhật ký câu 🟡
**Mô tả:** Ghi lại mỗi lần câu được cá.
**Luồng thêm:** nút 📓 → chụp/chọn ảnh (≤ 3) → loài (tìm trong cẩm nang hoặc tự nhập) → số lượng · cân nặng · chiều dài · mồi · kiểu câu · câu thả? · ghi chú → **Lưu**.
**Quy tắc:**
- Thời gian mặc định = bây giờ, sửa được. Vị trí mặc định = điểm câu đang chọn / vị trí hiện tại.
- **Điều kiện tự động** (snapshot PROJECT.md 9.6) chụp theo thời gian câu — người dùng không phải nhập.
- Ảnh: nén, **xóa EXIF**.
- Lưu cục bộ trước; đồng bộ khi đăng nhập & có mạng; trạng thái đồng bộ hiện bằng icon nhỏ.
- Mặc định **riêng tư**.
**AC:**
- AC-FISH06-1: Khi lưu nhật ký offline thì mục xuất hiện ngay trong danh sách với icon "chưa đồng bộ".
- AC-FISH06-2: Ảnh tải lên không còn dữ liệu GPS trong EXIF.
- AC-FISH06-3: Mục nhật ký có điều kiện con nước, trăng, áp suất đúng thời điểm câu.

### F-FISH-07 · Thống kê cá nhân 🟡
Biểu đồ: số cá theo loài · theo điểm · theo con nước (rong/kém) · theo trạng thái triều (lên/xuống/đứng) · theo giờ trong ngày · theo pha trăng · theo xu hướng áp suất. Câu tóm tắt tự sinh: "Bạn câu được nhiều nhất khi **nước ròng 1–2 giờ**, **trăng khuyết**, **sáng sớm**" (chỉ khi ≥ 10 lần ghi).

### F-FISH-08 · Điểm câu riêng tư 🟡
Điểm loại `spot` có thêm: kiểu nước (sông/kênh/hồ/biển/cửa sông), độ sâu ước lượng, ghi chú, ảnh. Không bao giờ chia sẻ tọa độ chính xác; chia sẻ ra ngoài dùng tọa độ làm mờ 2–5 km (người dùng chọn).

### F-FISH-09 · Thông báo giờ vàng 🟡
Bật cho từng điểm câu: báo trước giờ vàng X phút (mặc định 45) nếu điểm ≥ ngưỡng (mặc định 7,5). Tối đa 2 thông báo/ngày/điểm. Thông báo cục bộ (tính trên máy, lên lịch 3 ngày tới, cập nhật khi mở app/làm mới thời tiết).

### F-FISH-10 · Cẩm nang loài cá 🟡
~30 loài khởi đầu (PROJECT.md S10). Mỗi loài: ảnh minh họa · tên phổ thông + tên địa phương · môi trường · vùng · **tháng tốt** (dải 12 ô) · **giờ tốt** · **con nước tốt** · mồi · kiểu câu · mô tả · mẹo. Offline. Lọc theo môi trường/vùng; "Loài đang mùa" ở đầu.

### F-FISH-11 · Nút buộc câu 🟡
10–15 nút, mỗi nút: hình từng bước (vuốt ngang) · độ khó · dùng cho dây gì (mono, dù PE, fluoro) · độ bền tương đối. Offline.

### F-FISH-12 · Danh sách đồ nghề 🟡
Mẫu checklist theo kiểu câu (lục, đài, lure, câu tay, câu biển) + mục chung (nước uống, áo mưa, đèn, thuốc chống côn trùng, áo phao…). Tích được, lưu theo chuyến; tạo danh sách riêng.

### F-FISH-14 · Nhận diện cá qua ảnh 🔵
Mô hình chạy trên máy (TFLite) gợi ý top-3 loài kèm độ tin cậy; người dùng xác nhận. Không gửi ảnh lên server để nhận diện.

### F-FISH-17 · Câu biển 🟡
Điểm câu loại biển/cửa sông: thêm độ cao sóng, chu kỳ sóng, nhiệt độ mặt nước biển (Open-Meteo Marine); cảnh báo sóng > 1,5 m.

---

## 13. An toàn

### F-SAFE-01 · Cảnh báo dông, sét, gió mạnh 🟢
**Mô tả:** Băng đỏ trên cùng tab Câu cá, Chi tiết trạm, Chi tiết điểm khi trong **6 giờ tới** tại vị trí có:
- `weather_code` 95/96/99 (dông) → "⚡ Có dông sét lúc 15:00 — tránh câu ngoài trời, tránh dùng cần carbon".
- Gió giật > 50 km/h → "💨 Gió giật mạnh".
- `cape ≥ 3000` **và** xác suất mưa ≥ 50% → băng **vàng** "⚠ Có thể có dông" (không khóa chỉ số câu cá — CAPE ở VN thường cao, xem data-sources 2.4).
**Quy tắc:** Chạm băng → chi tiết theo giờ. Băng không tắt vĩnh viễn được (chỉ thu gọn).
**AC:**
- AC-SAFE01-1: Khi dữ liệu thời tiết giờ 15:00 có code 95 và bây giờ 11:00 thì băng hiện "Có dông sét lúc 15:00".
- AC-SAFE01-2: Băng hiện trên cả 3 màn hình đã nêu khi điều kiện đúng.

### F-SAFE-02 · "Nước sắp ngập bãi" 🟡
**Luồng:** Tab An toàn → **Bắt đầu theo dõi bãi** → chọn trạm/điểm → "Chỗ bạn đứng cao hơn mặt nước hiện tại bao nhiêu?" (thanh trượt 10–200 cm) → **Bắt đầu**.
**Quy tắc:** Ngưỡng = mực nước hiện tại (ước tính) + độ cao nhập. Từ dự báo (đã hiệu chỉnh) tìm thời điểm mực nước đạt ngưỡng → thông báo trước **45 phút** và **15 phút**, và lúc đạt. Không đạt trong 12 giờ → "Trong 12 giờ tới nước không lên tới chỗ bạn (tham khảo)". Tự tắt sau 12 giờ.

### F-SAFE-03 · Nước lên nhanh bất thường 🟡
Trạm theo dõi có `rate ≥ 20 cm/giờ` (hoặc ngưỡng riêng) → push (máy chủ). Không bị chặn bởi giờ yên lặng.

### F-SAFE-04 · Chuyến đi an toàn 🟡
Nhập giờ về dự kiến + chọn 1–3 người thân (từ danh bạ do người dùng chọn — chỉ lưu tên + số trên máy). Quá giờ → thông báo "Bạn đã về chưa?" → 15 phút không phản hồi → thông báo khẩn mở SMS **soạn sẵn** vị trí cuối, **người dùng bấm gửi** (app không tự gửi).

### F-SAFE-05 · SOS 🟡
Nút lớn: **Gọi 112** (cứu nạn) · **Gọi 114** (cứu hỏa/cứu nạn) · **Gửi vị trí** (chia sẻ qua ứng dụng bất kỳ, gồm tọa độ + link bản đồ). Hiện tọa độ chữ to để đọc qua điện thoại.

### F-SAFE-06 · Thông tin xả lũ hồ chứa 🔵
Danh sách hồ thượng nguồn của sông đang xem + lịch/thông báo xả (nếu nguồn có).

---

## 14. Cảnh báo & thông báo

### F-ALERT-01 · Nhắc đỉnh/chân triều (cục bộ) 🟢
**Mô tả:** Với mỗi trạm theo dõi có triều: bật "Nhắc trước đỉnh triều" / "trước chân triều", chọn trước 15/30/60/120 phút.
**Quy tắc:**
- Tính trên máy, lên lịch thông báo cục bộ cho **7 ngày tới**, lên lịch lại mỗi lần mở app và khi đổi cài đặt.
- Nội dung: "🌊 Mỹ Thuận: Đỉnh triều lúc 14:40 (dự kiến 3,02 m) — còn 30 phút. (tham khảo)".
- Tối đa 64 thông báo chờ (giới hạn hệ điều hành) → ưu tiên gần nhất.
- Android 13+: xin quyền thông báo khi người dùng bật lần đầu.
**AC:**
- AC-ALERT01-1: Khi bật nhắc 30 phút trước đỉnh cho trạm A và đóng app thì thông báo đến đúng giờ (±1 phút).
- AC-ALERT01-2: Khi tắt nhắc thì mọi thông báo chờ của trạm A bị hủy.
- AC-ALERT01-3: Chạm thông báo mở đúng Chi tiết trạm A.

### F-ALERT-02 · Cảnh báo đẩy theo ngưỡng 🟡
Tạo quy tắc cho trạm/điểm: vượt mức tự đặt · dưới mức · vượt BĐ I/II/III · lên nhanh. Máy chủ đánh giá 15 phút/lần (PROJECT.md 9.8: hysteresis 5 cm, cooldown 3 giờ). Danh sách quy tắc: bật/tắt, sửa, xóa; lịch sử đã gửi 30 ngày.

### F-ALERT-03 · Giờ yên lặng 🟡
Mặc định 22:00–05:30 (sửa được). Trong giờ yên lặng chỉ gửi: BĐ ≥ II, lên nhanh, dông sét đang tới.

### F-ALERT-04 · Tóm tắt buổi sáng 🟡
Thông báo 1 lần/ngày (giờ chọn, mặc định 06:00): "Hôm nay nước rong · Đỉnh 15:20 (3,05 m) · Câu cá 8/10 (giờ vàng 16:30–18:20) · Chiều có mưa". Tính cục bộ.

---

## 15. Thời tiết

### F-WX-01 · Thời tiết tại trạm/điểm 🟢
Khối 3 ngày (Chi tiết trạm) / 7 ngày (Câu cá): theo giờ (hôm nay) + theo ngày; mưa (mm + %), gió, nhiệt độ, mây, áp suất. Nguồn Open-Meteo qua Edge Function `weather`, cache 60 phút.
**AC:**
- AC-WX01-1: Hai trạm cách nhau < 5 km dùng chung một lần gọi (cùng ô cache).
- AC-WX01-2: Có dòng "Nguồn: Open-Meteo.com".

### F-WX-02 · Lưu lượng dự báo 🟡
"Lưu lượng sông dự báo: tăng nhẹ / ổn định / giảm" 7 ngày (Open-Meteo Flood), nhãn "mô hình toàn cầu, tham khảo".

---

## 16. Nông nghiệp & ghe thuyền

### F-AGRI-01 · Gợi ý giờ lấy/xả nước 🟡
Cho điểm loại Ruộng/Ao: khung giờ nước lớn (lấy nước) và nước ròng (xả nước) trong 3 ngày; kết hợp cảnh báo mặn khi có (🔵).

### F-AGRI-02 · Cảnh báo mặn 🔵
Trạm có độ mặn: cảnh báo khi vượt ngưỡng người dùng đặt (g/l).

### F-BOAT-01 · Tĩnh không qua cầu 🔵
Người dùng nhập chiều cao ghe trên mặt nước; chọn cầu (danh sách cầu có tĩnh không công bố + trạm tham chiếu) → khung giờ đi qua an toàn (giữ khoảng dư ≥ 30 cm), nhãn "tham khảo, luôn quan sát thực tế".

---

## 17. Tài khoản & đồng bộ

### F-UX-07 · Đăng nhập & đồng bộ 🟡
- Không đăng nhập: dùng đầy đủ tính năng xem + lưu cục bộ.
- Đăng nhập (email OTP / Google / Apple) để: đồng bộ Theo dõi, điểm, nhật ký, cảnh báo đẩy giữa các máy; sao lưu.
- Lần đầu đăng nhập: gộp dữ liệu cục bộ lên tài khoản (hỏi xác nhận).
- **Xóa tài khoản**: xóa toàn bộ dữ liệu trên máy chủ (ảnh, nhật ký, điểm, cảnh báo, thiết bị) — có xác nhận 2 bước.

---

## 18. Cài đặt & thông tin

### Cài đặt (S13) 🟢
| Mục | Lựa chọn | Mặc định |
|---|---|---|
| Đơn vị mực nước | m / cm | m |
| Giao diện | Theo máy / Sáng / Tối | Theo máy |
| Chữ lớn | Bật / Tắt | Tắt |
| Vai trò sử dụng | (như onboarding) | — |
| Tab mở đầu | Bản đồ / Theo dõi / Câu cá | theo vai trò |
| Loài cá mục tiêu | danh sách | không |
| Dữ liệu ngoại tuyến | dung lượng đang dùng · Xóa cache | — |
| Giờ yên lặng 🟡 | khoảng giờ | 22:00–05:30 |

### F-UX-09 · Nguồn dữ liệu & giới thiệu 🟢
Trang liệt kê mọi nguồn (tên, mô tả, liên kết, giấy phép, thời điểm cập nhật cuối của nguồn) + tuyên bố: "Số liệu dự báo và ước tính chỉ mang tính tham khảo. Luôn theo dõi thông tin chính thức từ cơ quan chức năng." + phiên bản app.
**AC:**
- AC-UX09-1: Mọi nguồn đang dùng trong app đều có mặt trong trang này.

### F-UX-05 · Widget màn hình chính 🟡
2 kích thước: nhỏ (1 trạm: mực nước + xu hướng + đếm ngược) · vừa (1 trạm + biểu đồ mini 12 giờ + chỉ số câu cá). Làm mới ~30 phút (giới hạn hệ điều hành); hiện giờ cập nhật.

### F-UX-06 · Chia sẻ thẻ ảnh 🟡
Tạo ảnh đẹp (1080×1350) từ: thẻ trạm, lịch triều ngày, chỉ số câu cá ngày → chia sẻ qua Zalo/Facebook. Có logo app + nguồn + "tham khảo". Không chứa tọa độ chính xác của điểm câu.

### F-UX-08 · Đọc to, tiếng Anh 🔵
Nút 🔊 đọc tóm tắt trạm bằng giọng tiếng Việt của hệ thống; bản tiếng Anh cho khách du lịch.

---

## 19. Quản trị

### F-ADM-01 · Tình trạng nguồn dữ liệu 🟡
Trang web (chỉ admin): mỗi nguồn — lần chạy cuối, trạng thái, số dòng, lỗi gần nhất, biểu đồ 7 ngày; số trạm mất dữ liệu > 6 giờ. Email cảnh báo khi nguồn lỗi 3 lần liên tiếp.

### F-ADM-02 · Quản lý trạm 🟡
Sửa tên, tọa độ, sông, ngưỡng báo động, mốc cao độ, bật/tắt trạm, ghép alias giữa các nguồn. Mọi thay đổi ghi nhật ký (ai, khi nào, giá trị cũ/mới).

---

## 20. Ngoài phạm vi

Không làm trong bản dev và các bản đã lên kế hoạch, trừ khi có quyết định mới (ghi vào PROJECT.md mục 19):
- ⚪ Mạng xã hội / cộng đồng (bài đăng, bình luận, điểm câu công khai, báo cáo ngập) — F-COMM-*, F-FISH-13, F-FISH-16.
- ⚪ Quy định khai thác thủy sản — F-FISH-15.
- ⚪ Bán hàng, quảng cáo, gói trả phí.
- ⚪ Bản đồ độ sâu từ máy dò cá.
- ⚪ Phiên bản đồng hồ thông minh, máy tính bảng tối ưu riêng.
- ❌ Tự phát hành bản tin dự báo lũ chính thức (thuộc thẩm quyền cơ quan nhà nước).
- ❌ Theo dõi vị trí nền liên tục của người dùng.
