# 🛠 DOCKER_STUDY - Maintainer & Developer Guide

Tài liệu này dành cho các AI Agent hoặc Developer tiếp nhận việc phát triển và bảo trì khóa học tự học Docker này.

## 1. Triết lý thiết kế (Core Philosophy)
- **Lab-Driven Learning:** Không dạy lý thuyết suông. Mỗi ngày học phải đi kèm với folder thực hành riêng.
- **Atomic Verification:** Mỗi bài tập kỹ thuật phải có script verify tự động (`.sh`) để người học tự kiểm tra kết quả ngay lập tức.
- **Root Cause Analysis (RCA):** Script verify phải cung cấp giải thích [NGUYÊN NHÂN] và gợi ý [DEBUG] thay vì chỉ báo PASS/FAIL đơn thuần.
- **Iterative Progress:** Người học phải cập nhật `Progress.md` sau mỗi buổi để duy trì động lực.

## 2. Cấu trúc dự án
```text
DOCKER_STUDY/
├── Plan.md                 # Lộ trình tổng thể 7 ngày (Refined)
├── Progress.md             # File theo dõi tiến độ cá nhân
├── MAINTAINER_GUIDE.md     # File này (Hướng dẫn cho AI tiếp theo)
├── Day01_Basics/           # Folder từng ngày
│   ├── README.md           
│   └── verify_day1.sh      
└── DayXX_.../              # Các ngày tiếp theo tuân thủ cấu trúc trên
```

## 3. Quy chuẩn Script Verify (RCA Style)
Mọi script `verify_dayX.sh` cần tuân thủ cấu trúc:
1. **Granular Check:** Chia nhỏ từng bước kiểm tra (ví dụ: Check file -> Check Service -> Check Logic).
2. **Color Coding:** Sử dụng màu sắc (BLUE cho tiêu đề, GREEN cho PASS, RED cho FAIL, CYAN cho DEBUG).
3. **Actionable Feedback:** Khi FAIL, phải chỉ ra lý do tại sao (ví dụ: "Thiếu port mapping", "Container bị thoát ngay khi start").

## 4. Trạng thái hiện tại (Current Status)
- **Hoàn thành:** Day 1 đến Day 5 (Nội dung & Script chuẩn RCA).
- **Đang thực hiện:** Day 6 - Debug & Optimization.

## 5. Lưu ý cho AI tiếp theo
- Giữ phong cách chuyên nghiệp, Senior Engineer nhưng giải thích dễ hiểu.
- Ưu tiên sử dụng các ví dụ về Java/C++.
- Khi có lỗi hệ thống (như thiếu plugin Compose V2), hãy hướng dẫn người học cách cài đặt trực tiếp trên môi trường của họ.
