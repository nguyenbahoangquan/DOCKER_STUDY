# 🗓️ Day 6: Debug & Optimization (Level Up)

## 🎯 Mục tiêu bài học
- Thành thạo quy trình Debug container chuyên nghiệp (Logs, Inspect, Exec, Stats).
- Làm chủ kỹ thuật **Multi-stage Build** để giảm dung lượng Image tối đa.
- Hiểu sâu về cơ chế **Layer Caching** để tối ưu tốc độ build.
- Xử lý sự cố mạng thực tế giữa các container.

---

## 📖 1. Quy trình Debug chuyên nghiệp (The Debugging Workflow)

Khi một container gặp sự cố (Crash, không kết nối được, chạy chậm), kỹ sư Docker thực hiện theo 4 bước sau:

### Bước 1: Kiểm tra "tiếng nói" của ứng dụng (`docker logs`)
Đây là nơi đầu tiên bạn tìm thấy Error Stacktrace.
- `docker logs <name>`: Xem toàn bộ log.
- `docker logs -f <name>`: Theo dõi log thời gian thực (Follow).
- `docker logs --tail 50 <name>`: Chỉ xem 50 dòng cuối.
- `docker logs --since 10m <name>`: Xem log trong 10 phút vừa qua.

### Bước 2: Soi "nội tạng" container (`docker inspect`)
Dùng để kiểm tra các thông số cấu hình ẩn.
- `docker inspect <name>`: Trả về file JSON khổng lồ.
- **Mẹo trích xuất nhanh:**
  - `docker inspect -f '{{.NetworkSettings.IPAddress}}' <name>`: Xem IP.
  - `docker inspect -f '{{.Mounts}}' <name>`: Xem các thư mục đang mount (Volume).

### Bước 3: Đột nhập vào bên trong (`docker exec`)
Dùng khi logs không đủ thông tin, cần kiểm tra file hệ thống hoặc kết nối mạng nội bộ.
- `docker exec -it <name> sh` (hoặc `bash`): Mở terminal bên trong container.

### Bước 4: Kiểm tra sức khỏe tài nguyên (`docker stats`)
Xem container có bị "ngốn" RAM hay CPU dẫn đến treo máy không.
- `docker stats`: Hiển thị bảng tài nguyên Real-time của tất cả container đang chạy.

---

## 📖 2. Tối ưu Image với Multi-stage Build

### Tại sao cần Multi-stage?
Bản build thông thường chứa rất nhiều "rác" không cần thiết ở Runtime (như Compiler, Source code gốc, Maven, Git, SSH). 
**Multi-stage build** cho phép bạn dùng nhiều câu lệnh `FROM`. Mỗi stage là một môi trường riêng. Bạn chỉ copy "sản phẩm cuối" (file .jar, binary) từ stage build sang stage chạy.

### Phân tích ví dụ Java tối ưu:
```dockerfile
# STAGE 1: BUILD (Dùng image lớn, đầy đủ công cụ)
FROM maven:3.8-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# STAGE 2: RUNTIME (Dùng image tí hon, chỉ chứa JRE)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
```
- **Kết quả:** Giảm kích thước từ ~800MB (Maven + JDK) xuống còn ~100MB (JRE Alpine).

---

## 📖 3. Bí mật Layer Caching

Docker build theo cơ chế chồng lớp (Union File System). Mỗi dòng lệnh `RUN`, `COPY`, `ADD` tạo ra một Layer.
- **Quy tắc vàng:** Những gì **ít thay đổi** để lên TRÊN, những gì **hay thay đổi** để xuống DƯỚI.
- **Tại sao lại tách `COPY pom.xml`?**
  - Nếu bạn để `COPY . .` lên đầu, mỗi khi bạn sửa 1 dòng code, Docker sẽ coi như layer đó đã đổi và **build lại từ đầu**, bao gồm cả việc tải lại hàng trăm MB thư viện.
  - Nếu tách `pom.xml` riêng, Docker sẽ thấy file này không đổi -> dùng `CACHED` kết quả tải thư viện cũ -> Build code mới chỉ mất vài giây.

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Multi-stage Build thực tế
1. Truy cập thư mục `Bai_1`.
2. Tạo file `pom.xml` và `src/` (nếu chưa có) với code Java đơn giản.
3. Viết `Dockerfile` Multi-stage (Sử dụng `eclipse-temurin:17-jre-alpine` cho stage cuối).
4. Build: `sudo docker build -t java-app-optimized .`
5. Kiểm tra size: `sudo docker images` và so sánh với bản build cũ (Day 3).

### Bài 2: Thử thách Layer Caching
1. Build lại image ở Bài 1 (lần 2).
2. Sửa file `Hello.java`, thêm một dòng in ra màn hình.
3. Build lại lần 3.
4. **Yêu cầu:** Quan sát output terminal, xác định bước nào hiện chữ `CACHED`, bước nào chạy thật. Giải thích tại sao bước tải thư viện không chạy lại.

### Bài 3: Lab thực tế - Khám chữa bệnh cho Container
Bạn sẽ giải quyết lỗi kết nối giữa 2 Container không cùng network.

**Bước 1: Tạo hiện trường lỗi**
```bash
# 1. Tạo mạng riêng cho Database
docker network create db-net

# 2. Chạy Database trong mạng đó
docker run -d --name db-server --network db-net -e MYSQL_ROOT_PASSWORD=root mysql:8.0

# 3. Chạy App ở mạng mặc định (Bridge)
docker run -d --name my-app alpine sleep 3600
```

**Bước 2: Chẩn đoán (Diagnostic)**
1. Vào App: `docker exec -it my-app sh`
2. Cài tool: `apk update && apk add curl`
3. Thử gọi DB: `curl db-server:3306`
   - **Kết quả mong đợi:** Lỗi `Could not resolve host: db-server`.
   - **Giải thích:** Do `my-app` nằm ở network mặc định nên DNS của Docker không biết `db-server` là ai.

**Bước 3: Khắc phục (The Fix)**
1. (Ở máy Host) Nối dây mạng cho App: `docker network connect db-net my-app`
2. Quay lại container App, chạy lại lệnh `curl db-server:3306`.
   - **Kết quả mong đợi:** Thấy phản hồi từ MySQL (Dù là lỗi giao thức nhưng DNS đã thông).

---

## 📝 Câu hỏi suy ngẫm

1. **Alpine Linux** rất nhẹ nhưng tại sao đôi khi cài thư viện Python hoặc C++ lại gặp lỗi "missing shared library"?
   > Trả lời: Do Alpine sử dụng **musl libc** thay vì **glibc** (phổ biến trên Ubuntu/Debian). Các thư viện được biên dịch sẵn thường tìm kiếm `glibc`, khi không thấy sẽ báo lỗi thiếu thư viện. Để khắc phục, cần cài thêm `gcompat` hoặc build từ source trong môi trường Alpine.

2. **Tại sao tuyệt đối không được dùng `docker commit` để tạo Image cho Production?**
   > Trả lời: Vì nó tạo ra một "hộp đen" (không có tính minh bạch), Image chứa nhiều rác (log, cache) làm tăng dung lượng, và cực kỳ khó tái tạo hoặc nâng cấp khi cần thiết. Luôn dùng **Dockerfile** để đảm bảo tính kế thừa và quản lý được mã nguồn.

3. **Làm sao để xoá toàn bộ các "Dangling Images" (Image rác không có tên) để giải phóng ổ cứng?**
   > Trả lời: 
     - Xóa Image rác: `docker image prune`
     - Xóa toàn bộ Image không dùng: `docker image prune -a`
     - Dọn dẹp tổng thể (Image, Container, Network, Cache): `docker system prune -f`

---

## ✅ Trạng thái hoàn thành (Status)
- [x] Hiểu quy trình Debug (Logs, Inspect, Exec).
- [x] Lý thuyết Multi-stage Build & Layer Caching.
- [x] Thực hành kết nối đa mạng (Bridge vs Custom Network).
- [x] Trả lời các câu hỏi về Alpine & Docker Commit.

## 🚀 Kế hoạch tiếp theo: Day 07 - Docker Compose
- Chuyển đổi các lệnh `docker run` phức tạp sang `docker-compose.yml`.
- Quản lý App và Database như một khối thống nhất.
- Tìm hiểu về Volume Persistence (Lưu trữ dữ liệu bền vững).
