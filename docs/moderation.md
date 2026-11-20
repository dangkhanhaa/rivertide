# Kiểm duyệt cộng đồng & chống spam (P2-54, P2-61)

> Dành cho chủ dự án. Mọi lệnh dưới đây chạy trong **Supabase → SQL Editor** (vai trò `postgres`)
> hoặc bằng khóa `service_role` từ máy chủ. App (khóa `anon`) **không gọi được** các hàm `mod_*`.
> Migration: `supabase/migrations/0005_anti_spam.sql`, `0008_curated_mode.sql`. Kiểm tra:
> `supabase/tests/anti_spam_check.sql`, `supabase/tests/curated_mode_check.sql`.

## 0. Duyệt trước — việc hằng ngày (P2-61)

App không xác thực số điện thoại, nên theo Nghị định 147/2024 nội dung công khai **phải được duyệt
trước khi hiện**. Bài mới ở trạng thái **chờ duyệt**: chỉ người đăng thấy (kèm nhãn "Đang chờ
duyệt"), người khác không thấy cho tới khi bạn duyệt.

**Cam kết: duyệt hoặc từ chối mọi bài trong vòng 24 giờ.** App hứa với người dùng "thường trong
24 giờ" — bỏ 1 ngày là người dùng thấy app "không chạy".

| Loại (`kind`) | Chờ duyệt khi | Không cần duyệt |
|---|---|---|
| `spot` | đăng điểm câu, sửa tên/ghi chú/loài/ảnh | — |
| `comment` | bình luận mới, sửa bình luận | — |
| `trip` | tạo kèo, sửa tên/ghi chú kèo | đổi giờ, số người, liên hệ (chỉ thành viên thấy) |
| `pond` | thêm hồ | — |
| `pond_edit` | người khác (kể cả người tạo) sửa hồ đã duyệt | **chủ hồ đã xác minh** sửa hồ của mình |
| `release` | người dùng báo lịch xả | **chủ hồ đã xác minh** đăng lịch xả (đã gọi điện xác minh khi duyệt nhận hồ) |
| `review` | đánh giá mới, sửa đánh giá | — |

Không duyệt: tin nhắn trong kèo (chỉ thành viên thấy), "Đang câu", "Có dính không", báo nhanh ở hồ,
xác nhận hồ, báo cáo, chặn. Nội dung có từ trước P2-61 coi như đã duyệt.

Bản sửa của bài đã duyệt: người khác vẫn thấy **bản cũ** cho tới khi bạn duyệt bản sửa; người
đăng thấy bản sửa kèm nhãn "Bản sửa đang chờ duyệt".

### Mỗi ngày (5 phút)

```sql
-- 1. Còn bao nhiêu bài chờ, bài cũ nhất chờ bao lâu (waiting phải < 24 giờ).
select * from public.mod_pending_summary();

-- 2. Danh sách chờ, cũ nhất trước. preview = nội dung; device_age = tuổi máy đăng;
--    strikes = số gậy. Sửa (change = 'edit') có "| trước: …" là bản đang hiện.
select kind, change, preview, device_age, strikes, approve_sql, reject_sql
  from public.mod_pending(100);
```

3. Copy cột `approve_sql` của các bài ổn, dán vào SQL Editor, Run (chạy nhiều dòng một lần được):

```sql
select public.mod_approve('spot', '<item_id>', NULL);
select public.mod_approve('review', '<pond_id>', '<author_hash>');   -- đánh giá cần mã tác giả
select public.mod_approve('pond_edit', '<pond_id>', '<editor_hash>'); -- sửa hồ cần mã người sửa
```

4. Bài không ổn: copy `reject_sql`, thay `'lý do'` bằng lý do ngắn (người đăng **không** thấy lý
do trong app, chỉ thấy "Không được duyệt"; lý do lưu để bạn tra lại). Spam/lừa đảo: thêm `true`
để cho tác giả 1 gậy (3 gậy = khóa đăng):

```sql
select public.mod_reject('comment', '<item_id>', 'quảng cáo', NULL);
select public.mod_reject('comment', '<item_id>', 'lừa đảo', NULL, true);   -- kèm 1 gậy
```

Bài bị từ chối: ẩn với mọi người, người đăng thấy "Không được duyệt" trong 30 ngày; nếu họ sửa
lại, bài quay về chờ duyệt. Bản sửa bị từ chối: bản cũ vẫn hiện, người đăng thấy "Bản sửa không
được duyệt" trong 7 ngày.

### Mẹo cho nhanh

```sql
-- Người quen đăng nhiều, đã xem qua: duyệt hết bài đang chờ của 1 máy.
select public.mod_approve_all_from('<author_hash>');

-- Mọi thứ 1 máy đã đăng 7 ngày (để quyết định có tin máy này không).
select * from public.mod_recent_content(24 * 7, '<author_hash>');
```

### Bật / tắt duyệt trước từng loại

Chỉ tắt khi đã có cách xác thực khác (vd. OTP số điện thoại) hoặc được tư vấn pháp lý. Tắt xong,
bài **mới** của loại đó hiện ngay; bài đang chờ vẫn phải duyệt tay. App vẫn báo "sẽ hiện sau khi
được duyệt" cho tới khi cập nhật chữ trong app.

```sql
select * from public.curation;
update public.curation set pre_moderate = false where kind = 'release';
```

### Áp dụng & kiểm tra

1. SQL Editor → dán toàn bộ `supabase/migrations/0008_curated_mode.sql` → Run.
2. SQL Editor → dán `supabase/tests/curated_mode_check.sql` → Run (trong `begin … rollback`,
   không để lại dữ liệu). Đạt khi thông báo cuối là `ALL CURATED-MODE CHECKS PASSED`.

## 1. Hệ thống hoạt động thế nào

Không có đăng nhập: mỗi máy tự sinh một khóa bí mật, server chỉ lưu SHA-256 (gọi là **mã máy**,
`device_hash`, 64 ký tự hex). Kẻ spam có thể tạo khóa mới tùy ý, nên từ P2-54 server kiểm thêm:

| Lớp | Làm gì |
|---|---|
| **Giới hạn theo IP** | Mỗi lượt ghi (bình luận, đăng điểm, báo cáo…) đi qua `public.guard()`. Server đọc IP từ header (`cf-connecting-ip`, rồi `x-forwarded-for` hop đầu, rồi `x-real-ip`), chỉ lưu **HMAC-SHA256 của IP** (IPv6 gộp theo /64) với khóa bí mật trong `private.secrets`. Không lưu IP gốc. Dữ liệu IP xóa sau **7 ngày**. |
| **Giới hạn theo máy** | Khoảng cách tối thiểu giữa 2 lượt + số lượt/ngày. Máy mới (< 10 phút) có hạn mức thấp hơn. Mỗi IP chỉ tạo được 10 máy mới/giờ, 40/ngày. |
| **Lọc nội dung** | Chặn link, số điện thoại, mời Zalo/Telegram/inbox, quảng cáo cờ bạc/vay tiền, từ thô tục (danh sách sửa được), lặp chữ ≥ 5 lần, viết HOA toàn bộ (văn bản dài), gửi lại y hệt nội dung trong 24 giờ, tên giả danh quản trị. Ô số điện thoại/Zalo của hồ câu, ô liên hệ của kèo câu vẫn được ghi số. |
| **Báo cáo có trọng số** | Mỗi IP chỉ tính 1 phiếu/nội dung; máy < 1 ngày tuổi tính 0,5. Ẩn khi tổng trọng số ≥ 3 **và** từ ≥ 3 IP khác nhau. Mỗi máy tối đa 20 báo cáo/ngày. |
| **Gậy & khóa** | Nội dung bị ẩn do báo cáo → tác giả nhận 1 gậy (gậy quá 30 ngày bị quên). 3 gậy → khóa đăng 7 ngày (lần 2: 30 ngày, lần 3+: 90 ngày) và mọi nội dung 7 ngày gần nhất của máy đó chuyển sang **ẩn bóng** (shadow). |
| **Ẩn bóng (shadow)** | Nội dung vẫn hiện với chính tác giả, người khác không thấy. Dùng cho máy bị khóa và cho kẻ lách luật (quản trị đặt tay). |

App nhận lỗi: `hint = rate_limit` (detail `burst` / `daily` / `new_device`), `content_blocked`
(detail = lý do: `link`, `phone`, `contact_ad`, `spam`, `offensive`, `chars`, `shouting`,
`impersonation`, `repeat`), `banned` (detail = thời điểm hết khóa, UTC). App cũ chỉ hiểu
`rate_limit`, các lỗi mới hiện thông báo chung "Chưa gửi được".

## 2. Sau khi áp migration — kiểm tra IP có đọc được không

```sql
-- Chờ vài người dùng thật gửi bài, rồi xem nguồn IP của 24 giờ qua.
select * from public.mod_ip_sources(24);
```

- `cf` hoặc `xff` chiếm gần hết → giới hạn IP đang hoạt động.
- Toàn `none` → server không thấy header IP: chỉ còn giới hạn theo máy. Báo lại để sửa
  `public.client_ip()`.

## 3. Xem nội dung bị báo cáo

```sql
-- Nội dung bị báo cáo trong 7 ngày, nặng nhất trước.
-- weight = tổng trọng số, distinct_ips = số IP khác nhau đã báo.
select kind, item_id, author_hash, preview, reports, weight, distinct_ips, hidden, shadow, last_report
  from public.mod_flagged(7);
```

```sql
-- Mọi thứ đăng trong 24 giờ qua (mới nhất trước).
select * from public.mod_recent_content(24);

-- Mọi thứ một máy đã đăng trong 7 ngày.
select * from public.mod_recent_content(24 * 7, '<device_hash 64 ký tự>');
```

## 4. Tìm nguồn spam

```sql
-- IP bận nhất 24 giờ qua: nhiều máy / nhiều máy mới trên 1 IP = có thể là script.
-- CẨN THẬN: mạng di động VN dùng chung IP (CGNAT) — xem họ đăng gì trước khi chặn.
select * from public.mod_top_ips(24, 20);

-- Máy bận nhất 24 giờ qua, kèm gậy / khóa.
select * from public.mod_top_devices(24, 20);
```

## 5. Xử lý

```sql
-- Khóa đăng 1 máy 7 ngày, kèm ẩn bóng nội dung 7 ngày gần nhất.
select public.mod_ban_device('<device_hash>', 7, 'spam quảng cáo');

-- Khóa nhưng KHÔNG ẩn nội dung cũ.
select public.mod_ban_device('<device_hash>', 7, 'cảnh cáo', false);

-- Ẩn bóng 30 ngày: vẫn cho đăng nhưng không ai khác thấy (kẻ lách luật sẽ không biết).
select public.mod_shadow_device('<device_hash>', 30);

-- Gỡ khóa + gỡ ẩn bóng + xóa gậy, và hiện lại nội dung đã ẩn bóng.
select public.mod_unban_device('<device_hash>');
-- Gỡ khóa nhưng giữ nội dung đang ẩn bóng.
select public.mod_unban_device('<device_hash>', false);

-- Chặn 1 IP (tối đa 168 giờ = 7 ngày). mode 'block' = từ chối, 'shadow' = nhận nhưng ẩn bóng.
select public.mod_block_ip('<ip_hash>', 24, 'block', 'flood bình luận');
select public.mod_unblock_ip('<ip_hash>');
```

Ẩn / hiện một nội dung (`kind`: `spot`, `comment`, `trip`, `trip_msg`, `pond`, `release`, `review`):

```sql
-- Ẩn bình luận; tham số cuối true = cho tác giả thêm 1 gậy.
select public.mod_set_hidden('comment', '<item_id>', true, null, true);

-- Hiện lại (vd bị báo cáo oan). Gậy đã cho không tự gỡ — dùng mod_unban_device nếu cần.
select public.mod_set_hidden('comment', '<item_id>', false);

-- Đánh giá hồ: item_id là id hồ, thêm mã máy tác giả.
select public.mod_set_hidden('review', '<pond_id>', true, '<author_hash>');
```

Hồ đã có chủ (đã duyệt nhận hồ) không bị ẩn tự động bởi báo cáo — chỉ quản trị ẩn bằng
`mod_set_hidden('pond', …)`.

## 6. Sửa danh sách từ bị chặn

`match`: `word` = khớp nguyên từ, **bỏ dấu** (chỉ dùng cho từ không trùng từ thường khi bỏ dấu);
`accented` = khớp nguyên từ **giữ dấu** (vd "lồn" không được bắt nhầm "lớn"); `name_part` = nằm
bất kỳ đâu trong tên hiển thị (bỏ dấu, bỏ khoảng trắng).

```sql
select * from public.blocked_terms order by category, term;

insert into public.blocked_terms (term, category, match) values ('bắn cá đổi thưởng', 'spam', 'accented');
delete from public.blocked_terms where term = 'sex';

-- Thử một câu trước khi thêm/xóa: trả về lý do hoặc null.
select public.content_issue('Câu mồi cơm, các bạn ra buổi sáng nhé', 'text');
```

App có bản sao ngắn của danh sách để báo ngay khi gõ (`app/lib/core/social/content_filter.dart`);
server luôn là nơi quyết định.

## 7. Chỉnh hạn mức

```sql
select * from public.rate_limits order by action;

-- Ví dụ: cho bình luận 50/ngày/máy, 600/ngày/IP.
update public.rate_limits set device_day = 50, ip_day = 600 where action = 'comment';
```

Cột: `min_gap_s` (giây giữa 2 lượt của 1 máy), `device_day`, `new_device_day` (máy < 10 phút),
`ip_minute`, `ip_hour`, `ip_day` (`null` = không giới hạn). Dòng `all` là tổng mọi hành động
của 1 IP; dòng `new_device` là số máy mới mỗi IP.

Mặc định (P2-54):

| action | Giữa 2 lượt | /máy/ngày | Máy mới | /IP/giờ | /IP/ngày |
|---|---|---|---|---|---|
| all (mọi thứ) | – | – | – | 600 (và 40/phút) | – |
| new_device | – | – | – | 10 | 40 |
| spot | 60 s | 10 | 2 | 20 | 60 |
| spot_edit | 5 s | 40 | 10 | 60 | 300 |
| comment | 15 s | 30 | 5 | 60 | 400 |
| comment_edit | 5 s | 50 | 10 | 100 | 500 |
| trip | 60 s | 5 | 1 | 10 | 40 |
| trip_edit | 5 s | 30 | 10 | 60 | 300 |
| trip_join | 3 s | 30 | 10 | 100 | 500 |
| trip_msg | 5 s | 100 | 15 | 300 | 2000 |
| pond | 60 s | 5 | 1 | 10 | 30 |
| pond_edit | 10 s | 20 | 3 | 40 | 150 |
| pond_confirm | 3 s | 30 | 5 | 60 | 300 |
| release | 30 s | 10 | 2 | 20 | 80 |
| review | 15 s | 20 | 3 | 40 | 200 |
| pulse | 5 s | 60 | 10 | 120 | 1000 |
| claim | 60 s | 3 | 1 | 5 | 15 |
| report | 3 s | 20 | 3 | 40 | 150 |
| checkin | 5 s | 60 | 20 | 300 | 3000 |
| bite | 5 s | 30 | 5 | 200 | 1500 |

Hạn mức IP gấp 4–10 lần hạn mức máy vì nhà mạng di động VN cho nhiều thuê bao dùng chung một IP
(CGNAT). Nếu người dùng thật ở cùng khu báo "gửi hơi nhanh"/"đủ lượt" nhiều, nâng `ip_hour`/`ip_day`.

## 8. Quyền riêng tư & dọn dữ liệu

- Không lưu IP gốc, chỉ HMAC với khóa ngẫu nhiên tạo lúc chạy migration (`private.secrets`, không
  đọc được qua API). Không lưu nội dung trong bảng giới hạn — chỉ md5 của văn bản đã bỏ dấu (để
  phát hiện gửi lặp).
- `rate_events` (lượt ghi + IP hash) xóa sau 7 ngày; IP hash trong `item_votes` bị xóa (null) sau
  7 ngày; chặn IP tối đa 7 ngày. Việc dọn chạy ngẫu nhiên ~1% lượt ghi, và hằng ngày lúc 03:17 UTC
  nếu bật `pg_cron`. Chạy tay: `select public.purge_abuse_data();`
- Lỗi trả về app chỉ chứa mã lý do, không chứa nội dung người dùng.

## 9. Áp dụng & kiểm tra

1. SQL Editor → dán toàn bộ `supabase/migrations/0005_anti_spam.sql` → Run (hoặc `supabase db push`).
2. SQL Editor → dán `supabase/tests/anti_spam_check.sql` → Run. Script chạy trong
   `begin … rollback` nên **không để lại dữ liệu**. Đạt khi dòng cuối là
   `ALL ANTI-SPAM CHECKS PASSED`; sai sẽ dừng với lỗi bắt đầu bằng `FAIL`.
3. Sau 1 ngày có người dùng: `select * from public.mod_ip_sources(24);` (mục 2).

## 10. Giới hạn còn lại

- Người có nhiều IP thật (bật/tắt chế độ máy bay để đổi IP di động) và chịu chờ máy "già" 1 ngày
  vẫn có thể báo cáo hội đồng; hệ thống chỉ làm việc đó tốn công hơn. Hãy xem `mod_flagged` định kỳ.
- Lượt bị từ chối không được ghi lại (lỗi hủy cả giao dịch) — xem số lỗi 4xx trong Supabase
  → Logs → API nếu cần.
- Ảnh tải lên bucket `spot-photos` chưa có giới hạn tần suất (Storage không đi qua `guard()`).
- `x-forwarded-for` có thể bị giả nếu request không qua Cloudflare; `cf-connecting-ip` được ưu tiên.
