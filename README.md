# RiverTide

App di động xem **mực nước sông, thủy triều, con nước và giờ câu cá** cho toàn Việt Nam — Flutter + bản đồ OpenFreeMap (Supabase ở giai đoạn sau).

> 🚧 Đang ở giai đoạn **bản dev**.

## Tài liệu

| File | Nội dung |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Luật bắt buộc khi code (cho AI và người) |
| [FEATURES.md](FEATURES.md) | Sản phẩm & đặc tả tính năng, tiêu chí chấp nhận |
| [PROJECT.md](PROJECT.md) | Kiến trúc, CSDL, API, thuật toán, **roadmap** |
| [TOOLS.md](TOOLS.md) | Cài công cụ, tài khoản, secrets |
| [docs/rules/](docs/rules/) | Chuẩn code chi tiết |

## Chạy bản dùng thử V0 (không máy chủ — PROJECT.md mục 3.0)

```powershell
cd app
C:\dev\flutter\bin\flutter.bat pub get
C:\dev\flutter\bin\flutter.bat gen-l10n
C:\dev\flutter\bin\dart.bat run build_runner build

# Xem trên trình duyệt
C:\dev\flutter\bin\flutter.bat run -d chrome

# Android (cần làm 1 lần: Android Studio → SDK Manager → cài "Android SDK Command-line Tools",
# rồi chạy: C:\dev\flutter\bin\flutter.bat doctor --android-licenses  và tạo máy ảo trong Device Manager)
C:\dev\flutter\bin\flutter.bat run
C:\dev\flutter\bin\flutter.bat build apk --release   # file: app\build\app\outputs\flutter-apk\app-release.apk

# Kiểm tra
C:\dev\flutter\bin\flutter.bat analyze
C:\dev\flutter\bin\flutter.bat test
```

Bản đồ nền: OpenFreeMap (miễn phí, không cần khóa hay đăng ký) qua gói `maplibre_gl`.

Cập nhật dự báo triều (hằng tháng): xem [docs/tide-validation.md](docs/tide-validation.md). Mực nước sông: xem [docs/river-model.md](docs/river-model.md).

### Đưa lên mạng miễn phí (GitHub Pages)

Workflow [.github/workflows/pages.yml](.github/workflows/pages.yml) chạy 3 lần mỗi ngày (11:30, 13:30, 16:30 giờ VN). Mỗi lần chạy, workflow:
1. lấy bản tin KTTV và lưu vào kho;
2. chạy `flutter test`;
3. build bản web và đăng lên `https://dangkhanhaa.github.io/rivertide/`.

App tải số liệu sông mới tại `https://dangkhanhaa.github.io/rivertide/data/kttv_tvhn.json`.

Cài đặt lần đầu (chủ dự án tự làm, không đưa mật khẩu cho ai):
1. github.com → **New repository** → tên `rivertide`, chọn **Public** (GitHub Pages miễn phí chỉ dùng được với kho công khai).
2. Trên máy:
   ```powershell
   cd D:\2026\CaNhan\RiverTide
   git init -b main
   git add .
   git commit -m "feat: V0 app"
   git remote add origin https://github.com/dangkhanhaa/rivertide.git
   git push -u origin main      # trình duyệt sẽ mở để bạn đăng nhập GitHub
   ```
3. Vào kho trên GitHub → **Settings → Pages → Source: GitHub Actions**.
4. Vào tab **Actions → KTTV data + web app → Run workflow**.

## Chạy bản đầy đủ có máy chủ (giai đoạn sau, sau khi làm xong TOOLS.md)

```powershell
# Backend local
supabase start
supabase db reset
supabase functions serve --env-file supabase/functions/.env

# App
cd app
copy env\example.json env\dev.json   # rồi điền giá trị
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=env/dev.json
```

## Cấu trúc

```
app/        Flutter app
supabase/   migrations, edge functions, seed
tools/      Python xử lý thủy triều, script
docs/       tài liệu, luật code, khảo sát nguồn dữ liệu
```
