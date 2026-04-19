# 🛠 DOCKER_STUDY - Maintainer & Developer Guide

Tài liệu này dành cho các AI Agent hoặc Developer tiếp nhận việc phát triển và bảo trì khóa học tự học Docker này.

## 1. Triết lý thiết kế (Core Philosophy)
- **Lab-Driven Learning:** Không dạy lý thuyết suông. Mỗi ngày học phải đi kèm với folder thực hành riêng.
- **Atomic Verification:** Mỗi bài tập kỹ thuật phải có script verify tự động (`.sh`) để người học tự kiểm tra kết quả ngay lập tức.
- **Iterative Progress:** Người học phải cập nhật `Progress.md` sau mỗi buổi để duy trì động lực.

## 2. Cấu trúc dự án
```text
DOCKER_STUDY/
├── Plan.md                 # Lộ trình tổng thể 7 ngày (Refined)
├── Progress.md             # File theo dõi tiến độ cá nhân
├── MAINTAINER_GUIDE.md     # File này (Hướng dẫn cho AI tiếp theo)
├── Day01_Basics/           # Folder từng ngày (Mẫu chuẩn)
│   ├── README.md           # Lý thuyết tóm tắt, Bài tập thực hành, Câu hỏi tư duy
│   └── verify_day1.sh      # Script tự động kiểm tra bài tập
└── DayXX_.../              # Các ngày tiếp theo tuân thủ cấu trúc trên
```

## 3. Quy trình phát triển một ngày học mới (Workflow)
Khi người học yêu cầu chuẩn bị cho ngày tiếp theo (ví dụ Day 2), AI Agent cần:
1. **Nghiên cứu:** Xem `Plan.md` để biết mục tiêu của ngày đó.
2. **Cấu trúc:** Tạo folder `DayXX_Name`.
3. **Nội dung (`README.md`):**
    - Tóm tắt lý thuyết (ngắn gọn, tập trung vào bản chất).
    - Danh sách bài tập (từ dễ đến khó).
    - Mục "Câu hỏi suy ngẫm" để kiểm tra mức độ hiểu sâu.
4. **Xác minh (`verify_dayX.sh`):** Viết script bash để kiểm tra các dấu vết kỹ thuật (container name, image tồn tại, port open, v.v.).
5. **Cập nhật:** Nhắc người học tick vào `Progress.md`.

## 4. Trạng thái hiện tại (Current Status)
- **Hoàn thành:** Cấu trúc dự án, Plan 7 ngày, Progress tracker, Nội dung & Script cho Day 1.
- **Tiếp theo:** Day 2 - Docker CLI & Container Management.

## 5. Lưu ý cho AI tiếp theo
- Giữ phong cách chuyên nghiệp, Senior Engineer nhưng giải thích dễ hiểu.
- Ưu tiên sử dụng các ví dụ về Java/C++ như đã định nghĩa trong Plan ban đầu.
- Luôn kiểm tra xem người học đã hoàn thành ngày trước đó chưa trước khi nhảy sang ngày mới.
