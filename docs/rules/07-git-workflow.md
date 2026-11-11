# 07 — Git & quy trình làm việc

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md). AI **không tự commit/push** trừ khi được yêu cầu.

## 1. Nhánh

| Nhánh | Dùng cho |
|---|---|
| `main` | Luôn chạy được, CI xanh |
| `task/P1-15-tide-calc` | 1 nhánh / 1 task: `task/<mã>-<mô-tả-ngắn>` |
| `fix/<mô-tả>` | Sửa lỗi ngoài roadmap |

Làm một mình giai đoạn đầu: được phép commit thẳng `main` **nếu** đã chạy đủ kiểm tra. Khi có CI (P1-32) → dùng nhánh + PR.

## 2. Commit

Định dạng: `<type>(<scope>): <mã task> <mô tả tiếng Việt hoặc Anh ngắn>`

| type | Khi nào |
|---|---|
| `feat` | Tính năng mới |
| `fix` | Sửa lỗi |
| `test` | Chỉ thêm/sửa test |
| `refactor` | Đổi cấu trúc, không đổi hành vi |
| `chore` | Cấu hình, phụ thuộc, công cụ |
| `docs` | Tài liệu |
| `db` | Migration CSDL |

Ví dụ:
```
feat(tide): P1-15 nội suy Hermite và tìm đỉnh/chân triều
db(core): P1-05 bảng stations, observations và RLS
fix(map): marker không đổi màu khi mất dữ liệu > 6 giờ
```

Luật:
- 1 commit = 1 thay đổi có nghĩa; không gộp nhiều task.
- Không commit file sinh build (`build/`, `.dart_tool/`). **Có** commit `*.g.dart`, `*.freezed.dart` (để build không phụ thuộc máy) — quyết định này áp dụng toàn dự án.
- Không commit secrets (xem 04-security mục 4).
- Commit `pubspec.lock`, `deno.lock`.

## 3. Trước khi commit — checklist

```powershell
cd app
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
cd ..\supabase\functions
deno fmt --check; deno lint
cd ..\..
git grep -n -I -i -E "service_role|PRIVATE KEY|client_secret"
git status   # kiểm tra không có file lạ / file env
```

## 4. Cập nhật tài liệu cùng code

| Khi thay đổi | Cập nhật |
|---|---|
| Xong task | Tích `[x]` PROJECT.md mục 14 |
| Schema/API | PROJECT.md mục 7/8 |
| Thêm package | PROJECT.md mục 5.1 + lý do vào mục 19 |
| Hành vi tính năng | FEATURES.md mục tương ứng |
| Quyết định kiến trúc | PROJECT.md mục 19 |
| Công thức chỉ số câu cá | `docs/fishing-score.md` + tăng version `fs-N` |

## 5. Phiên bản app

- `pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD`. Dev: `0.x.y`. Tăng `BUILD` mỗi bản gửi người thử.
- Tag khi gửi bản thử: `v0.1.0`.
