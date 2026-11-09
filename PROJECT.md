# PROJECT.md — RiverTide: App mực nước sông, thủy triều & câu cá (toàn quốc)

> **Đây là tài liệu gốc để vibe code.** Mọi tính năng, kiến trúc, CSDL, thuật toán, thứ tự công việc đều ở đây.
> Công cụ & cài đặt môi trường: xem [TOOLS.md](TOOLS.md).
>
> **🚧 Trọng tâm hiện tại: BẢN DEV chạy được (Giai đoạn 0 → 1).**
> Pháp lý, phát hành store, kiếm tiền, cộng đồng: **chưa tính** — đã ghi chú để làm sau.
>
> Ký hiệu ưu tiên: 🟢 MVP (dev) · 🟡 Bản 2 · 🔵 Bản 3 · ⚪ Để sau
> Ký hiệu cần kiểm chứng: `⚠ XÁC MINH`
>
> **⚡ 2026-11-09 — BẢN DÙNG THỬ V0: KHÔNG MÁY CHỦ, KHÔNG DB, 100% MIỄN PHÍ.**
> Trước khi có người dùng thật, chỉ có **1 app Flutter** gọi thẳng nguồn miễn phí. Xem **mục 3.0** (kiến trúc V0) và **mục 14 — Giai đoạn V0** (roadmap).
> Phần Supabase (mục 3 sơ đồ cũ, 7, 8, task 1B) **hoãn** tới khi cần đăng nhập/đồng bộ/cảnh báo đẩy — giữ nguyên thiết kế để dùng sau.

---

## Mục lục

