# 📈 TRACKING TIẾN ĐỘ HỌC DOCKER

## 📅 Tổng quan lộ trình

- [x] **Day 1**: Hiểu bản chất & Kiến trúc Docker (19/04)
- [x] **Day 2**: Thành thạo Docker CLI (20/04)
- [x] **Day 3**: Dockerfile & Image Deep Dive (21/04)
- [x] **Day 4**: Networking & Data Persistence (22/04)
- [x] **Day 5**: Docker Compose (Multi-service) (26/04)
- [x] **Day 6**: Debug & Optimization (Hoàn thành 27/04)
- [ ] **Day 7**: CI/CD & Production Best Practices (Bai 1-2 hoàn thành 09/05, còn Bai 3-5)
- [ ] **Day 8**: CI/CD Advanced — Multi-environment, Health Checks & Deployment Strategies (Đã tạo nội dung 05/05, chưa thực hành)

---

## 📊 Tổng hợp kiến thức (cập nhật 10/05/2026)

> Xem thêm: **`REFERENCE.md`** (cheatsheet lệnh + 12 sai lầm thường gặp + debug + production checklist).

### Day 1: Bản chất Docker
- Docker giải quyết "Works on my machine" — đóng gói app + runtime + dependencies vào container.
- **Kiến trúc**: Client → Daemon → Registry → Container.
- **Docker vs VM**: Docker chia sẻ kernel Host, dùng **Namespaces** (cách ly) + **cgroups** (giới hạn CPU/RAM). VM cần Guest OS riêng → nặng, chậm.
- **Image vs Container**: Image = read-only "bản thiết kế", Container = instance đang chạy. 1 Image → nhiều Container.

### Day 2: Docker CLI
- Vòng đời: `Created` → `Running` → `Paused` → `Stopped` → `Deleted`.
- **Stop vs Kill**: `docker stop` gửi SIGTERM (lịch sự, cho 10s dọn dẹp), `docker kill` gửi SIGKILL (thô bạo, ngắt ngay).
- **Restart policy**: `unless-stopped` ưu tiên hơn `always` cho Production.
- **Dọn dẹp**: `docker system prune`, `docker image prune`, `docker rm -f $(docker ps -aq)`.

### Day 3: Dockerfile & Image
- **CMD vs ENTRYPOINT**: CMD có thể override, ENTRYPOINT không. Kết hợp: ENTRYPOINT làm executable, CMD làm default args.
- **COPY vs ADD**: Ưu tiên COPY (tường minh), ADD tự giải nén tar + download URL (tránh dùng).
- **.dockerignore**: Loại file rác khỏi build context → build nhanh + bảo mật.
- **Layer Caching**: "Ít thay đổi lên TRÊN, hay thay đổi xuống DƯỚI". Tách `COPY pom.xml` riêng trước `COPY src`.
- **Bảo mật Secrets lúc build**: Dùng BuildKit `--mount=type=secret` hoặc Multi-stage build. Tuyệt đối không dùng ARG cho secrets.

### Day 4: Networking & Volume
- **User-defined Bridge** (khuyên dùng): Hỗ trợ DNS — gọi container bằng tên thay vì IP.
- **Bind Mount** (`-v /host/path:/container/path`): Cho Dev — code thay đổi ngay lập tức.
- **Named Volume** (`-v vol-name:/container/path`): Cho Prod — data tồn tại khi xóa container.
- **Debug Network**: `nslookup`, `ping`, `curl -v` bên trong container.

### Day 5: Docker Compose
- Thay vì 10 lệnh `docker run` → khai báo tất cả vào `docker-compose.yml`.
- Compose tự tạo Network riêng + DNS nội bộ (service gọi nhau bằng tên).
- **`.env`**: Tách cấu hình nhạy cảm (password, port) ra file riêng. Kiểm tra bằng `docker compose config`.
- **`depends_on`**: Chỉ đảm bảo container start, KHÔNG đảm bảo app sẵn sàng → cần `healthcheck` + `condition: service_healthy`.

### Day 6: Debug & Optimization
- **Debug 4 bước**: `docker logs` → `docker inspect` → `docker exec` → `docker stats`.
- **Multi-stage Build**: Tách stage build (to, đầy đủ tools) và stage runtime (nhỏ, chỉ JRE). Kết quả: ~800MB → ~100MB.
- **Alpine dùng musl libc** thay vì glibc → lỗi "missing shared library" với một số thư viện. Fix bằng `gcompat` hoặc dùng `-slim`.

### Day 7: CI/CD & Production
- **Docker Hub**: `docker login` → `docker build -t user/app:v1` → `docker push`. `docker tag` chỉ tạo alias (cùng image ID).
- **Non-root User**: Thứ tự BẮT BUỘC: `COPY` → `chown` → `USER`. Sai thứ tự = lỗi quyền.
- **Resource Limits**: `--memory 256m --cpus 0.5`. Exit code 137 = OOMKilled.
- **PID 1 Signal Handling**: Python/Node ở PID 1 ignore SIGTERM. Fix bằng `tini`.
- **Trivy**: Scan CVE. `apk upgrade --no-cache` fix 60-70% CVE (1 dòng). `.trivyignore` chỉ ẩn CVE, KHÔNG fix thật.
- **GitHub Actions**: Checkout → Login → Build & Push → Trivy Scan. Dùng Secrets cho token.

### Day 8: CI/CD Advanced
- **Health Check**: `starting` → `healthy` → `unhealthy`. Docker KHÔNG tự kill container khi unhealthy. `curl -f` là bắt buộc.
- **depends_on condition**: `service_healthy` (đợi app sẵn sàng) vs `service_started` (chỉ đợi container start).
- **Deployment Strategies**: Rolling Update (thay từng cái), Blue-Green (2 version song song, `nginx -s reload` switch zero downtime), Canary (% nhỏ traffic).
- **Multi-environment Pipeline**: `needs` tạo chuỗi phụ thuộc, `environment: production` + manual approval, `if: always()` cho cleanup.
- **Auto-test**: Unit Test (mỗi commit) → Integration Test (sau build) → Smoke Test (sau deploy staging).

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

### 🗓️ Day 7: 09/05/2026 — Thực hành
- **Trạng thái:** Đã hoàn thành Bai 1 & Bai 2. Còn Bai 3-5.
- **Đã thực hành:**
    - [x] **Bai 1**: Docker Hub — Tag, Push, Pull. Đã build image, tag theo convention `username/image:tag`, push lên Docker Hub, xóa local, pull lại và chạy container thành công.
    - [x] **Bai 2**: Non-root User + Resource Limits. Đã tạo Dockerfile với `addgroup/adduser`, `chown`, `USER`. Chạy container với `--memory 256m --cpus 0.5 --restart unless-stopped`. Kiểm tra `whoami = appuser`, permission denied khi ghi `/etc`. Test restart policy với `tini` (PID 1 signal handling).
- **Chưa thực hành:**
    - [ ] **Bai 3**: Trivy Security Scanning (install, scan, severity filter, JSON export, .trivyignore).
    - [ ] **Bai 4**: GitHub Actions CI/CD (workflow file, Secrets, Trivy trong pipeline, commit SHA tagging).
    - [ ] **Bai 5**: Tong hop Production-ready Dockerfile (checklist 10 items).
- **Kiến thức mới (từ thực hành):**
    - `docker tag` chỉ tạo alias (cùng image ID), không copy image — xác nhận bằng `docker images`.
    - Thứ tự QUAN TRỌNG: `COPY` → `chown` → `USER` — sai thứ tự sẽ lỗi quyền.
    - `--restart unless-stopped` ưu tiên hơn `--restart always` cho Production.
    - OOMKilled (Exit code 137) — container bị kill khi vượt memory limit.
    - **PID 1 signal handling**: Python đứng PID 1 sẽ ignore SIGTERM → `kill 1` không crash container → RestartCount = 0. Fix bằng `tini`: `RUN apk add --no-cache tini` + `ENTRYPOINT ["/sbin/tini", "--"]`.
    - **Docker group fix**: `sudo docker build` dùng root's buildx (bản cũ) → lỗi API mismatch. Fix: `sudo usermod -aG docker $USER` + `newgrp docker` để chạy `docker` không cần sudo.
    - `docker images` (có s) mới đúng — `docker image` là subcommand cần thêm arg.

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
