# Danh sách pháp lý trước khi phát hành (Việt Nam + cửa hàng)

> Task P2-60 · lập 20/11/2026. Bổ sung cho [../legal-compliance.md](../legal-compliance.md) (đánh giá ban đầu).
> **Đây không phải ý kiến pháp lý.** Số hiệu văn bản, ngưỡng, thời hạn ghi **⚠ cần luật sư xác minh** là nhớ theo
> hiểu biết chung, có thể đã đổi hoặc chưa chính xác. Nên thuê luật sư về CNTT/dữ liệu cá nhân rà một lần trước khi
> phát hành rộng.
>
> Cột **Ai**: Chủ = chủ dự án tự làm · LS = cần luật sư · Code = đã/được làm trong mã.
> Cột **Trạng thái**: ✅ xong · 🟡 một phần · ⛔ chưa · ❓ cần quyết định.

## 1. Bảo vệ dữ liệu cá nhân

| # | Việc | Vì sao | Làm gì | Ai | Trạng thái |
|---|---|---|---|---|---|
| 1.1 | Xác định văn bản đang có hiệu lực | Năm 2025 Quốc hội thông qua **Luật Bảo vệ dữ liệu cá nhân**, hiệu lực từ 2026 (⚠ cần luật sư xác minh số hiệu — nhớ là 91/2025/QH15, hiệu lực 01/01/2026 — và nghị định hướng dẫn). Nghị định 13/2023/NĐ-CP có thể đã bị thay thế | Chính sách quyền riêng tư v2 đã đổi sang "theo pháp luật Việt Nam về bảo vệ dữ liệu cá nhân", không ghi số nghị định. Luật sư xác nhận văn bản áp dụng và nghĩa vụ cụ thể | LS | 🟡 |
| 1.2 | Vị trí là dữ liệu nhạy cảm | NĐ 13/2023 xếp "vị trí cá nhân xác định qua dịch vụ định vị" là dữ liệu **nhạy cảm** (⚠ cần xác minh cách xếp trong Luật 2025). Dữ liệu nhạy cảm cần thông báo rõ và có thể không được miễn đánh giá tác động | App chỉ dùng vị trí trên máy; gửi đi: toạ độ làm tròn ~100 m (thời tiết, không kèm mã máy), ô ~200 m (đang câu), ~2 km (báo dính), toạ độ điểm câu do người dùng chọn đăng. Luật sư xác nhận cách nêu trong chính sách là đủ | LS · Code | 🟡 |
| 1.3 | Sự đồng ý | Đồng ý phải tự nguyện, cụ thể, rõ ràng; gộp chung vào "đồng ý điều khoản" có thể chưa đủ cho từng mục đích | Hiện: cổng đồng ý bắt buộc (P2-57) + hỏi quyền vị trí/thông báo riêng lúc cần. Luật sư xem có cần ô đồng ý riêng cho tính năng cộng đồng (đăng công khai, vị trí điểm câu) không | LS | 🟡 |
| 1.4 | Quyền xoá dữ liệu | Luật yêu cầu đáp ứng yêu cầu xoá; Google Play/Apple cũng yêu cầu | **Xoá dữ liệu của tôi** trong app (migration 0007) + trang `delete-data.html` + yêu cầu qua GitHub Issues khi mất máy | Code · Chủ | ✅ (sau khi áp 0007) |
| 1.5 | Dọn ảnh mồ côi | Trang xoá dữ liệu cam kết "tệp ảnh ... được dọn định kỳ"; Supabase không cho xoá tệp Storage bằng SQL | Mỗi tháng: SQL editor `select * from public.mod_orphan_photos();` → xoá các tệp đó (cũ hơn 1 ngày) trong Storage → bucket `spot-photos` | Chủ | ⛔ (việc định kỳ) |
| 1.6 | Hồ sơ đánh giá tác động xử lý dữ liệu cá nhân (DPIA) | Bên kiểm soát dữ liệu phải lập và lưu/nộp hồ sơ (⚠ cần luật sư: Luật 2025 có thể miễn/hoãn cho cá nhân, hộ kinh doanh, doanh nghiệp nhỏ trong một thời gian, trừ khi xử lý dữ liệu nhạy cảm) | Luật sư xác định có phải lập không; nếu có: mô tả dữ liệu (bảng ở `docs/release/google-play.md` mục 6), mục đích, nơi lưu, thời hạn, biện pháp bảo vệ (RLS, băm, HTTPS) | LS · Chủ | ⛔ |
| 1.7 | Chuyển dữ liệu ra nước ngoài | Máy chủ Supabase đặt ở nước ngoài → có thể phải lập **hồ sơ đánh giá tác động chuyển dữ liệu cá nhân ra nước ngoài** và gửi cơ quan chuyên trách (Bộ Công an — ⚠ cần xác minh đơn vị và thời hạn) | Kiểm vùng (region) của dự án Supabase trong dashboard; luật sư xác định nghĩa vụ; cân nhắc chọn vùng Singapore | LS · Chủ | ⛔ |
| 1.8 | Lưu trữ dữ liệu trong nước | Luật An ninh mạng 2018 + NĐ 53/2022: một số loại dữ liệu của người dùng Việt Nam phải lưu tại Việt Nam đối với **doanh nghiệp trong nước** (⚠ cần luật sư: cá nhân phát triển app có thuộc diện không) | Luật sư trả lời; nếu thuộc diện: cần máy chủ đặt tại Việt Nam | LS | ❓ |
| 1.9 | Thông báo vi phạm dữ liệu | Khi lộ dữ liệu phải báo cơ quan chức năng trong thời hạn ngắn (NĐ 13: 72 giờ — ⚠ cần xác minh theo Luật 2025) | Ghi sẵn quy trình: khoá khoá API, xoay khoá Supabase, đánh giá phạm vi, báo cơ quan, báo người dùng | Chủ · LS | ⛔ |
| 1.10 | Sao lưu đám mây | Chính sách nói dữ liệu trên máy "không gửi đi, không sao lưu lên đám mây" | Android: đã tắt sao lưu (`allowBackup=false`, `data_extraction_rules.xml`). iOS: iCloud Backup **vẫn** sao lưu thư mục app — phải xử lý trước khi lên App Store (`docs/release/app-store.md` mục 8) | Code | 🟡 |
| 1.11 | Trẻ em | Dữ liệu trẻ em cần đồng ý của cha mẹ | Chính sách: không dành cho trẻ dưới 16 dùng tính năng cộng đồng; trên cửa hàng chọn đối tượng 18+ | Chủ | ✅ |
| 1.12 | Kênh liên hệ | Người dùng phải liên hệ được để thực hiện quyền; GitHub cần tài khoản và là công khai | **Nên** thêm email hỗ trợ riêng vào privacy.html, terms.html, mục Pháp lý | Chủ · Code | ❓ |

