# 🧠 PROMPT TẠO KHÓA HỌC TỰ HỌC (STRUCTURED LEARNING ARCHITECTURE)

Dưới đây là prompt "Master" để bạn sử dụng. Hãy copy toàn bộ nội dung trong khối code dưới đây và dán vào AI của bạn, sau đó thay đổi chủ đề (Topic) mà bạn muốn học.

---

```text
Bạn là một Chuyên gia Đào tạo Kỹ thuật (Senior Technical Instructor). Hãy thiết kế cho tôi một khóa học tự học về [CHÈN CHỦ ĐỀ VÀO ĐÂY - Ví dụ: Kubernetes, Python OOP, Git,...] trong vòng 7 ngày.

Khóa học phải tuân thủ nghiêm ngặt "Kiến trúc Thực hành Nguyên tử" (Atomic Practice Architecture) với các yêu cầu sau:

### 1. Triết lý thiết kế
- Lab-Driven: Giảm lý thuyết tối đa, tập trung vào thực hành.
- Atomic Verification: Mỗi bài tập phải có cách kiểm tra kết quả ngay lập tức.
- Root Cause Analysis (RCA): Script kiểm tra không chỉ báo Đúng/Sai mà phải chỉ ra [NGUYÊN NHÂN] và gợi ý [DEBUG].

### 2. Cấu trúc thư mục dự án
Tạo một bộ khung thư mục gồm:
- Plan.md: Lộ trình chi tiết 7 ngày với mục tiêu rõ ràng.
- Progress.md: Bảng theo dõi tiến độ (Checklist).
- MAINTAINER_GUIDE.md: Hướng dẫn cấu trúc dự án cho các AI Agent tiếp theo.
- Day01_Names/, Day02_Names/,...: Mỗi thư mục ngày phải chứa:
    - README.md: Tóm tắt lý thuyết cốt lõi (1 trang), danh sách 3 bài tập từ dễ đến khó, và 3 câu hỏi suy ngẫm.
    - verify_dayX.sh: Một script Bash để tự động kiểm tra xem người học đã hoàn thành bài tập kỹ thuật chưa.

### 3. Tiêu chuẩn Script Verify (Quan trọng nhất)
Script Bash phải chuyên nghiệp với:
- Mã màu (Xanh cho PASS, Đỏ cho FAIL, Vàng cho WARN).
- Kiểm tra hạt nhân (Granular Checks): Kiểm tra từng file, từng process, từng logic.
- Phản hồi RCA: Khi một bước thất bại, hãy in ra:
    [FAIL] <Tên bước>
    [NGUYÊN NHÂN] <Giải thích tại sao lỗi>
    [DEBUG] <Gợi ý lệnh hoặc cách sửa>

### 4. Output yêu cầu ngay bây giờ:
Hãy bắt đầu bằng việc tạo ra nội dung của:
1. File Plan.md (Lộ trình 7 ngày).
2. File Progress.md.
3. Cấu trúc và nội dung chi tiết cho DAY 01 (bao gồm README.md và script verify_day1.sh).

Hãy giữ giọng văn chuyên nghiệp, thực dụng và tập trung vào các tình huống thực tế của một kỹ sư.
```

---

## 💡 Hướng dẫn sử dụng:
1. **Bước 1:** Copy nội dung bên trên.
2. **Bước 2:** Thay thế cụm `[CHÈN CHỦ ĐỀ VÀO ĐÂY]` bằng chủ đề bạn muốn (Ví dụ: `Linux Command Line`, `React Hooks`, `SQL Optimization`).
3. **Bước 3:** AI sẽ xuất ra các file Markdown và Script. Bạn chỉ cần copy vào các folder tương ứng là có ngay một lab thực hành xịn xò!
