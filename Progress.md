# 📈 TRACKING TIẾN ĐỘ HỌC DOCKER

## 📅 Tổng quan lộ trình

- [x] **Day 1**: Hiểu bản chất & Kiến trúc Docker (19/04)
- [x] **Day 2**: Thành thạo Docker CLI (20/04)
- [x] **Day 3**: Dockerfile & Image Deep Dive (21/04)
- [x] **Day 4**: Networking & Data Persistence (22/04)
- [x] **Day 5**: Docker Compose (Multi-service) (26/04)
- [x] **Day 6**: Debug & Optimization (Hoàn thành 27/04)
- [ ] **Day 7**: CI/CD & Production Best Practices (Đã cập nhật nội dung 05/05)
- [ ] **Day 8**: CI/CD Advanced — Multi-environment, Health Checks & Deployment Strategies (Đã tạo nội dung 05/05)

---

## 📝 Nhật ký chi tiết

### 🗓️ Day 1: 19/04/2026
- **Đã hoàn thành:** 
    - Hiểu kiến trúc Docker (Client-Daemon-Registry).
    - Phân biệt Docker vs VM.
- **Kiến thức mới:** Namespace (cách ly), Cgroups (giới hạn tài nguyên).

### 🗓️ Day 2: 20/04/2026
- **Đã hoàn thành:** 
    - Quản lý container: `run`, `exec`, `logs`, `stats`.
    - Map port 8081 cho Nginx.

### 🗓️ Day 3: 21/04/2026
- **Đã hoàn thành:** 
    - Tự viết Dockerfile cho Java App.
    - Hiểu CMD vs ENTRYPOINT.
    - Sử dụng `.dockerignore` để loại bỏ file log rác.
    - Thử nghiệm ADD vs COPY (tự giải nén tar).
    - **Advanced:** Sử dụng BuildKit Secrets (`--mount=type=secret`) và Multi-stage build cơ bản.

### 🗓️ Day 4: 22/04/2026
- **Trạng thái:** Hoàn thành xuất sắc 100% nội dung.
- **Đã hoàn thành:** 
    - [x] **Networking:** Tạo User-defined Bridge Network, hiểu cơ chế DNS nội bộ của Docker (gọi tên container thay vì IP).
    - [x] **Storage (Named Volume):** Sử dụng `mysql-data` để lưu trữ dữ liệu MySQL bền vững ngay cả khi xóa container.
    - [x] **Storage (Bind Mount):** Kết nối file `index.html` từ host vào container Nginx để phục vụ mục đích Development (Live Reload).
- **Kiến thức mới:** 
    - Phân biệt Bind Mount (Dev) vs Named Volume (Prod).
    - Hiểu tại sao IP container không cố định và lợi ích của Docker DNS.
    - Kỹ năng Debug nâng cao: Sử dụng `nslookup` và `ping` trong container để kiểm tra network.
- **Đã fix:** Cập nhật toàn bộ hệ thống script `verify.sh` sang phong cách **Root Cause Analysis (Phân tích nguyên nhân)** giúp tự học hiệu quả hơn.

### 🗓️ Day 5: 26/04/2026
- **Trạng thái:** Hoàn thành 100% nội dung thực hành và xử lý sự cố.
- **Đã hoàn thành:** 
    - [x] Thiết lập stack đa dịch vụ (Nginx, Redis, MySQL) bằng `docker-compose.yml`.
    - [x] Tách biệt cấu hình nhạy cảm (Password, Port) ra file `.env`.
    - [x] Làm chủ cơ chế phụ thuộc `depends_on` để kiểm soát thứ tự khởi động.
    - [x] Thực hành Scaling: Chạy song song nhiều instance web bằng lệnh `--scale`.
- **Kiến thức mới:** 
    - Cách Docker Compose gộp biến môi trường từ `.env` vào tệp cấu hình chính.
    - Kỹ năng Debug bằng lệnh `docker compose config` để kiểm tra bản thiết kế trước khi chạy.
    - Cách dọn dẹp hệ thống triệt để bằng `docker compose down -v`.

### 🗓️ Day 6: 27/04/2026
- **Trạng thái:** Hoàn thành 100% nội dung lý thuyết và thực hành Debug mạng.
- **Đã hoàn thành:** 
    - [x] **Debug chuyên nghiệp:** Sử dụng `docker logs`, `inspect`, và `exec` để tìm ra lỗi thiếu biến môi trường của MySQL (Exited code 1).
    - [x] **Xử lý mạng thực tế:** Tự tay kết nối hai container khác Network (`db-net`) và kiểm tra DNS bằng `ping` và `nc`.
    - [x] **Tối ưu hóa:** Nắm vững kiến thức về Multi-stage build và Layer caching để giảm dung lượng Image.
- **Kiến thức mới:** 
    - Sự khác biệt giữa **musl libc** (Alpine) và **glibc** (Ubuntu) dẫn đến lỗi thư viện.
    - Tại sao tuyệt đối không dùng `docker commit` cho môi trường Production.
    - Cách dọn dẹp hệ thống bằng `docker image prune` và `docker system prune`.
- **Đã fix:** Đồng bộ hóa định dạng trả lời câu hỏi trong toàn bộ các file README từ Day 01 đến Day 06 để khớp với hệ thống script `verify.sh`.

