# 01 — Kiến trúc code

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md). File này quy định **đặt code ở đâu, ai được gọi ai**.

## 1. Tổng quan tầng (app Flutter)

```
presentation  ──watch──►  providers (application)  ──►  domain (model, interface repo)
                                                          ▲
                                     data (repo impl, remote, local) ──implements──┘
core/  (dùng chung: calc, theme, network, db, l10n, logging, clock, widgets)
```

| Tầng | Chứa | Được import | KHÔNG được import |
|---|---|---|---|
| `domain/` | Model (freezed), interface repository, enum, value object | `core/calc`, `core/errors` | Flutter UI, dio, supabase, drift |
| `data/` | Repository impl, `*_remote_source.dart`, `*_local_source.dart`, DTO, mapper | `domain/`, `core/network`, `core/db`, `core/errors` | `presentation/` |
| `application/` | Riverpod providers / notifiers (logic màn hình, kết hợp nhiều repo) | `domain/`, provider của `data/` | widget |
| `presentation/` | Screen, widget, view-model nhỏ | `application/`, `domain/` (model), `core/theme`, `core/widgets`, `l10n` | `data/` trực tiếp, dio, supabase |
| `core/calc/` | Thuật toán Dart thuần | `dart:math`, `package:collection`, `package:meta` | Flutter, I/O, `DateTime.now()` |

## 2. Cấu trúc 1 feature (mẫu chuẩn — PHẢI theo)

```
app/lib/features/station_detail/
├── station_detail.dart                   # file public: export những gì feature khác được dùng (route, widget thẻ)
├── domain/
│   ├── station.dart                       # @freezed model
│   ├── water_reading.dart
│   └── station_repository.dart            # abstract interface class StationRepository
├── data/
│   ├── station_repository_impl.dart       # implements StationRepository
│   ├── station_remote_source.dart         # gọi Supabase / Edge Function
│   ├── station_local_source.dart          # đọc/ghi Drift
│   ├── dto/station_dto.dart               # JSON thô từ API (nếu khác model)
│   └── station_mapper.dart                # DTO ↔ model
├── application/
│   ├── station_providers.dart             # @riverpod repository provider + query providers
│   └── station_detail_controller.dart     # @riverpod class (nếu có trạng thái tương tác)
└── presentation/
    ├── station_detail_screen.dart         # Scaffold + tab
    ├── tabs/overview_tab.dart
    ├── tabs/chart_tab.dart
    └── widgets/level_hero.dart            # widget con, mỗi file 1 widget public
```

Test đặt song song: `app/test/features/station_detail/...` cùng đường dẫn, hậu tố `_test.dart`.

## 3. `core/` — nội dung cố định

```
core/
├── calc/          tide/ lunar/ astro/ fishing/ geo/       (Dart thuần + test ≥ 90%)
├── clock/         clock_provider.dart                       (nguồn thời gian duy nhất)
├── config/        env.dart                                  (đọc --dart-define)
├── db/            app_database.dart, tables/, daos/         (Drift)
├── errors/        app_exception.dart                        (sealed class)
├── l10n/          l10n_ext.dart (context.l10n)
├── logging/       log.dart
├── network/       dio_client.dart, supabase_client.dart, edge_api.dart, interceptors/
├── location/      location_service.dart
├── notifications/ local_notifications.dart, push.dart
├── theme/         app_colors.dart, app_text.dart, app_spacing.dart, app_theme.dart
├── format/        level_format.dart, time_format.dart       (định dạng số/giờ kiểu VN)
└── widgets/       loading_view.dart, error_view.dart, empty_view.dart, stale_banner.dart,
                   source_attribution.dart, estimate_badge.dart, async_value_view.dart
```

## 4. Luồng dữ liệu & cache (offline-first)

Repository PHẢI trả về `Cached<T>`:

```dart
@freezed
abstract class Cached<T> with _$Cached<T> {
  const factory Cached({
    required T data,
    required DateTime fetchedAtUtc,
    required bool isStale,       // quá TTL hoặc lấy từ cache do lỗi mạng
  }) = _Cached<T>;
}
```

Chiến lược chuẩn (stale-while-revalidate):

1. Đọc cache local → nếu có, phát ra ngay (`isStale` theo TTL).
2. Gọi remote → thành công: ghi cache, phát dữ liệu mới.
3. Remote lỗi: nếu đã có cache → giữ cache, `isStale = true` (UI hiện `StaleBanner`); nếu không có cache → ném `AppException`.

TTL chuẩn (đặt trong `core/config/cache_ttl.dart`, KHÔNG rải số khắp nơi):

| Dữ liệu | TTL |
|---|---|
| Danh sách trạm | 24 giờ |
| Mực nước mới nhất | 5 phút |
| Chuỗi đo | 15 phút |
| Thời tiết | 60 phút |
| Kết quả `point` | 10 phút |
| File triều năm | đến khi `model_version` đổi |

## 5. Lỗi

Một kiểu lỗi duy nhất cho toàn app:

```dart
sealed class AppException implements Exception {
  const AppException(this.debugMessage);
  final String debugMessage; // KHÔNG chứa dữ liệu cá nhân
}
final class NetworkException extends AppException { const NetworkException(super.m); }
final class TimeoutAppException extends AppException { const TimeoutAppException(super.m); }
final class ServerException extends AppException { const ServerException(super.m, {this.code}); final String? code; }
final class RateLimitedException extends AppException { const RateLimitedException(super.m); }
final class NotFoundException extends AppException { const NotFoundException(super.m); }
final class ParseException extends AppException { const ParseException(super.m); }
final class PermissionDeniedException extends AppException { const PermissionDeniedException(super.m); }
final class OfflineNoCacheException extends AppException { const OfflineNoCacheException(super.m); }
```

- Tầng `data` PHẢI bắt mọi lỗi của dio/supabase/drift và chuyển thành `AppException`.
- Tầng `presentation` hiển thị lỗi qua `ErrorView(exception)` → map sang chuỗi l10n. Không hiện `debugMessage` cho người dùng.

## 6. Điều hướng

- Tất cả route khai báo trong `app/lib/router.dart` bằng `go_router`, tên route là hằng trong `abstract final class Routes`.
- Tham số route PHẢI validate (id đúng regex `^[a-z0-9-]{3,64}$`, lat/lon trong biên VN) → sai thì về màn hình lỗi "Không tìm thấy".
- 5 tab dùng `StatefulShellRoute.indexedStack` để giữ trạng thái từng tab.

## 7. Backend — vị trí code

| Loại | Đặt ở |
|---|---|
| Schema, RLS, view, RPC, cron | `supabase/migrations/NNNN_name.sql` |
| Dữ liệu mẫu | `supabase/seed.sql`, `supabase/seed/*.csv` |
| Edge Function | `supabase/functions/<name>/index.ts` (chỉ khai báo route & gọi handler) |
| Logic Edge Function | `supabase/functions/<name>/handler.ts`, parser thuần ở `parse.ts` |
| Code dùng chung | `supabase/functions/_shared/*.ts` |
| Mẫu phản hồi nguồn | `supabase/functions/<name>/__fixtures__/*.json|html` |
| Python thủy triều | `tools/tide/*.py`, test `tools/tide/tests/` |

## 8. Thêm feature mới — checklist

- [ ] Có mã tính năng `F-xxx` trong FEATURES.md và task trong PROJECT.md.
- [ ] Tạo đủ thư mục theo mục 2 (bỏ tầng không cần, ví dụ feature chỉ hiển thị không cần `data/`).
- [ ] Đăng ký route trong `router.dart`.
- [ ] Chuỗi trong `app_vi.arb` với tiền tố tên feature (`stationDetail_...`).
- [ ] Test domain/application; widget test cho 4 trạng thái.
