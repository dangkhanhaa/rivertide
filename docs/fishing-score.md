# Nhật ký công thức chỉ số câu cá

> Mỗi lần đổi trọng số/ngưỡng: tăng version, ghi lý do. Công thức hiện hành: PROJECT.md mục 9.6.

| Version | Ngày | Thay đổi | Lý do |
|---|---|---|---|
| `fs-1` | 2026-11-06 | Công thức khởi đầu: tide 0.30 · solunar 0.25 · pressure 0.20 · daytime 0.10 · weather 0.10 · season 0.05; luật an toàn dông ≤ 2.0, mưa lớn ≤ 3.0 | Dựa trên kinh nghiệm dân gian + tài liệu solunar; chưa có dữ liệu thật |
| `fs-2` | 2026-11-16 | Mỗi giờ 4 mẫu 15 phút, thành phần dạng đường cong trơn; `S = 10 × T × (0.5 + 0.5 × C) + thưởng trùng khớp` (T: con nước 0.40 · solunar 0.33 · ánh sáng 0.27; C: áp suất 0.35 · nhiệt độ 0.30 · gió mưa 0.25 · mùa 0.10); con nước theo tốc độ dòng chảy tương đối trong ngày; áp suất Δ24h thay Δ3h; thêm nhiệt độ; điểm ngày = (top 3 + trung vị)/2; lý do chỉ nêu yếu tố thời điểm + áp suất | Người dùng báo giờ cá ăn không chuẩn. Δ3h áp suất ở nhiệt đới bị chi phối bởi dao động bán nhật của khí quyển (~2–3 hPa) → chiều nào cũng "tốt"; mô hình cũ cộng điều kiện thời tiết đẹp vào mọi giờ nên gần như cả ngày ≥ 7, giờ vàng không nổi bật. Kiểm bằng ngày giả lập Cần Thơ: giờ vàng rơi vào bình minh/hoàng hôn trùng giờ trăng chính và nước đang chảy; nước đứng giữa trưa ~4–5 điểm |