## 2. Mạng xã hội / nội dung người dùng (Nghị định 147/2024/NĐ-CP)

| # | Việc | Vì sao | Làm gì | Ai | Trạng thái |
|---|---|---|---|---|---|
| 2.1 | Quyết định mô hình cộng đồng | NĐ 147/2024 (hiệu lực 25/12/2024) quản lý dịch vụ mạng xã hội: xác thực tài khoản bằng số điện thoại di động Việt Nam (hoặc định danh điện tử), lưu trữ, gỡ nội dung vi phạm theo yêu cầu cơ quan nhà nước trong thời hạn ngắn (⚠ cần luật sư xác minh điều khoản và ngưỡng). App hiện **ẩn danh** (mã máy) | Chọn 1: **(A)** chế độ biên tập — tắt đăng tự do, nội dung do chủ dự án duyệt trước; **(B)** giữ cộng đồng và thêm xác thực OTP số điện thoại trước khi đăng (cần dịch vụ SMS, thay đổi lớn về dữ liệu). Khuyên: hỏi luật sư trước, phát hành cửa hàng với (A) hoặc với tính năng cộng đồng tắt (`env/community.json` không có Supabase → cộng đồng tự ẩn) nếu chưa chắc | LS · Chủ | ❓ |
| 2.2 | Giấy phép / thông báo mạng xã hội | Trên một ngưỡng người dùng phải có giấy phép thiết lập mạng xã hội; dưới ngưỡng có thể phải thông báo (⚠ cần luật sư: ngưỡng, thủ tục, và cơ quan cấp phép sau khi sắp xếp bộ máy năm 2025 — trước là Bộ TT&TT) | Luật sư xác định; chuẩn bị hồ sơ nếu cần | LS | ⛔ |
| 2.3 | Gỡ nội dung trong 24 giờ | Luật và cả hai cửa hàng | Có báo cáo, ẩn tự động khi nhiều báo cáo, hàm `mod_*` (docs/moderation.md). Chủ dự án phải **thật sự** xem GitHub Issues hằng ngày | Chủ | 🟡 |
| 2.4 | Lọc nội dung, chặn người dùng, quy tắc cộng đồng | Apple 1.2, Google UGC | 0005, 0006, terms.html §5–6 | Code | ✅ |

## 3. Khí tượng thủy văn

| # | Việc | Vì sao | Làm gì | Ai | Trạng thái |
|---|---|---|---|---|---|
| 3.1 | Hoạt động dự báo KTTV | Luật KTTV 2015: tổ chức, cá nhân **hoạt động dự báo, cảnh báo KTTV** (ngoài hệ thống nhà nước) cần giấy phép (⚠ cần luật sư xác minh điều và nghị định hướng dẫn hiện hành). App tự tính dự báo triều, ước tính mực nước sông, chỉ số câu cá, cảnh báo | Luật sư xác định app có bị coi là "hoạt động dự báo" không. Giảm rủi ro: mọi số tự tính ghi "ước tính/tham khảo", không gọi là "bản tin dự báo"; cảnh báo an toàn kèm miễn trừ và khuyên theo bản tin chính thức | LS · Code | 🟡 |
| 3.2 | Dùng và ghi nguồn bản tin KTTV | Truyền tải thông tin KTTV phải đúng nội dung và ghi nguồn (⚠ cần xác minh quy định về "truyền tải tin dự báo") | App ghi nguồn "Trung tâm Dự báo KTTV quốc gia", hiển thị số thực đo/dự báo/ước tính khác nhau (CLAUDE.md 3.3). Kiểm lại điều khoản sử dụng của nchmf.gov.vn | Chủ · LS | 🟡 |
| 3.3 | IOC Sea Level Monitoring | Điều khoản sử dụng chưa kiểm (docs/data-sources.md) | Đọc điều khoản IOC/VLIZ; ghi nguồn | Chủ | ⛔ |

## 4. Bản đồ và chủ quyền

| # | Việc | Vì sao | Làm gì | Ai | Trạng thái |
|---|---|---|---|---|---|
| 4.1 | Hoàng Sa, Trường Sa, ranh giới biển | Luật Đo đạc và Bản đồ 2018; NĐ 18/2020 (xử phạt bản đồ sai chủ quyền) | Đã: nhãn "(Việt Nam)", không vẽ ranh giới biển/tranh chấp (P2-57). Còn: soát mọi mức zoom, cả lớp vệ tinh và bản tối, trước mỗi lần đổi kiểu bản đồ | Chủ | 🟡 |
| 4.2 | Khu vực phân phối | Hiển thị chủ quyền Việt Nam có thể vướng luật thị trường khác | Phát hành **chỉ tại Việt Nam** trên cả hai cửa hàng lúc đầu | Chủ | ❓ |

## 5. Giấy phép dữ liệu và phần mềm bên thứ ba

| # | Nguồn | Giấy phép / điều kiện | Việc cần làm | Trạng thái |
|---|---|---|---|---|
| 5.1 | OpenStreetMap (qua OpenFreeMap/OpenMapTiles, Overpass) | **ODbL 1.0** — bắt buộc ghi "© OpenStreetMap contributors" nơi hiển thị bản đồ/dữ liệu | Có "© OpenStreetMap" trên bản đồ, thẻ loại nước và mục Nguồn dữ liệu. Nên ghi đủ "© OpenStreetMap contributors" và liên kết `openstreetmap.org/copyright` | 🟡 |
| 5.2 | OpenFreeMap / OpenMapTiles | Miễn phí; OpenMapTiles yêu cầu ghi "© OpenMapTiles" | Có trong mục Nguồn | ✅ |
| 5.3 | Natural Earth (đường bờ biển `assets/data/coast.json`) | **Phạm vi công cộng**, không bắt buộc ghi nguồn | Không cần (có thể ghi để minh bạch) | ✅ |
| 5.4 | Open-Meteo | Dữ liệu **CC BY 4.0** (phải ghi nguồn); API miễn phí **chỉ cho mục đích phi thương mại** và có giới hạn số lần gọi/ngày (⚠ cần xác minh giới hạn hiện hành) | Đã ghi nguồn. Nếu app có quảng cáo/thu phí hoặc vượt giới hạn: mua gói API thương mại | 🟡 |
| 5.5 | EOxCloudless (ảnh vệ tinh, EOX IT Services) | Bản các năm gần đây thường là **CC BY-NC-SA 4.0** (phi thương mại) và yêu cầu ghi nguồn kèm "contains modified Copernicus Sentinel data" (⚠ cần xác minh đúng năm đang dùng). Dùng tile của máy chủ EOX cho app phát hành rộng có thể cần thoả thuận | Đã ghi nguồn. Đọc điều khoản dịch vụ tiles.maps.eox.at; nếu thương mại → mua giấy phép hoặc bỏ lớp vệ tinh | 🟡 |
| 5.6 | GloFAS (qua Open-Meteo Flood) | Copernicus — ghi nguồn | Có trong mục Nguồn | ✅ |
| 5.7 | Phông chữ Be Vietnam Pro, Nunito, Quicksand | SIL OFL 1.1 — kèm giấy phép | Đã đăng ký trong màn hình Giấy phép | ✅ |
| 5.8 | Thư viện Flutter/Dart | MIT/BSD/Apache… | Màn hình Giấy phép tự liệt kê (`showLicensePage`) | ✅ |
| 5.9 | Biểu tượng app | Logo Flutter mặc định là **thương hiệu của Google** | ⛔ Thay bằng biểu tượng riêng (`tools/release/make_icons.py`) | ⛔ |

## 6. Tên, thương hiệu, tài khoản

| # | Việc | Vì sao | Làm gì | Ai | Trạng thái |
|---|---|---|---|---|---|
| 6.1 | Tra cứu nhãn hiệu "Con Nước" | Tránh trùng nhãn hiệu đã đăng ký (bị khiếu nại → cửa hàng gỡ app) | Tra cứu trên cơ sở dữ liệu của Cục Sở hữu trí tuệ (IP Việt Nam) và WIPO Brand Database, nhóm 9 (phần mềm) và 42; tìm trùng tên trên Google Play/App Store | Chủ | ⛔ |
| 6.2 | Đăng ký nhãn hiệu (tuỳ chọn) | Bảo vệ tên khi app lớn | Nộp đơn nhóm 9, 42 (⚠ chi phí, thời gian theo biểu phí hiện hành) | Chủ · LS | ❓ |
| 6.3 | Tư cách phát hành | Tài khoản cá nhân: tên thật hiện công khai trên cửa hàng; tổ chức cần D-U-N-S | Quyết định cá nhân hay hộ kinh doanh/công ty | Chủ | ❓ |
| 6.4 | Thuế, quảng cáo | Hiện miễn phí, không quảng cáo → không phát sinh doanh thu | Nếu sau này có thu nhập: kê khai thuế; cập nhật Data safety/App Privacy khi thêm quảng cáo | Chủ | ✅ (hiện tại) |

## 7. Văn bản pháp lý trong app

| # | Việc | Trạng thái |
|---|---|---|
| 7.1 | Điều khoản sử dụng v2 (`app/web/terms.html`) — thêm mục xoá dữ liệu | ✅ |
| 7.2 | Chính sách quyền riêng tư v2 (`app/web/privacy.html`) — sửa: tên hiển thị gửi kèm bài đăng; số điện thoại/Zalo người dùng tự nhập (kèo câu, nhận chủ hồ) — trước đây ghi sai là "không thu thập số điện thoại"; không sao lưu đám mây; quyền xoá toàn bộ; bỏ số NĐ 13/2023 | ✅ |
| 7.3 | `termsVersion` 1 → 2: mọi người dùng sẽ được hỏi đồng ý lại một lần | ✅ |
| 7.4 | Câu xin quyền vị trí (Android trong app, iOS Info.plist) — trước đây ghi "không gửi đi đâu" là **không đúng** (toạ độ làm tròn được gửi để lấy thời tiết) → đã sửa | ✅ |
| 7.5 | Luật sư rà toàn văn terms.html, privacy.html, delete-data.html | ⛔ |

## 8. Việc nên làm theo thứ tự

1. Thay biểu tượng app (5.9) — chặn cả hai cửa hàng.
2. Gặp luật sư một buổi với danh sách câu hỏi: 1.1, 1.2, 1.3, 1.6, 1.7, 1.8, 2.1, 2.2, 3.1. Mang theo `privacy.html`,
   `terms.html`, bảng dữ liệu ở `google-play.md` mục 6.
3. Quyết định mô hình cộng đồng (2.1) trước khi gửi cửa hàng.
4. Tạo email hỗ trợ (1.12), tra cứu nhãn hiệu (6.1), kiểm vùng Supabase (1.7).
5. Áp migration 0007, đăng web, rồi mới điền Play Console / App Store Connect.
