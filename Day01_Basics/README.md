# 🗓️ Day 1: Docker Basics - Hiểu bản chất Docker

## 🎯 Mục tiêu bài học
* Hiểu tại sao dùng Docker? (Giải quyết bài toán "Works on my machine").
* Nắm vững Docker Architecture: Engine, Daemon, Client, Registry.
* Phân biệt Docker vs Virtual Machine (Concept: Namespace, Control Group).

## 📖 Tóm tắt lý thuyết quan trọng

### 1. Tại sao cần Docker?
- **Vấn đề:** Sự khác biệt về môi trường giữa máy Dev và máy Server dẫn đến lỗi không mong muốn.
- **Giải pháp:** Docker đóng gói ứng dụng cùng toàn bộ môi trường (libraries, dependencies, config) vào một thực thể duy nhất.

### 2. Kiến trúc Docker (Architecture)
- **Docker Client:** Nơi bạn nhập lệnh (ví dụ: `docker run`).
- **Docker Daemon (dockerd):** "Bộ não" chạy nền, lắng nghe yêu cầu từ Client để quản lý Image, Container.
- **Docker Engine:** Sự kết hợp giữa Client và Daemon.
- **Docker Registry:** Nơi lưu trữ và chia sẻ Image (mặc định là Docker Hub).

### 3. Image vs Container
- **Image (Khuôn đúc):** Là file Read-only chứa code và môi trường. Bạn không thể thay đổi Image khi nó đã được build.
- **Container (Sản phẩm):** Là một thực thể chạy của Image. Bạn có thể tạo nhiều Container từ cùng một Image.

### 4. Docker vs Virtual Machine
- **VM:** Chạy trên Hypervisor, mỗi VM có một OS riêng (Guest OS) -> Nặng, tốn tài nguyên.
- **Docker:** Chạy trực tiếp trên nhân (Kernel) của máy Host. Để làm được điều này, Docker sử dụng 2 tính năng cốt lõi của Linux Kernel:
    - **Namespaces (Cách ly - Isolation):** Tạo ra các "vách ngăn" ảo. Mỗi container sẽ có Namespace riêng về Process (PID), Network (NET), User, Mount (MNT)... giúp container này không nhìn thấy tiến trình của container kia hay máy host.
    - **Control Groups (cgroups - Giới hạn - Limits):** Quy định container được dùng tối đa bao nhiêu CPU, bao nhiêu RAM. Không có cgroup, một container bị lỗi (memory leak) có thể làm treo toàn bộ máy host.

### 5. Vòng đời của một Container (Lifecycle)
Hiểu các trạng thái này giúp bạn debug tốt hơn:
- **Created:** Container đã được khởi tạo từ image nhưng chưa chạy tiến trình nào.
- **Running:** Tiến trình chính (PID 1) trong container đang hoạt động.
- **Paused:** Mọi tiến trình bị tạm dừng (CPU bị suspend).
- **Exited (Stopped):** Tiến trình chính đã kết thúc hoặc bị dừng chủ động. Dữ liệu trên layer ghi vẫn còn, nhưng RAM đã giải phóng.
- **Dead:** Trạng thái lỗi nặng khi container không thể dừng hẳn.

---

## 🛠️ Thực hành & Bài tập

### Bài 1: Chạy Hello World
```bash
docker run hello-world
```
*Hãy quan sát output để hiểu cách Docker kéo Image từ Registry về máy local.*

### Bài 2: Tương tác với Ubuntu
Chạy container Ubuntu ở chế độ tương tác:
```bash
docker run -it --name test-ubuntu ubuntu bash
```

### Bài 3: Tính chất Ephemeral (Tính tạm thời) - QUAN TRỌNG
1. Bên trong container `test-ubuntu`, hãy cài đặt `curl` hoặc `vim`:
   ```bash
   apt-get update && apt-get install -y curl
   ```
2. Kiểm tra: `curl --version`.
3. Thoát ra ngoài: `exit`.
4. Xoá container vừa chạy: `docker rm test-ubuntu`.
5. Chạy một container mới từ image `ubuntu` gốc:
   ```bash
   docker run -it --name test-ubuntu-new ubuntu bash
   ```
6. Kiểm tra lại `curl`: `curl --version`.

**Câu hỏi suy ngẫm:** Tại sao `curl` không còn ở container mới? Làm thế nào để lưu giữ những thay đổi này mãi mãi? (Gợi ý: Day 3 sẽ học về Dockerfile).

---

## 📝 Trả lời câu hỏi (Tự điền để củng cố kiến thức)

1. **Namespace** và **Cgroup** đóng vai trò gì trong việc tạo ra sự cách ly của Docker?
   > Trả lời:

2. Phân biệt Image và Container bằng một ví dụ thực tế khác (ngoài khuôn đúc/sản phẩm)?
   > Trả lời:

3. Vòng đời của một container gồm những trạng thái chính nào?
   > Trả lời:
