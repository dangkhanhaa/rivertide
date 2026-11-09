# 04 — Bảo mật

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md). Áp dụng **ngay từ bản dev**.

## 1. Phân loại dữ liệu

| Mức | Ví dụ | Quy tắc |
|---|---|---|
| **Công khai** | Trạm, mực nước, triều, thời tiết, loài cá | Đọc tự do, chỉ server ghi |
| **Cá nhân** | Điểm đã lưu, nhật ký câu, ảnh, cảnh báo, FCM token, email | Chỉ chủ sở hữu (RLS); không log; xóa được |
| **Bí mật hệ thống** | service_role, DB password, FCM service account, khóa Vietmap service, cron secret, keystore | Chỉ trong Supabase secrets/Vault, GitHub secrets, Bitwarden |

## 2. App — bắt buộc

- [ ] Chỉ HTTPS (Android `usesCleartextTraffic=false`, network security config chặn cleartext).
- [ ] App chỉ chứa: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `VIETMAP_TILE_KEY`, cấu hình Firebase — đều là khóa công khai có giới hạn.
- [ ] Cấu hình qua `--dart-define-from-file`, file `env/*.json` (trừ `example.json`) bị gitignore.
- [ ] Phiên đăng nhập lưu bằng `flutter_secure_storage`.
- [ ] Quyền: vị trí **khi dùng app** (không vị trí nền), thông báo, ảnh/camera chỉ khi người dùng bấm thêm ảnh. Mỗi lần xin quyền có màn hình giải thích trước.
- [ ] Ảnh trước khi tải lên: mã hóa lại (xóa EXIF/GPS), resize ≤ 1600px, ≤ 2 MB.
- [ ] Chia sẻ ra ngoài: tọa độ đã làm mờ (`fuzz`), không kèm id nội bộ.
- [ ] Deep link / tham số route: validate định dạng & phạm vi.
- [ ] Không WebView tải nội dung tùy ý. Link ngoài mở bằng trình duyệt hệ thống (`url_launcher`, `LaunchMode.externalApplication`), chỉ `https`.
- [ ] Build release: `--obfuscate --split-debug-info=build/symbols`.
- [ ] Crashlytics: tắt thu thập trong debug; không gắn user identifier là email.

## 3. Backend — bắt buộc

- [ ] RLS bật trên **mọi** bảng `public` (test tự động liệt kê bảng thiếu RLS — xem 05-testing).
- [ ] Edge Functions: zod validate, giới hạn body, rate limit, timeout, lỗi không lộ nội bộ.
- [ ] `adminClient()` (service_role) **chỉ** dùng trong Edge Functions / Python server-side.
- [ ] Function cron xác thực `x-cron-secret`; function client xác thực JWT + App Check (dev: monitor).
- [ ] Storage: bucket ảnh **private**, policy theo thư mục `<user_id>/`, giới hạn MIME (`image/jpeg`, `image/webp`) & kích thước.
- [ ] CORS: chỉ cần cho admin web — whitelist domain; app di động không cần CORS.
- [ ] Không chạy SQL ghép chuỗi từ input; dùng client query builder / tham số.
- [ ] Dữ liệu nguồn ngoài: kiểm tra kiểu, phạm vi, kích thước; HTML parse bằng parser (không regex trên toàn trang nếu tránh được); không `eval`.
- [ ] Phụ thuộc ghim phiên bản (`deno.json`, `pubspec.lock` commit, `requirements.txt` có version).

## 4. Quy trình

- [ ] Trước mỗi commit chạy (không được có kết quả):
  ```powershell
  git grep -n -I -i -E "service_role|PRIVATE KEY|BEGIN RSA|client_secret|cron_secret\s*=\s*['\"][^'\"]+"
  ```
- [ ] GitHub: secret scanning + push protection bật.
- [ ] Lộ khóa → làm theo TOOLS.md mục 11.5 ngay lập tức.
- [ ] Thay đổi RLS/Storage policy/auth → ghi rõ trong báo cáo task và **chờ người dùng duyệt**.

## 5. Quyền riêng tư (thiết kế)

- Không bắt buộc đăng nhập để dùng tính năng xem dữ liệu.
- Dữ liệu cá nhân mặc định **riêng tư**; chia sẻ là hành động chủ động.
- Không thu thập dữ liệu không dùng tới. Không bán/chia sẻ dữ liệu.
- Người dùng xóa được toàn bộ dữ liệu của mình (P2: `delete-account`).
- Edge Function `point` không lưu lịch sử tọa độ theo người dùng — cache chỉ theo ô geohash.
