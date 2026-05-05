# 🗓️ Day 3: Dockerfile & Image Building

## 🎯 Mục tiêu bài học
- Tự viết Dockerfile cho project Java/C++.
- Hiểu sự khác biệt giữa `CMD` và `ENTRYPOINT`.
- Sử dụng `.dockerignore` để tối ưu quá trình build và bảo mật.

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Dockerfile là gì?
Dockerfile là một file text chứa tập hợp các chỉ thị (instructions) để Docker Engine tự động xây dựng (build) một Docker Image.

### 2. Các chỉ thị quan trọng (Instructions)
| Chỉ thị | Ý nghĩa |
| :--- | :--- |
| `FROM` | Định nghĩa base image (Ví dụ: `openjdk:17-slim`, `gcc:12`). |
| `WORKDIR` | Thiết lập thư mục làm việc bên trong container. |
| `COPY` / `ADD` | Copy file từ máy host vào image. `COPY` được ưu tiên hơn. |
| `RUN` | Chạy các lệnh trong quá trình build (ví dụ: `apt install`, `mvn package`). |
| `ENV` | Thiết lập biến môi trường (Runtime). |
| `ARG` | Biến chỉ dùng trong quá trình build (Build-time). |
| `EXPOSE` | Thông báo port mà container sẽ lắng nghe (chỉ mang tính tài liệu). |
| `CMD` / `ENTRYPOINT` | Lệnh mặc định khi container khởi chạy. |

### 3. CMD vs ENTRYPOINT
- **`CMD`**: Có thể bị ghi đè (override) khi chạy `docker run <image> <new_command>`.
- **`ENTRYPOINT`**: Không bị ghi đè trực tiếp, các đối số truyền vào `docker run` sẽ được nối tiếp vào sau lệnh này.
- **Kết hợp**: Dùng `ENTRYPOINT` cho lệnh thực thi chính và `CMD` cho các tham số mặc định.

### 4. .dockerignore
Tương tự `.gitignore`, giúp loại bỏ các file không cần thiết (node_modules, .git, target, .env) khỏi build context để:
- Giảm dung lượng build context (build nhanh hơn).
- Tránh lộ thông tin nhạy cảm (secrets).

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Dockerfile cho Java App (Simple)
1. Tạo folder `java-app` và file `Hello.java`:
   ```java
   public class Hello {
       public static void main(String[] args) {
           System.out.println("Hello from Dockerized Java!");
       }
   }
   ```
2. Viết `Dockerfile`:
   ```dockerfile
   FROM openjdk:17-slim
   WORKDIR /app
   COPY Hello.java .
   RUN javac Hello.java
   CMD ["java", "Hello"]
   ```
3. Build và chạy:
   ```bash
   docker build -t my-java-app .
   docker run my-java-app
   ```

### Bài 2: Thử nghiệm CMD vs ENTRYPOINT
1. Viết `Dockerfile.test`:
   ```dockerfile
   FROM alpine
   ENTRYPOINT ["echo", "Hello"]
   CMD ["World"]
   ```
2. Build: `docker build -t test-cmd -f Dockerfile.test .`
3. Chạy bình thường: `docker run test-cmd` -> Output: `Hello World`
4. Chạy với tham số: `docker run test-cmd Docker` -> Output: `Hello Docker` (CMD bị ghi đè).

### Bài 3: Sử dụng .dockerignore để tối ưu build context
1. Tạo một file dữ liệu "rác" nặng khoảng 10MB trong thư mục `java-app`:
   ```bash
   # Lệnh tạo file 10MB chứa dữ liệu ngẫu nhiên
   dd if=/dev/urandom of=java-app/large-file.log bs=1M count=10
   ```
2. Thử build image và quan sát dòng đầu tiên:
   ```bash
   sudo docker build -t my-java-app java-app/
   # Chú ý dòng: "Sending build context to Docker daemon  10.25MB"
   ```
3. Tạo file `java-app/.dockerignore` (nếu chưa có) và thêm dòng này vào:
   ```text
   *.log
   ```
4. Build lại và quan sát sự khác biệt:
   ```bash
   sudo docker build -t my-java-app java-app/
   # Chú ý dòng: "Sending build context to Docker daemon  3.072kB"
   # Kết luận: File .log đã bị loại bỏ, build context nhẹ đi đáng kể!
   ```

