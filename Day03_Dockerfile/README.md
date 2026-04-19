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

---

## 📝 Câu hỏi suy ngẫm

1. Tại sao ta nên dùng `COPY` thay vì `ADD` trong đa số trường hợp?
   > Trả lời:

2. Nếu thay đổi một dòng code trong Java, Docker có phải download lại toàn bộ Base Image không? Tại sao? (Gợi ý: Tìm hiểu về Layer Caching).
   > Trả lời:

3. Làm thế nào để truyền một biến mật khẩu (Secret) vào lúc build mà không để lại dấu vết trong Image History?
   > Trả lời:
