# CLAUDE.md — LUẬT BẮT BUỘC cho AI khi code RiverTide

> File này được AI đọc tự động mỗi phiên. Mọi quy tắc ở đây là **BẮT BUỘC**, không phải gợi ý.
> Từ khóa: **PHẢI** = bắt buộc · **KHÔNG ĐƯỢC** = cấm tuyệt đối · **NÊN** = mặc định, chỉ bỏ khi có lý do ghi rõ.
> Nếu yêu cầu của người dùng mâu thuẫn với file này → **dừng lại, chỉ ra mâu thuẫn, hỏi lại** trước khi làm.

---

## 1. Bản đồ tài liệu — đọc đúng file trước khi code

| Cần biết | Đọc |
|---|---|
| Sản phẩm là gì, từng tính năng hoạt động thế nào, tiêu chí chấp nhận | [FEATURES.md](FEATURES.md) |
| Kiến trúc, CSDL, API, thuật toán, **roadmap task** | [PROJECT.md](PROJECT.md) |
| Công cụ, môi trường, tài khoản, secrets | [TOOLS.md](TOOLS.md) |
| Kiến trúc code, tầng, thư mục feature | [docs/rules/01-architecture.md](docs/rules/01-architecture.md) |
| Chuẩn code Dart/Flutter | [docs/rules/02-flutter-dart.md](docs/rules/02-flutter-dart.md) |
| Chuẩn SQL, Supabase, Edge Functions | [docs/rules/03-backend.md](docs/rules/03-backend.md) |
| Bảo mật | [docs/rules/04-security.md](docs/rules/04-security.md) |
| Kiểm thử | [docs/rules/05-testing.md](docs/rules/05-testing.md) |
| Giao diện, chữ tiếng Việt, khả năng tiếp cận | [docs/rules/06-ui-copy.md](docs/rules/06-ui-copy.md) |
| Git, commit, quy trình | [docs/rules/07-git-workflow.md](docs/rules/07-git-workflow.md) |

