# 03 — Chuẩn Backend: SQL, Supabase, Edge Functions, Python

> Bắt buộc theo [CLAUDE.md](../../CLAUDE.md). Schema gốc ở PROJECT.md mục 7, API ở mục 8.

## 1. SQL & migration

### 1.1. Đặt tên
| Thứ | Quy tắc | Ví dụ |
|---|---|---|
| Bảng | `snake_case`, **số nhiều** | `stations`, `saved_places` |
| Cột | `snake_case`, có đơn vị | `level_cm`, `distance_m`, `observed_at` |
| Thời gian | `timestamptz`, hậu tố `_at` | `created_at` |
| Khóa ngoại | `<bảng số ít>_id` | `station_id` |
| Index | `<bảng>_<cột>_idx`, gist: `_gix` | `observations_time_idx` |
| Policy | Câu mô tả ngắn trong ngoặc kép | `"own catches"` |
| Hàm/RPC | động từ + danh từ | `get_series`, `nearest_stations` |
| File migration | `NNNN_snake_case.sql` (tạo bằng `supabase migration new`) | `0007_add_salinity.sql` |

### 1.2. Luật migration
- **KHÔNG ĐƯỢC** sửa file migration đã có. Thay đổi = migration mới.
- Mỗi migration: 1 mục đích, có comment đầu file `-- Purpose: ... -- Task: P1-05`.
- Bảng mới PHẢI trong cùng file: `enable row level security` + policy + `comment on table`.
- Luôn `create ... if not exists` / `drop ... if exists` khi phù hợp.
- Kiểu dữ liệu: `text` (không `varchar(n)` — dùng `check (char_length(...) <= n)`), `int` cho cm, `numeric` cho số thực cần chính xác, `timestamptz` (không `timestamp`), `geography(Point,4326)` cho tọa độ, `jsonb` (không `json`).
- Cột không null mặc định; nullable chỉ khi có nghĩa "không biết".
- Ràng buộc nghiệp vụ bằng `check` (phạm vi giá trị, độ dài chuỗi).
- Index cho mọi khóa ngoại được truy vấn và cột lọc thời gian.
- Sau migration: `supabase db reset` PHẢI chạy sạch + chạy lại test RLS.

### 1.3. Hàm SQL
- Mặc định `security invoker`.
- `security definer` chỉ khi bắt buộc, và PHẢI có `set search_path = ''` + tên đầy đủ `public.table` + comment lý do + chỉ `grant execute` cho role cần.
- Hàm đọc: `stable`. Có `limit` trần để tránh trả quá nhiều.
- Tham số từ người dùng: kiểm tra phạm vi trong hàm (`if p_limit > 10 then ...`).

### 1.4. RLS — mẫu chuẩn
```sql
-- Bảng công khai chỉ đọc
alter table public.stations enable row level security;
create policy "public read" on public.stations for select to anon, authenticated using (active);

-- Bảng của người dùng
alter table public.catches enable row level security;
create policy "own select" on public.catches for select to authenticated using ((select auth.uid()) = user_id);
create policy "own insert" on public.catches for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own update" on public.catches for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own delete" on public.catches for delete to authenticated using ((select auth.uid()) = user_id);
```
- Dùng `(select auth.uid())` (Supabase khuyến nghị cho hiệu năng).
- Tách policy theo thao tác, chỉ định `to <role>`.
- Bảng chỉ server dùng: bật RLS, **không** tạo policy.

## 2. Edge Functions (Deno / TypeScript)

### 2.1. Cấu trúc
```
supabase/functions/
├── _shared/
│   ├── handler.ts        # bọc request: CORS, auth, rate limit, bắt lỗi, log
│   ├── errors.ts         # class HttpError + mã lỗi
│   ├── auth.ts           # verifyCron(), verifyClient() (JWT + App Check)
│   ├── supabase.ts       # adminClient() — CHỈ dùng phía server
│   ├── http.ts           # fetchWithTimeout(), retry, giới hạn kích thước
│   ├── cache.ts          # đọc/ghi weather_cache, point_cache
│   ├── geo.ts            # geohash, biên VN
│   ├── log.ts
│   └── schemas.ts        # zod schema dùng chung
└── point/
    ├── index.ts          # chỉ: Deno.serve(handler(...))
    ├── handler.ts        # logic
    ├── handler_test.ts
    └── __fixtures__/
```

### 2.2. Mẫu chuẩn
```ts
// supabase/functions/point/index.ts
import { createHandler } from "../_shared/handler.ts";
import { pointHandler } from "./handler.ts";

Deno.serve(createHandler({ auth: "client", rateLimitPerMin: 60 }, pointHandler));
```

```ts
// supabase/functions/point/handler.ts
import { z } from "npm:zod@3";
import { HttpError } from "../_shared/errors.ts";
import type { HandlerContext } from "../_shared/handler.ts";

export const PointRequest = z.object({
  lat: z.number().min(8.0).max(23.5),
  lon: z.number().min(102.0).max(117.5),
}).strict();

export async function pointHandler(req: Request, ctx: HandlerContext): Promise<Response> {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");
  const parsed = PointRequest.safeParse(await ctx.readJson(req, { maxBytes: 2_048 }));
  if (!parsed.success) throw new HttpError(400, "invalid_input");
  const lat = round4(parsed.data.lat);
  const lon = round4(parsed.data.lon);
  // ...
  return ctx.json({ /* đúng contract PROJECT.md 8.3 */ });
}

const round4 = (n: number) => Math.round(n * 1e4) / 1e4;
```

### 2.3. Luật
- `index.ts` chỉ nối handler. Logic trong `handler.ts`, parse nguồn trong `parse.ts` (hàm thuần, test bằng fixtures).
- Validate **mọi** input bằng zod `.strict()`. Giới hạn kích thước body.
- Lỗi trả về **chỉ** dạng `{ "error": { "code": "snake_case", "message": "..." } }`. KHÔNG trả stack trace, câu SQL, thông tin nội bộ.
- Mã HTTP: 400 input sai · 401 chưa xác thực · 403 App Check sai · 404 · 405 · 429 rate limit · 502 nguồn ngoài lỗi · 500 lỗi khác.
- Gọi ra ngoài: `fetchWithTimeout` (10s), retry ≤ 2 cho GET, giới hạn phản hồi 5 MB, kiểm tra `content-type`.
- Function cron: `auth: "cron"` → so khớp `x-cron-secret` bằng so sánh thời gian hằng.
- Phiên bản thư viện: **ghim cứng** (`npm:zod@3.23.8`) trong `deno.json` import map; không dùng `latest`.
- Log 1 dòng JSON/sự kiện: `{fn, level, msg, ms, ...}`; không log body người dùng.
- Kiểu CSDL: dùng `database.types.ts` sinh bởi `supabase gen types`.

### 2.4. Ingest — luật riêng
- Mỗi nguồn: `fetch.ts` (I/O) · `parse.ts` (thuần: text → `RawReading[]`) · `normalize.ts` (thuần: → `Observation[]`, đổi giờ VN → UTC, đổi đơn vị → cm, QC) · `handler.ts` (ghép + upsert + ghi `source_runs`).
- Upsert theo `(station_id, observed_at)`, batch ≤ 1000 dòng.
- Chạy lại nhiều lần **không** tạo trùng (idempotent) — có test.
- Mã trạm lạ (chưa có trong `station_aliases`) → bỏ qua + đếm + log `warn` (không tự tạo trạm).
- Ghi `source_runs`: `running` → `ok`/`partial`/`error` kèm số dòng & lỗi rút gọn (≤ 500 ký tự).
- Fixtures: lưu ≥ 2 phản hồi thật (một bình thường, một có lỗi/thiếu dữ liệu) — **xóa thông tin nhạy cảm** nếu có.

## 3. Python (`tools/tide`)
- Python 3.11+, định dạng `ruff format`, lint `ruff check`, kiểu `mypy --strict` cho module chính.
- Mỗi script có `main()` + `argparse`, không chạy logic khi import.
- Secrets đọc từ biến môi trường (`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`), KHÔNG hard-code, KHÔNG in ra log.
- Kiểm định bằng dữ liệu IOC thật (`tools/tide/validate.py`); không có test tự động (docs/rules/05).
- Đầu ra file triều PHẢI đúng định dạng PROJECT.md 8.5 và có `model.version`, `rmse_cm`.