### Bài 4: Kiểm chứng Layer Caching (Build "siêu tốc")
1. Sửa một dòng code nhỏ trong file `java-app/Hello.java` (ví dụ: đổi chuỗi in ra).
2. Chạy lại lệnh build:
   ```bash
   sudo docker build -t my-java-app java-app/
   ```
3. Quan sát output của Docker:
   - Các dòng `FROM`, `WORKDIR` sẽ hiện chữ `CACHED` (vì không đổi).
   - Dòng `COPY Hello.java .` sẽ được thực hiện lại vì file đã thay đổi (mất cache).
   - Các dòng **phía sau** dòng COPY (như `RUN javac...`) cũng sẽ bị chạy lại hoàn toàn.
   - **Kết luận:** Thứ tự các câu lệnh trong Dockerfile cực kỳ quan trọng để tận dụng Cache.

### Bài 5: Phân biệt COPY và ADD (Tính năng "phép thuật")
1. Trong thư mục `java-app`, tạo một file nén:
   ```bash
   tar -cvf test.tar Hello.java
   ```
2. Thử nghiệm với `ADD`:
   - Sửa `Dockerfile`: Thay `COPY Hello.java .` bằng `ADD test.tar .`
   - Build image: `docker build -t test-add java-app/`
   - Kiểm tra nội dung: `docker run --rm test-add ls`
   - **Kết quả:** `ADD` tự động giải nén `test.tar` thành file `Hello.java`.
3. Thử nghiệm với `COPY`:
   - Làm tương tự nhưng dùng `COPY test.tar .`
   - **Kết quả:** `COPY` giữ nguyên file `test.tar` bên trong container.

### Bài 6: Bảo mật Secrets (Mật khẩu/API Key) khi build
**Mục tiêu:** Truyền mật khẩu vào lúc build mà không để lại dấu vết trong lịch sử Image.

1. **Cách 1: Sử dụng BuildKit --secret (Khuyên dùng)**
   - Tạo file `password.txt` chứa nội dung: `my_super_secret_123`
   - Sửa `Dockerfile`:
     ```dockerfile
     # syntax=docker/dockerfile:1
     FROM alpine
     RUN --mount=type=secret,id=my_pass cat /run/secrets/my_pass > /result.txt
     ```
   - Build với tham số secret:
     ```bash
     DOCKER_BUILDKIT=1 docker build --secret id=my_pass,src=password.txt -t secret-test .
     ```
   - Kiểm tra: `docker history secret-test`. Bạn sẽ thấy không có mật khẩu nào bị lộ ở các layer.

2. **Cách 2: Sử dụng Multi-stage Build**
   - Viết `Dockerfile` có 2 stage:
     ```dockerfile
     # Stage 1: Build (Tạm thời)
     FROM alpine AS builder
     ARG MY_KEY=default_value
     RUN echo "Key của bạn là $MY_KEY" > /key.txt

     # Stage 2: Final (Sạch sẽ)
     FROM alpine
     COPY --from=builder /key.txt /key.txt
     ```
   - Build: `docker build --build-arg MY_KEY=12345 -t multi-stage-test .`
   - Kiểm tra: `docker history multi-stage-test`. Mật khẩu `12345` chỉ nằm ở stage 1 (đã bị xóa), Image cuối cùng chỉ chứa file kết quả.

---

## 📝 Câu hỏi suy ngẫm

1. Tại sao ta nên dùng `COPY` thay vì `ADD` trong đa số trường hợp?
   > Trả lời: `COPY` minh bạch, đơn giản và tránh các hành vi tự động (giải nén, tải URL) không mong muốn của `ADD`.

2. Nếu thay đổi một dòng code trong Java, Docker có phải download lại toàn bộ Base Image không? Tại sao? (Gợi ý: Tìm hiểu về Layer Caching).
   > Trả lời: Không. Docker sử dụng Layer Caching, nó chỉ build lại từ lớp bị thay đổi trở xuống. Base Image nằm ở lớp đầu tiên và không đổi nên sẽ được tái sử dụng.

3. Làm thế nào để truyền một biến mật khẩu (Secret) vào lúc build mà không để lại dấu vết trong Image History?
   > Trả lời: Sử dụng **BuildKit `--secret`** (an toàn nhất) hoặc kỹ thuật **Multi-stage build** để tách biệt môi trường chứa secret và image cuối cùng. Tuyệt đối không dùng `ARG` thông thường cho dữ liệu nhạy cảm vì nó sẽ bị lưu lại trong lịch sử Image.
