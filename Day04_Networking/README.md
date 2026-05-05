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

   **💡 Giải thích chi tiết câu lệnh:**
   *   `-d`: Chạy container ở chế độ nền (Detached mode).
   *   `--name my-web`: Đặt tên dễ nhớ cho container.
   *   `-p 8082:80`: Ánh xạ cổng (Port mapping). Truy cập tại `localhost:8082` trên máy host sẽ dẫn vào cổng `80` của Nginx trong container.
   *   `-v $(pwd)/index.html:/...`: **Bind Mount**. Gắn trực tiếp file `index.html` từ thư mục hiện tại (`pwd`) vào thư mục mặc định của Nginx. 
       *   *Cơ chế:* Mọi thay đổi trên file ở máy host sẽ phản ánh ngay lập tức vào container mà không cần build lại Image.

3. Sửa file `index.html` ở máy host và refresh trình duyệt `localhost:8082`.

---

## 🔍 Kỹ năng Debug Network nâng cao

Khi các container không kết nối được với nhau, bạn có thể sử dụng các công cụ sau bên trong container để kiểm tra:

1.  **`nslookup <tên_container>`**: Kiểm tra xem Docker DNS có đang hoạt động không (có giải quyết tên sang IP được không).
    *   *Lưu ý:* Nếu không có sẵn, cài bằng: `apt-get install -y dnsutils` (Ubuntu) hoặc `apk add bind-tools` (Alpine).
2.  **`ping -c 4 <tên_container_hoặc_IP>`**: Kiểm tra xem đường truyền vật lý giữa các container có thông suốt không.
3.  **`curl -v http://<tên_container>:<port>`**: Kiểm tra kết nối ở tầng ứng dụng (hiển thị chi tiết quá trình bắt tay HTTP).

---

## 📝 Câu hỏi suy ngẫm

1. Tại sao không nên dùng IP của container để các container khác kết nối tới?
   > Trả lời: Vì IP của container không cố định; mỗi khi container khởi động lại, Docker có thể cấp một IP mới. Việc dùng tên container thông qua User-defined Network (DNS) sẽ giúp kết nối luôn ổn định.

2. Lệnh nào dùng để kiểm tra chi tiết các container đang nằm trong một Network?
   > Trả lời: Lệnh `docker network inspect <tên_mạng>`.

3. Nếu bạn xoá một Volume bằng lệnh `docker volume rm`, dữ liệu bên trong có khôi phục lại được không?
   > Trả lời: Không, việc xóa Volume sẽ xóa vĩnh viễn dữ liệu được lưu trữ trong đó khỏi ổ cứng của máy host.
