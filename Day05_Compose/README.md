# 🗓️ Day 5: Docker Compose (Multi-Service)

## 🎯 Mục tiêu bài học
- Hiểu cấu trúc file `docker-compose.yml`.
- Chạy toàn bộ hệ thống (App + DB) chỉ với một lệnh.
- Quản lý vòng đời của một stack ứng dụng.

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Tại sao dùng Docker Compose?
Thay vì chạy 10 lệnh `docker run` thủ công với hàng chục flags, bạn khai báo tất cả vào file `.yml` và chỉ cần chạy `docker compose up`. Nó giúp cấu hình được lưu lại (Version control) và dễ dàng chia sẻ.

### 2. Cấu trúc cơ bản của `docker-compose.yml`
```yaml
version: "3.8"  # Phiên bản cấu trúc compose

services:       # Danh sách các container
  web:
    image: nginx
    ports:
      - "80:80"
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root

volumes:        # Khai báo volumes dùng chung
  db-data:

networks:       # Khai báo networks dùng chung
  frontend:
```

### 3. Các lệnh Compose quan trọng
| Lệnh | Ý nghĩa |
| :--- | :--- |
| `docker compose up -d` | Build (nếu cần) và khởi động toàn bộ stack ở chế độ nền. |
| `docker compose down` | Dừng và xoá sạch containers, networks trong file. |
| `docker compose ps` | Xem trạng thái các container trong stack. |
| `docker compose logs -f` | Xem log của toàn bộ services. |
| `docker compose restart <service>` | Khởi động lại một service cụ thể. |

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Dựng stack Web + Redis
1. Tạo file `docker-compose.yml`:
   ```yaml
   version: "3.8"
   services:
     web:
       image: nginx:alpine
       ports:
         - "8085:80"
     cache:
       image: redis:alpine
   ```
2. Chạy: `docker compose up -d`.
3. Kiểm tra: `docker compose ps`.
4. Xem log: `docker compose logs -f`.

### Bài 2: Sử dụng biến môi trường (.env)
1. Tạo file `.env`:
   ```text
   MYSQL_PASS=supersecret
   ```
2. Cập nhật `docker-compose.yml`:
   ```yaml
   services:
     db:
       image: mysql:8.0
       environment:
         MYSQL_ROOT_PASSWORD: ${MYSQL_PASS}
   ```
3. Chạy lại: `docker compose up -d`.

### Bài 3: Scaling (Tuỳ chọn)
Thử chạy: `docker compose up -d --scale web=3` (Lưu ý: Bạn phải bỏ `ports` cố định ở service web để tránh xung đột port).

---

## 📝 Câu hỏi suy ngẫm

1. Sự khác biệt giữa `docker compose down` và `docker compose stop` là gì?
   > Trả lời:

2. Làm thế nào để tự động build lại image khi file source code thay đổi trong Docker Compose? (Gợi ý: Dùng flag `--build`).
   > Trả lời:

3. Tên host mặc định mà các service dùng để gọi nhau trong cùng một Compose stack là gì?
   > Trả lời:
