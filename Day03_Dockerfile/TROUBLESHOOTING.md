# Nhật ký xử lý lỗi (Troubleshooting Log)

## 2026-04-21: Lỗi build Docker với `openjdk:17-slim`

### 1. Vấn đề (Issue)
Khi chạy lệnh `docker build -t my-java-app .`, gặp lỗi sau:
```text
Step 1/5 : FROM openjdk:17-slim
manifest for openjdk:17-slim not found: manifest unknown: manifest unknown
```

### 2. Nguyên nhân (Root Cause)
- Hình ảnh (image) chính thức `openjdk` trên Docker Hub đã bị **ngừng bảo trì (deprecated)**.
- Nhiều tag cũ, bao gồm `17-slim`, đã bị xóa khỏi hệ thống của Docker Hub để khuyến khích người dùng chuyển sang các bản phân phối từ nhà cung cấp khác (vendor images).

### 3. Giải pháp (Solution)
Sử dụng các hình ảnh thay thế được cộng đồng và các hãng lớn bảo trì tích cực. Thay đổi dòng `FROM` trong `Dockerfile`:

**Lựa chọn tốt nhất:**
```dockerfile
# Sử dụng Eclipse Temurin (Sự thay thế phổ biến nhất cho OpenJDK)
FROM eclipse-temurin:17-jdk
```

**Các lựa chọn khác:**
- `amazoncorretto:17` (Từ Amazon)
- `bellsoft/liberica-openjdk-debian:17` (Rất phổ biến trong cộng đồng Spring Boot)
- `eclipse-temurin:17-jre-alpine` (Nếu bạn cần hình ảnh siêu nhẹ và chỉ chạy file .jar)

---

## 2026-04-21: Lỗi `permission denied` khi kết nối Docker daemon

### 1. Vấn đề (Issue)
Khi chạy lệnh `docker build`, gặp lỗi:
```text
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: ...
```

### 2. Nguyên nhân (Root Cause)
- Người dùng hiện tại không có quyền truy cập vào file socket của Docker (`/var/run/docker.sock`).
- Mặc định, chỉ người dùng `root` hoặc người dùng trong nhóm `docker` mới có quyền này.

### 3. Giải pháp (Solution)

**Cách 1: Sử dụng `sudo` (Nhanh nhất)**
Thêm `sudo` trước mỗi lệnh docker:
```bash
sudo docker build -t my-java-app .
```

**Cách 2: Thêm người dùng vào nhóm `docker` (Khuyên dùng)**
Để chạy lệnh Docker mà không cần `sudo`:
1. Thêm user của bạn vào nhóm docker: `sudo usermod -aG docker $USER`
2. Để thay đổi có hiệu lực ngay lập tức mà không cần logout: `newgrp docker`
3. Kiểm tra lại: `docker ps`

