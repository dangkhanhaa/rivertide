# Báo cáo Đánh giá Pháp lý & Hướng dẫn Tuân thủ Chuẩn mực
Dự án: **RiverTide** (*Con Nước*)

> **Ngày lập:** 20/11/2026  
> **Tình trạng dự án:** Bản thử nghiệm (Dev / Web GitHub Pages / APK tải trực tiếp)  
> **Mục tiêu tài liệu:** Rà soát toàn diện các rủi ro pháp lý theo Luật pháp Việt Nam và tiêu chuẩn của Apple App Store / Google Play Store; đồng thời cung cấp checklist hành động và mẫu nội dung điều khoản để áp dụng ngay.

---

## 1. Tóm tắt tình trạng tuân thủ

| Lĩnh vực | Căn cứ pháp lý / Quy chuẩn | Đánh giá hiện tại | Mức độ rủi ro khi Public |
|---|---|---|---|
| **Bản đồ & Chủ quyền** | Luật Đo đạc và Bản đồ 2018, Nghị định 18/2020/NĐ-CP | Đã ghim nhãn Hoàng Sa, Trường Sa (Việt Nam), ưu tiên `name:vi` Biển Đông | 🟡 **Trung bình** (Cần kiểm tra kỹ các mức zoom của tile OpenFreeMap) |
| **Mạng xã hội & Bình luận** | Nghị định 147/2024/NĐ-CP (hiệu lực 25/12/2024) | Dùng hash máy ẩn danh để đăng điểm, bình luận, tạo kèo | 🔴 **Rất cao** (Vi phạm quy định bắt buộc xác thực số điện thoại) |
| **Khí tượng Thủy văn & Cảnh báo** | Luật Khí tượng Thủy văn 2015 | Thu thập bản tin KTTV + tự tính dự báo triều, ngập bãi, dông sét | 🔴 **Cao** (Chưa có Tuyên bố miễn trừ trách nhiệm - Legal Disclaimer) |
| **Bảo vệ Dữ liệu Cá nhân** | Nghị định 13/2023/NĐ-CP (PDPD) | Thu thập GPS chính xác; đã xóa EXIF ảnh, làm mờ tọa độ | 🟡 **Trung bình** (Chưa có Privacy Policy & Thỏa thuận người dùng ToS) |
| **Tiêu chuẩn Store (Google/Apple)** | App Store Review Guidelines, Google Play Policy | Chưa có Privacy Policy URL, thiếu tính năng Chặn người dùng (Block User) | 🔴 **Chặn phát hành** (Sẽ bị Store từ chối duyệt ngay) |

---

## 2. Chi tiết các vấn đề Pháp lý tại Việt Nam

### 2.1. Tính năng Cộng đồng & Bình luận (Nghị định 147/2024/NĐ-CP)
Đây là **vấn đề quan trọng và rủi ro lớn nhất** nếu mở app cho người ngoài sử dụng tự do.

* **Bối cảnh pháp lý:**
  Nghị định 147/2024/NĐ-CP thay thế NĐ 72/2013 và NĐ 27/2018, có hiệu lực từ ngày **25/12/2024** siết chặt việc quản lý thông tin trên mạng xã hội và ứng dụng internet.
* **Các điểm chạm trong app:**
  * Tính năng **Điểm câu cộng đồng** (đăng bài, tải ảnh, mô tả).
  * Tính năng **Bình luận dưới điểm**.
  * Tính năng **Kèo câu** (tạo nhóm rủ nhau đi câu, nhắn tin tương tác trong kèo).
  * Tính năng **Đang câu ở đây**, **Đánh giá hồ câu**, **Báo dính cá**.
* **Rủi ro vi phạm:**
  1. **Bắt buộc xác thực bằng Số điện thoại di động (Điều 23 & 32):** Mọi ứng dụng có tính năng mạng xã hội/tương tác cộng đồng tại Việt Nam chỉ được cho phép người dùng đăng bài, bình luận, chia sẻ thông tin **sau khi đã xác thực tài khoản bằng số điện thoại di động tại Việt Nam** (hoặc số định danh cá nhân). Cơ chế hiện tại của app (`mã bí mật ngẫu nhiên lưu trên máy`) là ẩn danh, không đáp ứng luật.
  2. **Trách nhiệm kiểm duyệt & gỡ bỏ thông tin vi phạm:** Nếu có người dùng đăng ảnh phản cảm, cờ bạc trá hình (đá gà, số đề qua kèo câu), hoặc lừa đảo, nền tảng phải có khả năng ngăn chặn và gỡ bỏ nội dung trong vòng 24 giờ. Cơ chế "3 người báo cáo mới ẩn" là chưa đủ chặt chẽ.
  3. **Giấy phép / Thông báo:** Dịch vụ có tính năng mạng xã hội nếu đạt quy mô từ 10.000 lượt truy cập/tháng hoặc từ 1.000 thành viên thường xuyên thì phải có Giấy phép Mạng xã hội do Bộ Thông tin và Truyền thông cấp.

### 2.2. Chủ quyền Lãnh thổ & Bản đồ số (Luật Đo đạc và Bản đồ 2018)
* **Căn cứ:** Luật số 27/2018/QH14 và Điều 11 Nghị định 18/2020/NĐ-CP (xử phạt 40–50 triệu đồng đối với cá nhân, buộc gỡ bỏ hoặc tiêu hủy phần mềm có bản đồ sai lệch chủ quyền).
* **Đánh giá hiện trạng:**
  * ✅ **Tốt:** App đã chủ động thêm layer `fixedLabels` trong `map_screen_build_map.dart` hiển thị cố định:
    * `Quần đảo Hoàng Sa (Việt Nam)` (17.5°N, 112.0°E)
    * `Quần đảo Trường Sa (Việt Nam)` (10.0°N, 112.8°E)
    * Xử lý ưu tiên tên tiếng Việt (`name:vi`) cho Biển Đông.
* **Rủi ro tiềm ẩn:**
  * Nguồn dữ liệu tile OpenFreeMap / OpenStreetMap là nguồn quốc tế. Cần rà soát kỹ ở các cấp độ phóng to (zoom level) xem có hiển thị các đường ranh giới biển tranh chấp bất hợp pháp (đường 9 đoạn / đường chữ U) hay không. Bất kỳ nét vẽ nào vi phạm chủ quyền biển đảo đều khiến ứng dụng bị cấm vĩnh viễn tại Việt Nam.

### 2.3. Khí tượng Thủy văn & Trách nhiệm Dân sự (Luật Khí tượng Thủy văn 2015)
* **Căn cứ:** Luật số 90/2015/QH13.
* **Các tính năng liên quan:**
  * Trích xuất bản tin mực nước sông từ PDF của Trung tâm KTTV Quốc gia (`nchmf.gov.vn`).
  * Tính toán dự báo thủy triều, chỉ số câu cá.
  * Cảnh báo an toàn: Băng dông sét, cảnh báo ngập bãi, tính năng *"Mấy giờ nước ngập lối về"* (báo thức khi triều dâng cô lập bãi bồi/ghềnh đá).
* **Rủi ro:**
  * Nếu người đi câu dựa vào thông số dự báo của app để ra ghềnh đá/bãi sông và gặp tai nạn (đuối nước, nước dâng bất ngờ do xả lũ thủy điện mà mô hình toán học chưa tính được): Nhà phát triển sẽ đối mặt với rủi ro tranh chấp dân sự hoặc khiếu nại nếu không có **Tuyên bố miễn trừ trách nhiệm (Disclaimer)** rõ ràng và dễ thấy.

### 2.4. Quyền riêng tư & Bảo vệ Dữ liệu Cá nhân (Nghị định 13/2023/NĐ-CP)
* **Đánh giá:**
  * ✅ Đã làm tốt: Tự động xóa EXIF/GPS của ảnh cá trước khi lưu trữ; làm mờ vị trí chia sẻ (`fuzz`); không ép đăng nhập khi chỉ xem số liệu.
  * ❌ Thiếu: Dữ liệu vị trí GPS của người dùng là dữ liệu cá nhân theo NĐ 13/2023. App hiện **chưa có trang Chính sách quyền riêng tư (Privacy Policy)** và **Điều khoản sử dụng (Terms of Service)** để thông báo minh bạch cho người dùng trước khi cấp quyền vị trí.

---

## 3. Tiêu chuẩn Phát hành Store (Google Play & Apple App Store)

Nếu nộp app lên Store hiện tại, ứng dụng sẽ bị **Reject** do:
1. **Thiếu Privacy Policy URL:** Bắt buộc phải có URL công khai trên trang giới thiệu ứng dụng và bên trong màn hình Cài đặt của app.
2. **Quy định về Nội dung do Người dùng Tạo (UGC):**
   * Theo Apple App Store Review Guideline 1.2 và Google Play Policy: Ứng dụng có đăng bài, bình luận, tạo nhóm phải có:
     * Điều khoản sử dụng rõ ràng nghiêm cấm hành vi quấy rối, nội dung độc hại.
     * Cơ chế **Báo cáo vi phạm (Report)** (đã có).
     * Cơ chế **Chặn người dùng (Block User)** để ẩn ngay toàn bộ nội dung của người bị chặn (chưa có).
     * Cam kết xử lý báo cáo vi phạm trong vòng 24 giờ.
3. **Ký ứng dụng (Signing Key):** File APK hiện ký bằng Android debug key. Cần sinh Keystore phát hành chính thức (`app-release.jks`) được bảo vệ bí mật.

---

## 4. Kế hoạch Hành động (Action Plan)

### Bước 1: Bảo vệ Pháp lý Ngay lập tức (Dễ làm - Cần làm ngay)

#### 1. Thêm Tuyên bố Miễn trừ Trách nhiệm (Legal Disclaimer)
* Thêm vào:
  1. Hộp thoại **Giới thiệu / Về ứng dụng** (màn hình Cài đặt).
  2. Dòng chú thích nhỏ ở cuối các thẻ cảnh báo ngập bãi, dông sét, và tính năng "Mấy giờ nước ngập lối về".
* **Nội dung mẫu:**
  > *"Mọi số liệu mực nước, dự báo thủy triều, chỉ số câu cá và cảnh báo an toàn trên ứng dụng chỉ mang tính chất tham khảo dựa trên mô hình tính toán khoa học và dữ liệu công cộng, không thay thế cho các bản tin cảnh báo thiên tai chính thức của cơ quan nhà nước có thẩm quyền hoặc các quy tắc cứu hộ, an toàn sông nước. Người dùng tự chịu trách nhiệm về quyết định và an toàn của bản thân khi hoạt động ngoài trời."*

#### 2. Soạn trang Privacy Policy & Terms of Service
* Tạo file tĩnh `docs/privacy.html` hoặc đăng lên GitHub Pages:  
  `https://dangkhanhaa.github.io/rivertide/privacy.html`
* Nội dung gồm:
  * Cam kết chỉ dùng GPS để tính khoảng cách trạm gần nhất và mực nước cục bộ; không bán dữ liệu.
  * Ảnh tải lên được xóa thông tin GPS nhúng; người dùng sở hữu quyền xóa nội dung của mình.
  * Hòm thư liên hệ tiếp nhận phản ánh/khiếu nại nội dung.

---

### Bước 2: Xử lý Tính năng Cộng đồng theo Nghị định 147/2024

Chọn 1 trong 2 hướng đi phù hợp với nguồn lực:

* **Phương án A (Khuyên dùng cho giai đoạn đầu - An toàn tuyệt đối, chi phí 0đ):**
  * Chuyển các tính năng cộng đồng (Điểm câu công khai, Hồ câu, Kèo câu) sang **chế độ Biên tập (Curated / Read-only)**.
  * Dữ liệu điểm câu, hồ câu do đội ngũ phát triển tổng hợp và kiểm duyệt trước khi đưa lên.
  * Tạm ẩn/tắt tính năng bình luận tự do và tạo kèo tự do.
  * 👉 **Ưu điểm:** Không bị xem là mạng xã hội; không cần làm thủ tục xác thực số điện thoại di động; không lo người dùng đăng nội dung xấu.

* **Phương án B (Nếu vẫn muốn giữ tính năng Mạng xã hội):**
  * Bổ sung cơ chế đăng nhập và **xác thực số điện thoại bằng OTP** (qua Firebase Phone Auth hoặc dịch vụ SMS trong nước) trước khi cho phép người dùng: đăng điểm câu, viết bình luận, tạo kèo câu.
  * Bổ sung nút **"Chặn người này" (Block User)** bên cạnh nút Báo cáo.
  * Có danh sách từ khóa cấm (blacklisted words) lọc tự động các bình luận xấu.
  * Chuẩn bị hồ sơ Thông báo mạng xã hội với Cục Phát thanh, truyền hình và thông tin điện tử (Bộ TT&TT).

---

### Bước 3: Rà soát Kỹ thuật Trước khi Phát hành Store

- [ ] Zoom kiểm tra kỹ vùng Biển Đông trên bản đồ nền OpenFreeMap ở các mức zoom (từ zoom 4 đến zoom 14), bảo đảm không có nét đứt phân định ranh giới biển bất thường.
- [ ] Bổ sung liên kết `Chính sách quyền riêng tư` và `Điều khoản sử dụng` vào tab Cài đặt của app.
- [ ] Bổ sung nút `Chặn người dùng` ở mục bình luận và bài đăng cộng đồng (nếu bật).
- [ ] Tạo file keystore ký phát hành Android chính thức và cấu hình trong `android/app/build.gradle`.
- [ ] Đặt email hỗ trợ người dùng công khai trong app (ví dụ: `support@rivertide.vn` hoặc email cá nhân) để nhận phản ánh về bản quyền và nội dung.

