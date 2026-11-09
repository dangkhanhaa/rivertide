# 02 — Chuẩn code Dart / Flutter

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md). Ví dụ trong file này là **mẫu chuẩn** — code mới PHẢI viết theo cùng kiểu.

## 1. Định dạng & lint

- `dart format` với `page_width: 100` (khai báo trong `analysis_options.yaml` → `formatter: page_width: 100`).
- Lint: `very_good_analysis` + các luật bổ sung dưới. `flutter analyze` PHẢI 0 issue (kể cả info).

```yaml
# app/analysis_options.yaml
include: package:very_good_analysis/analysis_options.yaml
formatter:
  page_width: 100
analyzer:
  exclude: ["**/*.g.dart", "**/*.freezed.dart", "lib/l10n/gen/**"]
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
linter:
  rules:
    public_member_api_docs: false
    avoid_print: true
    prefer_final_locals: true
    prefer_const_constructors: true
    unawaited_futures: true
    always_use_package_imports: true
    avoid_dynamic_calls: true
    lines_longer_than_80_chars: false
```

## 2. Đặt tên

| Thứ | Quy tắc | Ví dụ |
|---|---|---|
| File | `snake_case.dart` | `tide_predictor.dart` |
| Class, enum, typedef, extension | `UpperCamelCase` | `TidePredictor`, `TideState` |
| Biến, hàm, tham số | `lowerCamelCase` | `nextExtreme`, `levelCm` |
| Hằng | `lowerCamelCase` (không `SCREAMING`) | `const defaultTtl = Duration(minutes: 5);` |
| Private | tiền tố `_` | `_interpolate` |
| Provider (codegen) | tên hàm, Riverpod tự thêm `Provider` | `stationById` → `stationByIdProvider` |
| Đơn vị | **hậu tố đơn vị bắt buộc** cho số đo | `levelCm`, `distanceM`, `windKmh`, `pressureHpa`, `rateCmPerH`, `durationMin` |
| Thời gian | hậu tố `Utc` hoặc `Local` khi có thể nhầm | `observedAtUtc` |
| Boolean | `is/has/can/should` | `isStale`, `hasTide` |
| Màn hình | hậu tố `Screen` | `StationDetailScreen` |
| Widget con | danh từ mô tả | `LevelHero`, `TideCountdownCard` |
| Test | `<file>_test.dart`, mô tả tiếng Anh | `test('returns slack when rate < 3 cm/h', ...)` |

## 3. Model — freezed

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'station.freezed.dart';
part 'station.g.dart';

@freezed
abstract class Station with _$Station {
  const factory Station({
    required String id,
    required String name,
    required double lat,
    required double lon,
    required bool hasTide,
    String? riverId,
    String? province,
    int? alarm1Cm,
    int? alarm2Cm,
    int? alarm3Cm,
  }) = _Station;

  factory Station.fromJson(Map<String, Object?> json) => _$StationFromJson(json);
}
```

Luật:
- Model domain **bất biến**, dùng `copyWith`.
- JSON dùng `Map<String, Object?>` (không `dynamic`).
- Tên field JSON snake_case → dùng `@JsonKey(name: 'has_tide')` hoặc cấu hình `build.yaml` `field_rename: snake` toàn dự án (**chọn build.yaml**).
- Enum có giá trị JSON: `@JsonEnum(fieldRename: FieldRename.snake)`.

## 4. Riverpod (codegen)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_providers.g.dart';

@Riverpod(keepAlive: true)
StationRepository stationRepository(Ref ref) => StationRepositoryImpl(
      remote: StationRemoteSource(ref.watch(edgeApiProvider)),
      local: StationLocalSource(ref.watch(appDatabaseProvider)),
      clock: ref.watch(clockProvider),
    );

@riverpod
Future<Cached<Station>> stationById(Ref ref, String id) =>
    ref.watch(stationRepositoryProvider).getById(id);

@riverpod
class FavoriteStations extends _$FavoriteStations {
  @override
  Future<List<String>> build() => ref.watch(favoritesRepositoryProvider).getIds();

  Future<void> toggle(String stationId) async {
    final repo = ref.read(favoritesRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.toggle(stationId);
      return repo.getIds();
    });
  }
}
```

Luật:
- **Chỉ** dùng annotation `@riverpod` / `@Riverpod(...)`. KHÔNG khai báo provider tay (`Provider(...)`), KHÔNG `StateProvider`, `ChangeNotifierProvider`.
- Trong `build()` của widget: dùng `ref.watch`. Trong callback (onPressed…): dùng `ref.read`. KHÔNG `ref.read` trong `build()`.
- Repository/service: `keepAlive: true`. Query theo màn hình: mặc định autoDispose.
- Không giữ `BuildContext` trong provider. Không gọi điều hướng từ provider.
- Side effect (hiện SnackBar, điều hướng) làm trong widget bằng `ref.listen`.

## 5. Widget

```dart
class LevelHero extends ConsumerWidget {
  const LevelHero({required this.stationId, super.key});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestReadingProvider(stationId));
    return AsyncValueView(
      value: latest,
      onRetry: () => ref.invalidate(latestReadingProvider(stationId)),
      data: (cached) => _LevelHeroContent(reading: cached.data, isStale: cached.isStale),
    );
  }
}
```

Luật:
- Widget `const` khi có thể. Tách widget thành **class** (không tách thành hàm trả `Widget`).
- `build()` ≤ 80 dòng, không có logic nghiệp vụ, không format số tay (dùng `core/format`).
- Mọi dữ liệu bất đồng bộ đi qua `AsyncValueView` (core/widgets) → đủ 4 trạng thái.
- `StatelessWidget`/`ConsumerWidget` mặc định; `StatefulWidget` chỉ khi có controller (AnimationController, TextEditingController, ScrollController) — nhớ `dispose`.
- Danh sách dài: `ListView.builder` / `SliverList`. Không `Column` + `map` cho > 20 phần tử.
- Ảnh mạng: `CachedNetworkImage` có `memCacheWidth`.
- Không dùng `MediaQuery.of(context).size` lặp lại — dùng `MediaQuery.sizeOf(context)`.

## 6. Thời gian — `clockProvider`

```dart
// core/clock/clock_provider.dart
typedef Clock = DateTime Function();

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => () => DateTime.now().toUtc();
```

- Mọi chỗ cần "bây giờ" PHẢI dùng `ref.watch(clockProvider)()` hoặc nhận `Clock` qua constructor.
- Test override: `clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 6, 3))`.
- Đổi sang giờ VN để hiển thị: `core/format/time_format.dart` dùng package `timezone` (`Asia/Ho_Chi_Minh`).
- Đồng hồ đếm ngược cập nhật mỗi phút: `tickerProvider` (Stream mỗi 60s, căn đúng đầu phút) — KHÔNG tạo `Timer` trong widget.

## 7. Async & lỗi

- Không `Future` bị bỏ quên: dùng `await` hoặc `unawaited(...)` có chủ đích.
- Timeout mạng: đặt ở `dio_client` (connect 10s, receive 15s). Không đặt timeout lẻ tẻ.
- Retry: chỉ cho GET idempotent, tối đa 2 lần, backoff 1s → 3s (interceptor dùng chung).
- Không `try/catch` ở presentation; lỗi đã là `AppException` từ data.

## 8. Log

```dart
import 'package:rivertide/core/logging/log.dart';

log.info('tide file loaded', {'stationId': id, 'year': year});
log.warn('source stale', {'source': 'vndms'});
log.error('parse failed', error: e, stackTrace: st);
```

- Release: chỉ `warn` + `error`, gửi Crashlytics (không kèm dữ liệu cá nhân).
- KHÔNG log: tọa độ chính xác (làm tròn 2 chữ số nếu cần), token, email, nội dung ghi chú.

## 9. Chuỗi & định dạng

- Chuỗi: `context.l10n.stationDetail_title` (extension trong `core/l10n`).
- Số: `LevelFormat.meters(levelCm)` → `"2,85 m"`; `LevelFormat.rate(rateCmPerH)` → `"+6 cm/giờ"`.
- Giờ: `TimeFormat.hm(utc)` → `"14:40"`; `TimeFormat.dayWithLunar(utc)` → `"T5, 06/11 (16/9 ÂL)"`.
- Khoảng thời gian: `TimeFormat.countdown(duration)` → `"2 giờ 15 phút"`.

## 10. Hiệu năng

- Màn hình chính mở < 2s trên máy tầm thấp: không tính toán nặng trong `build`, dùng `compute`/`Isolate.run` cho việc > 16ms (giải nén file triều, tính chỉ số 7 ngày).
- Biểu đồ: giảm điểm (downsample) ≤ 500 điểm trước khi vẽ.
- Bản đồ: chỉ tải trạm trong khung nhìn, debounce 400ms khi kéo.
- Đo bằng DevTools ở chế độ `--profile`, không đo bằng debug.

## 11. Import

- Luôn `package:rivertide/...` (không import tương đối).
- Thứ tự: `dart:` → `package:` bên ngoài → `package:rivertide/` (formatter + lint tự xử lý).
- Không import `src/` của package ngoài.

## 12. Cấu hình môi trường

```dart
// core/config/env.dart
abstract final class Env {
  static const name = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const vietmapTileKey = String.fromEnvironment('VIETMAP_TILE_KEY');

  static void assertValid() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty || vietmapTileKey.isEmpty) {
      throw StateError('Missing --dart-define-from-file=env/<env>.json');
    }
    if (!supabaseUrl.startsWith('https://') && name != 'dev') {
      throw StateError('SUPABASE_URL must be https');
    }
  }
}
```

`bootstrap.dart` gọi `Env.assertValid()` đầu tiên.