0. [Cách vibe code với file này + Quy tắc cho AI](#0-cách-vibe-code-với-file-này)
1. [Tổng quan sản phẩm](#1-tổng-quan-sản-phẩm)
2. [Nguyên tắc thiết kế](#2-nguyên-tắc-thiết-kế)
3. [Kiến trúc tổng thể](#3-kiến-trúc-tổng-thể)
4. [Cấu trúc thư mục (monorepo)](#4-cấu-trúc-thư-mục-monorepo)
5. [Tech stack & thư viện](#5-tech-stack--thư-viện)
6. [Nguồn dữ liệu](#6-nguồn-dữ-liệu)
7. [Cơ sở dữ liệu](#7-cơ-sở-dữ-liệu)
8. [Backend: Edge Functions, Cron, API](#8-backend-edge-functions-cron-api)
9. [Thuật toán](#9-thuật-toán)
10. [App: điều hướng, màn hình, giao diện](#10-app-điều-hướng-màn-hình-giao-diện)
11. [Danh mục tính năng đầy đủ (mã F-xxx)](#11-danh-mục-tính-năng-đầy-đủ)
12. [Bảo mật](#12-bảo-mật)
13. [Kiểm thử](#13-kiểm-thử)
14. [ROADMAP chi tiết — checklist công việc](#14-roadmap-chi-tiết)
15. [Mẫu prompt vibe code](#15-mẫu-prompt-vibe-code)
16. [Rủi ro & phương án dự phòng](#16-rủi-ro--phương-án-dự-phòng)
17. [Việc để sau (chưa tính)](#17-việc-để-sau-chưa-tính)
18. [Thuật ngữ](#18-thuật-ngữ)
19. [Nhật ký quyết định](#19-nhật-ký-quyết-định)

---

## 0. Cách vibe code với file này

### 0.1. Quy trình mỗi lần làm việc

1. Mở mục **14 ROADMAP**, chọn task tiếp theo chưa xong (theo thứ tự mã, ví dụ `P1-07`).
2. Copy **mẫu prompt** ở mục 15, điền mã task → gửi cho Claude Code.
3. AI đọc mục liên quan trong file này, code, chạy test.
4. Bạn chạy app thử → đạt **Tiêu chí xong** của task → tích `[x]` trong roadmap.
5. Commit: `git commit -m "P1-07: <mô tả ngắn>"`.
6. Nếu thay đổi quyết định (đổi thư viện, đổi thiết kế) → ghi vào **mục 19 Nhật ký quyết định**.

### 0.2. Bộ tài liệu & luật cho AI

| File | Vai trò |
|---|---|
| [CLAUDE.md](CLAUDE.md) | **Luật bắt buộc** cho AI, quy trình mỗi task, mẫu báo cáo (AI tự đọc mỗi phiên) |
| [FEATURES.md](FEATURES.md) | Mô tả sản phẩm, người dùng, đặc tả từng tính năng + **tiêu chí chấp nhận (AC)** |
| PROJECT.md (file này) | Kiến trúc, CSDL, API, thuật toán, **roadmap task** |
| [TOOLS.md](TOOLS.md) | Công cụ, môi trường, tài khoản, secrets |
| [docs/rules/](docs/rules/) | Chuẩn code chi tiết: kiến trúc, Flutter/Dart, backend, bảo mật, test, giao diện & chữ, Git |

> Mỗi task trong mục 14 phải đạt **cả** "Tiêu chí xong" ở đây **và** các AC của tính năng tương ứng trong FEATURES.md.

### 0.3. Định nghĩa "Xong" (Definition of Done) cho mọi task

- [ ] Chạy được trên máy ảo Android (và web nếu task liên quan admin).
- [ ] `flutter analyze` sạch, test liên quan pass.
- [ ] Không có chuỗi tiếng Việt hard-code trong code giao diện.
- [ ] Không có khóa bí mật trong code.
- [ ] Có xử lý 3 trạng thái: **đang tải / lỗi / không có dữ liệu**.
- [ ] Đã commit với mã task.

---

## 1. Tổng quan sản phẩm

**Tên tạm:** RiverTide (tên tiếng Việt gợi ý: *Con Nước*) — ⚪ chốt sau.

**Một câu:** App xem **mực nước sông, thủy triều, con nước và giờ câu cá** cho **toàn bộ Việt Nam**, miễn phí, chạy cả khi mất mạng.

### 1.1. Nhóm người dùng

| Nhóm | Nhu cầu chính | Tính năng chủ lực |
|---|---|---|
| 🎣 Dân câu cá (chính) | Giờ câu ngon, con nước, thời tiết, an toàn | Module câu cá, Solunar, nhật ký |
| 🏠 Dân ven sông, đô thị ven biển | Triều cường, ngập, lũ | Cảnh báo, ước tính ngập |
| 🌾 Nông dân, nuôi thủy sản | Giờ lấy/xả nước, mặn | Lịch triều, tiện ích nông nghiệp |
| ⛴ Ghe thuyền | Nước lớn, chiều cao qua cầu | Lịch triều, tĩnh không cầu |
| 🧭 Du lịch | An toàn, giờ đẹp | Bản đồ, thời tiết |

### 1.2. Phạm vi địa lý: toàn quốc

| Vùng | Đặc điểm thủy văn | Dữ liệu chủ đạo |
|---|---|---|
| Đồng bằng sông Cửu Long | Triều bán nhật không đều, lũ mùa (tháng 8–11), xâm nhập mặn | Trạm KTTV, MRC (Tân Châu, Châu Đốc…), triều |
| Đông Nam Bộ (TP.HCM, Vũng Tàu) | Triều mạnh, triều cường gây ngập | Trạm KTTV, triều Vũng Tàu |
| Duyên hải miền Trung | Lũ nhanh, sông ngắn dốc; ven biển triều hỗn hợp | Trạm KTTV, mưa |
| Tây Nguyên | Sông suối, hồ thủy điện | Trạm KTTV, hồ chứa, mưa |
| Bắc Bộ (sông Hồng, Thái Bình) | Nhật triều vùng cửa sông, lũ mùa hè | Trạm KTTV, triều Hòn Dấu |
| Miền núi phía Bắc | Lũ quét, sạt lở | Mưa, trạm KTTV |

→ App phải xử lý cả **trạm có triều** (`has_tide = true`) và **trạm không triều** (chỉ thực đo + xu hướng).

---

## 2. Nguyên tắc thiết kế

1. **Offline-first:** Thủy triều, âm lịch, mặt trăng, mặt trời, chỉ số câu cá (phần không phụ thuộc thời tiết) đều tính **trên máy**. Dữ liệu tải về được lưu lại; mất mạng vẫn xem được dữ liệu gần nhất + thời điểm cập nhật.
2. **Trung thực về dữ liệu:** Phân biệt rõ 3 loại trên UI:
   - **Thực đo** (màu đậm, nét liền) — từ trạm.
   - **Dự báo triều** (nét đứt) — tính toán.
   - **Ước tính** (nền sọc, nhãn "ước tính") — nội suy tại điểm không có trạm.
3. **Nhẹ:** App < 30 MB; màn hình chính mở < 2 giây trên máy tầm thấp; tải dữ liệu tối thiểu (gzip, cache).
4. **Dễ dùng cho người lớn tuổi:** Chữ to, tương phản cao, số liệu lớn, ít thao tác.
5. **Riêng tư mặc định:** Không bắt buộc đăng nhập; điểm câu & nhật ký mặc định riêng tư.
6. **Không phụ thuộc 1 nguồn:** Mỗi loại dữ liệu có nguồn dự phòng; nguồn hỏng → app vẫn chạy với dữ liệu khác + báo "nguồn tạm gián đoạn".

---

## 3. Kiến trúc tổng thể

### 3.0. Kiến trúc V0 — bản dùng thử, không máy chủ (ĐANG ÁP DỤNG)

```
┌──────────── NGUỒN MIỄN PHÍ, KHÔNG CẦN KHÓA ────────────┐   ┌── Chạy tay trên máy dev (1 lần/tháng) ──┐
│ IOC (thực đo Vũng Tàu, Quy Nhơn, mỗi phút)              │   │ tools/tide (Python + utide):            │
│ Open-Meteo Forecast (thời tiết) · Marine (triều mô hình)│   │ tải 1–2 năm IOC → hằng số → dự báo      │
└───────────────┬─────────────────────────────────────────┘   │ 10 phút cho năm nay + năm sau           │
                │ HTTPS, gọi thẳng từ app                      │ → app/assets/tide/<trạm>.json.gz        │
                ▼                                              └──────────────────┬──────────────────────┘
┌──────────────────────── APP FLUTTER (Android) ────────────────────────┐        │ đóng gói vào app
│ UI ─► Riverpod ─► Repositories ─► {HTTP (dio), Drift (cache + dữ liệu  │◄───────┘
│                                    người dùng), assets triều}           │
│ core/calc: tide · lunar · astro · fishing · geo · skill (sai số)       │
│ Vietmap (bản đồ) · fl_chart · flutter_local_notifications              │
└────────────────────────────────────────────────────────────────────────┘
```

| Việc | Cách làm ở V0 | Ghi chú |
|---|---|---|
| Thực đo theo giờ (loại A) | App gọi IOC lấy 30 ngày gần nhất → trung bình 10 phút quanh mỗi giờ → lưu Drift | Mỗi máy tự lấy; ổn với vài chục người dùng thử |
| Dự báo triều | Đọc asset dự báo 10 phút (Python sinh sẵn) + hiệu chỉnh theo thực đo mới nhất (F-TIDE-07) | Chạy offline |
| Sai số 30 ngày | **Tính trên máy**: so thực đo IOC 30 ngày với dự báo trong asset → ±cm, ±phút | Không cần lưu ở server |
| Trạm ven biển không có máy đo | Open-Meteo Marine `sea_level_height_msl`, nhãn "dự báo mô hình · tham khảo" | Độ tin cậy theo kết quả P0-05 |
| Thời tiết, chỉ số câu cá | Open-Meteo Forecast gọi thẳng, cache Drift theo ô lưới 1 giờ | Gói miễn phí Open-Meteo chỉ cho dùng **phi thương mại** — đủ cho dùng thử |
| Dữ liệu người dùng | Drift trên máy (điểm lưu, nhật ký câu, cài đặt) | Chưa đồng bộ |
| Cảnh báo | Thông báo cục bộ lên lịch trước theo giờ đỉnh/chân, giờ vàng | Không cần FCM |
| Trạm sông (bản tin KTTV) | **V0-09 (sau):** GitHub Actions miễn phí đọc PDF 1 lần/ngày → JSON tĩnh trên GitHub Pages → app đọc | Vẫn không thuê máy chủ |
| Phát hành thử | APK Android gửi trực tiếp hoặc Firebase App Distribution (miễn phí) | iOS cần tài khoản Apple 99 USD/năm + máy Mac/Codemagic → để sau |

**Ngoài V0 (cần máy chủ, để sau):** đăng nhập & đồng bộ (F-UX-07), cảnh báo đẩy theo thực đo (F-ALERT-02+), chia sẻ cộng đồng, quản trị (F-ADM).
**Khóa trong app:** không có khóa nào — bản đồ nền OpenFreeMap không cần khóa (quyết định 09/11/2026), các nguồn dữ liệu cũng không cần khóa.

### 3.1. Kiến trúc đầy đủ (giai đoạn sau, khi cần máy chủ)

```
┌─────────────────────────── NGUỒN DỮ LIỆU (miễn phí) ───────────────────────────┐
│ KTTV / VNDMS / Thủy lợi (mực nước VN) · MRC (Mekong) · Open-Meteo (thời tiết,  │
│ lũ, độ cao, biển) · UHSLC / dữ liệu tích lũy (hằng số triều) · Vietmap (bản đồ)│
└───────────────┬─────────────────────────────────────────────┬─────────────────┘
                │ (Edge Functions ingest-*, mỗi 15 phút)       │ (GitHub Actions, hàng tháng)
                ▼                                             ▼
┌──────────────────────────── SUPABASE (Singapore) ─────────────────────────────┐
│ Postgres + PostGIS                                                            │
│  ├ stations, rivers, observations, tide_extremes, sources, source_runs ...    │
│  ├ user data: saved_places, catches, alert_subscriptions, devices ...        │
│  └ RLS trên mọi bảng                                                          │
│ pg_cron ──► pg_net ──► Edge Functions (ingest, alerts, cleanup)               │
│ Edge Functions (Deno/TS): point, weather, register-device, ...                │
│ Storage: tide/{station}/{year}.json.gz (công khai) · catch-photos (riêng tư)  │
│ Auth: ẩn danh / email OTP / Google / Apple                                    │
└───────────────┬───────────────────────────────────────────────────────────────┘
                │ HTTPS (PostgREST + Functions), App Check
                ▼
┌──────────────────────────── APP FLUTTER (Android/iOS) ────────────────────────┐
│ UI (features) ─► Riverpod providers ─► Repositories ─► {Remote API, Drift DB} │
│ core/calc: tide · lunar · astro (sun/moon) · fishing_score · interpolation    │
│ Bản đồ Vietmap (vietmap_flutter_gl) · fl_chart · FCM · local notifications    │
└───────────────────────────────────────────────────────────────────────────────┘
          ▲
          │ FCM (thông báo đẩy)
     Firebase (FCM, App Check, Crashlytics)
```

### Luồng dữ liệu chính

| Luồng | Mô tả |
|---|---|
| **Ingest** | Cron 15 phút → `ingest-<source>` → tải → parse → chuẩn hóa (cm, UTC) → `upsert observations` → ghi `source_runs` |
| **Tide build** | GitHub Actions hàng tháng → Python `utide` → hằng số + dự báo 2 năm, mỗi 10 phút → nén JSON → Storage `tide/{station_id}/{year}.json.gz` + bảng `tide_extremes` |
| **App đọc trạm** | PostgREST `stations` (cache 24h trên máy) + `latest_observations` view |
| **App đọc chuỗi đo** | RPC `get_series(station_id, from, to, step)` |
| **App đọc triều** | Tải file năm từ Storage (1 lần/năm/trạm) → lưu Drift → nội suy trên máy |
| **Thời tiết** | Edge Function `weather` (proxy + cache theo ô lưới) → Open-Meteo |
| **Điểm bất kỳ** | Edge Function `point` |
| **Cảnh báo** | Cron 15 phút sau ingest → `alerts-evaluate` → FCM |

---

## 4. Cấu trúc thư mục (monorepo)

```
RiverTide/
├── CLAUDE.md                      # LUẬT bắt buộc cho AI
├── FEATURES.md                    # mô tả sản phẩm & đặc tả tính năng + AC
├── PROJECT.md                     # file này: kỹ thuật + roadmap
├── TOOLS.md                       # công cụ & môi trường
├── README.md                      # hướng dẫn chạy nhanh
├── .gitignore
├── .editorconfig
├── .vscode/
│   ├── settings.json
│   └── launch.json                # cấu hình chạy app dev/prod
├── .github/workflows/
│   ├── ci.yml
│   └── tide-build.yml
├── docs/
│   ├── rules/                     # chuẩn code chi tiết (01 → 07), AI bắt buộc theo
│   ├── data-sources.md            # kết quả khảo sát nguồn (P0-03)
│   ├── stations-catalog.md        # danh mục trạm, mốc cao độ, ngưỡng báo động
│   ├── fishing-score.md           # ghi chú tinh chỉnh công thức
│   └── adr/                       # quyết định kiến trúc (nếu cần)
├── app/                           # Flutter app
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── l10n.yaml
│   ├── env/
│   │   ├── example.json           # commit
│   │   └── dev.json               # KHÔNG commit
│   ├── assets/
│   │   ├── images/
│   │   ├── icons/
│   │   └── data/
│   │       ├── species.json       # cẩm nang loài cá (offline)
│   │       └── knots.json         # nút buộc câu
│   ├── lib/
│   │   ├── main.dart
│   │   ├── bootstrap.dart         # khởi tạo Firebase, Supabase, Drift, timezone
│   │   ├── app.dart               # MaterialApp.router, theme
│   │   ├── router.dart            # go_router
│   │   ├── l10n/app_vi.arb
│   │   ├── core/
│   │   │   ├── config/env.dart            # đọc --dart-define
│   │   │   ├── theme/                     # màu, chữ, kích thước
│   │   │   ├── network/                   # dio client, interceptors, lỗi
│   │   │   ├── db/                        # Drift database + DAO
│   │   │   ├── calc/                      # ★ Dart thuần, có unit test
│   │   │   │   ├── tide/                  # nội suy, tìm đỉnh/chân, tốc độ
│   │   │   │   ├── lunar/                 # âm lịch (thuật toán Hồ Ngọc Đức)
│   │   │   │   ├── astro/                 # mặt trời, mặt trăng, solunar
│   │   │   │   ├── fishing/               # chỉ số câu cá
│   │   │   │   └── geo/                   # khoảng cách, geohash, làm mờ vị trí
│   │   │   ├── location/
│   │   │   ├── notifications/
│   │   │   └── widgets/                   # widget dùng chung (LoadingView, ErrorView…)
│   │   └── features/
│   │       ├── map/
│   │       ├── stations/
│   │       ├── station_detail/
│   │       ├── point_detail/
│   │       ├── tide_calendar/
│   │       ├── fishing/
│   │       ├── catches/           # nhật ký câu
│   │       ├── places/            # điểm của tôi
│   │       ├── alerts/
│   │       ├── weather/
│   │       ├── safety/
│   │       ├── species/
│   │       ├── settings/
│   │       └── auth/
│   └── test/
│       ├── core/calc/...          # test thuật toán
│       └── features/...
├── supabase/
│   ├── config.toml
│   ├── seed.sql                   # trạm mẫu, loài cá, nguồn
│   ├── migrations/
│   │   ├── 0001_extensions.sql
│   │   ├── 0002_core_tables.sql
│   │   ├── 0003_user_tables.sql
│   │   ├── 0004_rls.sql
│   │   ├── 0005_functions_views.sql
│   │   └── 0006_cron.sql
│   └── functions/
│       ├── _shared/               # cors, supabase client, zod schemas, fcm, cache
│       ├── health/
│       ├── ingest-mrc/
│       ├── ingest-vndms/
│       ├── ingest-thuyloi/
│       ├── weather/
│       ├── point/
│       ├── register-device/
│       ├── alerts-evaluate/
│       └── cleanup/
└── tools/
    ├── nchmf/                     # Python: tìm & parse bản tin PDF KTTV (pdfplumber)
    │   ├── find_latest.py
    │   ├── parse_tvhn.py
    │   ├── parse_tide.py
    │   ├── station_map.csv        # tên trạm trong bản tin → station_id
    │   ├── upload.py
    │   ├── fixtures/              # PDF mẫu
    │   └── tests/
    ├── tide/                      # Python
    │   ├── requirements.txt
    │   ├── fetch_history.py       # lấy chuỗi đo lịch sử
    │   ├── fit_constituents.py    # utide.solve
    │   ├── predict.py             # utide.reconstruct → JSON
    │   ├── extremes.py            # tìm đỉnh/chân
    │   ├── upload.py              # đẩy lên Supabase Storage + tide_extremes
    │   └── validate.py            # so với bảng thủy triều chính thức
    └── scripts/
        └── import_stations.py     # nhập danh mục trạm từ CSV
```

---

## 5. Tech stack & thư viện

### 5.1. App Flutter — `pubspec.yaml` (phiên bản: dùng bản mới nhất tương thích khi tạo dự án)

| Nhóm | Gói | Dùng để |
|---|---|---|
| State | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` (dev) | Quản lý trạng thái |
| Điều hướng | `go_router` | Route, deep link |
| Model | `freezed_annotation`, `json_annotation`, `freezed` (dev), `json_serializable` (dev), `build_runner` (dev) | Model bất biến, JSON |
| Mạng | `dio` | HTTP tới Edge Functions, Open-Meteo dự phòng |
| Backend | `supabase_flutter` | Auth, PostgREST, Storage |
| CSDL cục bộ | `drift`, `drift_flutter`, `drift_dev` (dev), `path_provider` | Offline cache |
| Bản đồ | `maplibre_gl` (0.28, maplibre.org, BSD-3) + kiểu bản đồ **OpenFreeMap** (miễn phí, không khóa, cho phép thương mại — đọc openfreemap.org ngày 09/11/2026) | Bản đồ nền; nhãn ưu tiên tên tiếng Việt `name:vi`; app tự vẽ nhãn Hoàng Sa, Trường Sa (Việt Nam). Vietmap: tùy chọn sau này |
| Biểu đồ | `fl_chart` | Mực nước, chỉ số câu cá |
| Vị trí | `geolocator`, `permission_handler` | Vị trí hiện tại |
| Thông báo | `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `timezone`, `flutter_timezone` | Đẩy + cục bộ |
| Chống app giả | `firebase_app_check` | App Check |
| Báo lỗi | `firebase_crashlytics` | Crash |
| Bảo mật lưu trữ | `flutter_secure_storage` | Token |
| Ảnh | `image_picker`, `image` (xóa EXIF bằng cách mã hóa lại), `cached_network_image` | Nhật ký câu |
| Widget màn hình chính | `home_widget` | 🟡 |
| Chạy nền | `workmanager` | Làm mới widget, lịch nhắc 🟡 |
| Tiện ích | `intl`, `share_plus`, `url_launcher`, `package_info_plus`, `connectivity_plus`, `collection`, `logger` | |
| Lint | `very_good_analysis` hoặc `flutter_lints` (dev) | Chất lượng code |
| Test | `flutter_test`, `mocktail` (dev) | |

> Thiên văn (mặt trời/mặt trăng) & âm lịch: **tự viết** trong `core/calc` theo thuật toán công khai (SunCalc / Meeus / Hồ Ngọc Đức) để chủ động và test được. Không phụ thuộc gói bên ngoài ít được duy trì.

### 5.2. Backend

| Thành phần | Công nghệ |
|---|---|
| CSDL | Postgres 15+ với **PostGIS** |
| API đọc | PostgREST (tự có của Supabase) + RPC SQL |
| Hàm máy chủ | Supabase Edge Functions — **Deno + TypeScript**, `zod` validate, `deno-dom` parse HTML khi cần |
| Lịch chạy | `pg_cron` + `pg_net` |
| Lưu file | Supabase Storage |
| Đăng nhập | Supabase Auth (ẩn danh, email OTP, Google, Apple) |
| Thông báo | FCM HTTP v1 (gọi từ Edge Function bằng service account) |

### 5.3. Xử lý thủy triều

Python 3.12 · `utide` · `numpy` · `pandas` · `scipy` — chạy local / GitHub Actions.

---

## 6. Nguồn dữ liệu

> ✅ Đã khảo sát ở P0-03 (2026-11-06). **Chi tiết, endpoint thật, kết luận: [docs/data-sources.md](docs/data-sources.md).**

### 6.1. Danh sách nguồn (sau khảo sát)

| Mã | Nguồn | Dữ liệu | Cách lấy | Tần suất | Trạng thái |
|---|---|---|---|---|---|
| `ioc` | IOC Sea Level Monitoring | Thực đo mực nước biển theo phút: Vũng Tàu, Quy Nhơn (lịch sử ≥ 2024) | JSON `service.php?query=data` → **Edge Function `ingest-ioc`** | 15 phút | ✅ 🟢 Chính (ven biển, fit triều) |
| `nchmf_tvhn` | KTTV Quốc gia: bản tin thủy văn hạn ngắn | Thực đo + dự báo mực nước khoảng 25 trạm sông (6 giờ/mốc hoặc đỉnh/chân ngày) | PDF → **Python `tools/nchmf` (GitHub Actions)** | 1 lần/ngày | ⚠ 🟢 Nguồn sông duy nhất hiện có |
| `nchmf_tide` | KTTV Quốc gia: bản tin thủy triều 10 ngày | Đỉnh/chân triều dự báo ~14 trạm ven biển | PDF → Python | 1 lần/ngày | ⚠ 🟢 Kiểm chứng + bổ sung |
| `om_forecast` | Open-Meteo Forecast | Mưa, gió, áp suất, mây, nhiệt độ, CAPE, mã thời tiết, mặt trời | `api.open-meteo.com/v1/forecast` | Theo yêu cầu, cache 1h | ✅ 🟢 |
| `om_marine` | Open-Meteo Marine | Sóng, nhiệt độ mặt biển, **`sea_level_height_msl`** (mô hình triều) | `marine-api.open-meteo.com/v1/marine` | Cache 3h | ✅ 🟢 triều dự phòng ven biển · 🟡 câu biển |
| `om_elevation` | Open-Meteo Elevation | Độ cao mặt đất (**lệch cao vài mét ở đồng bằng**) | `api.open-meteo.com/v1/elevation` | Cache vĩnh viễn | ⚠ 🟢 chỉ hiển thị kèm cảnh báo |
| `om_flood` | Open-Meteo Flood (GloFAS) | Lưu lượng dự báo (**sai nếu ô lưới không đúng dòng chính**) | `flood-api.open-meteo.com/v1/flood` | Cache 6h | ⚠ 🟡 chỉ với ô chọn tay |
| `vietmap` | Vietmap | Bản đồ nền, tìm kiếm, địa chỉ | `vietmap_flutter_gl` 4.1.1 + API qua Edge Function | Theo yêu cầu | ✅ 🟢 |
| `mrc` | Ủy hội sông Mê Kông | Mực nước 15 phút trạm Mekong | API cần đăng nhập (401) | — | ❌ Chờ đăng ký quyền |
| `vndms` | Cổng phòng chống thiên tai | Mực nước trạm toàn quốc | Chứng chỉ SSL hết hạn | — | ❌ Chờ sửa / liên hệ |
| `thuyloi`, `kttvnb` | Thủy lợi VN, Đài KTTV Nam Bộ | — | Chứng chỉ SSL lỗi | — | ❌ |
| `siwrr` | Viện KH Thủy lợi miền Nam | Bản tin mặn tháng | Trang bài viết | Tháng | ⚠ 🔵 |

### 6.2. Chiến lược hằng số thủy triều (quan trọng)

Mỗi trạm `has_tide = true` cần **hằng số điều hòa** (biên độ, pha của các sóng M2, S2, K1, O1, N2, K2, P1, Q1, M4, MS4…).

| Cách | Khi nào dùng | Độ chính xác |
|---|---|---|
| **A. Fit từ chuỗi đo dày** (≥ 30 ngày, tốt nhất ≥ 1 năm, mỗi giờ) | **Vũng Tàu, Quy Nhơn (IOC, lịch sử ≥ 2 năm)** — làm ngay; trạm khác khi có nguồn 15 phút (MRC/vndms) | Tốt nhất (`high`) |
| **B. Mô hình toàn cầu** Open-Meteo Marine `sea_level_height_msl` | Điểm ven biển không có trạm; cần kiểm chứng sai lệch so với IOC trước khi dùng | Trung bình (`medium`) |
| **C. Trạm tham chiếu + hiệu chỉnh** (lệch giờ, hệ số biên độ, ước lượng từ đỉnh/chân bản tin `nchmf_tvhn`) | Trạm triều trong sông (Phả Lại, Kim Long, Tân Châu…) | Thấp (`low`) |
| **D. Đỉnh/chân dự báo của bản tin** `nchmf_tide` | ~14 trạm ven biển, 10 ngày tới | Dùng hiển thị đỉnh/chân + **kiểm chứng** A/B |

**Quy trình:** P0-05 fit Vũng Tàu & Quy Nhơn từ IOC (1–2 năm) và kiểm chứng với bản tin `nchmf_tide` → P1 lưu liên tục mọi chuỗi đo → mỗi tháng fit lại. Trạm trong sông: dùng C cho tới khi có chuỗi đo dày.

> Lưu ý sông vùng triều có ảnh hưởng lũ (ĐBSCL mùa lũ): triều thuần túy sẽ **lệch** khi lũ lớn → app hiển thị **thực đo đè lên dự báo**, và tính "độ lệch hiện tại" = thực đo − dự báo, cộng độ lệch này vào vài giờ tới (hiệu chỉnh đơn giản, F-TIDE-09).

### 6.3. Chuẩn hóa dữ liệu (bắt buộc cho mọi ingest)

| Hạng mục | Chuẩn |
|---|---|
| Mực nước | `level_cm` kiểu `integer`, theo **mốc cao độ của trạm** (ghi ở `stations.datum`, ví dụ "Hòn Dấu", "Mũi Nai", "Hải đồ") |
| Thời gian | `timestamptz` UTC. Nguồn VN thường giờ +07 → đổi sang UTC |
| Trạm | `station_id` nội bộ dạng `<source>-<mã gốc>` (vd `mrc-019803`, `vndms-12345`); bảng `station_aliases` để ghép trùng khi nhiều nguồn cùng một trạm |
| Trùng lặp | Upsert theo khóa `(station_id, observed_at)` |
| Giá trị lỗi | Loại bỏ nếu ngoài khoảng `[min_valid_cm, max_valid_cm]` của trạm hoặc nhảy > `max_jump_cm` trong 15 phút; ghi `qc_flag` |

---

## 7. Cơ sở dữ liệu

### 7.1. Sơ đồ quan hệ (rút gọn)

```
sources 1─* stations *─1 rivers
stations 1─* observations
stations 1─* tide_extremes
stations 1─* station_aliases
sources 1─* source_runs
auth.users 1─1 profiles
auth.users 1─* saved_places, catches, alert_subscriptions
devices *─1 auth.users (nullable)
species 1─* catches
```

### 7.2. Migration `0001_extensions.sql`

```sql
create extension if not exists postgis;
create extension if not exists pg_cron;
create extension if not exists pg_net;
create extension if not exists pgcrypto;
```

### 7.3. Migration `0002_core_tables.sql` (dữ liệu công khai)

```sql
create table public.sources (
  id text primary key,                     -- 'mrc', 'vndms', ...
  name text not null,
  url text,
  attribution text not null,               -- dòng ghi nguồn hiển thị trong app
  license_note text,
  enabled boolean not null default true
);

create table public.rivers (
  id text primary key,                     -- 'tien', 'hau', 'hong', ...
  name text not null,                      -- 'Sông Tiền'
  basin text                               -- 'Mekong', 'Hồng – Thái Bình', ...
);

create type public.region as enum ('north_mountain','red_delta','north_central','south_central','highlands','southeast','mekong_delta');

create table public.stations (
  id text primary key,                     -- '<source>-<code>'
  name text not null,
  river_id text references public.rivers(id),
  province text,
  region public.region,
  location geography(Point,4326) not null,
  source_id text not null references public.sources(id),
  datum text,                              -- mốc cao độ
  has_tide boolean not null default false,
  tide_confidence text check (tide_confidence in ('high','medium','low')),
  alarm1_cm int, alarm2_cm int, alarm3_cm int,
  record_cm int, record_year int,
  min_valid_cm int default -500, max_valid_cm int default 3000, max_jump_cm int default 100,
  river_km numeric,                        -- vị trí dọc sông (km từ cửa) để nội suy
  active boolean not null default true,
  meta jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create index stations_location_gix on public.stations using gist (location);
create index stations_river_idx on public.stations (river_id);

create table public.station_aliases (
  station_id text not null references public.stations(id) on delete cascade,
  source_id text not null references public.sources(id),
  external_code text not null,
  primary key (source_id, external_code)
);

create table public.observations (
  station_id text not null references public.stations(id) on delete cascade,
  observed_at timestamptz not null,
  level_cm int not null,
  discharge_m3s numeric,
  salinity_gl numeric,                     -- độ mặn g/l nếu có
  source_id text not null references public.sources(id),
  qc_flag smallint not null default 0,     -- 0 ok, 1 nghi ngờ, 2 loại
  inserted_at timestamptz not null default now(),
  primary key (station_id, observed_at)
);
create index observations_time_idx on public.observations (observed_at desc);

create table public.observations_hourly (  -- tổng hợp giữ lâu dài
  station_id text not null references public.stations(id) on delete cascade,
  hour timestamptz not null,
  level_avg_cm int, level_min_cm int, level_max_cm int,
  primary key (station_id, hour)
);

create table public.tide_extremes (
  station_id text not null references public.stations(id) on delete cascade,
  t timestamptz not null,
  level_cm int not null,
  kind text not null check (kind in ('high','low')),
  primary key (station_id, t)
);

create table public.tide_files (           -- danh mục file dự báo triều trong Storage
  station_id text not null references public.stations(id) on delete cascade,
  year int not null,
  path text not null,                      -- 'tide/<station>/<year>.json.gz'
  step_minutes int not null default 10,
  model_version text not null,
  generated_at timestamptz not null default now(),
  primary key (station_id, year)
);

create table public.source_runs (
  id bigint generated always as identity primary key,
  source_id text not null references public.sources(id),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null check (status in ('running','ok','partial','error')),
  rows_upserted int default 0,
  error text
);

create table public.species (
  id text primary key,                     -- 'ca-loc'
  name_vi text not null,
  name_alt text[],                         -- tên địa phương
  name_sci text,
  habitat text[],                          -- 'song','kenh','ho','bien','cua_song'
  regions public.region[],
  best_months int[],                       -- 1..12
  best_tide text[],                        -- 'rising','falling','slack','any'
  best_time text[],                        -- 'dawn','dusk','night','day'
  baits text[],
  methods text[],                          -- 'cau_luc','cau_dai','lure','cau_tay','cau_bien'
  min_size_cm int,                         -- ⚪ quy định (để sau)
  description_md text,
  image_path text
);

create table public.point_cache (
  cell text primary key,                   -- geohash độ dài 6 (~1.2 km)
  payload jsonb not null,
  expires_at timestamptz not null
);

create table public.weather_cache (
  cell text primary key,                   -- geohash độ dài 5 (~5 km)
  payload jsonb not null,
  expires_at timestamptz not null
);
```

### 7.4. Migration `0003_user_tables.sql` (dữ liệu người dùng)

```sql
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) <= 40),
  created_at timestamptz not null default now()
);

create table public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  fcm_token text not null unique,
  platform text not null check (platform in ('android','ios')),
  locale text default 'vi',
  app_version text,
  updated_at timestamptz not null default now()
);

create type public.place_kind as enum ('home','field','spot','dock','pond','other');

create table public.saved_places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 60),
  kind public.place_kind not null default 'other',
  location geography(Point,4326) not null,
  ground_elevation_cm int,                 -- người dùng tự nhập (ưu tiên hơn mô hình)
  note text check (char_length(note) <= 500),
  created_at timestamptz not null default now()
);

create table public.alert_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null check (target_type in ('station','place')),
  station_id text references public.stations(id) on delete cascade,
  place_id uuid references public.saved_places(id) on delete cascade,
  rule jsonb not null,                     -- xem 9.7
  enabled boolean not null default true,
  quiet_start time, quiet_end time,        -- giờ yên lặng (giờ VN)
  state jsonb not null default '{}'::jsonb,-- trạng thái hysteresis, last_fired_at
  created_at timestamptz not null default now(),
  check ((target_type='station' and station_id is not null) or (target_type='place' and place_id is not null))
);

create table public.catches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  caught_at timestamptz not null,
  place_id uuid references public.saved_places(id) on delete set null,
  location geography(Point,4326),          -- chính xác, riêng tư
  species_id text references public.species(id),
  species_other text,
  count int not null default 1 check (count between 1 and 999),
  weight_g int check (weight_g between 0 and 500000),
  length_cm numeric check (length_cm between 0 and 500),
  bait text, method text,
  released boolean default false,          -- câu thả
  photo_paths text[] default '{}',
  note text check (char_length(note) <= 1000),
  conditions jsonb not null default '{}'::jsonb,  -- snapshot tự động (9.6)
  created_at timestamptz not null default now()
);
create index catches_user_time_idx on public.catches (user_id, caught_at desc);
```

### 7.5. Migration `0004_rls.sql`

```sql
-- Bật RLS cho MỌI bảng
alter table public.sources            enable row level security;
alter table public.rivers             enable row level security;
alter table public.stations           enable row level security;
alter table public.station_aliases    enable row level security;
alter table public.observations       enable row level security;
alter table public.observations_hourly enable row level security;
alter table public.tide_extremes      enable row level security;
alter table public.tide_files         enable row level security;
alter table public.source_runs        enable row level security;
alter table public.species            enable row level security;
alter table public.point_cache        enable row level security;
alter table public.weather_cache      enable row level security;
alter table public.profiles           enable row level security;
alter table public.devices            enable row level security;
alter table public.saved_places       enable row level security;
alter table public.alert_subscriptions enable row level security;
alter table public.catches            enable row level security;

-- Dữ liệu công khai: ai cũng ĐỌC được, không ai GHI qua API (chỉ service_role ghi)
create policy "public read" on public.sources            for select using (true);
create policy "public read" on public.rivers             for select using (true);
create policy "public read" on public.stations           for select using (active);
create policy "public read" on public.observations       for select using (qc_flag < 2);
create policy "public read" on public.observations_hourly for select using (true);
create policy "public read" on public.tide_extremes      for select using (true);
create policy "public read" on public.tide_files         for select using (true);
create policy "public read" on public.species            for select using (true);
-- station_aliases, source_runs, point_cache, weather_cache, devices: KHÔNG có policy → chỉ service_role

-- Dữ liệu người dùng: chỉ chủ sở hữu
create policy "own profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "own places" on public.saved_places
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own alerts" on public.alert_subscriptions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own catches" on public.catches
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

Storage policies (tạo trong migration hoặc dashboard):
- Bucket `tide` — **public read**, ghi chỉ service_role.
- Bucket `catch-photos` — **private**; đường dẫn `<user_id>/<uuid>.jpg`; policy: `auth.uid()::text = (storage.foldername(name))[1]` cho select/insert/delete; giới hạn 2 MB, chỉ `image/jpeg`, `image/webp`.

### 7.6. Migration `0005_functions_views.sql`

```sql
-- Mực nước mới nhất mỗi trạm (+ xu hướng 1 giờ)
create or replace view public.latest_observations
with (security_invoker = true) as
select distinct on (o.station_id)
  o.station_id, o.observed_at, o.level_cm,
  o.level_cm - (
    select o2.level_cm from public.observations o2
    where o2.station_id = o.station_id
      and o2.observed_at <= o.observed_at - interval '55 minutes'
      and o2.qc_flag < 2
    order by o2.observed_at desc limit 1
  ) as delta_1h_cm
from public.observations o
where o.qc_flag < 2 and o.observed_at > now() - interval '3 days'
order by o.station_id, o.observed_at desc;

-- Chuỗi đo theo khoảng thời gian, gộp theo bước (phút)
create or replace function public.get_series(p_station text, p_from timestamptz, p_to timestamptz, p_step_min int default 15)
returns table (t timestamptz, level_cm int)
language sql stable security invoker as $$
  select to_timestamp(floor(extract(epoch from observed_at) / (p_step_min*60)) * (p_step_min*60)) as t,
         round(avg(level_cm))::int
  from public.observations
  where station_id = p_station and observed_at between p_from and p_to and qc_flag < 2
  group by 1 order by 1
  limit 5000;
$$;

-- Trạm gần nhất
create or replace function public.nearest_stations(p_lat double precision, p_lon double precision, p_limit int default 3)
returns table (id text, name text, river_id text, distance_m double precision, has_tide boolean)
language sql stable security invoker as $$
  select s.id, s.name, s.river_id,
         st_distance(s.location, st_makepoint(p_lon, p_lat)::geography) as distance_m,
         s.has_tide
  from public.stations s
  where s.active
  order by s.location <-> st_makepoint(p_lon, p_lat)::geography
  limit least(p_limit, 10);
$$;

-- Trạm trong khung bản đồ (bounding box)
create or replace function public.stations_in_bbox(min_lon double precision, min_lat double precision, max_lon double precision, max_lat double precision)
returns setof public.stations
language sql stable security invoker as $$
  select * from public.stations
  where active and location && st_makeenvelope(min_lon, min_lat, max_lon, max_lat, 4326)::geography
  limit 2000;
$$;
```

### 7.7. Lưu trữ & dọn dẹp

| Dữ liệu | Giữ bao lâu |
|---|---|
| `observations` (15 phút) | 120 ngày → sau đó chỉ còn `observations_hourly` |
| `observations_hourly` | Vĩnh viễn (dùng fit triều, so sánh năm trước) |
| `source_runs` | 30 ngày |
| `point_cache`, `weather_cache` | Xóa khi hết hạn |

> Trước khi xóa `observations` cũ, phải đảm bảo `observations_hourly` đã tổng hợp (cron `aggregate-hourly`).

---

## 8. Backend: Edge Functions, Cron, API

### 8.1. Danh sách Edge Functions

| Function | Gọi bởi | Xác thực | Mô tả |
|---|---|---|---|
| `health` | UptimeRobot | Không | Trả `{ok, db, last_ingest_by_source}` |
| `ingest-ioc` | pg_cron | Header `x-cron-secret` | Lấy dữ liệu IOC (Vũng Tàu, Quy Nhơn) → QC → upsert |
| *(Python, không phải Edge Function)* `tools/nchmf/ingest.py` | GitHub Actions 11:00 giờ VN hằng ngày | `SUPABASE_SERVICE_ROLE_KEY` trong GitHub secrets | Tìm bài bản tin mới → tải PDF → `pdfplumber` → upsert `observations` (thực đo) + `forecasts` (dự báo) + `tide_extremes` |
| `ingest-mrc`, `ingest-vndms` | — | — | ⏸ Chỉ làm khi được cấp quyền / nguồn sửa lỗi |
| `aggregate-hourly` | pg_cron | `x-cron-secret` | Tổng hợp giờ (có thể là SQL thuần trong cron) |
| `weather` | App | anon JWT + App Check | Proxy Open-Meteo, cache theo geohash5 |
| `point` | App | anon JWT + App Check | Thông tin điểm bất kỳ (8.3) |
| `geocode` | App | anon JWT + App Check | Proxy Vietmap tìm kiếm & địa chỉ |
| `register-device` | App | anon JWT + App Check | Lưu/cập nhật FCM token |
| `alerts-evaluate` | pg_cron | `x-cron-secret` | Đánh giá điều kiện cảnh báo → FCM 🟡 |
| `cleanup` | pg_cron | `x-cron-secret` | Xóa dữ liệu hết hạn |
| `delete-account` | App | User JWT | 🟡 Xóa toàn bộ dữ liệu người dùng |

### 8.2. Lịch cron (migration `0006_cron.sql`)

| Job | Lịch | Việc |
|---|---|---|
| `ingest-ioc` | `*/15 * * * *` | |
| `nchmf` (GitHub Actions, không phải pg_cron) | `0 4 * * *` UTC (11:00 VN) | thử lại 13:00 VN nếu chưa có bản tin mới |
| `aggregate-hourly` | `10 * * * *` | |
| `alerts-evaluate` | `12,27,42,57 * * * *` | 🟡 sau ingest |
| `cleanup` | `30 3 * * *` | 03:30 UTC |

Mẫu gọi Edge Function từ cron:

```sql
select cron.schedule('ingest-mrc', '5,20,35,50 * * * *', $$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'functions_url') || '/ingest-mrc',
    headers := jsonb_build_object('x-cron-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret')),
    timeout_milliseconds := 60000
  );
$$);
```

> Lưu `functions_url` và `cron_secret` trong **Supabase Vault**, không hard-code.

### 8.3. API `point` — hợp đồng

**Request** `POST /functions/v1/point`

```json
{ "lat": 10.3521, "lon": 105.8890 }
```

Validate: `lat ∈ [8.0, 23.5]`, `lon ∈ [102.0, 117.5]` (bao lãnh thổ & biển VN), làm tròn 4 chữ số.

**Response 200**

```json
{
  "cell": "w3gv2c",
  "address": { "name": "Xã Long Hòa", "district": "H. Châu Thành", "province": "Tiền Giang" },
  "elevation_m": 1.6,
  "nearest_stations": [
    { "id": "vndms-xxxx", "name": "Mỹ Thuận", "river_id": "tien", "distance_m": 8200,
      "has_tide": true, "latest": { "observed_at": "2026-11-06T04:00:00Z", "level_cm": 210, "delta_1h_cm": -6 } }
  ],
  "estimate": {
    "method": "river_interp",        // river_interp | nearest | none
    "confidence": "medium",          // high <5km, medium 5–20km, low >20km hoặc khác sông
    "level_cm": 200,
    "tide_ref_station": "vndms-xxxx",
    "tide_lag_minutes": 25
  },
  "weather_ref": "w3gv2",            // app gọi /weather với cell này
  "sources": ["vndms", "open-meteo", "vietmap"],
  "generated_at": "2026-11-06T04:05:12Z"
}
```

**Lỗi:** `400 {error:{code:"out_of_bounds"}}`, `429 {error:{code:"rate_limited"}}`, `502 {error:{code:"upstream"}}` (trả phần có được, kèm `partial: true` nếu được).

### 8.4. API `weather` — hợp đồng

`GET /functions/v1/weather?cell=w3gv2` (hoặc `lat`,`lon`)

Gọi Open-Meteo với:

```
hourly=temperature_2m,precipitation,precipitation_probability,weather_code,cloud_cover,
       pressure_msl,wind_speed_10m,wind_gusts_10m,wind_direction_10m,cape,is_day
daily=sunrise,sunset,precipitation_sum,wind_speed_10m_max,weather_code
timezone=Asia/Ho_Chi_Minh&forecast_days=7&past_days=1
```

Cache 60 phút theo `cell`. Trả nguyên khối đã rút gọn + `attribution`.

### 8.5. Định dạng file dự báo triều trong Storage

`tide/<station_id>/<year>.json.gz`

```json
{
  "station_id": "vndms-xxxx",
  "year": 2027,
  "datum": "Hòn Dấu",
  "tz": "UTC",
  "start": "2027-01-01T00:00:00Z",
  "step_minutes": 10,
  "levels_cm": [123, 125, 128, ...],      // 52.560 phần tử (365 ngày × 144)
  "extremes": [["2027-01-01T03:20:00Z", 312, "H"], ["2027-01-01T09:50:00Z", 45, "L"]],
  "model": { "version": "utide-1", "constituents": 25, "fit_from": "2026-01-01", "fit_to": "2026-12-31", "rmse_cm": 8.4 },
  "confidence": "high"
}
```

Kích thước ước tính sau gzip: ~60–120 KB/trạm/năm. App tải năm hiện tại + năm sau.

### 8.6. Chuẩn chung cho Edge Functions

- `_shared/cors.ts`, `_shared/errors.ts` (`{ error: { code, message } }`), `_shared/supabase.ts` (client service_role — chỉ dùng phía server).
- `_shared/auth.ts`: kiểm tra JWT (anon hoặc user) + **App Check token** header `X-Firebase-AppCheck` (dev: cho phép bỏ qua bằng biến `APP_CHECK_ENFORCE=false`).
- `_shared/ratelimit.ts`: giới hạn theo IP + device (ví dụ 60 req/phút cho `point`) — lưu tạm trong bảng `rate_limits` hoặc dùng Upstash nếu cần ⚪.
- Timeout gọi nguồn ngoài: 10 giây; thử lại 2 lần với backoff.
- Log có cấu trúc: `console.log(JSON.stringify({fn, level, msg, ...}))`.
- Mỗi function có `index_test.ts` (Deno test) cho phần parse/validate.

---

## 9. Thuật toán

Tất cả đặt trong `app/lib/core/calc/` (Dart thuần) — trừ fit triều (Python).

### 9.1. Thủy triều

**Fit (Python, `tools/tide`)**

```python
coef = utide.solve(t, h, lat=lat, method='ols', conf_int='linear',
                   constit='auto', nodal=True, trend=False)
pred = utide.reconstruct(t_future, coef)    # mỗi 10 phút, 2 năm
```

- Yêu cầu dữ liệu: ≥ 30 ngày liên tục (≥ 90% đầy đủ). Ghi `rmse_cm` so với dữ liệu kiểm chứng (tách 10% cuối làm test).
- `confidence`: `high` nếu rmse < 10 cm và dữ liệu ≥ 180 ngày; `medium` nếu rmse < 20 cm; còn lại `low`.

**Dùng trên app (`core/calc/tide/`)**

| Hàm | Mô tả |
|---|---|
| `levelAt(DateTime t)` | Nội suy **Hermite bậc 3** giữa các điểm 10 phút |
| `rateAt(t)` | Đạo hàm (cm/giờ) → tốc độ lên/xuống |
| `nextExtremes(t, count)` | Từ danh sách `extremes` |
| `stateAt(t)` | `rising` / `falling` / `slack` (slack khi \|rate\| < 3 cm/h, ⚠ tinh chỉnh theo trạm) |
| `countdownToNext(t)` | Thời gian đến đỉnh/chân kế tiếp |
| `dailyRange(date)` | Biên độ triều trong ngày (đỉnh cao nhất − chân thấp nhất) |
| `springNeap(date)` | Phân loại ngày theo biên độ so với trung bình 29 ngày: `spring` (rong) ≥ 120%, `neap` (kém) ≤ 80% |
| `correctedLevel(t, lastObs)` | Hiệu chỉnh: `pred(t) + bias * decay(t - tObs)`, `bias = obs - pred(tObs)`, `decay` giảm tuyến tính về 0 trong 12 giờ |

**Test:** so với bảng thủy triều chính thức tại ≥ 3 trạm (Vũng Tàu, Hòn Dấu, Quy Nhơn ⚠ chọn theo dữ liệu có): sai lệch giờ đỉnh/chân trung bình < 20 phút, độ cao < 15 cm.

### 9.2. Âm lịch (`core/calc/lunar/`)

- Thuật toán **Hồ Ngọc Đức** (công khai), múi giờ **+7**.
- Hàm: `solarToLunar(date) → (day, month, year, isLeapMonth)`, `lunarToSolar(...)`, tên can chi năm.
- **Test bắt buộc:** Tết Nguyên đán các năm 2020–2030 (đối chiếu lịch chính thức), các tháng nhuận.

### 9.3. Con nước (cách gọi dân gian miền Nam)

Dựa trên **ngày âm lịch** + **biên độ triều thực tế** (9.1 `springNeap`):

| Ngày âm (gần đúng) | Tên | Ghi chú |
|---|---|---|
| 28 → 3, 13 → 18 | **Nước rong** (nước lớn) | Biên độ lớn |
| 7 → 9, 22 → 24 | **Nước kém** (nước ròng sát) | Biên độ nhỏ |
| 10, 25 | **Nước nhảy** (con nước mới bắt đầu lên) | Theo kinh nghiệm dân gian ⚠ kiểm chứng |
| còn lại | Nước trung bình | |

> Hiển thị **cả nhãn dân gian lẫn số liệu thật**. Nếu biên độ thực tế mâu thuẫn với nhãn âm lịch → ưu tiên số liệu thật, nhãn dân gian để làm phụ.
> Miền Bắc/Trung có thể dùng cách gọi khác → nhãn theo `region` (bảng tra trong `assets/data/tide_terms.json`).

### 9.4. Mặt trời & mặt trăng (`core/calc/astro/`)

Theo **SunCalc** (Agafonkin) / **Meeus**:

| Hàm | Đầu ra |
|---|---|
| `sunTimes(date, lat, lon)` | Bình minh, hoàng hôn, giữa trưa, rạng đông/chạng vạng dân sự |
| `moonPosition(t, lat, lon)` | Độ cao, phương vị |
| `moonTimes(date, lat, lon)` | Trăng mọc, trăng lặn (có thể không có trong ngày) |
| `moonTransits(date, lat, lon)` | Trăng lên đỉnh (upper transit) & xuống chân (lower transit) — tìm cực trị độ cao, bước 5 phút + tinh chỉnh |
| `moonIllumination(t)` | % sáng, pha (0–1), tên pha |

**Test:** so với số liệu công bố (ví dụ timeanddate) cho Hà Nội, Đà Nẵng, Cần Thơ — sai số < 5 phút.

### 9.5. Solunar

| Giai đoạn | Khung giờ |
|---|---|
| **Chính (major)** | ±60 phút quanh trăng lên đỉnh và trăng xuống chân |
| **Phụ (minor)** | ±30 phút quanh trăng mọc và trăng lặn |
| **Ngày tốt** | Trong ±2 ngày quanh trăng non / trăng tròn |

### 9.6. Chỉ số câu cá (`core/calc/fishing/`)

Tính cho mỗi giờ `h` tại điểm (trạm hoặc điểm lưu). Mỗi thành phần ∈ [0, 1].

```
S = 10 × Σ(w_i × s_i) / Σ(w_i đang có dữ liệu)       → làm tròn 1 chữ số
```

| Thành phần | w | Cách tính `s` |
|---|---|---|
| **tide** | 0.30 | Chỉ khi `has_tide`. `m` = phút tới lần đổi con nước gần nhất (đỉnh/chân, trước hoặc sau). `m ≤ 20`: 0.5 (nước đứng) · `20 < m ≤ 120`: 1.0 · `120 < m ≤ 180`: 0.75 · `> 180`: 0.5. Nhân hệ số con nước: rong 1.0 · trung bình 0.85 · kém 0.7. Trạm không triều: dùng `flow` thay thế: mực nước thay đổi nhẹ (2–10 cm/h) 0.9, đứng yên 0.6, lên rất nhanh (> 20 cm/h, nước đục) 0.3 |
| **solunar** | 0.25 | Trong giờ chính 1.0 · giờ phụ 0.75 · ngoài 0.35. Cộng 0.1 nếu là "ngày tốt" (tối đa 1.0) |
| **pressure** | 0.20 | `Δp` = thay đổi áp suất 3 giờ (hPa). Giảm 1–3: 1.0 · \|Δp\| < 1: 0.8 · tăng 1–3: 0.6 · giảm > 3: 0.3 · tăng > 3: 0.4 |
| **daytime** | 0.10 | Trong ±90 phút quanh bình minh/hoàng hôn: 1.0 · ban đêm: 0.6 · 11h–14h: 0.4 · còn lại 0.6 |
| **weather** | 0.10 | Gió < 15 km/h: 1.0 · 15–25: 0.6 · > 25: 0.2. Nhân mưa: < 1 mm/h ×1.0 · 1–5 ×0.8 · > 5 ×0.4. Mây 30–80%: +0.1 (tối đa 1.0) |
| **season** | 0.05 | Có loài cá người dùng chọn: tháng hiện tại ∈ `best_months` → 1.0, không → 0.4. Không chọn loài → bỏ thành phần này |

**Luật ghi đè an toàn (bắt buộc):**
- Có dông/sét (`weather_code` ∈ {95, 96, 99}) **hoặc** gió giật > 50 km/h → `S = min(S, 2.0)` + cảnh báo **đỏ**.
- Mưa > 20 mm/h → `S = min(S, 3.0)`.
- `cape ≥ 3000` **và** `precipitation_probability ≥ 50` → **không** khóa điểm, chỉ hiện cảnh báo **vàng** "Có thể có dông".
- ⚠ KHÔNG dùng `cape > 2000` làm điều kiện khóa: khảo sát P0-03 cho thấy CAPE ở Việt Nam thường > 2000 kể cả trời quang (Cần Thơ 06/11/2026: 2070–2860) → sẽ báo động giả hằng ngày.

**Giờ vàng:** các khoảng liên tục có `S ≥ 7.0`, gộp khoảng cách < 30 phút; hiện tối đa 3 khoảng có điểm cao nhất, kèm **lý do** (ví dụ "bình minh + nước ròng + solunar chính").

**Điểm ngày:** trung bình 4 giờ có điểm cao nhất trong ngày.

**Snapshot điều kiện cho nhật ký câu** (`catches.conditions`):

```json
{ "tide_state":"falling","tide_level_cm":180,"minutes_to_turn":75,"spring_neap":"spring",
  "lunar_day":15,"moon_phase":0.98,"solunar":"major",
  "pressure_hpa":1008,"pressure_trend_3h":-1.4,"wind_kmh":8,"rain_mm":0,"cloud":40,"temp_c":29,
  "score":8.2,"version":"fs-1" }
```

> File `docs/fishing-score.md` ghi lại mọi lần chỉnh trọng số, kèm `version` (`fs-1`, `fs-2`…).

### 9.7. Nội suy mực nước tại điểm bất kỳ (`point`)

1. Tìm 3 trạm gần nhất (`nearest_stations`).
2. Nếu 2 trạm gần nhất **cùng sông** và điểm nằm giữa chúng (theo `river_km` chiếu gần đúng) → nội suy tuyến tính theo `river_km`; độ trễ triều nội suy tương tự (`tide_lag_minutes` từ `stations.meta.tide_lag_min`).
3. Ngược lại → dùng trạm gần nhất (`method = nearest`).
4. `confidence`: `high` < 5 km cùng sông · `medium` 5–20 km · `low` > 20 km hoặc khác sông · `none` > 50 km.
5. Độ cao mặt đất: `saved_places.ground_elevation_cm` (nếu người dùng nhập) > Open-Meteo Elevation.
6. **Nguy cơ ngập** (chỉ khi cùng mốc cao độ — ⚠ mốc cao độ của mô hình độ cao và của trạm có thể khác nhau → ban đầu chỉ hiện **chênh lệch tương đối** và nhãn "tham khảo", không kết luận chắc chắn).

### 9.8. Đánh giá cảnh báo (`alerts-evaluate`) 🟡

`rule` (jsonb):

```json
{ "type": "level_above", "value_cm": 350 }
{ "type": "level_below", "value_cm": 50 }
{ "type": "alarm", "level": 1 }                // vượt báo động I/II/III
{ "type": "rise_rate", "cm_per_hour": 20 }
{ "type": "tide_extreme", "kind": "high", "before_minutes": 30 }   // xử lý bằng thông báo cục bộ trên máy
```

- **Hysteresis:** bắn khi vượt ngưỡng; chỉ "nạp lại" khi xuống dưới `ngưỡng − 5 cm` (hoặc lên trên `ngưỡng + 5 cm` với `level_below`).
- **Cooldown:** tối thiểu 3 giờ giữa 2 lần bắn cùng subscription.
- **Giờ yên lặng:** không bắn, trừ `alarm` cấp ≥ 2 và `rise_rate`.
- Gom thông báo: tối đa 1 push / thiết bị / 15 phút (gộp nội dung).

### 9.9. Làm mờ vị trí (`core/calc/geo/`)

`fuzz(lat, lon, radiusKm)`: dịch ngẫu nhiên (seed theo id bản ghi để ổn định) trong bán kính, rồi làm tròn 2 chữ số thập phân. Dùng khi chia sẻ ảnh/nhật ký ra ngoài.

---

## 10. App: điều hướng, màn hình, giao diện

### 10.1. Điều hướng (thanh dưới 5 tab)

| Tab | Route | Màn hình |
|---|---|---|
| 🗺 Bản đồ | `/map` | Bản đồ trạm, bấm điểm |
| ⭐ Theo dõi | `/watch` | Trạm & điểm yêu thích (thẻ tóm tắt) |
| 🎣 Câu cá | `/fishing` | Chỉ số, giờ vàng, nhật ký |
| 🔔 Cảnh báo | `/alerts` | Danh sách cảnh báo, lịch sử |
| ⚙ Thêm | `/more` | Lịch triều, cẩm nang, an toàn, cài đặt, giới thiệu, nguồn dữ liệu |

Route con:

```
/station/:id                    (tab: tong-quan | bieu-do | lich-trieu | lich-su | thong-tin)
/point?lat=&lon=
/tide-calendar/:stationId?month=YYYY-MM
/fishing/spot/:placeId
/catches, /catches/new, /catches/:id
/places, /places/:id
/species, /species/:id
/knots
/safety
/settings, /settings/data-sources, /about
/onboarding
```

### 10.2. Đặc tả màn hình

#### S01 — Onboarding (lần đầu)
- 3 trang: giới thiệu → chọn vai trò (câu cá / ven sông / nông nghiệp / ghe thuyền — chọn nhiều) → xin quyền vị trí (giải thích lý do, có nút "Để sau").
- Lưu lựa chọn → ảnh hưởng tab mặc định và thẻ hiển thị.

#### S02 — Bản đồ `/map`
- Bản đồ Vietmap, mặc định vùng nhìn theo vị trí (hoặc toàn VN nếu chưa cấp quyền).
- Marker trạm: chấm tròn màu theo trạng thái (xanh bình thường · vàng BĐ1 · cam BĐ2 · đỏ BĐ3 · xám mất dữ liệu > 6h) + mũi tên xu hướng. **Gom cụm** khi thu nhỏ.
- Chỉ tải trạm trong khung nhìn (`stations_in_bbox`), debounce 400 ms.
- Bấm marker → **bottom sheet** tóm tắt (tên, mực nước, xu hướng, đếm ngược triều) → "Xem chi tiết".
- **Nhấn giữ** điểm bất kỳ → thả ghim → bottom sheet `point` (S04 rút gọn).
- Nút: định vị, tìm kiếm (Vietmap qua `geocode`), lớp bản đồ (thường/vệ tinh 🟡), bộ lọc (chỉ trạm có triều / có cảnh báo).
- Trạng thái: đang tải, lỗi mạng (hiện dữ liệu cache + băng "Ngoại tuyến · cập nhật lúc HH:mm").

#### S03 — Chi tiết trạm `/station/:id`
- **Header:** tên trạm, sông, tỉnh, nguồn, "cập nhật X phút trước", nút ⭐, 🔔, chia sẻ.
- **Tab Tổng quan:**
  - Số lớn: mực nước (m, 2 chữ số), mũi tên + tốc độ cm/h, trạng thái (đang lên/xuống/đứng).
  - Thanh mức so với BĐ I/II/III, "còn X m tới BĐ I".
  - Thẻ triều (nếu `has_tide`): đỉnh/chân kế tiếp, đếm ngược trực tiếp (cập nhật mỗi phút), con nước hôm nay, ngày âm.
  - Biểu đồ mini 24h: thực đo (liền) + dự báo (đứt) + vạch "bây giờ".
  - Hôm nay: cao nhất/thấp nhất · cùng ngày năm trước 🟡 · kỷ lục.
  - Thời tiết 3 ngày (mưa, gió) · chỉ số câu cá hôm nay (link sang tab Câu cá).
- **Tab Biểu đồ:** chọn 24h / 3 ngày / 7 ngày / 30 ngày / 1 năm; phóng to bằng 2 ngón, kéo ngang; chạm hiện tooltip; vạch báo động; lớp dự báo triều; lớp mưa (cột) 🟡.
- **Tab Lịch triều:** danh sách theo ngày: các đỉnh/chân (giờ, cao độ), nhãn con nước, ngày âm, pha trăng; chọn tháng.
- **Tab Lịch sử** 🟡: cao nhất mỗi năm, các đợt lũ lớn.
- **Tab Thông tin:** tọa độ, mốc cao độ, ngưỡng báo động, nguồn & giấy phép, độ tin cậy dự báo triều (`tide_confidence`, rmse).

#### S04 — Chi tiết điểm `/point`
- Địa danh, tọa độ, nút sao chép tọa độ, mở chỉ đường (Vietmap/Google Maps qua `url_launcher`).
- Trạm gần nhất (3 trạm, khoảng cách, mực nước, xu hướng).
- Khối **Ước tính** (nền sọc, nhãn "ước tính · độ tin cậy: trung bình"): mực nước, giờ triều đã hiệu chỉnh độ trễ.
- Độ cao mặt đất + chênh lệch tham khảo.
- Thời tiết, chỉ số câu cá tại điểm.
- Nút: ⭐ Lưu điểm (chọn loại: nhà, ruộng, điểm câu, bến…), 🔔 Theo dõi.

#### S05 — Theo dõi `/watch`
- Danh sách thẻ trạm & điểm đã lưu: mực nước, xu hướng, đếm ngược triều, chỉ số câu cá (nếu điểm câu). Kéo để sắp xếp. Kéo xuống để làm mới.
- Trống → gợi ý "Thêm trạm gần bạn".

#### S06 — Câu cá `/fishing`
- Chọn điểm câu (điểm đã lưu / vị trí hiện tại / trạm).
- **Thẻ hôm nay:** điểm ngày (to), con nước, pha trăng, nhãn "tham khảo".
- **Giờ vàng:** tối đa 3 khoảng + lý do.
- **Biểu đồ 24h:** cột chỉ số theo giờ (màu theo mức) + đường mực nước chồng + biểu tượng mặt trời/trăng mọc lặn + khung solunar.
- **Điều kiện:** nhiệt độ, gió (hướng), mây, áp suất + xu hướng 3h, mưa.
- **7 ngày tới:** dải điểm mỗi ngày (chạm để xem ngày đó).
- Lối tắt: 📓 Ghi nhật ký · 📍 Điểm câu · 🐟 Cẩm nang loài · 🪢 Nút buộc · 🛟 An toàn.
- Cảnh báo dông/sét hiện băng đỏ trên cùng.

#### S07 — Nhật ký câu `/catches` 🟡
- Danh sách theo ngày, ảnh nhỏ, loài, cân nặng, điểm câu (tên, không hiện tọa độ).
- Thêm mới: ảnh (tối đa 3, nén ≤ 1600px, JPEG 80%, **xóa EXIF**), loài (tìm trong cẩm nang hoặc tự nhập), số lượng, cân nặng, chiều dài, mồi, kiểu câu, câu thả?, ghi chú. **Điều kiện tự động** chụp tại `caught_at`.
- Lưu **cục bộ trước** (Drift), đồng bộ lên Supabase khi có mạng & đã đăng nhập.
- **Thống kê:** theo loài, theo điểm, theo con nước/pha trăng/giờ trong ngày/áp suất ("Bạn câu được nhiều nhất khi…").

#### S08 — Cảnh báo `/alerts`
- 🟢 Thông báo cục bộ: nhắc trước đỉnh/chân triều X phút cho trạm đã chọn; nhắc giờ vàng câu cá.
- 🟡 Cảnh báo máy chủ: tạo quy tắc (9.8), bật/tắt, giờ yên lặng, lịch sử đã gửi.

#### S09 — Lịch triều tháng `/tide-calendar/:stationId`
- Lưới tháng: mỗi ô có ngày dương, ngày âm, biểu tượng pha trăng, chấm màu con nước (rong/kém), biên độ.
- Chạm ngày → danh sách đỉnh/chân + biểu đồ ngày.

#### S10 — Cẩm nang loài cá `/species` 🟡
- Danh sách + tìm kiếm + lọc (sông/kênh/hồ/biển, vùng miền).
- Chi tiết: ảnh, tên gọi địa phương, mùa tốt, giờ tốt, con nước tốt, mồi, kiểu câu, mô tả.
- Dữ liệu offline trong `assets/data/species.json` (khởi đầu ~30 loài phổ biến: cá lóc, rô đồng, trê, tra, basa, chép, rô phi, mè, trắm, lăng, chạch, bống tượng, kèo, chẽm, hồng, mú, đối, sơn, thác lác, he, mè vinh, lòng tong, chốt, ngát, dứa, bông lau, chim, nhái, tai tượng, sặc…). ⚠ Nội dung cần người có kinh nghiệm duyệt.

#### S11 — Nút buộc `/knots` 🟡
- 10–15 nút thông dụng (Palomar, Improved Clinch, Uni, FG, Albright, Snell, Double Uni, Rapala loop…): ảnh từng bước (SVG/PNG), mô tả, dùng cho dây gì. Offline.

#### S12 — An toàn `/safety`
- 🟢 Băng cảnh báo dông/sét/gió mạnh tại vị trí (từ `weather`).
- 🟡 **Chuyến đi an toàn:** chọn giờ về + số người thân; quá giờ chưa bấm "Đã về" → thông báo nhắc → sau 15 phút mở SMS soạn sẵn tọa độ (người dùng bấm gửi — không tự gửi ngầm).
- 🟡 **"Nước sắp ngập bãi":** người dùng đặt "độ cao chỗ đứng" (so với mực nước lúc bắt đầu) → app tính thời điểm nước dâng tới → thông báo trước 45 & 15 phút.
- 🟡 Nút SOS: gọi 112/114, chia sẻ vị trí.

#### S13 — Cài đặt `/settings`
- Đơn vị (m/cm), giao diện (sáng/tối/theo máy), cỡ chữ, vai trò, giờ yên lặng, trạm mặc định, quản lý dữ liệu offline (dung lượng, xóa cache), đăng nhập/đăng xuất 🟡, xóa tài khoản 🟡, **nguồn dữ liệu & ghi nguồn**, giới thiệu, phiên bản.

### 10.3. Hệ thống giao diện

**Màu (tokens — định nghĩa trong `core/theme/colors.dart`, có bản sáng & tối):**

| Token | Sáng | Tối | Dùng cho |
|---|---|---|---|
| `primary` | `#0B6E99` (xanh sông) | `#4FB3E0` | Nút chính, thanh tab |
| `water` | `#1E88E5` | `#64B5F6` | Đường thực đo |
| `tidePred` | `#7E57C2` | `#B39DDB` | Đường dự báo triều (nét đứt) |
| `ok` | `#2E7D32` | `#81C784` | Bình thường |
| `alarm1` | `#F9A825` | `#FFD54F` | BĐ I |
| `alarm2` | `#EF6C00` | `#FFB74D` | BĐ II |
| `alarm3` | `#C62828` | `#E57373` | BĐ III / nguy hiểm |
| `stale` | `#9E9E9E` | `#757575` | Mất dữ liệu |
| `fishHigh` | `#00897B` | `#4DB6AC` | Chỉ số câu cá cao |

> Kiểm tra tương phản ≥ 4.5:1 cho chữ. Không chỉ dùng màu để truyền tải trạng thái — luôn kèm chữ/biểu tượng.

**Chữ:** font hệ thống (Roboto / SF) hỗ trợ tiếng Việt đầy đủ. Số liệu lớn: 48–56sp, đậm, `tabularFigures`. Hỗ trợ `textScaler` tới 1.6× không vỡ bố cục.

**Khoảng cách:** bội số 4 (4, 8, 12, 16, 24, 32). Vùng chạm tối thiểu 48×48 dp.

**Định dạng:** số theo kiểu VN (`2,85 m`), giờ 24h (`14:40`), ngày `T5, 06/11` + `(16/9 ÂL)`.

### 10.4. Lưu trữ cục bộ (Drift)

| Bảng | Nội dung | Làm mới |
|---|---|---|
| `stations_cache` | Toàn bộ trạm (nhẹ) | 24h hoặc kéo làm mới |
| `latest_cache` | Mực nước mới nhất | 5 phút khi mở app |
| `series_cache` | Chuỗi đo theo trạm/khoảng | 15 phút |
| `tide_years` | File triều đã giải nén (blob) | Theo `model_version` |
| `weather_cache` | Theo cell | 60 phút |
| `favorites` | Trạm/điểm theo dõi (cả khi chưa đăng nhập) | Cục bộ |
| `catches_local`, `places_local` | Dữ liệu người dùng + cờ `sync_status` | Đồng bộ 🟡 |
| `settings` | Cài đặt | Cục bộ |

---

## 11. Danh mục tính năng đầy đủ

| Mã | Tính năng | Ưu tiên | Màn hình |
|---|---|---|---|
| **Mực nước & triều** ||||
| F-WL-01 | Mực nước hiện tại, xu hướng, tốc độ | 🟢 | S03, S05 |
| F-WL-02 | Thanh báo động I/II/III, "còn X tới BĐ" | 🟢 | S03 |
| F-WL-03 | Biểu đồ 24h → 1 năm, zoom, tooltip | 🟢 (24h–30 ngày) / 🟡 (1 năm) | S03 |
| F-WL-04 | So sánh cùng ngày năm trước, kỷ lục | 🟡 | S03 |
| F-WL-05 | Độ mặn (trạm có dữ liệu) | 🔵 | S03 |
| F-TIDE-01 | Dự báo triều theo trạm (offline) | 🟢 | S03 |
| F-TIDE-02 | Đếm ngược đỉnh/chân, trạng thái lên/xuống/đứng | 🟢 | S03, S05 |
| F-TIDE-03 | Lịch triều theo ngày | 🟢 | S03 |
| F-TIDE-04 | Lịch triều tháng + âm lịch + pha trăng | 🟢 | S09 |
| F-TIDE-05 | Con nước (rong/kém/nhảy) | 🟢 | S03, S06, S09 |
| F-TIDE-06 | Tốc độ dòng chảy ước tính | 🟡 | S03 |
| F-TIDE-07 | Hiệu chỉnh dự báo theo thực đo | 🟡 | S03 |
| F-TIDE-08 | Dự báo kết hợp triều + mưa + lũ 7 ngày | 🔵 | S03 |
| F-TIDE-09 | Dòng thời gian theo giờ (thực đo/dự báo, chạm xem chi tiết giờ) | 🟢 | S03 tab Theo giờ, S04, S06 |
| **Bản đồ** ||||
| F-MAP-01 | Bản đồ Vietmap, marker trạm màu theo trạng thái, gom cụm | 🟢 | S02 |
| F-MAP-02 | Bottom sheet trạm | 🟢 | S02 |
| F-MAP-03 | Nhấn giữ điểm bất kỳ → ước tính | 🟢 | S02, S04 |
| F-MAP-04 | Định vị, tìm kiếm địa danh | 🟢 | S02 |
| F-MAP-05 | Lớp vệ tinh | 🟡 | S02 |
| F-MAP-06 | Thanh trượt thời gian (mực nước toàn vùng) | 🟡 | S02 |
| F-MAP-07 | Lớp mưa | 🟡 | S02 |
| F-MAP-08 | Lớp nguy cơ ngập | 🔵 | S02 |
| F-MAP-09 | Đo khoảng cách, vẽ vùng | 🔵 | S02 |
| **Câu cá** ||||
| F-FISH-01 | Chỉ số câu cá theo giờ & ngày | 🟢 | S06 |
| F-FISH-02 | Giờ vàng + lý do | 🟢 | S06 |
| F-FISH-03 | Solunar, mặt trời/trăng mọc lặn, độ sáng trăng | 🟢 | S06 |
| F-FISH-04 | Điều kiện: áp suất & xu hướng, gió, mưa, mây | 🟢 | S06 |
| F-FISH-05 | Dự báo 7 ngày | 🟢 | S06 |
| F-FISH-06 | Nhật ký câu + điều kiện tự động | 🟡 | S07 |
| F-FISH-07 | Thống kê cá nhân | 🟡 | S07 |
| F-FISH-08 | Điểm câu riêng tư | 🟡 | S04, S06 |
| F-FISH-09 | Thông báo giờ vàng | 🟡 | S08 |
| F-FISH-10 | Cẩm nang loài cá (offline) | 🟡 | S10 |
| F-FISH-11 | Nút buộc câu | 🟡 | S11 |
| F-FISH-12 | Danh sách đồ nghề theo kiểu câu | 🟡 | S06 |
| F-FISH-13 | Điểm câu cộng đồng, hồ câu dịch vụ | ⚪ | — |
| F-FISH-14 | Nhận diện cá qua ảnh (TFLite) | 🔵 | S07 |
| F-FISH-15 | Quy định khai thác | ⚪ | — |
| F-FISH-16 | Nhóm câu, giải câu, xếp hạng | ⚪ | — |
| F-FISH-17 | Câu biển: sóng, nhiệt độ mặt nước (Open-Meteo Marine) | 🟡 | S06 |
| **An toàn** ||||
| F-SAFE-01 | Cảnh báo dông/sét/gió mạnh | 🟢 | S06, S12 |
| F-SAFE-02 | "Nước sắp ngập bãi" | 🟡 | S12 |
| F-SAFE-03 | Cảnh báo nước lên nhanh bất thường | 🟡 | S08 |
| F-SAFE-04 | Chuyến đi an toàn | 🟡 | S12 |
| F-SAFE-05 | SOS gọi 112/114 + chia sẻ vị trí | 🟡 | S12 |
| F-SAFE-06 | Thông tin xả lũ hồ chứa | 🔵 | — |
| **Cảnh báo** ||||
| F-ALERT-01 | Nhắc đỉnh/chân triều (cục bộ) | 🟢 | S08 |
| F-ALERT-02 | Cảnh báo đẩy theo ngưỡng/báo động | 🟡 | S08 |
| F-ALERT-03 | Giờ yên lặng | 🟡 | S08 |
| F-ALERT-04 | Tóm tắt buổi sáng | 🟡 | — |
| **Nông nghiệp / ghe thuyền** ||||
| F-AGRI-01 | Gợi ý giờ lấy/xả nước theo triều | 🟡 | S03 |
| F-AGRI-02 | Cảnh báo mặn | 🔵 | — |
| F-BOAT-01 | Tĩnh không qua cầu theo mực nước | 🔵 | — |
| **Tiện ích chung** ||||
| F-UX-01 | Sáng/tối, tiếng Việt, cỡ chữ lớn | 🟢 | Toàn app |
| F-UX-02 | Offline-first | 🟢 | Toàn app |
| F-UX-03 | Onboarding chọn vai trò | 🟢 | S01 |
| F-UX-04 | Theo dõi trạm/điểm yêu thích | 🟢 | S05 |
| F-UX-05 | Widget màn hình chính | 🟡 | — |
| F-UX-06 | Chia sẻ thẻ ảnh (Zalo/Facebook) | 🟡 | S03, S06 |
| F-UX-07 | Đăng nhập & đồng bộ | 🟡 | S13 |
| F-UX-08 | Đọc to bằng giọng nói, tiếng Anh | 🔵 | — |
| F-UX-09 | Trang nguồn dữ liệu & ghi nguồn | 🟢 | S13 |
| **Cộng đồng** ||||
| F-COMM-01 → 03 | Báo cáo ngập kèm ảnh, bảng tin, kiểm duyệt | ⚪ | — |
| **Quản trị** ||||
| F-ADM-01 | Theo dõi tình trạng nguồn dữ liệu | 🟡 | Admin web |
| F-ADM-02 | Quản lý trạm, ngưỡng | 🟡 | Admin web |

---

## 12. Bảo mật

Ngay cả bản dev cũng làm đúng từ đầu (sửa sau rất tốn công).

### 12.1. App
- [ ] Chỉ HTTPS. Android: `android:usesCleartextTraffic="false"`; iOS: ATS mặc định.
- [ ] Không có service_role key / khóa bí mật trong app (kiểm tra bằng `grep` trước mỗi commit — xem 12.4).
- [ ] Cấu hình qua `--dart-define-from-file`, file env không commit.
- [ ] Token lưu bằng `flutter_secure_storage` (supabase_flutter: cấu hình `localStorage` tùy chỉnh dùng secure storage).
- [ ] Build release: `--obfuscate --split-debug-info`.
- [ ] Quyền tối thiểu: `ACCESS_COARSE_LOCATION` + `ACCESS_FINE_LOCATION` (khi dùng), `POST_NOTIFICATIONS`, `INTERNET`, `CAMERA`/ảnh (chỉ khi thêm nhật ký). **Không** xin vị trí nền.
- [ ] Ảnh: mã hóa lại để xóa EXIF trước khi tải lên.
- [ ] Không log dữ liệu cá nhân / tọa độ chính xác vào Crashlytics.
- [ ] Deep link: validate tham số (`lat/lon` trong biên, `id` đúng định dạng).

### 12.2. Backend
- [ ] RLS bật trên **mọi** bảng (test bằng anon key: không đọc được dữ liệu người khác, không ghi được bảng công khai).
- [ ] Edge Functions: validate input bằng zod; giới hạn tốc độ; timeout; không trả stack trace.
- [ ] Function cron xác thực bằng `x-cron-secret` (so sánh thời gian hằng).
- [ ] App Check: dev = theo dõi; trước phát hành = bắt buộc.
- [ ] Secrets trong `supabase secrets` / Vault — không trong code, không trong migration.
- [ ] Parse dữ liệu nguồn ngoài như **dữ liệu không tin cậy**: giới hạn kích thước phản hồi (≤ 5 MB), kiểm tra kiểu, loại giá trị bất thường.
- [ ] Storage: bucket ảnh private, giới hạn kích thước & MIME, đường dẫn theo `user_id`.
- [ ] Auth: rate limit mặc định; bật bảo vệ mật khẩu lộ (nếu dùng mật khẩu).

### 12.3. Quy trình
- [ ] GitHub: 2FA, Dependabot, Secret scanning + Push protection.
- [ ] Review mọi migration RLS trước khi `db push`.
- [ ] Trước phát hành: tự kiểm theo **OWASP MASVS** (L1) ⚪.

### 12.4. Lệnh kiểm tra nhanh trước commit

```powershell
# Không được thấy kết quả nào:
git grep -n -i -E "service_role|BEGIN PRIVATE KEY|sk_live|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJzZXJ2aWNlX3JvbGUi"
```

---

## 13. Kiểm thử

| Loại | Phạm vi | Công cụ | Bắt buộc ở |
|---|---|---|---|
| Unit (Dart) | `core/calc/*` — tide, lunar, astro, solunar, fishing score, geo | `flutter test` | P1 |
| Unit (Deno) | Parser từng nguồn (dùng file mẫu đã lưu trong `__fixtures__`), validate, rule cảnh báo | `deno test` | P1 |
| Widget test | Màn hình chính: trạng thái tải/lỗi/rỗng | `flutter test` | P1 |
| Kiểm chứng triều | So với bảng thủy triều chính thức (9.1) | `tools/tide/validate.py` | P1 |
| RLS test | Script SQL/TS dùng anon key thử đọc/ghi trái phép | `deno test` | P1 |
| Integration | App ↔ Supabase local | Chạy tay theo checklist | P1 |
| Hiệu năng | Mở app < 2s, cuộn bản đồ mượt trên máy tầm thấp | DevTools | P2 |
| Beta | 20–50 người dùng thật (dân câu, người ven sông) | Firebase App Distribution / Play internal | P2 |

**Bộ dữ liệu chuẩn cho test (`app/test/fixtures/`):**
- `tide_vungtau_2027.json` — file triều mẫu.
- `lunar_tet_2020_2030.json` — ngày Tết dương ↔ âm.
- `astro_cantho_2026-11.json` — mặt trời/trăng mọc lặn tham chiếu.
- `weather_sample.json` — phản hồi Open-Meteo mẫu.

---

## 14. ROADMAP chi tiết

> Làm **tuần tự** theo mã. Mỗi task có: mô tả → phụ thuộc → **Tiêu chí xong (DoD)**.
> 🚧 **Mục tiêu hiện tại: Giai đoạn V0 = app Android dùng thử, không máy chủ, miễn phí (mục 3.0).**

### Giai đoạn V0 — App dùng thử không máy chủ 🚧 (làm trước Giai đoạn 1)

V0 **dùng lại** các task bên dưới, làm theo đúng thứ tự này; task nào ghi "điều chỉnh" thì làm theo phần điều chỉnh thay cho mô tả gốc.

| Thứ tự | Task | Điều chỉnh cho V0 |
|---|---|---|
| 1 | P0-02 Môi trường | Chỉ cần: Flutter, Android Studio/SDK, Python venv `tools/tide`. **Không** cần Docker, Supabase CLI, Deno, Firebase |
| 2 | P0-05 Thử nghiệm thủy triều | Thêm: xuất dự báo 10 phút năm nay + năm sau thành `app/assets/tide/<trạm>.json.gz` (định dạng 8.5) |
| 3 | P1-01 → P1-04 | Bỏ `env` Supabase; `env/dev.json` chỉ có khóa Vietmap |
| 4 | P1-13 → P1-17 | Giữ nguyên |
| 5 | **V0-05 · Repository gọi thẳng nguồn** (thay P1-05 → P1-12, P1-18, P1-19) | `ioc_client` (parser có test bằng fixture sẵn có), `open_meteo_client` (forecast + marine), `tide_asset_repository`, cache Drift + cờ `stale`; validate mọi phản hồi (kiểu, phạm vi, kích thước). DoD: unit test với fixture; tắt mạng vẫn trả cache |
| 6 | **V0-06 · `calc/skill`** | Sai số 30 ngày trên máy (độ cao cm, giờ đỉnh/chân phút). DoD: test với fixture IOC + asset |
| 7 | P1-20 → P1-28 | P1-24 gọi Open-Meteo trực tiếp thay cho API `point`; ngoài trạm thì nhãn "ước tính" |
| 8 | P1-29, P1-31 | Giữ nguyên (bỏ phần kiểm tra RLS) |
| 9 | **V0-08 · Bản dùng thử** (thay P1-33) | `flutter build apk --release` (ký bằng khóa dev, không commit) → gửi file/Firebase App Distribution. DoD: 3 người cài và dùng được |
| 10 | **V0-09 · Bản tin KTTV qua GitHub Actions** (tùy chọn, sau V0-08) | Python `tools/nchmf` chạy 11:00 VN → `data/kttv/latest.json` trên GitHub Pages → app đọc. DoD: chạy 3 ngày liên tiếp không lỗi |

Hoãn tới khi cần máy chủ: P1-05 → P1-12, P1-18, P1-30, P1-32 (phần Deno), toàn bộ Giai đoạn 2 phần cần Supabase.

**Trạng thái V0 (2026-11-09, cập nhật chiều):**
- **Đã có:**
  - App chạy được trên web, mã Android đã viết nhưng chưa build lần nào.
  - Bản đồ OpenFreeMap (P1-20). Mở app là tự tìm vị trí của người dùng.
  - **Chạm điểm bất kỳ** trên bản đồ (P1-24): xem tọa độ, mực nước (mô hình biển tại điểm hoặc trạm sông KTTV gần nhất), thời tiết, giờ mặt trời và các trạm gần.
  - **38 trạm**: 2 trạm có máy đo IOC, 14 điểm mô hình biển, 11 trạm sông KTTV có đường mực nước từng giờ ước tính, 11 trạm sông có triều chỉ có mức cao nhất/thấp nhất. Chi tiết trong docs/river-model.md.
  - Bộ đọc bản tin KTTV và workflow GitHub Actions/Pages (V0-09) đã viết, **chưa chạy trên GitHub** vì chưa có kho mã.
  - 223 test Flutter, 9 test cho tools/nchmf, 11 test cho tools/tide, đều pass.
- **Chưa xong:**
  - P0-02: Android SDK, chủ dự án tự cài.
  - P1-14: chưa đối chiếu giờ mặt trời/mặt trăng với timeanddate.
  - S09 lịch tháng, S01 onboarding, P1-28 thông báo cục bộ, V0-08 build APK.
  - Tìm địa danh: chưa có dịch vụ miễn phí phù hợp.
  - Tọa độ các trạm KTTV mới là gần đúng (P0-04).

### Giai đoạn 0 — Chuẩn bị (≈ 1–2 tuần)

- [ ] **P0-01 · Khởi tạo repo**
  Tạo cấu trúc thư mục mục 4, `.gitignore` (TOOLS.md 11.4), `README.md`, `CLAUDE.md`, `FEATURES.md`, `docs/rules/*`, `.vscode/settings.json`, `.editorconfig`.
  ✅ Đã tạo file (2026-11-06). Còn lại: `git init` + commit đầu + push lên GitHub private (bạn tự làm hoặc yêu cầu AI).
  DoD: `git status` sạch, đã push lên GitHub private.

- [ ] **P0-02 · Môi trường**
  Hoàn tất TOOLS.md mục 2 → 9, 10.1 → 10.6.
  DoD: checklist TOOLS.md mục 16 phần "Phần mềm" đều ✅.

- [x] **P0-03 · Khảo sát nguồn dữ liệu** ⭐ quan trọng nhất — ✅ 2026-11-06, kết quả: [docs/data-sources.md](docs/data-sources.md). Còn mở: đề nghị cấp dữ liệu MRC/KTTV/vndms (việc của chủ dự án, mục 4 trong data-sources).
  Với mỗi nguồn ở 6.1: mở trang, DevTools → Network, tìm endpoint JSON/HTML; ghi lại URL, tham số, định dạng, múi giờ, đơn vị, mốc cao độ, tần suất cập nhật, có cần header/cookie không, điều khoản sử dụng. **Lưu 2–3 phản hồi mẫu** vào `supabase/functions/ingest-<source>/__fixtures__/`.
  DoD: `docs/data-sources.md` có bảng đầy đủ cho `vndms`, `mrc`, `nchmf`, `thuyloi`, Open-Meteo; xác định nguồn **chính** cho từng vùng.

- [ ] **P0-04 · Danh mục trạm**
  Từ P0-03, lập `docs/stations-catalog.md` + `supabase/seed/stations.csv`: id, tên, sông, tỉnh, vùng, tọa độ, nguồn, mốc cao độ, has_tide, BĐ I/II/III. Mục tiêu đợt đầu: **~40 trạm từ nguồn hợp lệ hiện có** (IOC 2 + bản tin triều ~12 + bản tin thủy văn ~25 — xem data-sources mục 5). Tọa độ & ngưỡng báo động tra từ tài liệu công khai, ghi nguồn từng dòng.
  DoD: CSV hợp lệ, kiểm tra vị trí trên bản đồ (QGIS hoặc geojson.io) đúng trên sông.

- [x] **P0-05 · Thử nghiệm thủy triều** — ✅ 2026-11-09, báo cáo: [docs/tide-validation.md](docs/tide-validation.md) (Vũng Tàu RMSE 10,4 cm · đỉnh/chân ±9,5 phút; Quy Nhơn 6,5 cm · ±14 phút; file dự báo 2026–2027 trong `app/assets/tide/`)
  `tools/tide`: tải chuỗi đo IOC **12–24 tháng** cho Vũng Tàu (`vung`, cảm biến `ra2`) và Quy Nhơn (`quin`, `rad`), mỗi yêu cầu ≤ 30 ngày; `fit_constituents.py` + `predict.py`; `validate.py` so đỉnh/chân dự báo với bản tin `nchmf_tide` (fixture 06–15/11/2026) và với 10% dữ liệu IOC giữ lại. So thêm Open-Meteo Marine `sea_level_height_msl` để quyết định có dùng làm dự phòng không.
  DoD: báo cáo sai lệch giờ & độ cao; đạt ngưỡng 9.1 hoặc ghi rõ lý do.

- [ ] **P0-06 · Thử Vietmap**
  Tạo app Flutter tạm (hoặc làm luôn ở P1-01) hiển thị bản đồ Vietmap với khóa dev, 1 marker.
  DoD: bản đồ hiển thị trên máy ảo; ghi lại tên gói, cách khai báo khóa, style URL vào `docs/`.

- [ ] **P0-07 · Thiết kế giao diện (wireframe)**
  Phác 6 màn hình chính: S02, S03, S04, S05, S06, S09 (Figma/Pencil/giấy).
  DoD: ảnh wireframe lưu trong `docs/design/`.

### Giai đoạn 1 — BẢN DEV / MVP (≈ 6–8 tuần) 🚧

**1A. Nền tảng app**

- [ ] **P1-01 · Tạo dự án Flutter**
  `flutter create --org vn.rivertide --project-name rivertide --platforms android,ios app` · thêm gói mục 5.1 · `analysis_options.yaml` · `l10n.yaml` + `app_vi.arb` · `core/config/env.dart` đọc dart-define · `.vscode/launch.json` với `--dart-define-from-file=env/dev.json`.
  DoD: app trắng chạy trên máy ảo; `flutter analyze` sạch.

- [ ] **P1-02 · Theme & khung điều hướng**
  `core/theme` (màu 10.3, sáng/tối, chữ), `router.dart` (go_router + `StatefulShellRoute` 5 tab), widget chung `LoadingView`, `ErrorView`, `EmptyView`, `StaleBanner`.
  DoD: chuyển 5 tab được; đổi sáng/tối theo hệ thống.

- [ ] **P1-03 · Drift database**
  Các bảng 10.4, DAO cơ bản, migration version 1.
  DoD: unit test ghi/đọc mỗi bảng.

- [ ] **P1-04 · Cấu hình Android**
  `minSdk` phù hợp với các gói, quyền mục 12.1, tắt cleartext, cấu hình đọc `key.properties` (nếu có, không bắt buộc ở dev), tên app, icon tạm.
  DoD: build `flutter build apk --debug` thành công.

**1B. Backend**

- [ ] **P1-05 · Supabase local + migrations**
  `supabase init`; migrations `0001`–`0005` (mục 7); `seed.sql` (sources, rivers, species mẫu) + nhập `stations.csv` (`tools/scripts/import_stations.py` hoặc `\copy`).
  DoD: `supabase db reset` chạy sạch; `select count(*) from stations` ≥ 50; test RLS (anon không ghi được `stations`).

- [ ] **P1-06 · Edge Function `_shared` + `health`**
  cors, errors, supabase client, zod, auth (JWT + App Check tùy chọn), log.
  DoD: `supabase functions serve` → `curl /health` trả `ok:true`; `deno test` pass.

- [ ] **P1-07 · Edge Function `ingest-ioc`**
  Parser thuần (test bằng `supabase/functions/ingest-ioc/__fixtures__`) + fetch 2 giờ gần nhất + QC (chọn cảm biến chính `ra2`/`rad`, so chéo cảm biến phụ, loại nhảy > `max_jump_cm`) + chuẩn hóa m → cm + gộp 5 phút + upsert + `source_runs`.
  DoD: chạy tay → có dữ liệu Vũng Tàu & Quy Nhơn trong `observations`; test parser/QC pass; chạy lại không tạo trùng.

- [ ] **P1-08 · Python `tools/nchmf` — ingest bản tin KTTV**
  `find_latest.py` (tìm bài mới trên nchmf) · `parse_tvhn.py` & `parse_tide.py` (`pdfplumber`, test bằng `tools/nchmf/fixtures/*.pdf`) · bảng ánh xạ tên trạm → `station_id` · `upload.py` (upsert `observations`, `tide_extremes`, bảng dự báo) · workflow `.github/workflows/nchmf.yml` chạy 11:00 VN.
  Thêm bảng `forecasts (station_id, issued_at, valid_at, level_cm, kind)` bằng migration mới.
  DoD: parse đúng 100% trạm trong 2 fixture (so tay với PDF); chạy thật 3 ngày liên tiếp không lỗi.

- [ ] **P1-09 · Cron**
  Migration `0006_cron.sql` + Vault secrets; job ingest, aggregate-hourly, cleanup.
  DoD: sau 1 giờ chạy local (hoặc trên project dev cloud), `source_runs` có ≥ 4 lần `ok` mỗi nguồn.

- [ ] **P1-10 · Deploy lên Supabase dev (cloud)**
  `supabase link` → `db push` → `functions deploy` → `secrets set` → cron chạy trên cloud.
  DoD: dữ liệu tự cập nhật trên cloud mỗi 15 phút, theo dõi 24h không lỗi.

- [ ] **P1-11 · Edge Function `weather`**
  Proxy Open-Meteo (8.4), cache `weather_cache` theo geohash5.
  DoD: gọi 2 lần liên tiếp → lần 2 lấy từ cache; test pass.

- [ ] **P1-12 · Edge Function `point` + `geocode`**
  Theo 8.3 & 9.7; `geocode` proxy Vietmap (search + reverse).
  DoD: gọi với tọa độ ở Cần Thơ, Hà Nội, Đà Nẵng trả đúng trạm gần nhất; ngoài biên → 400.

**1C. Thuật toán (Dart thuần, test trước)**

- [x] **P1-13 · `calc/lunar`** ✅ 2026-11-09 (Tết 2030 = 02/02 theo UTC+7, khác lịch TQ 03/02 — ⚠ đối chiếu lịch chính thức) — âm lịch (9.2). DoD: test Tết 2020–2030 pass.
- [ ] **P1-14 · `calc/astro`** — mặt trời, mặt trăng, pha, transit (9.4). DoD: sai số < 5 phút so với fixtures.
- [x] **P1-15 · `calc/tide`** ✅ 2026-11-09 — nội suy, tốc độ, trạng thái, đỉnh/chân, đếm ngược, rong/kém (9.1, 9.3). DoD: test với file mẫu; đỉnh/chân trùng `extremes` ±10 phút.
- [x] **P1-16 · `calc/fishing`** ✅ 2026-11-09 — solunar (9.5) + chỉ số câu cá + giờ vàng + luật an toàn (9.6). DoD: test các ca biên (dông → ≤ 2.0; không triều; không có loài).
- [x] **P1-17 · `calc/geo`** ✅ 2026-11-09 — haversine, geohash, fuzz. DoD: test pass.

**1D. Pipeline thủy triều**

- [ ] **P1-18 · Tide build tự động**
  Hoàn thiện `tools/tide/*` → sinh file 8.5 cho các trạm `has_tide` có đủ dữ liệu → `upload.py` lên Storage bucket `tide` + `tide_files` + `tide_extremes`. Workflow `.github/workflows/tide-build.yml` (chạy tay + hàng tháng).
  DoD: ≥ 5 trạm có file triều năm hiện tại + năm sau; app tải được bằng URL public.

**1E. Tính năng app**

- [ ] **P1-19 · Repository & providers dữ liệu**
  `stations_repository` (cache 24h), `observations_repository` (latest + series), `tide_repository` (tải & lưu file năm), `weather_repository`, `point_repository`. Chiến lược: trả cache ngay → làm mới nền → báo lỗi mềm.
  DoD: unit test với mock; hoạt động khi tắt mạng (trả cache + cờ `stale`).

- [ ] **P1-20 · S02 Bản đồ** (F-MAP-01 → 04) — *V0 (09/11/2026): đã có bản đồ OpenFreeMap, chấm màu + mũi tên, gom cụm, sheet trạm, tìm trạm không dấu, định vị, bộ lọc, chú giải. Còn thiếu: nhấn giữ → ghim (thuộc P1-24), tìm địa danh (chưa có dịch vụ miễn phí phù hợp), kiểm tra trên máy Android.*
  Marker màu, gom cụm, tải theo bbox, bottom sheet trạm, nhấn giữ → ghim, định vị, tìm kiếm.
  DoD: chạy mượt với ≥ 50 trạm; offline hiện cache + băng ngoại tuyến.

- [ ] **P1-21 · S03 Chi tiết trạm — Tổng quan** (F-WL-01, 02, F-TIDE-02, 05)
  DoD: đếm ngược cập nhật mỗi phút; trạm không triều ẩn thẻ triều.

- [ ] **P1-22 · S03 — Biểu đồ** (F-WL-03: 24h, 3 ngày, 7 ngày, 30 ngày)
  `fl_chart`: thực đo + dự báo + vạch báo động + vạch "bây giờ" + tooltip + zoom/kéo.
  DoD: mượt trên máy ảo; chuyển khoảng thời gian < 1s khi đã cache.

- [ ] **P1-22b · S03 — Tab Theo giờ** (F-TIDE-09)
  Danh sách giờ −6 → +72 giờ, dòng đỉnh/chân chèn đúng phút, vạch Bây giờ, đồng bộ chạm biểu đồ ↔ danh sách, khung chi tiết giờ.
  DoD: đạt AC-TIDE09-1 → 5.

- [ ] **P1-23 · S03 — Lịch triều & Thông tin** (F-TIDE-03, F-UX-09)
  DoD: hiện đúng 7 ngày tới; tab thông tin có nguồn & độ tin cậy.

- [ ] **P1-24 · S04 Chi tiết điểm** (F-MAP-03) — *V0 (09/11/2026): chạm hoặc nhấn giữ bất kỳ đâu trên bản đồ → tọa độ (sao chép được), mực nước tại điểm (mô hình biển hoặc trạm sông gần nhất, ghi rõ khoảng cách), thời tiết, giờ mặt trời, 3 trạm gần nhất, xem chi tiết theo giờ, ⭐ lưu điểm. Còn thiếu: tên địa danh, chỉ đường.*
  DoD: khối ước tính có nhãn & độ tin cậy; lưu điểm vào `favorites` cục bộ.

- [ ] **P1-25 · S05 Theo dõi** (F-UX-04)
  DoD: thêm/xóa/sắp xếp; kéo làm mới; offline vẫn hiện.

- [ ] **P1-26 · S06 Câu cá** (F-FISH-01 → 05, F-SAFE-01)
  DoD: chọn điểm → điểm ngày, giờ vàng có lý do, biểu đồ 24h, 7 ngày, băng dông/sét.

- [ ] **P1-27 · S09 Lịch triều tháng** (F-TIDE-04)
  DoD: lưới tháng có âm lịch, pha trăng, con nước; chạm ngày xem chi tiết.

- [ ] **P1-28 · S08 Thông báo cục bộ** (F-ALERT-01)
  Nhắc trước đỉnh/chân X phút; nhắc giờ vàng. Lên lịch 7 ngày tới bằng `flutter_local_notifications` (zoned), lên lịch lại khi mở app.
  DoD: nhận thông báo đúng giờ trên máy ảo (kể cả khi app đóng).

- [ ] **P1-29 · S01 Onboarding + S13 Cài đặt** (F-UX-01, 03)
  DoD: lần đầu hiện onboarding; cài đặt lưu & áp dụng ngay (đơn vị, giao diện, cỡ chữ).

- [ ] **P1-30 · Firebase cơ bản**
  `flutterfire configure`; Crashlytics; App Check chế độ debug provider; (FCM để P2).
  DoD: crash thử xuất hiện trên Crashlytics.

**1F. Hoàn thiện bản dev**

- [ ] **P1-31 · Kiểm thử tổng**
  Chạy toàn bộ test; kiểm tra RLS; chạy app trên điện thoại thật tầm thấp; thử mất mạng; thử cỡ chữ lớn; chế độ tối.
  DoD: không lỗi chặn; ghi các lỗi nhỏ vào `docs/known-issues.md`.

- [ ] **P1-32 · CI**
  `.github/workflows/ci.yml`: analyze + test (Flutter), lint + test (Deno).
  DoD: CI xanh trên `main`.

- [ ] **P1-33 · Bản dev chia sẻ**
  Build APK debug/profile → chia sẻ cho 3–5 người quen (Firebase App Distribution hoặc gửi file).
  DoD: ✅ **BẢN DEV HOÀN THÀNH** — người khác cài và dùng được.

### Giai đoạn 2 — Bản 2 (≈ 6–8 tuần) 🟡

- [ ] **P2-01** Supabase Auth: ẩn danh → nâng cấp email OTP / Google / Apple; `profiles`; liên kết dữ liệu cục bộ.
- [ ] **P2-02** Đồng bộ `favorites`, `saved_places` (F-UX-07).
- [ ] **P2-03** FCM + `register-device` + `alerts-evaluate` + S08 quy tắc cảnh báo (F-ALERT-02, 03, F-SAFE-03).
- [ ] **P2-04** Nhật ký câu S07 + Storage ảnh + điều kiện tự động (F-FISH-06).
- [ ] **P2-05** Thống kê cá nhân (F-FISH-07).
- [ ] **P2-06** Điểm câu riêng tư + thông báo giờ vàng theo điểm (F-FISH-08, 09).
- [ ] **P2-07** Cẩm nang loài cá S10 + nút buộc S11 + đồ nghề (F-FISH-10, 11, 12).
- [ ] **P2-08** An toàn S12: ngập bãi, chuyến đi an toàn, SOS (F-SAFE-02, 04, 05).
- [ ] **P2-09** Widget màn hình chính (F-UX-05).
- [ ] **P2-10** Chia sẻ thẻ ảnh (F-UX-06).
- [ ] **P2-11** Lớp vệ tinh, lớp mưa, thanh trượt thời gian (F-MAP-05, 06, 07).
- [ ] **P2-12** So sánh năm trước, biểu đồ 1 năm, tốc độ dòng chảy, hiệu chỉnh triều theo thực đo (F-WL-03/04, F-TIDE-06/07).
- [ ] **P2-13** Câu biển: Open-Meteo Marine (F-FISH-17).
- [ ] **P2-14** Thêm nguồn `thuyloi`, `nchmf`; mở rộng ≥ 150 trạm toàn quốc.
- [ ] **P2-15** Trang quản trị web: tình trạng nguồn, quản lý trạm (F-ADM-01, 02).
- [ ] **P2-16** Gợi ý giờ lấy/xả nước (F-AGRI-01); tóm tắt buổi sáng (F-ALERT-04).
- [ ] **P2-17** Fit lại hằng số triều với dữ liệu tích lũy; nâng `tide_confidence`.
- [ ] **P2-18** Beta 20–50 người, thu phản hồi, tinh chỉnh chỉ số câu cá (`fs-2`).

### Giai đoạn 3 — Bản 3 🔵

- [ ] **P3-01** Nhận diện cá TFLite (F-FISH-14).
- [ ] **P3-02** Dự báo kết hợp triều + mưa + lũ (F-TIDE-08), lớp nguy cơ ngập (F-MAP-08).
- [ ] **P3-03** Độ mặn (F-WL-05, F-AGRI-02).
- [ ] **P3-04** Tĩnh không cầu (F-BOAT-01).
- [ ] **P3-05** Xả lũ hồ chứa (F-SAFE-06).
- [ ] **P3-06** Đo khoảng cách, vẽ vùng (F-MAP-09); đọc to, tiếng Anh (F-UX-08).

### Giai đoạn 4 — Phát hành & cộng đồng ⚪ (chưa tính — xem mục 17)

---

## 15. Mẫu prompt vibe code

### 15.1. Làm 1 task

```
Đọc CLAUDE.md và PROJECT.md. Thực hiện task <MÃ TASK> trong mục 14.
- Đọc các mục spec liên quan (ghi rõ mục nào bạn đã đọc).
- Lập kế hoạch ngắn (các file sẽ tạo/sửa) rồi mới code.
- Viết test trước cho phần logic.
- Chạy flutter analyze / flutter test (hoặc deno lint / deno test) và sửa hết lỗi.
- Cuối cùng: tóm tắt đã làm gì, cách tôi tự kiểm tra theo Tiêu chí xong, và những gì còn thiếu.
```

### 15.2. Sửa lỗi

```
Lỗi: <dán thông báo lỗi / mô tả hiện tượng / ảnh chụp>
Bước tái hiện: <1, 2, 3>
Mong muốn: <...>
Tìm nguyên nhân gốc trước khi sửa, giải thích ngắn nguyên nhân, sửa, thêm test chống tái phát.
```

### 15.3. Khảo sát nguồn dữ liệu (P0-03)

```
Tôi đã lưu phản hồi mẫu từ <nguồn> vào <đường dẫn fixtures>. Endpoint: <URL>.
Phân tích định dạng, múi giờ, đơn vị; đề xuất parser TypeScript thuần + test theo chuẩn mục 6.3;
ghi kết quả vào docs/data-sources.md.
```

### 15.4. Review trước khi commit

```
Review thay đổi hiện tại theo mục 12 (Bảo mật) và 0.3 (Definition of Done) trong PROJECT.md.
Liệt kê vấn đề theo mức độ nghiêm trọng; không tự sửa khi chưa hỏi.
```

### 15.5. Cập nhật spec

```
Tôi quyết định <thay đổi>. Cập nhật PROJECT.md ở các mục liên quan và thêm 1 dòng vào mục 19 Nhật ký quyết định.
```

---

## 16. Rủi ro & phương án dự phòng

| Rủi ro | Khả năng | Ảnh hưởng | Phương án |
|---|---|---|---|
| Nguồn VN đổi giao diện/endpoint, chặn truy cập | Cao | Mất dữ liệu thực đo | Parser tách riêng + fixtures; `source_runs` + UptimeRobot báo lỗi ngay; nhiều nguồn dự phòng; app vẫn chạy với dự báo triều + thời tiết |
| Không lấy được dữ liệu lịch sử để fit triều | Trung bình | Dự báo triều kém | Tích lũy dữ liệu từ ngày đầu ingest; dùng UHSLC/trạm tham chiếu; nhãn độ tin cậy |
| Mốc cao độ các nguồn khác nhau | Cao | So sánh sai | Lưu `datum` mỗi trạm; không so sánh chéo trạm khác mốc; hiển thị mốc trong tab Thông tin |
| Vượt hạn mức miễn phí (Vietmap, Open-Meteo, Supabase) | Trung bình | Gián đoạn | Cache mạnh theo ô lưới; theo dõi số lượt; giới hạn tốc độ |
| Supabase free tạm dừng project | Trung bình (dev) | Dev gián đoạn | Cron giữ hoạt động; khôi phục tay trên dashboard; prod dùng Pro |
| Chỉ số câu cá không "đúng" với người dùng | Cao | Mất tin tưởng | Nhãn tham khảo; thu nhật ký để tinh chỉnh; cho người dùng xem "lý do" |
| Lũ làm triều lệch lớn | Cao (mùa lũ) | Dự báo sai | Hiệu chỉnh theo thực đo (F-TIDE-07); hiện thực đo nổi bật hơn dự báo |
| Pin/hiệu năng máy yếu | Trung bình | Đánh giá thấp | Không chạy nền liên tục; tính toán nhẹ; test máy tầm thấp |

---

## 17. Việc để sau (chưa tính)

Theo yêu cầu, các mục dưới **chưa làm** ở bản dev — ghi lại để không quên:

- ⚪ **Pháp lý:** Luật Khí tượng thủy văn 2015 (giấy phép dự báo), Nghị định 13/2023 (bảo vệ dữ liệu cá nhân), quy định mạng xã hội khi có tính năng cộng đồng, điều khoản sử dụng các nguồn (Open-Meteo thương mại, Vietmap).
- ⚪ **Phát hành store:** Google Play (closed testing), App Store (Codemagic, TestFlight), ảnh chụp màn hình, mô tả, chính sách quyền riêng tư, trang xóa tài khoản.
- ⚪ **Kiếm tiền:** quảng cáo / gói Pro (ảnh hưởng tới điều khoản Open-Meteo).
- ⚪ **Cộng đồng:** báo cáo ngập, điểm câu cộng đồng, nhóm, giải câu, kiểm duyệt (F-COMM-*, F-FISH-13, 16).
- ⚪ **Quy định khai thác thủy sản** (F-FISH-15).
- ⚪ Supabase prod (Pro), sao lưu, App Check bắt buộc, OWASP MASVS.
- ⚪ Tên app & thương hiệu chính thức, đổi `--org` nếu cần (**phải chốt trước khi phát hành**, không đổi được sau đó).

---

## 18. Thuật ngữ

| Thuật ngữ | Nghĩa |
|---|---|
| **Đỉnh triều / chân triều** | Mực nước cao nhất / thấp nhất trong một chu kỳ triều |
| **Nước rong / nước kém** | Kỳ triều biên độ lớn (quanh rằm, mùng 1) / nhỏ (quanh mùng 8, 23) |
| **Nước đứng (slack)** | Lúc đổi chiều, nước gần như không lên xuống |
| **Báo động I/II/III** | Các mức cảnh báo lũ chính thức theo trạm |
| **Mốc cao độ (datum)** | Mốc 0 để đo mực nước (Hòn Dấu, Mũi Nai, hải đồ…) |
| **Hằng số điều hòa** | Biên độ & pha các sóng triều thành phần (M2, S2, K1, O1…) để tính triều |
| **Solunar** | Lý thuyết giờ hoạt động của cá theo vị trí mặt trăng |
| **Transit** | Lúc mặt trăng lên cao nhất (đỉnh) / thấp nhất (chân) trên bầu trời |
| **RLS** | Row Level Security — quy tắc quyền đọc/ghi từng dòng trong Postgres |
| **Edge Function** | Hàm chạy trên máy chủ Supabase (Deno/TypeScript) |
| **Geohash** | Mã chuỗi đại diện ô lưới trên bản đồ (dùng để cache) |
| **App Check** | Cơ chế Firebase xác nhận yêu cầu đến từ app thật |
| **MVP** | Phiên bản tối thiểu dùng được |

---

## 19. Nhật ký quyết định

| Ngày | Quyết định | Lý do |
|---|---|---|
| 2026-11-06 | Flutter (Dart) cho app | 1 code Android + iOS, nhẹ, mượt biểu đồ, khó dịch ngược |
| 2026-11-06 | Supabase (Postgres + PostGIS, Edge Functions, Auth, Storage) | Gói miễn phí đủ cho dev, có sẵn đăng nhập, RLS bảo mật |
| 2026-11-06 | Bản đồ Vietmap | Thể hiện đúng chủ quyền Việt Nam |
| 2026-11-06 | Thủy triều tính trước bằng Python (utide), app nội suy offline | Chính xác, không phải viết hiệu chỉnh nodal bằng Dart, chạy offline |
| 2026-11-06 | Phạm vi toàn quốc | Yêu cầu của chủ dự án |
| 2026-11-06 | Ưu tiên bản dev; pháp lý/phát hành để sau | Yêu cầu của chủ dự án |
| 2026-11-06 | Đối tượng chính: dân câu cá | Yêu cầu của chủ dự án |
| 2026-11-06 | Nguồn thực đo: IOC (ven biển, 15 phút) + bản tin PDF KTTV (sông, 1 lần/ngày); bỏ vndms/MRC/thủy lợi khỏi bản dev | P0-03: vndms/thủy lợi/KTTV Nam Bộ lỗi chứng chỉ SSL, MRC cần đăng nhập |
| 2026-11-06 | Ingest PDF bằng Python trên GitHub Actions, không dùng Edge Function | PDF cần `pdfplumber`, chạy 1 lần/ngày |
| 2026-11-06 | Bỏ UHSLC, dùng IOC để fit hằng số triều | UHSLC không kết nối được; IOC có lịch sử ≥ 2 năm |
| 2026-11-06 | CAPE không còn khóa chỉ số câu cá, chỉ cảnh báo vàng | CAPE ở VN thường > 2000 kể cả trời quang |
| 2026-11-06 | Không kết luận "có thể ngập" từ độ cao mô hình trong bản dev | Open-Meteo Elevation lệch cao vài mét ở đồng bằng |
| 2026-11-09 | **Bản dùng thử V0 không máy chủ, không DB**: 1 app Flutter gọi thẳng IOC + Open-Meteo; dự báo triều sinh sẵn bằng Python và đóng gói vào app; sai số 30 ngày tính trên máy | Chủ dự án muốn miễn phí hoàn toàn, không thuê máy chủ, có app dùng thử sớm |
| 2026-11-09 | Khi cần DB: dùng Supabase (Postgres) như thiết kế mục 7; BE .NET được cân nhắc nhưng chưa chốt | Supabase có sẵn Auth + RLS, không phải dựng API; vẫn là Postgres chuẩn nên chuyển đi được |
| 2026-11-09 | V0 chỉ Android | iOS cần tài khoản Apple trả phí + máy Mac/dịch vụ build |
| 2026-11-09 | **Bản đồ nền: OpenFreeMap + `maplibre_gl`** thay Vietmap | Chủ dự án yêu cầu miễn phí 100%, không đăng ký; OpenFreeMap không khóa, không giới hạn lượt xem, cho phép thương mại; nhãn lấy `name:vi`, tự vẽ nhãn chủ quyền Hoàng Sa/Trường Sa. Rủi ro: dịch vụ không cam kết SLA |
| 2026-11-09 | **Mực nước sông = bản tin KTTV + mô hình triều trong app**; dữ liệu đưa qua GitHub Actions + GitHub Pages (kho mã công khai) | Không có nguồn mực nước sông thời gian thực miễn phí; trong kiểm thử ngược, mô hình tốt hơn 2,4 lần (Hà Nội) và 4 lần (Nam Đàn) so với cách nối mốc 6 giờ — docs/river-model.md |
