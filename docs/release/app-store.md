# Phát hành Con Nước lên App Store (iOS)

> Task P2-60 · lập 20/11/2026. **Chưa build thử iOS lần nào** (không có máy Mac): mọi thứ dưới đây đã chuẩn bị
> trong mã nhưng chỉ kiểm được bằng mắt, chưa qua Xcode. Mục **⚠ cần xác minh** phải kiểm lại trên App Store
> Connect / trang hướng dẫn của Apple. Liên quan: [google-play.md](google-play.md), [legal-checklist.md](legal-checklist.md).

## 0. Đã sẵn sàng trong code

| Hạng mục | Trạng thái |
|---|---|
| Bundle ID | `vn.rivertide.rivertide` (đăng ký đúng chuỗi này trong Certificates, Identifiers & Profiles) |
| Tên hiện trên màn hình | `CFBundleDisplayName` = **Con Nước** |
| iOS tối thiểu | 15.0 |
| Ngôn ngữ | `CFBundleLocalizations`: vi, en, zh, ko, ja |
| Câu xin quyền (tiếng Việt) | Vị trí khi dùng app; máy ảnh (chụp ảnh nhật ký); thư viện ảnh (chọn ảnh); lưu ảnh (khi chia sẻ chọn "Lưu ảnh"). Câu chữ khớp chính sách quyền riêng tư (vị trí **có** gửi đi dạng làm tròn để lấy thời tiết — câu cũ "không gửi đi" đã sửa) |
| Mã hoá xuất khẩu | `ITSAppUsesNonExemptEncryption = false` (chỉ HTTPS của hệ điều hành) |
| Bản kê quyền riêng tư | `ios/Runner/PrivacyInfo.xcprivacy`, đã thêm vào target Runner (Copy Bundle Resources) trong `project.pbxproj` |
| Tính năng chỉ Android | Báo thức, widget: đã chặn trên iOS (không gọi plugin). Mọi chữ "app Android/APK" chỉ hiện trên bản web (guideline 2.3.10 cấm nhắc nền tảng khác) |
| UGC (1.2) | Điều khoản bắt buộc trước khi dùng, lọc nội dung, báo cáo, chặn người dùng, cam kết 24 giờ |
| Xoá dữ liệu (5.1.1(v)) | Thêm → Pháp lý → **Xoá dữ liệu của tôi** |

## 1. Điều kiện bắt buộc

1. **Apple Developer Program**: 99 USD/năm. Cá nhân (tên thật hiện là người bán) hoặc tổ chức (cần D-U-N-S, pháp nhân).
2. **Máy Mac có Xcode** để build và tải lên. ⚠ Cần xác minh phiên bản Xcode/SDK tối thiểu Apple đang yêu cầu khi
   tải lên (Apple nâng mỗi mùa xuân). Không có Mac: thuê Mac đám mây (MacinCloud…), hoặc dịch vụ CI có máy Mac
   (Codemagic, GitHub Actions `macos-*`). Khoá ký iOS khi đó nằm trên dịch vụ — chỉ dùng dịch vụ tin cậy.
3. **Máy iPhone thật** để thử trước khi gửi (TestFlight).

## 2. Các bước trên máy Mac

```bash
cd app
flutter pub get
cd ios && pod install && cd ..          # nếu dự án dùng CocoaPods; Swift Package Manager thì bỏ qua
open ios/Runner.xcworkspace              # (hoặc Runner.xcodeproj nếu không có workspace)
```

Trong Xcode, target **Runner**:
1. Signing & Capabilities → chọn Team, bật *Automatically manage signing*.
2. Kiểm **PrivacyInfo.xcprivacy** có trong Build Phases → Copy Bundle Resources (đã thêm sẵn; nếu Xcode báo thiếu
   tệp: kéo `Runner/PrivacyInfo.xcprivacy` vào nhóm Runner, tích target Runner).
3. Không cần bật capability nào (không Push, không App Groups, không Background Modes).
4. Xem trước vấn đề: thiết bị **iPad** đang được hỗ trợ (`TARGETED_DEVICE_FAMILY = 1,2`) → App Store bắt buộc ảnh
   chụp iPad và app phải dùng tốt trên iPad. Nếu chưa muốn làm iPad: đổi Targeted Device Families thành *iPhone*.

```bash
flutter build ipa --release --dart-define-from-file=env/community.json
```
Tải `build/ios/ipa/*.ipa` lên bằng Transporter hoặc Xcode Organizer → TestFlight → thử → gửi duyệt.
Sau khi tải lên, mở **App Store Connect → bản build → Privacy report** (Xcode Organizer: *Generate Privacy Report*)
để xem bản kê tổng hợp của app + plugin; nếu Apple gửi email "ITMS-91053 Missing API declaration" thì bổ sung đúng
mục được nêu vào `PrivacyInfo.xcprivacy`.

## 3. Bản kê quyền riêng tư (PrivacyInfo.xcprivacy) — vì sao khai như vậy

- `NSPrivacyTracking = false`, không có tracking domain (không quảng cáo, không SDK phân tích).
- Dữ liệu thu thập (đều **gắn với người dùng** qua mã máy, **không** theo dõi, mục đích **App Functionality**):
  vị trí gần đúng, vị trí chính xác (điểm người dùng đăng), ảnh, nội dung khác do người dùng tạo, tin nhắn (chat
  trong kèo), số điện thoại (ô liên hệ kèo / nhận chủ hồ, tuỳ chọn), User ID (tên hiển thị), Device ID (mã băm của
  mã ngẫu nhiên trên máy).
- API "lý do bắt buộc" khai ở cấp app (cho phần không có bản kê riêng):
  - UserDefaults `CA92.1` — plugin home_widget không có bản kê riêng.
  - File timestamp `C617.1` và Disk space `E174.1` — SQLite do package `sqlite3` (drift) đóng gói vào app không có
    bản kê riêng; SQLite gọi `stat/fstat` lên tệp CSDL của chính app và `statfs` khi mở CSDL.
    ⚠ Cần xác minh bằng Privacy Report sau lần build đầu; bỏ mục nào Apple không yêu cầu.
- Các plugin có bản kê riêng (đã kiểm trong pub cache): shared_preferences_foundation, flutter_local_notifications,
  image_picker_ios, share_plus, url_launcher_ios, package_info_plus, geolocator_apple, app_links. MapLibre iOS SDK
  (qua maplibre_gl): ⚠ cần xác minh bản kê có trong framework.

## 4. App Store Connect — trả lời "App Privacy"

Chọn **Có, chúng tôi thu thập dữ liệu**. Với từng loại dưới đây: *Linked to user: Yes* · *Used for tracking: No* ·
*Purpose: App Functionality*.

| Mục Apple | Ghi chú |
|---|---|
| Location → Coarse Location | Check-in ô ~200 m, báo dính cá ô ~2 km, toạ độ làm tròn cho thời tiết |
| Location → Precise Location | Vị trí điểm câu/hồ/kèo do người dùng đăng |
| User Content → Photos or Videos | Ảnh điểm câu, hồ câu |
| User Content → Other User Content | Điểm câu, bình luận, đánh giá, kèo, báo cáo |
| User Content → Emails or Text Messages | Tin nhắn trong kèo câu |
| Contact Info → Phone Number | Tuỳ chọn, ô liên hệ kèo / nhận chủ hồ |
| Identifiers → User ID | Tên hiển thị (tự đặt) |
| Identifiers → Device ID | Mã băm mã máy (chống spam, quyền sở hữu bài đăng) |

Không chọn: Health, Financial, Contacts, Browsing/Search History, Purchases, Diagnostics, Usage Data, Sensitive Info.
Privacy Policy URL: `https://dangkhanhaa.github.io/rivertide/privacy.html`.

## 5. Thông tin khác trên App Store Connect

| Mục | Điền |
|---|---|
| Danh mục | Weather (chính) · Sports hoặc Navigation (phụ) |
| Phân loại tuổi | Trả lời bảng hỏi thật: **có** nội dung do người dùng tạo và **có** nhắn tin/chat; không bạo lực, không cờ bạc… Apple tự tính mức tuổi (⚠ hệ mức tuổi Apple đổi từ 2025 — xem kết quả trên Connect) |
| Bản quyền | `© 2026 <tên chủ dự án>` |
| URL hỗ trợ | `https://github.com/dangkhanhaa/rivertide/issues` (nên có thêm email — mục 7) |
| Khu vực phân phối | Khuyên **chỉ Việt Nam** lúc đầu (dữ liệu, ngôn ngữ, bản đồ chủ quyền; tránh luật riêng của thị trường khác như Trung Quốc đại lục) |
| Giá | Miễn phí, không mua trong app |
| Đăng nhập cho người duyệt | Không cần (không có tài khoản) |

## 6. Ghi chú gửi người duyệt (dán vào "Notes" — tiếng Anh)

```
Con Nuoc ("water tide") shows river levels, tides, weather and fishing times for Vietnam.
No account or login is needed; all features work right after accepting the Terms of Use on first launch.

User-generated content (Guideline 1.2):
- Users must accept the Terms of Use (zero tolerance for objectionable content and abusive users) before using the app.
- Automatic filtering: links, phone numbers, gambling/scam terms and offensive words are refused by the server; rate limits stop spam.
- Report: every public spot, comment, trip and pond has a "Report" action; content reported by several users is hidden automatically.
- Block: "Block this person" on spots, comments, trips, trip messages and pond reviews hides all of that author's content immediately. Undo: More > Legal > Unblock all.
- We act on reports within 24 hours and remove the content and the offender. Contact: More > Legal > Contact / report abuse.

Data deletion (Guideline 5.1.1(v)): there are no accounts. More > Legal > "Xoá dữ liệu của tôi" (Delete my data) deletes everything this device posted on our server and all data on the device. Web page: https://dangkhanhaa.github.io/rivertide/delete-data.html

Location is only requested when the user taps the "my location" button and is optional.
All forecasts are labelled as estimates for reference; the app shows a safety disclaimer.
To try the community features: on the Map tab tap (or long-press) any place, then "Ghim công khai" (Pin publicly) to publish a spot; open any community spot or comment to see Report and Block.
```
⚠ Kiểm lại đường đi trong app ở dòng cuối cho đúng bản build gửi duyệt trước khi dán.

## 7. Rủi ro bị từ chối và cách xử lý

| Guideline | Rủi ro | Xử lý |
|---|---|---|
| 2.3.8 / 5.2 | Biểu tượng là logo Flutter mặc định | ⛔ Chưa xong — `tools/release/make_icons.py` (iOS không được có kênh trong suốt; script tự làm phẳng) |
| 1.2 | Liên hệ chỉ qua GitHub Issues (cần tài khoản GitHub) có thể bị coi là "khó liên hệ" | **Khuyên** thêm một email hỗ trợ vào privacy.html, terms.html và mục Pháp lý (cần chủ dự án tạo email) |
| 2.1 | Người duyệt mở app khi máy chủ Supabase tạm dừng (gói miễn phí tự dừng khi lâu không dùng) | Kiểm Supabase đang chạy trước khi gửi; mở app thử 1 lần |
| 4.2 | "Chức năng tối thiểu" — trên iOS không có báo thức/widget | Vẫn đủ: bản đồ, triều, thời tiết, giờ vàng, cảnh báo, cộng đồng, nhật ký |
| 2.3.10 | Nhắc Android/APK | Đã ẩn trên iOS |
| 5.1.1 | Câu xin quyền không rõ/không đúng | Đã viết lại theo đúng cách dùng |
| 5.1.2 | Dữ liệu dùng sai mục đích khai | Bản kê, App Privacy và privacy.html đã đối chiếu cùng nhau |
| 1.4.1 | Cảnh báo an toàn có thể gây hại nếu sai | Nhãn "tham khảo/ước tính", miễn trừ trách nhiệm, ghi nguồn |

## 8. Việc còn mở cho iOS

- Câu xin quyền chỉ có tiếng Việt (hiện cho mọi ngôn ngữ máy). Muốn dịch: thêm `InfoPlist.strings` cho en/zh/ko/ja trong Xcode.
- iCloud Backup của iPhone mặc định sao lưu thư mục Documents của app (có CSDL: mã máy, nhật ký câu). Bản Android đã tắt
  sao lưu; chính sách nói dữ liệu "không sao lưu lên đám mây". Trên Mac cần quyết định: (a) loại thư mục CSDL khỏi
  sao lưu (`isExcludedFromBackup`, cần một ít mã Swift/Dart), hoặc (b) sửa chính sách thành "trừ bản sao lưu iCloud do
  bạn bật". ⚠ Chưa làm vì chưa thể kiểm trên iOS.
- Thông báo/báo thức trên iOS: chưa hỗ trợ (cần quyền thông báo iOS + kiểm thử trên máy thật) — để sau.
