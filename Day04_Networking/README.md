# 🗓️ Day 4: Networking & Data Persistence (Volume)

## 🎯 Mục tiêu bài học
- Hiểu các loại Network trong Docker (`bridge`, `host`, `none`).
- Kết nối nhiều container thông qua Docker DNS.
- Phân biệt Bind Mount và Named Volume để lưu trữ dữ liệu bền vững.

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Docker Networking
| Kiểu Network | Đặc điểm |
| :--- | :--- |
| `bridge` | Mặc định. Các container có dải IP riêng và cách ly với host. |
| `host` | Container dùng chung Network Stack với máy host (Performance cao). |
| `none` | Cách ly hoàn toàn network của container. |
| `User-defined Bridge` | **Khuyên dùng**. Hỗ trợ DNS (gọi tên container thay vì IP). |

### 2. Docker Storage (Persistence)
- **Bind Mount**: Gắn một folder cụ thể trên máy host vào container. 
  - *Dùng khi*: Muốn code update ngay lập tức vào container (Development).
- **Named Volume**: Docker tự quản lý vị trí lưu trữ trên ổ cứng. 
  - *Dùng khi*: Lưu dữ liệu Database, logs (Production). Dữ liệu không bị mất khi xoá container.

---

## 🛠️ Thực hành & Bài tập

### Bài 1: User-defined Network & DNS
1. Tạo một network mới:
   ```bash
   docker network create my-custom-net
   ```
2. Chạy một container Nginx đặt tên là `web-server`:
   ```bash
   docker run -d --name web-server --network my-custom-net nginx
   ```
3. Chạy một container Ubuntu để test kết nối:
   ```bash
   docker run -it --rm --network my-custom-net ubuntu bash
   # Bên trong Ubuntu:
   apt-get update && apt-get install -y curl
   curl http://web-server  # DNS tự động giải quyết 'web-server' thành IP của Nginx
   ```

### Bài 2: Sử dụng Named Volume với MySQL
1. Chạy MySQL container và map dữ liệu vào volume `mysql-data`:
   ```bash
   docker run -d --name my-db \
     -v mysql-data:/var/lib/mysql \
     -e MYSQL_ROOT_PASSWORD=root \
     mysql:8.0
   ```
2. Kiểm tra danh sách volume: `docker volume ls`.
3. Xoá container: `docker rm -f my-db`.
4. Chạy lại container mới với cùng volume: Dữ liệu cũ (nếu có tạo table) vẫn còn nguyên.

### Bài 3: Bind Mount cho Frontend (Live Reload giả lập)
1. Tạo file `index.html` ở máy host.
2. Chạy Nginx:
   ```bash
   docker run -d --name my-web -p 8082:80 -v $(pwd)/index.html:/usr/share/nginx/html/index.html nginx
   ```
3. Sửa file `index.html` ở máy host và refresh trình duyệt `localhost:8082`.

---

## 📝 Câu hỏi suy ngẫm

1. Tại sao không nên dùng IP của container để các container khác kết nối tới?
   > Trả lời:

2. Lệnh nào dùng để kiểm tra chi tiết các container đang nằm trong một Network?
   > Trả lời:

3. Nếu bạn xoá một Volume bằng lệnh `docker volume rm`, dữ liệu bên trong có khôi phục lại được không?
   > Trả lời:
