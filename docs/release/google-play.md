# Phát hành Con Nước lên Google Play

> Task P2-60 · lập 20/11/2026. Mục nào ghi **⚠ cần xác minh** là chính sách Google hay thay đổi: kiểm lại
> trong Play Console / trang chính sách trước khi bấm gửi. Liên quan: [app-store.md](app-store.md),
> [legal-checklist.md](legal-checklist.md).

## 0. Đã sẵn sàng trong code (không cần làm lại)

| Hạng mục | Trạng thái |
|---|---|
| Mã gói | `vn.rivertide.rivertide` — **không bao giờ đổi** sau lần tải lên đầu tiên |
| Target API | `targetSdk 36` (Android 16), `minSdk 24`, `compileSdk 36` — mặc định Flutter 3.47. Play nâng mức tối thiểu mỗi tháng 8 (31/8/2025: API 35; ⚠ cần xác minh mức năm 2026) |
| Ký bản phát hành | Gradle đọc `app/android/key.properties` (không commit). Thiếu file → ký bằng khoá debug và in cảnh báo; bản đó **Play từ chối** |
| Quyền | INTERNET, vị trí COARSE/FINE (chỉ hỏi khi bấm nút vị trí), POST_NOTIFICATIONS (chỉ hỏi khi bật báo thức, sau khi đã đồng ý điều khoản), RECEIVE_BOOT_COMPLETED (đặt lại báo thức sau khi khởi động máy). Thư viện tự thêm quyền "thường" (VIBRATE, WAKE_LOCK, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE, FOREGROUND_SERVICE của WorkManager) — không hiện hộp thoại, không cần khai báo riêng |
| Không có | Vị trí nền, báo thức chính xác (SCHEDULE_EXACT_ALARM), đọc ảnh/tệp (dùng Photo Picker), danh bạ, SMS, quảng cáo, SDK phân tích. Dịch vụ vị trí nền của geolocator đã bị gỡ khỏi manifest |
| Mạng | Chỉ HTTPS (`usesCleartextTraffic=false`) |
| Sao lưu | Tắt (`allowBackup=false` + `data_extraction_rules.xml`): mã máy và nhật ký câu không lên Google Drive, không chép sang máy mới — đúng như chính sách quyền riêng tư |
| UGC | Đồng ý điều khoản bắt buộc trước khi dùng; lọc nội dung + giới hạn spam (0005); báo cáo; chặn người dùng (0006); cam kết xử lý 24 giờ |
| Xoá dữ liệu | Trong app: Thêm → Pháp lý → **Xoá dữ liệu của tôi** (0007). Trang web: `https://dangkhanhaa.github.io/rivertide/delete-data.html` |
| Liên kết APK | Nút "Tải app Android (APK)" chỉ hiện trên bản **web**, không hiện trong bản cài từ Play (chính sách cấm app tự cài/tải mã thực thi ngoài Play) |

## 1. Việc chủ dự án phải làm bằng tay (theo thứ tự)

1. **Biểu tượng app** — ⛔ hiện vẫn là logo Flutter mặc định (Android, iOS, web). Cả hai cửa hàng sẽ từ chối.
   Vẽ 1 ảnh vuông ≥ 1024×1024 PNG rồi chạy `python tools/release/make_icons.py icon.png` (cần `pip install pillow`).
2. **Tạo khoá tải lên (upload key)** — một lần duy nhất:
   `powershell -ExecutionPolicy Bypass -File tools\release\make_upload_key.ps1`
   Sao lưu ngay tệp `.jks` + mật khẩu (trong `app/android/key.properties`) vào **2 nơi**: trình quản lý mật khẩu và
   USB cất ở nhà. Không gửi qua chat/email, không đưa vào Git.
3. **Cài Android SDK Command-line Tools** (Android Studio → SDK Manager → SDK Tools). Thiếu nó thì
   `flutter build appbundle` vẫn tạo ra `.aab` nhưng báo lỗi ở bước kiểm tra cuối ("failed to strip debug symbols").
4. **Áp migration 0007** lên Supabase thật (SQL editor hoặc `supabase db push`), rồi chạy
   `supabase/tests/delete_my_data_check.sql` (tự ROLLBACK) — phải thấy `ALL DELETE-MY-DATA CHECKS PASSED`.
5. **Đăng bản web** (GitHub Pages) để `delete-data.html` và chính sách v2 lên mạng trước khi điền Play Console.
6. **Nâng phiên bản** trước mỗi lần tải lên: `app/pubspec.yaml` `version: 0.1.0+1` → `0.1.0+2`… (số sau `+` là
   versionCode, chỉ được tăng) và `Env.version` trong `app/lib/core/config/env.dart` khớp phần trước `+`.
7. **Build**: `powershell -ExecutionPolicy Bypass -File tools\release\build_release.ps1` → tải
   `app/build/app/outputs/bundle/release/app-release.aab` lên Play Console.

## 2. Tài khoản nhà phát triển

- Phí đăng ký một lần 25 USD. Chọn loại tài khoản:
  - **Cá nhân**: cần giấy tờ tuỳ thân, xác minh danh tính và số điện thoại. ⚠ Cần xác minh: tài khoản cá nhân tạo sau
    13/11/2023 phải **thử nghiệm kín (closed testing) với ít nhất 12 người thử, liên tục 14 ngày** rồi mới được xin
    quyền phát hành chính thức (production). Chuẩn bị sẵn danh sách 15–20 email Gmail của người quen sẽ cài và mở
    app trong 14 ngày.
  - **Tổ chức**: cần mã D-U-N-S và pháp nhân (công ty/hộ kinh doanh). Không bị yêu cầu 12 người × 14 ngày.
- Tên nhà phát triển hiện công khai trên cửa hàng. Email liên hệ của nhà phát triển là **bắt buộc** và công khai —
  nên tạo một email riêng cho app (vd. Gmail riêng) thay vì email cá nhân.
- ⚠ Cần xác minh: Google đang triển khai **xác minh nhà phát triển Android** cho cả app cài ngoài Play (theo từng
  nước từ 2026). Nếu vẫn phát hành APK trên web, theo dõi khi nào áp dụng cho Việt Nam.

## 3. Ký app và APK trên web

- Bật **Play App Signing** (mặc định với app mới): Google giữ khoá ký thật, bạn chỉ giữ khoá tải lên.
- Bản APK đang phát trên web hiện **ký bằng khoá debug**. App cài từ Play ký bằng khoá khác → máy đã cài APK
  không cập nhật được từ Play, phải gỡ ra (mất nhật ký câu trên máy). Báo trước cho người dùng APK.
- Sau khi có trên Play: nên thay nút tải APK trên web bằng liên kết Play, hoặc phát APK tải về từ
  Play Console (App bundle explorer → tải APK đã ký) để cùng chữ ký với bản Play.

## 4. Mục "Nội dung ứng dụng" (App content) — câu trả lời

| Mục | Trả lời |
|---|---|
| Chính sách quyền riêng tư | `https://dangkhanhaa.github.io/rivertide/privacy.html` |
| Quảng cáo | **Không** có quảng cáo |
| Quyền truy cập app | **Mọi chức năng dùng được mà không cần đăng nhập hay quyền đặc biệt** |
| Đối tượng mục tiêu | **18 tuổi trở lên** (tránh chính sách Gia đình; chính sách quyền riêng tư không cho trẻ dưới 16 dùng tính năng cộng đồng). App không thiết kế cho trẻ em |
| Ứng dụng tin tức | **Không** |
| Ứng dụng của chính phủ | **Không** |
| Tính năng tài chính / sức khoẻ / COVID | **Không** |
| Quyền dịch vụ nền trước (FGS) | Không có (không khai) |
| Xếp hạng nội dung (IARC) | Xem mục 5 |
| An toàn dữ liệu | Xem mục 6 |
| Xoá dữ liệu | App **không tạo tài khoản** → không bắt buộc URL xoá tài khoản; vẫn khai "có cách yêu cầu xoá dữ liệu" và dán `https://dangkhanhaa.github.io/rivertide/delete-data.html` |

## 5. Bảng hỏi xếp hạng nội dung (IARC)

- Danh mục: **Tiện ích / Năng suất / Liên lạc / Khác** (Utility, Productivity, Communication, or Other).
- Bạo lực, tình dục, ngôn ngữ thô tục, chất kích thích, cờ bạc, kinh dị: **Không** (nội dung người dùng bị lọc từ tục,
  cờ bạc; quy tắc cộng đồng cấm).
- **Người dùng tương tác / trao đổi nội dung với nhau**: **Có** (điểm câu, bình luận, kèo câu, tin nhắn trong kèo,
  đánh giá hồ).
- **Chia sẻ vị trí của người dùng với người khác**: **Có** (điểm câu/kèo câu do người dùng đăng có toạ độ; "Đang câu ở
  đây" chỉ hiện số người theo ô ~200 m).
- Mua hàng kỹ thuật số: **Không**. Trình duyệt web tự do: **Không**.
- Kết quả dự kiến: mọi lứa tuổi kèm nhãn "Người dùng tương tác", "Chia sẻ vị trí" (⚠ IARC tự tính).

## 6. Biểu mẫu An toàn dữ liệu (Data safety) — khớp với code

Câu hỏi chung:
- Thu thập hoặc chia sẻ dữ liệu người dùng bắt buộc khai? **Có**.
- Mọi dữ liệu mã hoá khi truyền? **Có** (HTTPS).
- Người dùng yêu cầu xoá được? **Có** (trong app + `delete-data.html`).
- Tài khoản: **App không cho tạo tài khoản**.

"Chia sẻ" (share) = chuyển cho bên thứ ba. Supabase (máy chủ), Open-Meteo (thời tiết), OpenFreeMap/EOX (bản đồ) là
nhà cung cấp dịch vụ xử lý thay mình → theo định nghĩa của Google **không tính là chia sẻ** (⚠ cần xác minh lại câu
chữ trong Console). Không bán, không quảng cáo → mọi dòng dưới đây: **Thu thập: Có · Chia sẻ: Không · Không xử lý
tạm thời (ephemeral)**.

| Loại dữ liệu (Google) | Lấy từ đâu trong app | Bắt buộc? | Mục đích |
|---|---|---|---|
| Vị trí → Vị trí gần đúng | "Đang câu ở đây" (ô ~200 m), "Có dính không?" (ô ~2 km), toạ độ làm tròn ~100 m gửi Open-Meteo | Tuỳ chọn | Chức năng app |
| Vị trí → Vị trí chính xác | Toạ độ điểm câu, hồ câu, kèo câu người dùng đăng | Tuỳ chọn | Chức năng app |
| Thông tin cá nhân → Tên | Tên hiển thị (tự đặt, có thể để trống) đi kèm bài đăng | Tuỳ chọn | Chức năng app |
| Thông tin cá nhân → Số điện thoại | Ô liên hệ của kèo câu (chỉ thành viên thấy); nhận là chủ hồ (chỉ chủ dự án thấy) | Tuỳ chọn | Chức năng app |
| Tin nhắn → Tin nhắn khác trong app | Tin nhắn trong kèo câu | Tuỳ chọn | Chức năng app |
| Ảnh và video → Ảnh | Ảnh điểm câu, hồ câu (nén lại, xoá EXIF/GPS) | Tuỳ chọn | Chức năng app |
| Hoạt động trong app → Nội dung khác do người dùng tạo | Điểm câu, bình luận, đánh giá, lịch xả cá, báo cáo, lượt chặn | Tuỳ chọn | Chức năng app |
| Mã thiết bị hoặc mã khác | Mã băm SHA-256 của mã ngẫu nhiên trên máy; mã băm IP (HMAC, xoá sau 7 ngày) | Tuỳ chọn (chỉ khi dùng tính năng cộng đồng) | Chức năng app; Chống gian lận, bảo mật |

**Không thu thập**: email, danh bạ, tài chính, sức khoẻ, tệp, lịch, lịch sử duyệt web, âm thanh, chẩn đoán/sự cố
(không có SDK báo lỗi), mã quảng cáo. Nhật ký câu, nơi theo dõi, cài đặt **chỉ nằm trên máy** → không phải khai.

> Đổi tính năng (thêm đăng nhập, SDK báo lỗi, quảng cáo…) thì **phải** cập nhật bảng này, `privacy.html` và
> `ios/Runner/PrivacyInfo.xcprivacy` cùng lúc.

## 7. Trang cửa hàng (bản nháp tiếng Việt)

**Tên app** (≤ 30 ký tự): `Con Nước – Thủy triều & câu cá`

**Mô tả ngắn** (≤ 80 ký tự):
`Mực nước, thủy triều, thời tiết và giờ vàng câu cá cho sông, biển Việt Nam.`

**Mô tả đầy đủ**:

```
Con Nước giúp người đi câu biết nước lên hay xuống, thời tiết ra sao và lúc nào cá dễ ăn mồi.

• Mực nước và thủy triều: con nước lớn, nước ròng theo giờ cho bờ biển và các sông chịu ảnh hưởng triều; mực nước sông từ bản tin của Trung tâm Dự báo Khí tượng Thủy văn quốc gia.
• Thời tiết kiểu app thời tiết: nhiệt độ, gió, mưa, dông, UV, áp suất, dự báo 48 giờ và 7 ngày.
• Giờ vàng và chỉ số câu cá: dựa trên con nước, mặt trăng, bình minh, hoàng hôn và thời tiết.
• Cảnh báo an toàn: dông sét, gió giật, mưa lớn, nước lên nhanh, "Mấy giờ nước ngập lối về".
• Bản đồ: tìm trạm, sông, hồ câu dịch vụ và điểm câu gần bạn; lớp ảnh vệ tinh.
• Cộng đồng: chia sẻ điểm câu, bình luận, rủ kèo đi câu, đánh giá hồ câu, xem lịch xả cá. Có báo cáo và chặn người dùng.
• Nhật ký câu cá lưu ngay trên máy bạn.
• Báo thức con nước và widget màn hình chính.

Không cần đăng ký tài khoản. Không quảng cáo.

Lưu ý: mọi số liệu, dự báo và cảnh báo chỉ để tham khảo, không thay thế bản tin chính thức của cơ quan nhà nước. Luôn mặc áo phao và tự đảm bảo an toàn khi ra sông nước.

Nguồn dữ liệu: Trung tâm Dự báo KTTV quốc gia, IOC Sea Level Monitoring, Open-Meteo, © OpenStreetMap, OpenFreeMap, EOxCloudless (EOX IT Services).
```

Lưu ý khi viết: không dùng "chính xác nhất", "chính thức", "số 1"; không nhắc tên app/cửa hàng khác; không nhồi từ khoá.

**Hình ảnh cần chuẩn bị**

| Mục | Yêu cầu |
|---|---|
| Biểu tượng | 512×512 PNG 32-bit (tạo bởi `make_icons.py` → `app/build/store/play-icon-512.png`) |
| Ảnh nổi bật (feature graphic) | 1024×500 JPG/PNG, không trong suốt |
| Ảnh chụp điện thoại | 2–8 ảnh, tỉ lệ 9:16, cạnh 1080–3840 px. Gợi ý 6 ảnh: (1) bản đồ có trạm + chú giải, (2) thẻ con nước một trạm với đồ thị triều, (3) thời tiết 48 giờ/7 ngày, (4) giờ vàng + chỉ số câu cá, (5) cảnh báo an toàn "Mấy giờ nước ngập lối về", (6) điểm câu cộng đồng có nút Báo cáo/Chặn |
| Ảnh máy tính bảng | Tuỳ chọn |

Ảnh chụp phải là app thật, chữ tiếng Việt, không chứa dữ liệu cá nhân thật của ai (tên, số điện thoại trong kèo…).

## 8. Đường phát hành đề xuất

1. **Thử nghiệm nội bộ** (internal testing, tối đa 100 người, duyệt nhanh): tải `.aab` đầu tiên, tự cài thử trên
   2–3 máy thật (Android 8, 13, 15/16): vị trí, báo thức, widget, đăng/xoá điểm câu, Xoá dữ liệu của tôi.
2. **Thử nghiệm kín** ≥ 12 người × 14 ngày (nếu tài khoản cá nhân) — nhắc người thử mở app vài lần.
3. **Xin quyền production** trong Console (trả lời câu hỏi về đợt thử nghiệm) → phát hành theo tỉ lệ (staged rollout)
   20% → 100%.

## 9. Lý do hay bị từ chối và cách đã xử lý

| Rủi ro | Xử lý |
|---|---|
| Logo/biểu tượng mặc định, trùng thương hiệu | ⛔ Chưa xong — thay biểu tượng (mục 1.1) |
| Chính sách quyền riêng tư không khớp Data safety | Đã đối chiếu từng dòng (mục 6) và sửa privacy.html v2 |
| UGC thiếu báo cáo/chặn/điều khoản | Có đủ (P2-54, P2-57) |
| Tự tải/cài APK ngoài Play | Nút APK chỉ có trên web |
| Quyền vị trí nền / báo thức chính xác | Không dùng |
| Thông tin y tế/thiên tai gây hiểu lầm | Nhãn "tham khảo/ước tính" + miễn trừ trách nhiệm + nguồn |
| App không chạy được khi người duyệt mở | Supabase phải đang chạy; không cần đăng nhập |