Thứ tự ưu tiên khi các file mâu thuẫn: **CLAUDE.md > docs/rules/* > PROJECT.md > FEATURES.md**. Phát hiện mâu thuẫn → báo người dùng.

---

## 2. Quy trình BẮT BUỘC cho mỗi task

1. **Xác định task:** mỗi lần chỉ làm **đúng 1 task** có mã trong PROJECT.md mục 14 (vd `P1-15`). Không có mã → hỏi người dùng gán mã hoặc xác nhận đây là việc ngoài roadmap.
2. **Đọc spec:** đọc mục PROJECT.md + FEATURES.md + docs/rules liên quan. Ghi rõ trong câu trả lời đã đọc những mục nào.
3. **Kiểm tra phụ thuộc:** task phụ thuộc task chưa xong → dừng, báo.
4. **Lập kế hoạch ngắn:** liệt kê file sẽ tạo/sửa/xóa + cách kiểm tra. Task > 10 file hoặc có thay đổi CSDL/bảo mật → **chờ người dùng đồng ý** rồi mới code.
5. **Test trước** cho mọi logic thuần (`core/calc`, parser, validate, rule).
6. **Code** theo docs/rules.
7. **Tự kiểm tra** — chạy và PHẢI pass hết:
   ```
   cd app;  dart format --set-exit-if-changed .;  flutter analyze;  flutter test
   cd supabase/functions;  deno fmt --check;  deno lint;  deno test -A
   supabase db reset   (khi có đổi migration)
   ```
   Lệnh nào chưa chạy được (chưa cài công cụ…) → **nói rõ là chưa chạy**, KHÔNG được báo "đã pass".
8. **Báo cáo** theo mẫu mục 8. Tích `[x]` task trong PROJECT.md **chỉ khi** đạt hết Tiêu chí xong.
9. **KHÔNG tự commit/push** trừ khi người dùng yêu cầu. Khi được yêu cầu: theo docs/rules/07.

---

## 3. LUẬT CỨNG — vi phạm = phải làm lại

### 3.1. Bảo mật
- **KHÔNG ĐƯỢC** đặt `service_role` key, mật khẩu, private key, service account, khóa API bí mật vào code app, file commit, log, test, comment.
- **KHÔNG ĐƯỢC** tắt/bỏ qua RLS. Mọi bảng mới PHẢI `enable row level security` + policy trong **cùng migration**.
- **KHÔNG ĐƯỢC** gọi API bên ngoài cần khóa bí mật trực tiếp từ app → PHẢI qua Edge Function.
- **KHÔNG ĐƯỢC** log tọa độ chính xác, email, token, nội dung nhật ký câu của người dùng.
- PHẢI validate **mọi** input từ ngoài (người dùng, deep link, API nguồn, request vào Edge Function).
- Dữ liệu từ nguồn bên ngoài là **không tin cậy**: kiểm tra kiểu, phạm vi, kích thước.

### 3.2. Kiến trúc
- PHẢI theo cấu trúc feature-first + 3 tầng `data / domain / presentation` (docs/rules/01).
- `presentation` **KHÔNG ĐƯỢC** import `data` trực tiếp; chỉ qua provider của repository.
- `core/calc/**` PHẢI là **Dart thuần**: KHÔNG import `package:flutter`, KHÔNG I/O, KHÔNG `DateTime.now()` bên trong (nhận thời gian làm tham số).
- Một feature **KHÔNG ĐƯỢC** import file nội bộ của feature khác; chỉ import qua `core/` hoặc file public `features/<x>/<x>.dart`.
- **KHÔNG ĐƯỢC** thêm package mới khi chưa có trong PROJECT.md mục 5.1 → phải hỏi người dùng, nêu lý do, kích thước, mức bảo trì; được đồng ý thì cập nhật PROJECT.md.
- **KHÔNG ĐƯỢC** đổi tên bảng, cột, route, API contract đã có mà không cập nhật PROJECT.md và mọi nơi dùng.

### 3.3. Dữ liệu
- Mực nước: **`int` centimet** trong code & CSDL. Chỉ đổi sang mét khi hiển thị.
- Thời gian: **UTC** trong CSDL & tính toán; hiển thị theo `Asia/Ho_Chi_Minh`. KHÔNG dùng `DateTime.now()` rải rác — dùng `clockProvider` (docs/rules/02).
- Tọa độ: WGS84, `lat` trước `lon` trong Dart; PostGIS `st_makepoint(lon, lat)`.
- Mọi số liệu dự báo/ước tính trên UI PHẢI có nhãn **"tham khảo"** hoặc **"ước tính"** + **nguồn**.
- Phân biệt trực quan 3 loại: **thực đo** (nét liền) · **dự báo** (nét đứt) · **ước tính** (nền sọc + nhãn).

### 3.4. Giao diện
- **KHÔNG ĐƯỢC** hard-code chuỗi hiển thị — PHẢI dùng `context.l10n.xxx` (file `app/lib/l10n/app_vi.arb`).
- **KHÔNG ĐƯỢC** hard-code màu, cỡ chữ, khoảng cách — PHẢI dùng token trong `core/theme`.
- Mọi màn hình có dữ liệu bất đồng bộ PHẢI xử lý đủ **4 trạng thái: đang tải · lỗi · rỗng · có dữ liệu (kể cả dữ liệu cũ/offline)**.
- Vùng chạm ≥ 48×48 dp. Không truyền tải thông tin chỉ bằng màu. Hỗ trợ cỡ chữ ×1.6 không vỡ.

### 3.5. Chất lượng code
- File ≤ **300 dòng**, hàm/phương thức ≤ **50 dòng**, widget `build()` ≤ **80 dòng** → vượt thì tách.
- **KHÔNG ĐƯỢC** dùng `print` — dùng `log` từ `core/logging`.
- **KHÔNG ĐƯỢC** để `TODO` không có mã task: viết `// TODO(P2-04): ...`.
- **KHÔNG ĐƯỢC** dùng `dynamic`, `!` (bang operator) trừ khi có comment giải thích vì sao an toàn.
- **KHÔNG ĐƯỢC** bắt lỗi rồi nuốt (`catch (_) {}`) — phải chuyển thành `AppException` hoặc log + xử lý.
- **KHÔNG ĐƯỢC** sửa file sinh tự động (`*.g.dart`, `*.freezed.dart`, `database.types.ts`) — chạy lại generator.
- **KHÔNG ĐƯỢC** sửa migration SQL đã tồn tại — tạo migration mới.
- **KHÔNG ĐƯỢC** xóa/vô hiệu hóa test đang fail để "cho qua". Sửa code hoặc báo người dùng.
- **KHÔNG ĐƯỢC** thêm tính năng, refactor, đổi định dạng ngoài phạm vi task.

### 3.6. Trung thực
- **KHÔNG ĐƯỢC** bịa endpoint, tên package, API, tham số. Không chắc → nói rõ "chưa xác minh", đề xuất cách kiểm.
- **KHÔNG ĐƯỢC** báo "xong", "pass" khi chưa chạy kiểm tra.
- Ghi rõ giới hạn, phần chưa làm, rủi ro trong báo cáo.

---

## 4. Ngôn ngữ

| Chỗ | Ngôn ngữ |
|---|---|
| Tên file, biến, hàm, class, bảng, cột, commit type | **Tiếng Anh** |
| Comment kỹ thuật trong code | Tiếng Anh, ngắn, giải thích **vì sao** (không lặp lại code làm gì) |
| Chuỗi hiển thị cho người dùng | **Tiếng Việt** trong `app_vi.arb` |
| Tài liệu `docs/`, báo cáo cho người dùng | **Tiếng Việt** |

---

## 5. Lệnh thường dùng

```powershell
# App
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # sau khi sửa freezed/riverpod/drift/json
flutter gen-l10n
flutter run --dart-define-from-file=env/dev.json
dart format .
flutter analyze
flutter test
flutter test --coverage

# Backend
supabase start
supabase db reset
supabase migration new <snake_case_name>
supabase functions serve --env-file supabase/functions/.env
cd supabase/functions; deno fmt; deno lint; deno test -A

# Thủy triều
cd tools/tide; .\.venv\Scripts\Activate.ps1; python -m pytest
```

---

## 6. Khi không chắc chắn

Dừng và hỏi người dùng nếu:
- Spec mơ hồ / thiếu / mâu thuẫn.
- Cần thêm package, đổi kiến trúc, đổi schema CSDL ngoài task.
- Cần thông tin bên ngoài chưa xác minh (endpoint nguồn dữ liệu, giá dịch vụ).
- Thay đổi có thể làm mất dữ liệu người dùng.

Đưa ra **1 đề xuất cụ thể** kèm lý do, không liệt kê lan man.

---

## 7. Danh sách cấm nhanh (grep được)

```
print(          → dùng log
dynamic         → dùng kiểu cụ thể
Colors.         → dùng AppColors / theme
TextStyle(      → dùng AppText / theme (trừ trong core/theme)
DateTime.now()  → dùng ref.read(clockProvider)() (trừ core/clock)
service_role    → không bao giờ trong app/
http://         → chỉ https
catch (_) {}    → không nuốt lỗi
```

---

## 8. Mẫu báo cáo cuối task (BẮT BUỘC)

```markdown
## <MÃ TASK> — <tên task>

**Đã đọc:** PROJECT.md §…, FEATURES.md §…, docs/rules/…

**Đã làm:**
- `path/file.dart` — tạo: …
- `path/other.dart` — sửa: …

**Kiểm tra:**
| Lệnh | Kết quả |
|---|---|
| flutter analyze | ✅ 0 issues / ❌ … / ⏭ chưa chạy (lý do) |
| flutter test | ✅ 24 passed |

**Tiêu chí xong (DoD):**
- [x] …
- [ ] … (chưa đạt vì …)

**Bạn tự kiểm tra:** 1. … 2. …

**Chưa làm / rủi ro / cần quyết định:** …
```
