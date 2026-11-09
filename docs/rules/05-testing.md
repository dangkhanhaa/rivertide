# 05 — Kiểm thử

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md).

## 1. Cái gì PHẢI có test

| Phần | Loại test | Mức tối thiểu |
|---|---|---|
| `core/calc/**` (tide, lunar, astro, fishing, geo) | Unit | **≥ 90% dòng**, đủ ca biên |
| `core/format/**` | Unit | 100% hàm public |
| Repository (data) | Unit với mock remote/local | Thành công · lỗi mạng có cache · lỗi mạng không cache · parse lỗi |
| Provider/Controller có logic | Unit với `ProviderContainer` | Mỗi hành động public |
| Màn hình | Widget test | 4 trạng thái: loading · error · empty · data (+ stale) |
| Edge Function parser/normalize | Deno test với `__fixtures__` | Mỗi fixture, ca thiếu dữ liệu, giá trị bất thường |
| Edge Function handler | Deno test | Input hợp lệ · input sai (400) · phương thức sai (405) |
| RLS | Deno/SQL test với anon & user key | Không đọc dữ liệu người khác, không ghi bảng công khai, **mọi bảng public có RLS** |
| Python tide | pytest | Tín hiệu tổng hợp khôi phục đúng; đỉnh/chân đúng |

## 2. Viết test

- Đặt tên mô tả hành vi: `test('marks reading stale when remote fails and cache exists', ...)`.
- Cấu trúc **Arrange – Act – Assert**, mỗi test kiểm 1 hành vi.
- **Không** phụ thuộc thời gian thật, mạng thật, múi giờ máy: dùng `clockProvider` override, fixtures, `DateTime.utc(...)`.
- Mock bằng `mocktail`. Không mock thứ mình sở hữu nếu dùng bản thật được dễ (ví dụ Drift in-memory: `NativeDatabase.memory()`).
- Số thực: so với sai số (`closeTo(x, 0.01)`).
- Fixtures tham chiếu (thiên văn, âm lịch, bảng triều) phải ghi **nguồn** trong file `README` của thư mục fixtures.

## 3. Bộ test chuẩn bắt buộc cho thuật toán

| Module | Ca bắt buộc |
|---|---|
| `lunar` | Tết 2020–2030; ngày đầu/cuối tháng nhuận (vd 2023 nhuận tháng 2, 2025 nhuận tháng 6); 31/12 → 1/1 |
| `astro` | Mặt trời mọc/lặn Hà Nội, Đà Nẵng, Cần Thơ (sai số < 2 phút); trăng mọc/lặn (< 5 phút); ngày không có trăng mọc; pha trăng tròn/non |
| `tide` | Nội suy giữa 2 điểm; đỉnh/chân trùng `extremes` ±10 phút; trạng thái `slack` quanh đỉnh; đếm ngược qua nửa đêm; qua năm mới (đổi file năm); `springNeap` |
| `fishing` | Dông → ≤ 2.0; mưa lớn → ≤ 3.0; trạm không triều; không chọn loài; giờ vàng gộp khoảng < 30 phút; tổng trọng số chuẩn hóa khi thiếu dữ liệu |
| `geo` | Haversine (vd Hồ Hoàn Kiếm 21.0285,105.8542 ↔ Nhà thờ Đức Bà 10.7798,106.6990 ≈ 1.143 km ±3 km); geohash; fuzz ổn định theo seed và nằm trong bán kính |

## 4. Chạy

```powershell
cd app; flutter test                         # toàn bộ
cd app; flutter test test/core/calc          # chỉ thuật toán
cd app; flutter test --coverage              # coverage → coverage/lcov.info
cd supabase/functions; deno test -A
cd tools/tide; python -m pytest -q
```

## 5. CI (khi có — P1-32)

CI PHẢI chạy: format check, analyze, test (Flutter) · fmt check, lint, test (Deno) · pytest. Fail bất kỳ → không merge.

## 6. Kiểm thử tay trước khi đánh dấu task giao diện "xong"

- [ ] Máy ảo Android, chế độ sáng & tối.
- [ ] Cỡ chữ hệ thống lớn nhất.
- [ ] Tắt mạng (chế độ máy bay) → mở lại màn hình.
- [ ] Mạng chậm (máy ảo: Network type EDGE).
- [ ] Xoay màn hình (nếu hỗ trợ) / màn hình nhỏ 5".
