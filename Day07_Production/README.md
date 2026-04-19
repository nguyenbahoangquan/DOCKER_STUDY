# 🗓️ Day 7: CI/CD & Production Best Practices

## 🎯 Mục tiêu bài học
- Biết cách Push image lên Docker Hub (Registry).
- Tự động hóa quá trình build & push bằng GitHub Actions.
- Áp dụng các Best Practices về Security (Non-root user, Trivy scan).

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Docker Hub & Registry
Registry là nơi lưu trữ tập trung các Docker Images (như GitHub cho source code).
- **Lệnh**: `docker login`, `docker tag`, `docker push`.
- **Convention**: `username/image-name:tag`.

### 2. CI/CD với GitHub Actions
Khi bạn push code lên GitHub, GitHub Actions sẽ:
1. Checkout code.
2. Build Docker Image.
3. Đăng nhập Docker Hub (Dùng Secrets để bảo mật).
4. Push Image.

### 3. Production Best Practices
- **Security**: Chạy container dưới `USER appuser` (non-root) để hạn chế quyền truy cập nếu bị exploit.
- **Scanning**: Dùng các công cụ như `Trivy` hoặc `Snyk` để quét lỗ hổng bảo mật (CVE) trong Image.
- **Immutability**: Dùng version tag rõ ràng (v1.0.1) thay vì chỉ dùng `:latest`.
- **Resource Limits**: Luôn giới hạn Memory và CPU khi chạy container.

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Push lên Docker Hub
1. Đăng ký tài khoản Docker Hub.
2. Gắn tag cho image: `docker tag my-java-app:latest <username>/my-java-app:v1`.
3. Push: `docker push <username>/my-java-app:v1`.

### Bài 2: Security - Non-root User
1. Sửa Dockerfile thêm đoạn lệnh tạo User:
   ```dockerfile
   RUN addgroup -S appgroup && adduser -S appuser -G appgroup
   USER appuser
   ```
2. Build lại và chạy: `docker exec -it <name> whoami` -> Kết quả phải là `appuser`.

### Bài 3: GitHub Actions Workflow (Mô phỏng)
Tạo file `.github/workflows/docker.yml` trong project và thử đọc hiểu cấu trúc file này.

---

## 📝 Câu hỏi suy ngẫm

1. Tại sao không nên lưu file `.env` hoặc API Key trực tiếp vào Docker Image?
   > Trả lời:

2. Làm thế nào để Docker container tự khởi động lại khi Server bị Restart? (Gợi ý: Tìm hiểu `--restart always`).
   > Trả lời:

3. Ý nghĩa của việc dùng `docker push` so với việc dùng `docker save` ra file `.tar` là gì?
   > Trả lời:
