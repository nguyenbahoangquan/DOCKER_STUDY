# 🗓️ Day 2: Docker CLI & Container Management

## 🎯 Mục tiêu bài học
* Thành thạo các lệnh quản lý vòng đời container.
* Hiểu ý nghĩa các Flags quan trọng khi chạy container.
* Biết cách kiểm tra tài nguyên và log của container.

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Vòng đời của Container (Lifecycle)
- **Created:** Container đã được tạo nhưng chưa chạy.
- **Running:** Container đang hoạt động.
- **Paused:** Container bị tạm dừng (CPU bị suspend nhưng RAM vẫn giữ).
- **Stopped:** Container đã dừng, tài nguyên được giải phóng nhưng cấu hình vẫn còn.
- **Deleted:** Container bị xoá hoàn toàn khỏi hệ thống.

### 2. Các lệnh CLI trọng tâm
| Lệnh | Ý nghĩa |
| :--- | :--- |
| `docker run` | Tạo và chạy một container mới từ image. |
| `docker ps` | Liệt kê các container đang chạy (`-a` để xem cả container đã dừng). |
| `docker stop` / `docker start` | Dừng hoặc khởi động lại một container hiện có. |
| `docker exec` | Chạy một lệnh bên trong container đang hoạt động. |
| `docker logs` | Xem output (stdout/stderr) của container (`-f` để theo dõi realtime). |
| `docker rm` | Xoá container (`-f` để ép xoá container đang chạy). |
| `docker inspect` | Xem thông tin chi tiết (JSON) của container/image. |
| `docker stats` | Xem thông số tài nguyên (CPU, RAM, Network) realtime. |

### 3. Giải thích các Flags phổ biến
- `-d` (detached): Chạy container dưới nền (không chiếm terminal).
- `-it`: Kết hợp của `-i` (interactive) và `-t` (tty) để tương tác với terminal bên trong container.
- `--name`: Đặt tên dễ nhớ cho container (thay vì ID ngẫu nhiên).
- `--rm`: Tự động xoá container sau khi nó dừng (rất tốt để test nhanh).
### 4. Phân biệt Stop vs Kill (Cực kỳ quan trọng)
- **`docker stop` (Lịch sự):** Gửi tín hiệu **SIGTERM** tới container. Nó cho ứng dụng một khoảng thời gian (mặc định 10 giây) để lưu dữ liệu, đóng kết nối DB rồi mới dừng.
- **`docker kill` (Thô bạo):** Gửi tín hiệu **SIGKILL**. Ứng dụng bị ngắt điện ngay lập tức, không kịp dọn dẹp. Dùng khi app bị treo.

### 5. Restart Policy (Cơ chế tự cứu)
Khi chạy container, bạn có thể chỉ định nó tự khởi động lại nếu bị crash:
- `--restart no`: Không tự khởi động lại (mặc định).
- `--restart on-failure`: Chỉ khởi động lại nếu container thoát với mã lỗi (exit code != 0).
- `--restart always`: Luôn khởi động lại trừ khi bạn chủ động stop nó.

### 6. Lệnh dọn dẹp hệ thống (Prune)
Sau một thời gian dùng Docker, ổ cứng sẽ đầy bởi các container/image rác:
- `docker system prune`: Xoá sạch các container đã dừng, network rác và cache.
- `docker image prune`: Chỉ xoá các image không dùng tới.
- `docker rm -f $(docker ps -aq)`: Xoá toàn bộ container trên máy (cẩn thận!).

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Chạy Web Server Nginx dưới nền
1. Chạy Nginx tại port 8080 trên máy thật:
   ```bash
   docker run -d --name my-nginx -p 8080:80 nginx
   ```
2. Kiểm tra trạng thái: `docker ps`.
3. Truy cập trình duyệt: `localhost:8080`.
4. Xem log của Nginx: `docker logs my-nginx`.

### Bài 2: Tương tác và chỉnh sửa
1. Dùng `docker exec` để sửa file index của Nginx:
   ```bash
   docker exec -it my-nginx bash
   # Bên trong container:
   echo "<h1>Hello from Docker Day 2</h1>" > /usr/share/nginx/html/index.html
   exit
   ```
2. Reload lại trình duyệt `localhost:8080` để thấy thay đổi.

### Bài 3: Quản lý tài nguyên
1. Chạy lệnh: `docker stats my-nginx`.
2. Quan sát mức tiêu thụ RAM và CPU của Nginx khi bạn F5 trình duyệt liên tục.

### Bài 4: Dọn dẹp
1. Dừng container: `docker stop my-nginx`.
2. Xoá container: `docker rm my-nginx`.
3. Chạy lại Nginx ở port **8081**:
   ```bash
   docker run -d --name my-nginx-8081 -p 8081:80 nginx
   ```

---

## 📝 Trả lời câu hỏi

1. Làm thế nào để xem log của một container đã bị lỗi và thoát ra (Exited)?
   > Trả lời:

2. Sự khác biệt giữa `docker stop` và `docker kill` là gì? (Gợi ý: Tìm hiểu về tín hiệu SIGTERM và SIGKILL).
   > Trả lời:

3. Lệnh nào dùng để đổi tên một container đang tồn tại?
   > Trả lời:
