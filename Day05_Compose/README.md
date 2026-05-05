# 🗓️ Day 5: Docker Compose (Multi-Service)

## 🎯 Mục tiêu bài học
- Thành thạo cấu trúc tệp `docker-compose.yml` (V2).
- Biết cách tách biệt cấu hình và mã nguồn thông qua tệp biến môi trường `.env`.
- Hiểu cơ chế phụ thuộc giữa các dịch vụ (`depends_on`).

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Tại sao dùng Docker Compose?
Thay vì chạy 10 lệnh `docker run` thủ công, bạn khai báo tất cả vào file `.yml`. 
- **Infrastructure as Code:** Cấu hình hệ thống được lưu vết.
- **Isolations:** Tự động tạo Network riêng cho các service trong cùng stack.
- **DNS nội bộ:** Các service gọi nhau bằng tên (ví dụ: `web` gọi `db`).

### 2. Quản lý biến môi trường với `.env`
Docker Compose tự động tìm kiếm tệp tên là `.env` trong cùng thư mục.
- Cú pháp trong `.env`: `KEY=VALUE`
- Cú pháp trong `.yml`: `${KEY}` hoặc `${KEY:-default_value}`

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Dựng stack Web + Cache + DB (Sửa lỗi Logic)
Trong bài tập này, chúng ta sẽ dựng một stack gồm Nginx, Redis và MySQL. Hãy đảm bảo Port mapping được gán đúng cho dịch vụ cần thiết.

1. Cập nhật `docker-compose.yml`:
   ```yaml
   services:
     web:
       image: nginx:alpine
       ports:
         - "${WEB_PORT:-8085}:80" # Map từ host vào Nginx
       depends_on:
         - cache
         - db
     cache:
       image: redis:alpine
     db:
       image: mysql:8.0
       environment:
         MYSQL_ROOT_PASSWORD: ${MYSQL_PASS}
   ```

2. Tạo file `.env` để bảo mật thông tin:
   ```env
   WEB_PORT=8085
   MYSQL_PASS=your_secure_password
   ```

3. Chạy stack:
   ```bash
   sudo docker compose up -d
   ```

### Bài 2: Kiểm tra cấu hình (Debugging)
Dùng lệnh sau để kiểm tra xem Docker Compose đã nạp biến từ `.env` vào file `.yml` đúng chưa:
```bash
sudo docker compose config
```

### Bài 3: Kiểm tra tính phụ thuộc
Dùng lệnh `docker compose ps` để xem trạng thái. Thử dừng `db` và xem `web` có bị ảnh hưởng không.

---

## 📝 Câu hỏi suy ngẫm

1. Tại sao không nên mở cổng (ports) cho `db` và `cache` ra ngoài host?
   > Trả lời: Để tăng tính bảo mật. Các dịch vụ này chỉ cần được truy cập nội bộ bởi ứng dụng (`web`). Việc mở port ra host sẽ tạo cơ hội cho các cuộc tấn công từ bên ngoài.

2. Lệnh `docker compose config` giúp ích gì trong quá trình CI/CD?
   > Trả lời: Nó giúp kiểm tra cú pháp file YAML và xác nhận các biến môi trường được nội suy (interpolate) chính xác trước khi thực triển khai, giúp tránh lỗi runtime trên server.

3. `depends_on` có đảm bảo ứng dụng bên trong container (ví dụ: MySQL) đã sẵn sàng nhận kết nối chưa?
   > Trả lời: Không hoàn toàn. `depends_on` chỉ đảm bảo container MySQL đã ở trạng thái "Running", nhưng không biết được tiến trình MySQL bên trong đã hoàn tất việc khởi tạo database và sẵn sàng nhận kết nối hay chưa. Để xử lý triệt để, cần dùng thêm các script `wait-for-it.sh` hoặc cơ chế `healthcheck`.