### 🗓️ Day 7: 05/05/2026 — Cập nhật nội dung
- **Trạng thái:** Đã tái cấu trúc toàn bộ nội dung Day 7, chưa thực hành.
- **Đã hoàn thành:**
    - [x] **Rewrite README.md**: Mở rộng từ 3 bài → 5 bài tập chi tiết với bước cụ thể và giải thích sâu.
    - [x] **Rewrite verify_day7.sh**: Cập nhật script verify theo phong cách RCA, phủ kín 5 bài tập (37+ check items).
    - [x] **Bai 1**: Docker Hub — Tag, Push, Pull (end-to-end workflow).
    - [x] **Bai 2**: Non-root User + Resource Limits (chown ordering, memory/CPU limits, restart policy, OOMKilled).
    - [x] **Bai 3**: Trivy Security Scanning (install, scan, severity filter, JSON export, .trivyignore).
    - [x] **Bai 4**: GitHub Actions CI/CD (workflow file, Secrets, Trivy trong pipeline, commit SHA tagging).
    - [x] **Bai 5**: Tong hop Production-ready Dockerfile (checklist 10 items).
- **Kiến thức mới:**
    - `docker tag` chỉ tạo alias (cùng image ID), không copy image.
    - Thứ tự QUAN TRỌNG: `COPY` → `chown` → `USER` — sai thứ tự sẽ lỗi quyền.
    - `--restart unless-stopped` ưu tiên hơn `--restart always` cho Production.
    - OOMKilled (Exit code 137) — container bị kill khi vượt memory limit.
    - Trivy `exit-code: '1'` trong CI/CD — fail pipeline nếu phát hiện CVE CRITICAL.

### 🗓️ Day 8: 05/05/2026 — Tạo nội dung mới
- **Trạng thái:** Đã tạo cấu trúc Day 8 (README.md + verify_day8.sh), chưa thực hành.
- **Nội dung đã tạo:**
    - [x] **README.md**: 5 bài tập chi tiết về CI/CD Advanced.
    - [x] **verify_day8.sh**: Script verify RCA style, ~50+ check items.
    - [x] **Bai 1**: Health Check — HEALTHCHECK trong Dockerfile, observe starting/healthy/unhealthy, simulate "sick" app.
    - [x] **Bai 2**: Docker Compose healthcheck + `depends_on` condition: `service_healthy` vs `service_started`.
    - [x] **Bai 3**: Multi-environment Pipeline — 6 jobs GitHub Actions (test→build→integration-test→deploy-dev→deploy-staging→deploy-prod với manual approval).
    - [x] **Bai 4**: Blue-Green Deployment — Nginx router, switch traffic, instant rollback.
    - [x] **Bai 5**: Tổng hợp auto-test script + Trivy + production-ready Dockerfile.
- **Kiến thức mới (sắp học):**
    - HEALTHCHECK lifecycle: `starting` → `healthy` → `unhealthy`. Docker KHÔNG tự kill container khi unhealthy.
    - `curl -f` là bắt buộc trong HEALTHCHECK CMD — không có `-f`, curl luôn trả exit 0.
    - `condition: service_healthy` vs `condition: service_started` trong `depends_on`.
    - Blue-Green: 2 version chạy song song, Nginx `nginx -s reload` switch traffic zero downtime.
    - `if: always()` cho cleanup step — luôn dọn container test kể cả pipeline fail.
    - `needs` tạo chuỗi phụ thuộc — nếu 1 job fail, tất cả job phía sau bị skip.
- **Đã cập nhật:**
    - `Progress.md`: Thêm Day 7 + Day 8 vào tổng quan và nhật ký.
    - `Plan.md`: Thêm nội dung chi tiết Day 8.

---

## 💡 Ghi chú quan trọng
- **Lệnh hay dùng:**
  - `docker network inspect <net_name>`: Kiểm tra danh sách container trong network.
  - `docker run -v $(pwd)/file:/path/in/container`: Cú pháp Bind Mount nhanh.
  - `docker volume rm`: Lệnh xóa dữ liệu vĩnh viễn (cần cẩn trọng).
  - `docker inspect --format '{{.State.Health.Status}}' <c>`: Kiểm tra health status container.
  - `docker inspect --format '{{.State.OOMKilled}}' <c>`: Kiểm tra container có bị kill do vượt RAM không.
  - `trivy image --severity CRITICAL,HIGH <image>`: Scan CVE mức nghiêm trọng.
  - `nginx -s reload`: Reload Nginx config mà KHÔNG downtime (dùng cho Blue-Green).
- **Kinh nghiệm:**
  - Luôn ưu tiên dùng **Container Name** để kết nối các dịch vụ thay vì IP để tránh lỗi khi container restart.
  - Thứ tự Dockerfile: `COPY` → `chown` → `USER` — sai thứ tự sẽ lỗi quyền.
  - `--restart unless-stopped` ưu tiên hơn `--restart always` cho Production.
  - HEALTHCHECK phải dùng `curl -f` — không có `-f`, curl luôn trả exit 0 bất kể HTTP 500.
  - `docker tag` chỉ tạo alias, KHÔNG copy image (cùng image ID).
  - Exit code 137 = OOMKilled (vượt memory limit), cần tăng `--memory` hoặc fix memory leak.
  - Blue-Green rollback: Chỉ cần `nginx -s reload` để chuyển traffic ngược — tức thì, zero downtime.
