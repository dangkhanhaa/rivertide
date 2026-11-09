# TOOLS.md — Công cụ, tài khoản & môi trường cho dự án RiverTide

> File này hướng dẫn **cài đặt và chuẩn bị mọi thứ** trước khi code, từ A đến Z, trên **Windows 11**.
> Kế hoạch dự án, kiến trúc, tính năng, roadmap nằm ở file riêng: [PROJECT.md](PROJECT.md).
>
> Quy ước:
> - `⚠ XÁC MINH` = thông tin có thể đã thay đổi (giá, hạn mức, tên gói) → kiểm tra lại trên trang chính thức khi làm.
> - Lệnh trong khung `powershell` chạy trong **PowerShell** (mở bằng Windows Terminal).
> - Đánh dấu `[x]` vào các ô khi làm xong.
>
> **🚧 Hiện tại chỉ làm BẢN DEV chạy được.** Chỉ cần làm: mục 2 → 9, mục 10.1 → 10.6, mục 11.2 → 11.4.
> Các mục về phát hành (10.7 → 10.10, 12, 13, 17) **để sau**, khi chuẩn bị đưa lên chợ ứng dụng.

---

## Mục lục

1. [Thứ tự thực hiện](#1-thứ-tự-thực-hiện)
2. [Yêu cầu máy tính](#2-yêu-cầu-máy-tính)
3. [Bảo mật cá nhân — làm TRƯỚC tiên](#3-bảo-mật-cá-nhân--làm-trước-tiên)
4. [Cài phần mềm nền](#4-cài-phần-mềm-nền)
5. [Cài Flutter & Android](#5-cài-flutter--android)
6. [VS Code & tiện ích](#6-vs-code--tiện-ích)
7. [Supabase CLI & Docker](#7-supabase-cli--docker)
8. [Firebase CLI & FlutterFire](#8-firebase-cli--flutterfire)
9. [Python cho xử lý thủy triều](#9-python-cho-xử-lý-thủy-triều)
10. [Tài khoản dịch vụ (đăng ký + cấu hình bảo mật)](#10-tài-khoản-dịch-vụ)
11. [Quản lý khóa bí mật (secrets)](#11-quản-lý-khóa-bí-mật-secrets)
12. [Khóa ký ứng dụng (keystore) — cực quan trọng](#12-khóa-ký-ứng-dụng-keystore)
13. [CI/CD: GitHub Actions & Codemagic](#13-cicd-github-actions--codemagic)
14. [Thiết bị kiểm thử](#14-thiết-bị-kiểm-thử)
15. [Công cụ phụ trợ](#15-công-cụ-phụ-trợ)
16. [Checklist hoàn tất môi trường](#16-checklist-hoàn-tất-môi-trường)
17. [Tổng hợp chi phí](#17-tổng-hợp-chi-phí)
18. [Lỗi thường gặp & cách sửa](#18-lỗi-thường-gặp--cách-sửa)

---

## 1. Thứ tự thực hiện

Làm đúng thứ tự này để không bị vướng:

| Bước | Việc | Thời gian ước tính |
|---|---|---|
| 1 | Bảo mật cá nhân: trình quản lý mật khẩu, 2FA, email dự án | 30 phút |
| 2 | Cài phần mềm nền: Git, VS Code, Windows Terminal, Node, Python | 30 phút |
| 3 | Cài Flutter + Android Studio + máy ảo Android | 1–2 giờ |
| 4 | Cài Docker + Supabase CLI | 30 phút |
| 5 | Cài Firebase CLI + FlutterFire CLI | 15 phút |
| 6 | Đăng ký tài khoản: GitHub, Supabase, Firebase, Vietmap, Cloudflare | 1–2 giờ |
| 7 | Tạo repo, cấu hình secrets | 30 phút |
| 8 | (Khi gần phát hành) Google Play, Apple Developer, Codemagic, tên miền | 1–3 ngày (chờ duyệt) |

> Tài khoản Google Play và Apple có thể mất **vài ngày đến 2 tuần** để xác minh danh tính → đăng ký sớm (từ giai đoạn 1) dù chưa phát hành.

---

## 2. Yêu cầu máy tính

| Hạng mục | Tối thiểu | Khuyên dùng |
|---|---|---|
| Hệ điều hành | Windows 10 64-bit | Windows 11 (bạn đang dùng ✅) |
| RAM | 8 GB | **16 GB** trở lên (Android Studio + máy ảo + Docker khá nặng) |
| Ổ cứng | 40 GB trống | **SSD**, 60 GB trống |
| CPU | Hỗ trợ ảo hóa | Bật **ảo hóa (VT-x / AMD-V)** trong BIOS |

### Bật tính năng ảo hóa của Windows (cần cho máy ảo Android & Docker)

Mở PowerShell **với quyền Administrator**:

```powershell
# Bật Hypervisor Platform (máy ảo Android) và WSL2 (Docker)
dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --install --no-distribution
```

Khởi động lại máy. Kiểm tra: mở **Task Manager → Performance → CPU** → dòng `Virtualization: Enabled`.

---

## 3. Bảo mật cá nhân — làm TRƯỚC tiên

App phát hành công khai = bạn giữ chìa khóa của hàng nghìn người dùng. Mất tài khoản = mất app.

- [ ] **Cài trình quản lý mật khẩu**: [Bitwarden](https://bitwarden.com) (miễn phí) hoặc 1Password.
  ```powershell
  winget install Bitwarden.Bitwarden
  ```
- [ ] Tạo **mật khẩu chính** mạnh (≥ 4 từ ngẫu nhiên), ghi ra giấy cất két.
- [ ] Cài app 2FA trên điện thoại: **Aegis** (Android), **Ente Auth**, hoặc Google Authenticator. Ưu tiên app có sao lưu mã hóa.
- [ ] Tạo **email riêng cho dự án** (vd. `rivertide.app@gmail.com`) — dùng cho mọi dịch vụ dưới đây, bật 2FA.
- [ ] Trong Bitwarden, tạo thư mục `RiverTide` chứa: mọi mật khẩu, mã khôi phục 2FA, khóa API, mật khẩu keystore.
- [ ] Lưu **mã khôi phục (recovery codes)** của mọi dịch vụ vào Bitwarden + bản in giấy.

**Quy tắc vàng**
1. Không bao giờ dán khóa bí mật vào chat, Zalo, email, hay commit lên Git.
2. Mỗi dịch vụ một mật khẩu riêng (Bitwarden tự sinh).
3. Mọi tài khoản đều bật 2FA.

---

## 4. Cài phần mềm nền

Windows 11 có sẵn `winget`. Mở PowerShell (thường) và chạy:

```powershell
winget install --id Git.Git -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Microsoft.WindowsTerminal -e
winget install --id OpenJS.NodeJS.LTS -e        # cần cho Firebase CLI
winget install --id Python.Python.3.12 -e       # xử lý thủy triều
winget install --id GitHub.cli -e               # gh: thao tác GitHub từ terminal
winget install --id DenoLand.Deno -e            # chạy/kiểm tra Edge Functions Supabase
```

Đóng và mở lại terminal, rồi kiểm tra:

```powershell
git --version
code --version
node --version
python --version
gh --version
deno --version
```

### Cấu hình Git

```powershell
git config --global user.name "Ten Cua Ban"
git config --global user.email "email-du-an@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf true      # Windows: tự đổi xuống dòng
```

### Đăng nhập GitHub CLI

```powershell
gh auth login     # chọn GitHub.com → HTTPS → Login with a web browser
```

---

## 5. Cài Flutter & Android

### 5.1. Android Studio (để lấy Android SDK + máy ảo)

```powershell
winget install --id Google.AndroidStudio -e
```

Mở Android Studio lần đầu → chọn **Standard** setup → đợi tải SDK.
Sau đó vào **More Actions → SDK Manager**:
- Tab **SDK Platforms**: tích bản Android mới nhất (API level cao nhất).
- Tab **SDK Tools**: tích
  - [x] Android SDK Build-Tools
  - [x] **Android SDK Command-line Tools (latest)** ← hay bị quên
  - [x] Android Emulator
  - [x] Android SDK Platform-Tools

### 5.2. Flutter SDK

1. Tải Flutter SDK cho Windows (bản **stable**) tại: https://docs.flutter.dev/get-started/install/windows
2. Giải nén vào **`C:\dev\flutter`** (KHÔNG để trong `Program Files` hay thư mục có dấu cách/tiếng Việt).
3. Thêm vào PATH:

```powershell
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path","User") + ";C:\dev\flutter\bin",
  "User")
```

4. Mở terminal mới:

```powershell
flutter --version
flutter config --no-analytics          # tắt gửi thống kê (tùy chọn)
flutter doctor --android-licenses      # nhấn y để đồng ý tất cả
flutter doctor -v
```

Mục tiêu `flutter doctor`: các dòng **Flutter, Android toolchain, VS Code, Connected device** đều ✅.
Dòng `Visual Studio` (để build app Windows desktop) có thể bỏ qua — dự án không cần.

### 5.3. Tạo máy ảo Android

Android Studio → **Device Manager → Create Virtual Device** → chọn **Pixel 7** (hoặc tương tự) → system image bản mới nhất **có Google Play** (cần cho Firebase Messaging) → Finish.

```powershell
flutter emulators                       # liệt kê
flutter emulators --launch <ten_may_ao> # chạy
flutter devices                         # phải thấy máy ảo
```

### 5.4. Điện thoại Android thật (khuyên dùng song song)

1. **Cài đặt → Giới thiệu điện thoại** → nhấn 7 lần vào **Số hiệu bản tạo (Build number)** → bật Tùy chọn nhà phát triển.
2. Bật **Gỡ lỗi USB (USB debugging)**.
3. Cắm cáp → chọn **Cho phép** trên điện thoại.
4. `flutter devices` → thấy điện thoại.

### 5.5. JDK

Android Studio đã kèm JDK. Nếu `flutter doctor` báo lỗi Java:

```powershell
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
```

---

## 6. VS Code & tiện ích

```powershell
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension denoland.vscode-deno
code --install-extension supabase.postgrestools          # ⚠ XÁC MINH tên extension Supabase/Postgres
code --install-extension eamodio.gitlens
code --install-extension usernamehw.errorlens
code --install-extension yzhang.markdown-all-in-one
code --install-extension ms-python.python
code --install-extension redhat.vscode-yaml
code --install-extension github.vscode-github-actions
code --install-extension streetsidesoftware.code-spell-checker
```

Gợi ý thêm (tùy chọn):
- `Nash.awesome-flutter-snippets` — snippet Flutter.
- `RobertBrunhage.flutter-riverpod-snippets` — snippet Riverpod.
- `mtxr.sqltools` + `mtxr.sqltools-driver-pg` — xem CSDL Postgres.

### Cài đặt VS Code nên bật (`settings.json` của workspace)

Sẽ được tạo trong repo tại `.vscode/settings.json` (xem PROJECT.md mục cấu trúc thư mục):

```json
{
  "editor.formatOnSave": true,
  "dart.lineLength": 100,
  "[dart]": { "editor.rulers": [100], "editor.codeActionsOnSave": { "source.fixAll": "explicit", "source.organizeImports": "explicit" } },
  "deno.enablePaths": ["supabase/functions"],
  "files.eol": "\n"
}
```

### Claude Code (vibe code)

Bạn đang dùng Claude Code trong VS Code ✅. Repo sẽ có file `CLAUDE.md` chứa quy tắc cho AI (nội dung lấy từ PROJECT.md mục 0).

---

## 7. Supabase CLI & Docker

Supabase CLI dùng để: tạo migration CSDL, chạy Supabase **trên máy** (local) để thử, triển khai Edge Functions.
Chạy local cần **Docker Desktop**.

### 7.1. Docker Desktop

```powershell
winget install --id Docker.DockerDesktop -e
```

Mở Docker Desktop → Settings → General → tích **Use the WSL 2 based engine**. Kiểm tra:

```powershell
docker --version
docker run hello-world
```

### 7.2. Supabase CLI

Cách khuyên dùng trên Windows là **Scoop**:

```powershell
# Cài Scoop (nếu chưa có)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Cài Supabase CLI
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

supabase --version
```

Các lệnh sẽ dùng nhiều (chạy trong thư mục repo):

```powershell
supabase login                       # đăng nhập (mở trình duyệt)
supabase init                        # tạo thư mục supabase/ (chỉ 1 lần)
supabase start                       # chạy Supabase local (Docker)
supabase stop
supabase migration new <ten>         # tạo file migration SQL
supabase db reset                    # chạy lại toàn bộ migration + seed trên local
supabase link --project-ref <ref>    # liên kết với project trên cloud
supabase db push                     # đẩy migration lên cloud
supabase functions new <ten>
supabase functions serve             # chạy Edge Functions local
supabase functions deploy <ten>
supabase secrets set KEY=value       # đặt biến bí mật cho Edge Functions trên cloud
supabase gen types typescript --local > supabase/functions/_shared/database.types.ts
```

---

## 8. Firebase CLI & FlutterFire

Firebase dùng cho: **thông báo đẩy (FCM)**, **App Check** (chống app giả), **Crashlytics** (báo lỗi), **Remote Config** (bật/tắt tính năng từ xa).

```powershell
npm install -g firebase-tools
firebase --version
firebase login

dart pub global activate flutterfire_cli
# Thêm Pub cache vào PATH nếu được nhắc:
[Environment]::SetEnvironmentVariable("Path",
  [Environment]::GetEnvironmentVariable("Path","User") + ";$env:LOCALAPPDATA\Pub\Cache\bin", "User")
flutterfire --version
```

Khi đã có project Flutter (giai đoạn 1), chạy trong thư mục `app/`:

```powershell
flutterfire configure --project=<firebase-project-id>
```

Lệnh này sinh `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`.
> Các file này **không phải bí mật tuyệt đối** (chứa API key công khai của Firebase), nhưng vẫn nên giới hạn khóa (xem mục 10.4).

---

## 9. Python cho xử lý thủy triều

Dùng để tính **hằng số điều hòa thủy triều** và **sinh bảng dự báo triều** cho từng trạm (chạy trên máy hoặc GitHub Actions — không chạy trong app).

```powershell
# Trong thư mục repo
cd tools\tide
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install utide numpy pandas scipy matplotlib requests python-dotenv supabase pdfplumber pytest ruff mypy
pip freeze > requirements.txt
```

> Nếu PowerShell chặn chạy `Activate.ps1`: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

Kiểm tra:

```powershell
python -c "import utide, numpy, pandas; print('OK')"
```

Tùy chọn: cài **Jupyter** để thử nghiệm dữ liệu: `pip install jupyterlab` → `jupyter lab`.

---

## 10. Tài khoản dịch vụ

Dùng **email dự án** (mục 3) cho tất cả. Mỗi dịch vụ: bật 2FA → lưu mã khôi phục vào Bitwarden.

### 10.1. GitHub — lưu code

- [ ] Đăng ký https://github.com → bật **2FA**.
- [ ] Tạo repo **private** `rivertide`:
  ```powershell
  cd D:\2026\CaNhan\RiverTide
  git init
  gh repo create rivertide --private --source=. --remote=origin
  ```
- [ ] Settings → **Code security**: bật **Dependabot alerts**, **Dependabot security updates**, **Secret scanning**, **Push protection** (chặn commit lỡ chứa khóa).
- [ ] Settings → **Branches**: thêm rule bảo vệ `main` (yêu cầu CI pass trước khi merge) — bật khi đã có CI.

### 10.2. Supabase — CSDL, đăng nhập, lưu ảnh, hàm máy chủ

- [ ] Đăng ký https://supabase.com (đăng nhập bằng GitHub) → bật **MFA** trong Account.
- [ ] Tạo **2 project**:
  - `rivertide-dev` — để thử nghiệm.
  - `rivertide-prod` — bản phát hành (tạo ở giai đoạn 2).
- [ ] Region: **Southeast Asia (Singapore)** — gần Việt Nam nhất.
- [ ] Database password: Bitwarden tự sinh, lưu lại.
- [ ] Lưu vào Bitwarden: `Project URL`, `anon key` (công khai), `service_role key` (**BÍ MẬT TUYỆT ĐỐI**), `project ref`.
- [ ] **Database → Extensions**: bật `postgis`, `pg_cron`, `pg_net`.
- [ ] **Authentication → Providers**: bật Email (OTP), Google, Apple (cấu hình ở giai đoạn 2).
- [ ] **Authentication → Settings**: bật **Leaked password protection**, giới hạn tốc độ (rate limit) mặc định giữ nguyên.
- [ ] **Storage**: tạo bucket ở giai đoạn 1 theo PROJECT.md.

> ⚠ XÁC MINH: gói miễn phí hiện có giới hạn (dung lượng DB, số project, **tạm dừng project sau 7 ngày không hoạt động**). Khi phát hành công khai nên nâng **Pro** cho project prod để không bị tạm dừng và có sao lưu hằng ngày.

### 10.3. Firebase — thông báo đẩy, App Check, Crashlytics

- [ ] https://console.firebase.google.com → **Add project** `rivertide` (tắt Google Analytics nếu không cần, hoặc bật nếu muốn thống kê — nhớ khai báo trong chính sách quyền riêng tư).
- [ ] Thêm app **Android** (package name, vd. `vn.rivertide.app` — ⚠ chọn tên gói cuối cùng ngay từ đầu, KHÔNG đổi được sau khi phát hành).
- [ ] Thêm app **iOS** (Bundle ID giống package name).
- [ ] **Cloud Messaging**: bật. Với iOS cần tải **APNs Auth Key (.p8)** từ Apple Developer (giai đoạn 2).
- [ ] **App Check**: đăng ký provider **Play Integrity** (Android), **App Attest** (iOS). Ban đầu để chế độ *monitor*, bật *enforce* trước khi phát hành.
- [ ] **Crashlytics**: bật.
- [ ] Tạo **Service Account** (Project settings → Service accounts → Generate new private key) để máy chủ Supabase gửi thông báo đẩy qua FCM HTTP v1 → file JSON này là **BÍ MẬT**, lưu Bitwarden, chỉ đưa vào `supabase secrets`.

### 10.4. Google Cloud (đi kèm Firebase) — giới hạn khóa API

Vào https://console.cloud.google.com → chọn project Firebase → **APIs & Services → Credentials**:
- [ ] Mỗi **API key** do Firebase tạo: **Application restrictions** → Android apps (package + SHA-1) / iOS apps (Bundle ID).
- [ ] **API restrictions**: chỉ cho phép các API Firebase cần dùng.
- [ ] **Billing**: KHÔNG cần bật thẻ cho các tính năng đang dùng (FCM, Crashlytics, App Check miễn phí). Nếu bật, đặt **Budget alert** = 1 USD.

### 10.5. Vietmap — bản đồ

- [ ] Đăng ký tài khoản nhà phát triển tại trang Vietmap Maps API (https://maps.vietmap.vn — ⚠ XÁC MINH địa chỉ trang đăng ký).
- [ ] Đọc **bảng giá & hạn mức miễn phí**, điều khoản dùng cho app thương mại / công khai.
- [ ] Tạo **2 khóa API**:
  - `VIETMAP_TILE_KEY` — dùng trong app để tải bản đồ (bắt buộc nằm trong app) → **giới hạn** theo package name / bundle ID nếu Vietmap hỗ trợ; nếu không, giới hạn hạn mức và theo dõi.
  - `VIETMAP_SERVICE_KEY` — dùng cho tìm kiếm địa danh, đổi tọa độ ra địa chỉ → **chỉ để trên máy chủ** (Supabase secrets).
- [ ] Tải tài liệu SDK Flutter của Vietmap (gói `vietmap_flutter_gl` trên pub.dev — ⚠ XÁC MINH tên gói & phiên bản).
- [ ] Hỏi Vietmap: có **style vệ tinh** không, có điều kiện gì.

### 10.6. Open-Meteo — thời tiết, lũ, độ cao

- [ ] Không cần tài khoản cho bản miễn phí (phi thương mại, ~10.000 lượt/ngày — ⚠ XÁC MINH).
- [ ] **Nếu app có quảng cáo hoặc thu phí** → phải mua gói **API thương mại** của Open-Meteo, nhận API key → lưu Supabase secrets `OPEN_METEO_API_KEY`.
- [ ] Ghi chú ghi nguồn bắt buộc: "Weather data by Open-Meteo.com" (giấy phép CC BY 4.0).

### 10.7. Cloudflare — trang web, tên miền, DNS

- [ ] Đăng ký https://cloudflare.com → bật 2FA.
- [ ] Dùng **Cloudflare Pages** để host: trang giới thiệu, **chính sách quyền riêng tư**, **điều khoản sử dụng**, trang xóa tài khoản, trang quản trị (Flutter Web).
- [ ] Tên miền:
  - `.com` có thể mua ngay trên Cloudflare Registrar.
  - `.vn` mua qua nhà đăng ký Việt Nam (Mắt Bão, PA Việt Nam, Nhân Hòa…) rồi trỏ DNS về Cloudflare.

### 10.8. Google Play Console — phát hành Android

- [ ] https://play.google.com/console → phí **25 USD một lần**.
- [ ] Chọn loại tài khoản: **Cá nhân** hoặc **Tổ chức** (tổ chức cần mã số **D-U-N-S** — miễn phí nhưng chờ vài ngày).
- [ ] ⚠ Tài khoản **cá nhân mới** thường phải chạy **thử nghiệm kín (closed testing) với ít nhất 12 người trong 14 ngày** trước khi được phát hành công khai (⚠ XÁC MINH quy định hiện hành) → chuẩn bị danh sách người thử từ giai đoạn 1.
- [ ] Bật **Play App Signing** (Google giữ khóa ký chính, bạn giữ khóa upload — xem mục 12).

### 10.9. Apple Developer — phát hành iOS

- [ ] https://developer.apple.com/programs → **99 USD/năm**. Cần Apple ID có bật 2FA.
- [ ] Cá nhân hoặc tổ chức (tổ chức cần D-U-N-S).
- [ ] Tạo **App ID** (Bundle ID), bật capability **Push Notifications**, **Sign in with Apple**, **App Attest**.
- [ ] Tạo **APNs Auth Key (.p8)** → tải lên Firebase Cloud Messaging.
- [ ] Tạo **App Store Connect API key** → dùng cho Codemagic tự ký & tải bản build.
- [ ] Không có Mac → build iOS bằng **Codemagic** (mục 13), thử trên iPhone qua **TestFlight**.

### 10.10. Dịch vụ theo dõi

- [ ] **UptimeRobot** (https://uptimerobot.com, miễn phí): theo dõi URL Edge Function `/health` mỗi 5 phút, gửi email khi sập.
- [ ] (Tùy chọn) **Sentry** gói miễn phí nếu muốn theo dõi lỗi Edge Functions chi tiết hơn log của Supabase.

---

## 11. Quản lý khóa bí mật (secrets)

### 11.1. Bảng tổng hợp

| Tên | Loại | Nằm ở đâu | Có trong app không? |
|---|---|---|---|
| `SUPABASE_URL` | Công khai | App + máy chủ | Có |
| `SUPABASE_ANON_KEY` | Công khai (bị giới hạn bởi RLS) | App | Có |
| `SUPABASE_SERVICE_ROLE_KEY` | **BÍ MẬT** | Chỉ Supabase Edge Functions (tự có sẵn), GitHub Actions secrets | **KHÔNG BAO GIỜ** |
| `SUPABASE_DB_PASSWORD` | **BÍ MẬT** | Bitwarden, GitHub Actions secrets | Không |
| `VIETMAP_TILE_KEY` | Bán công khai (giới hạn) | App | Có |
| `VIETMAP_SERVICE_KEY` | **BÍ MẬT** | Supabase secrets | Không |
| `FCM_SERVICE_ACCOUNT_JSON` | **BÍ MẬT** | Supabase secrets | Không |
| `OPEN_METEO_API_KEY` (nếu mua) | **BÍ MẬT** | Supabase secrets | Không |
| Firebase options (`google-services.json`…) | Công khai (giới hạn) | App | Có |
| Keystore Android + mật khẩu | **BÍ MẬT** | Bitwarden + 2 bản sao lưu ngoại tuyến, GitHub secrets (base64) | Không |
| App Store Connect API key | **BÍ MẬT** | Codemagic | Không |

### 11.2. Cách truyền cấu hình vào app Flutter

Không dùng file `.env` đóng gói trong app. Dùng `--dart-define-from-file`:

```
app/env/dev.json      ← KHÔNG commit (có trong .gitignore)
app/env/prod.json     ← KHÔNG commit
app/env/example.json  ← commit, chỉ có tên khóa, giá trị rỗng
```

`app/env/example.json`:

```json
{
  "ENV": "dev",
  "SUPABASE_URL": "",
  "SUPABASE_ANON_KEY": "",
  "VIETMAP_TILE_KEY": ""
}
```

Chạy:

```powershell
flutter run --dart-define-from-file=env/dev.json
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json
```

### 11.3. Secrets cho Edge Functions

```powershell
# Local: tạo supabase/functions/.env (KHÔNG commit)
# Cloud:
supabase secrets set VIETMAP_SERVICE_KEY=xxx --project-ref <ref>
supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(Get-Content -Raw .\secrets\fcm.json)" --project-ref <ref>
supabase secrets list --project-ref <ref>
```

### 11.4. `.gitignore` bắt buộc có

```gitignore
# Secrets
app/env/*.json
!app/env/example.json
supabase/functions/.env
supabase/.env
secrets/
*.jks
*.keystore
key.properties
*.p8
*.p12
*.mobileprovision
service-account*.json

# Build
build/
.dart_tool/
app/build/
tools/tide/.venv/
__pycache__/
.DS_Store
```

### 11.5. Nếu lỡ lộ khóa

1. **Thu hồi / tạo lại khóa ngay** trên dịch vụ tương ứng (Supabase: Settings → API → roll key).
2. Cập nhật secrets mới ở mọi nơi.
3. Xóa khỏi lịch sử Git không đủ — khóa đã lộ coi như hỏng, phải đổi.
4. Ghi lại sự cố vào `docs/incidents.md`.

---

## 12. Khóa ký ứng dụng (keystore)

> **Mất keystore upload + không bật Play App Signing = không bao giờ cập nhật được app nữa.** Làm cẩn thận.

### 12.1. Tạo khóa upload Android

```powershell
mkdir D:\RiverTideSecrets   # thư mục NGOÀI repo
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v `
  -keystore D:\RiverTideSecrets\upload-keystore.jks `
  -storetype JKS -keyalg RSA -keysize 4096 -validity 10000 `
  -alias upload
```

- Mật khẩu: Bitwarden tự sinh, lưu mục "Android upload keystore".
- Thông tin (CN, O…): tên bạn/tổ chức.

### 12.2. Khai báo cho Gradle

Tạo `app/android/key.properties` (**KHÔNG commit**):

```properties
storePassword=<mat_khau>
keyPassword=<mat_khau>
keyAlias=upload
storeFile=D:\\RiverTideSecrets\\upload-keystore.jks
```

Cấu hình `build.gradle(.kts)` đọc file này sẽ được làm ở PROJECT.md (task P1-04).

### 12.3. Lấy mã SHA-1 / SHA-256 (cho Firebase, Google Sign-In, giới hạn khóa API)

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore D:\RiverTideSecrets\upload-keystore.jks -alias upload
# Khóa debug:
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore $env:USERPROFILE\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

> Sau khi bật Play App Signing, lấy thêm SHA-1/SHA-256 của **App signing key** trong Play Console → Setup → App integrity → thêm vào Firebase.

### 12.4. Sao lưu

- [ ] Bản 1: Bitwarden (đính kèm file — gói miễn phí có thể không hỗ trợ đính kèm, khi đó dùng bản 2 & 3).
- [ ] Bản 2: USB mã hóa (BitLocker To Go) cất ở nhà.
- [ ] Bản 3: ổ đám mây cá nhân trong file nén **có mật khẩu** (7-Zip AES-256).

---

## 13. CI/CD: GitHub Actions & Codemagic

### 13.1. GitHub Actions (miễn phí cho repo private trong hạn mức phút — ⚠ XÁC MINH)

Các workflow sẽ tạo trong `.github/workflows/` (chi tiết ở PROJECT.md):

| Workflow | Khi nào chạy | Làm gì |
|---|---|---|
| `ci.yml` | Mỗi push / pull request | `flutter analyze`, `flutter test`, `deno lint`, `deno test` |
| `android-release.yml` | Khi tạo tag `v*` | Build `.aab` đã ký → tải lên Play Console (track internal) |
| `tide-build.yml` | Hàng tháng + bấm tay | Chạy Python sinh bảng triều → đẩy lên Supabase Storage |
| `db-migrate.yml` | Khi merge vào `main` có thay đổi `supabase/migrations` | `supabase db push` lên prod (cần duyệt tay) |

GitHub repo → Settings → **Secrets and variables → Actions** → thêm:

```
SUPABASE_ACCESS_TOKEN        (supabase.com → Account → Access Tokens)
SUPABASE_PROJECT_REF_DEV
SUPABASE_PROJECT_REF_PROD
SUPABASE_DB_PASSWORD_PROD
SUPABASE_SERVICE_ROLE_KEY_PROD   (cho tide-build)
ANDROID_KEYSTORE_BASE64      (xem lệnh dưới)
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_PASSWORD
ENV_PROD_JSON                (nội dung app/env/prod.json)
PLAY_SERVICE_ACCOUNT_JSON    (Play Console → API access, để tự tải bản build)
```

Mã hóa keystore sang base64:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("D:\RiverTideSecrets\upload-keystore.jks")) | Set-Clipboard
```

Bật **Environments** `production` với **Required reviewers** = bạn → mọi workflow đụng tới prod phải bấm duyệt.

### 13.2. Codemagic — build iOS không cần Mac

- [ ] Đăng ký https://codemagic.io bằng GitHub → bật 2FA.
- [ ] Gói miễn phí có giới hạn số phút build macOS mỗi tháng (⚠ XÁC MINH).
- [ ] Kết nối repo `rivertide`.
- [ ] **Teams → Integrations → Developer Portal**: thêm App Store Connect API key.
- [ ] Bật **Automatic code signing** cho iOS.
- [ ] Thêm biến môi trường nhóm `rivertide_prod`: `ENV_PROD_JSON` (secure).
- [ ] File cấu hình `codemagic.yaml` ở gốc repo (tạo ở giai đoạn 2).

---

## 14. Thiết bị kiểm thử

| Thiết bị | Mục đích | Ghi chú |
|---|---|---|
| Máy ảo Android (Pixel, Android mới) | Code hằng ngày | Đã có ở mục 5.3 |
| **Điện thoại Android tầm thấp** (RAM 3–4 GB, Android 9–11) | Kiểm tra hiệu năng thật | Đa số người dùng miền Tây/dân câu dùng máy phổ thông |
| Điện thoại Android tầm trung đời mới | Kiểm tra thông báo, widget | |
| **iPhone** (mượn cũng được) | TestFlight | Bắt buộc thử trước khi phát hành iOS |
| Máy ảo màn hình nhỏ (5") và lớn/tablet | Kiểm tra bố cục | |

Thử thêm các tình huống:
- Mất mạng / mạng 3G chậm (máy ảo: Extended controls → Cellular → Network type: EDGE).
- Chữ cỡ lớn (Cài đặt → Hiển thị → Cỡ chữ lớn nhất).
- Chế độ tối.
- Tiết kiệm pin bật (thông báo có tới không?).

---

## 15. Công cụ phụ trợ

| Công cụ | Dùng để | Chi phí |
|---|---|---|
| **Figma** hoặc **Pencil** | Thiết kế giao diện, icon, ảnh chụp màn hình cho store | Miễn phí |
| **Postman** hoặc **Bruno** | Thử API nguồn dữ liệu, Edge Functions | Miễn phí |
| Trình duyệt **Chrome/Edge DevTools** (tab Network) | Tìm endpoint JSON của các trang bản đồ trạm (giai đoạn 0) | Có sẵn |
| **DBeaver** | Xem/sửa CSDL Postgres bằng giao diện | Miễn phí |
| **QGIS** | Xem/kiểm tra dữ liệu bản đồ, vị trí trạm, đường sông | Miễn phí |
| **7-Zip** | Nén có mật khẩu (sao lưu keystore) | Miễn phí |
| **scrcpy** | Hiện màn hình điện thoại Android lên máy tính, quay video demo | Miễn phí |
| **Inkscape** | Vẽ icon dạng vector | Miễn phí |
| **Canva** | Ảnh quảng bá, ảnh store | Gói miễn phí |

```powershell
winget install --id 7zip.7zip -e
winget install --id dbeaver.dbeaver -e
winget install --id Genymobile.scrcpy -e
winget install --id Bruno.Bruno -e
winget install --id OSGeo.QGIS -e         # khá nặng, cài khi cần
```

---

## 16. Checklist hoàn tất môi trường

### Bảo mật
- [ ] Bitwarden + mật khẩu chính đã cất giấy
- [ ] App 2FA trên điện thoại, có sao lưu
- [ ] Email dự án riêng, bật 2FA

### Phần mềm
- [ ] `git --version` ✅
- [ ] `flutter doctor -v` — Flutter, Android toolchain, VS Code, Connected device ✅
- [ ] Máy ảo Android chạy được; điện thoại thật nhận được
- [ ] `docker run hello-world` ✅
- [ ] `supabase --version` ✅ ; `supabase start` chạy được
- [ ] `firebase --version`, `flutterfire --version` ✅
- [ ] `deno --version` ✅
- [ ] `python -c "import utide"` ✅ trong `.venv`
- [ ] VS Code đã cài các extension mục 6

### Tài khoản
- [ ] GitHub (2FA, repo private, Dependabot + Secret scanning + Push protection)
- [ ] Supabase dev (postgis, pg_cron, pg_net bật)
- [ ] Firebase (Android + iOS app, App Check, Crashlytics)
- [ ] Vietmap (2 khóa: tile & service)
- [ ] Cloudflare
- [ ] Google Play Console (đã gửi xác minh)
- [ ] Apple Developer (khi phát hành iOS)
- [ ] Codemagic (khi phát hành iOS)
- [ ] UptimeRobot

### Khóa & sao lưu
- [ ] Keystore upload đã tạo, 3 bản sao lưu
- [ ] Mọi secret đã nằm trong Bitwarden
- [ ] `.gitignore` đã chặn file bí mật
- [ ] GitHub Actions secrets đã nhập

---

## 17. Tổng hợp chi phí

| Khoản | Khi nào | Chi phí |
|---|---|---|
| Phần mềm lập trình (Flutter, VS Code, Android Studio, Docker, Python…) | Ngay | **0 đ** |
| GitHub, Firebase, Cloudflare Pages, UptimeRobot | Ngay | **0 đ** |
| Supabase | Giai đoạn 0–1 | 0 đ (gói Free) |
| Supabase Pro cho prod | Khi phát hành | ~25 USD/tháng ⚠ XÁC MINH |
| Vietmap | Theo hạn mức | ⚠ XÁC MINH bảng giá |
| Open-Meteo | Phi thương mại | 0 đ; thương mại: gói trả phí ⚠ XÁC MINH |
| Google Play Console | Giai đoạn 1 | **25 USD một lần** |
| Apple Developer | Giai đoạn 2 | **99 USD/năm** |
| Codemagic | Giai đoạn 2 | 0 đ trong hạn mức miễn phí |
| Tên miền `.com` / `.vn` | Giai đoạn 1 | ~300.000 – 800.000 đ/năm |
| Điện thoại Android tầm thấp để thử | Giai đoạn 1 | ~1.5 – 2.5 triệu (máy cũ) |
| **Tổng năm đầu (ước tính)** | | **~ 6 – 15 triệu đ** tùy có nâng Supabase Pro & Vietmap |

---

## 18. Lỗi thường gặp & cách sửa

| Lỗi | Cách sửa |
|---|---|
| `flutter` không nhận lệnh | Kiểm tra PATH có `C:\dev\flutter\bin`; mở terminal **mới** |
| `cmdline-tools component is missing` | Android Studio → SDK Manager → SDK Tools → tích *Android SDK Command-line Tools* |
| `Android license status unknown` | `flutter doctor --android-licenses` |
| Máy ảo rất chậm / không chạy | Bật ảo hóa BIOS + `HypervisorPlatform` (mục 2); tắt bớt app; dùng điện thoại thật |
| Docker báo lỗi WSL | `wsl --update`, khởi động lại máy; Docker Desktop → Settings → bật WSL 2 engine |
| `supabase start` lỗi cổng 54321/54322 bị chiếm | `supabase stop --no-backup` rồi chạy lại; hoặc đổi cổng trong `supabase/config.toml` |
| Gradle build lỗi lần đầu / quá lâu | Kiểm tra mạng; `cd app/android; .\gradlew clean`; xóa `%USERPROFILE%\.gradle\caches` nếu hỏng |
| Đường dẫn có tiếng Việt / dấu cách gây lỗi | Giữ repo ở `D:\2026\CaNhan\RiverTide` (không dấu) ✅ |
| Không nhận thông báo đẩy trên máy ảo | Máy ảo phải là bản **có Google Play**; đã cấp quyền thông báo (Android 13+) |
| PowerShell chặn script `.ps1` | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `flutterfire` không nhận | Thêm `%LOCALAPPDATA%\Pub\Cache\bin` vào PATH |
| `keytool` không nhận | Dùng đường dẫn đầy đủ trong `Android Studio\jbr\bin\keytool.exe` |

---

*Cập nhật lần cuối: 2026-11-06. Khi đổi công cụ hoặc dịch vụ, sửa file này và ghi lý do ở cuối PROJECT.md (mục Nhật ký quyết định).*
