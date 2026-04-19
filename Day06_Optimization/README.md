# 🗓️ Day 6: Debug & Optimization (Level Up)

## 🎯 Mục tiêu bài học
- Debug container lỗi thông qua `logs`, `inspect`, `exec`.
- Giảm dung lượng Image bằng Multi-stage Build.
- Hiểu và tận dụng Layer Caching để build nhanh hơn.

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Debugging Workflow
Khi container không chạy như ý, hãy thực hiện theo thứ tự:
- **`docker logs`**: Kiểm tra Error message từ ứng dụng.
- **`docker inspect`**: Kiểm tra cấu hình: IP, Port, Env, Mount points.
- **`docker exec`**: Vào thẳng container để check file, kết nối mạng.
- **`docker stats`**: Xem container có bị treo do thiếu RAM/CPU không.

### 2. Multi-stage Build
Kỹ thuật dùng nhiều `FROM` trong một Dockerfile.
- Stage 1 (Builder): Chứa đầy đủ công cụ build (Maven, GCC, NPM).
- Stage 2 (Runner): Chỉ chứa Runtime nhỏ nhất (JRE, Alpine, Distroless) và copy sản phẩm cuối từ Stage 1 sang.
- **Kết quả**: Giảm dung lượng Image từ 800MB xuống còn 100MB-200MB.

### 3. Nguyên tắc Layer Caching
Mỗi câu lệnh `RUN`, `COPY`, `ADD` tạo ra một Layer mới. Docker sẽ cache các layer này. 
- **Mẹo**: Những thứ ít thay đổi (Dependencies) để lên trên, những thứ hay thay đổi (Source Code) để xuống dưới cùng.

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Multi-stage Build cho Java (So sánh size)
1. Viết `Dockerfile` tối ưu:
   ```dockerfile
   # Stage 1: Build
   FROM maven:3.8-openjdk-17 AS builder
   WORKDIR /app
   COPY pom.xml .
   RUN mvn dependency:go-offline
   COPY src ./src
   RUN mvn package -DskipTests

   # Stage 2: Runtime
   FROM openjdk:17-slim
   WORKDIR /app
   COPY --from=builder /app/target/*.jar app.jar
   CMD ["java", "-jar", "app.jar"]
   ```
2. Build và so sánh size với image Java ở Day 3 bằng lệnh `docker images`.

### Bài 2: Sắp xếp layer tối ưu
1. Thử thay đổi một file source code.
2. Build lại: Quan sát Docker sẽ dùng cache ở bước `mvn dependency:go-offline`, giúp tiết kiệm hàng phút chờ download thư viện.

### Bài 3: Debug kết nối
1. Chạy 1 container app lỗi kết nối Database.
2. Dùng `docker exec` vào container, cài `curl` hoặc `telnet` để check xem có ping được tới DB không.

---

## 📝 Câu hỏi suy ngẫm

1. Sự khác biệt chính giữa `openjdk:17-slim` và `openjdk:17-alpine` là gì? Khi nào Alpine gây lỗi?
   > Trả lời:

2. Tại sao ta không nên cài đặt `vim` hay `git` vào Production Image?
   > Trả lời:

3. Lệnh nào giúp xoá các Layer trung gian (dangling images) sau khi build xong?
   > Trả lời:
