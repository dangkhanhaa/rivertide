# 06 — Giao diện, chữ tiếng Việt, khả năng tiếp cận

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md). Màu & màn hình chi tiết: PROJECT.md mục 10, FEATURES.md.

## 1. Design tokens (chỉ dùng token, không hard-code)

```dart
// Đúng
Container(color: context.colors.surface, padding: const EdgeInsets.all(AppSpacing.md));
Text(l10n.level, style: context.text.titleMedium);
// Sai
Container(color: Color(0xFF0B6E99), padding: EdgeInsets.all(15));
```

| Nhóm | Token |
|---|---|
| Khoảng cách | `AppSpacing.xs=4, sm=8, md=12, lg=16, xl=24, xxl=32` |
| Bo góc | `AppRadius.sm=8, md=12, lg=20` |
| Màu | `AppColors` (PROJECT.md 10.3): `primary, water, tidePred, ok, alarm1, alarm2, alarm3, stale, fishHigh, surface, onSurface…` — có bản sáng & tối |
| Chữ | `AppText`: `displayLevel` (số mực nước 48–56sp, đậm, tabular), `headline, title, body, label, caption` |
| Biểu tượng | Material Symbols Rounded; kích thước 20/24/32 |

## 2. Mẫu thành phần dùng chung (core/widgets)

| Widget | Dùng khi |
|---|---|
| `AsyncValueView` | Mọi dữ liệu bất đồng bộ (tự lo loading/error/empty) |
| `LoadingView` | Skeleton (khung xám) — không dùng vòng xoay toàn màn hình nếu đã có bố cục |
| `ErrorView` | Lỗi + nút "Thử lại" + giải thích ngắn |
| `EmptyView` | Không có dữ liệu + hành động gợi ý |
| `StaleBanner` | "Ngoại tuyến · cập nhật lúc 14:05" |
| `EstimateBadge` | Nhãn "Ước tính · độ tin cậy: trung bình" (nền sọc) |
| `SourceAttribution` | Dòng nguồn dữ liệu nhỏ dưới mỗi khối số liệu |
| `AlarmLevelBar` | Thanh so mực nước với BĐ I/II/III |
| `TrendArrow` | Mũi tên + chữ ("Đang lên") — không chỉ mũi tên |
| `ScoreBadge` | Chỉ số câu cá 0–10 + màu + chữ mức ("Tốt") |

## 3. Khả năng tiếp cận (a11y)

- Vùng chạm ≥ 48×48 dp.
- Tương phản chữ ≥ 4.5:1 (chữ lớn ≥ 3:1) — kiểm cả chế độ tối.
- Không chỉ dùng màu: luôn kèm chữ hoặc biểu tượng (mức báo động, chỉ số câu cá, xu hướng).
- `Semantics` cho biểu đồ, số liệu lớn, nút chỉ có icon: ví dụ `"Mực nước 2,85 mét, đang lên 6 xăng-ti-mét mỗi giờ"`.
- Hỗ trợ `textScaler` tới 1.6: dùng `Flexible`/`Wrap`, không cố định chiều cao chứa chữ.
- Hoạt ảnh tôn trọng `MediaQuery.disableAnimationsOf(context)`.

## 4. Giọng văn tiếng Việt

| Quy tắc | Đúng | Sai |
|---|---|---|
| Xưng "bạn", lịch sự, ngắn | "Bạn chưa lưu trạm nào." | "Người dùng chưa có dữ liệu trạm yêu thích." |
| Dùng từ người dân quen | "Nước ròng", "nước lớn", "con nước" | "Pha giảm triều" |
| Câu hành động cho nút | "Thử lại", "Lưu điểm", "Đặt cảnh báo" | "OK", "Submit" |
| Lỗi: nói chuyện gì + làm gì | "Không tải được dữ liệu. Kiểm tra mạng rồi thử lại." | "Error 502" |
| Số liệu dự báo luôn có nhãn | "Đỉnh triều dự kiến 14:40 (tham khảo)" | "Đỉnh triều 14:40" |
| Không phóng đại | "Chỉ số câu cá: 8/10 — Tốt" | "Chắc chắn câu được nhiều cá!" |
| Viết hoa đầu câu, không viết hoa toàn bộ | "Báo động II" | "BÁO ĐỘNG II" |
| Đơn vị có dấu cách | "2,85 m", "6 cm/giờ", "29 °C" | "2.85m" |

Thuật ngữ chuẩn (dùng nhất quán):

| Khái niệm | Dùng chữ |
|---|---|
| high tide / low tide | **Đỉnh triều** / **Chân triều** |
| rising / falling / slack | **Đang lên** / **Đang xuống** / **Nước đứng** |
| spring / neap | **Nước rong** / **Nước kém** |
| alarm level 1–3 | **Báo động I / II / III** (viết tắt BĐ I…) |
| observed / predicted / estimated | **Thực đo** / **Dự báo** / **Ước tính** |
| station | **Trạm** |
| fishing score | **Chỉ số câu cá** |
| golden hours | **Giờ vàng** |
| lunar day | **ngày âm** (hiển thị "16/9 ÂL") |

## 5. Khóa chuỗi l10n

- Định dạng: `<feature>_<ngữ cảnh>_<mô tả>` — `stationDetail_overview_toAlarm1`.
- Có `@` mô tả cho dịch giả/AI hiểu ngữ cảnh; tham số dùng placeholder có kiểu:
```json
"stationDetail_overview_toAlarm1": "Còn {distance} tới Báo động I",
"@stationDetail_overview_toAlarm1": {
  "description": "Khoảng cách từ mực nước hiện tại tới ngưỡng báo động I",
  "placeholders": { "distance": { "type": "String", "example": "0,65 m" } }
}
```
- Số nhiều/giới tính: dùng cú pháp ICU `{count, plural, ...}` khi cần.

## 6. Bố cục chung

- Lề màn hình 16dp. Khoảng giữa các khối 12–16dp.
- Thông tin quan trọng nhất (mực nước, đếm ngược, chỉ số) ở **trên cùng, chữ to**.
- Bottom sheet bản đồ: 3 nấc (thu gọn 25% / nửa / toàn màn hình).
- Nút hành động chính ở tầm ngón cái (nửa dưới màn hình).
