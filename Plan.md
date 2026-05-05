# 🚀 LỘ TRÌNH HỌC DOCKER TRONG 7 NGÀY (CHI TIẾT)

## 🎯 Mục tiêu sau 7 ngày

- Tự build Docker image cho project Java/C++
- Hiểu và debug container chuyên nghiệp (log, stats, inspect, exec)
- Sử dụng Docker Compose cho multi-service (Backend + Database + Cache)
- Tích hợp Docker vào workflow dev/test (volume, networking)
- Đọc, hiểu và tối ưu Dockerfile (multi-stage, Alpine, layer caching)
- Đưa Docker vào CI/CD với GitHub Actions

---

## 🗓️ DAY 1 – Hiểu bản chất Docker

### 🎯 Mục tiêu
- Hiểu vấn đề "Works on my machine" và lý do Docker ra đời
- Nắm kiến trúc: Docker Engine, Daemon, Client, Registry
- Phân biệt được Container vs VM (Namespace, cgroup)

### 📚 Kiến thức cần nắm
#### Docker giải quyết bài toán gì?
Môi trường dev khác prod → app chạy được trên máy dev nhưng lỗi trên server. Docker đóng gói app + runtime + dependencies vào 1 "hộp" (container) chạy được ở bất kỳ đâu.

#### Docker vs Virtual Machine
- **VM**: ảo hóa phần cứng, cần Guest OS riêng → nặng (GB), khởi động chậm (phút)
- **Docker**: chia sẻ kernel host, dùng Linux Namespace + cgroup để cô lập → nhẹ (MB), khởi động nhanh (giây)

#### Image vs Container (Khuôn đúc vs Sản phẩm)
- **Image**: file read-only, là "bản thiết kế" (như class)
- **Container**: instance đang chạy từ image (như object)
- 1 image → nhiều container. Container bị xoá không ảnh hưởng image

#### Docker Architecture
Client (docker CLI) → REST API → Docker Daemon (dockerd) → Registry (Docker Hub) → Containers

#### Vòng đời container
`created` → `running` → `paused` → `stopped` → `removed`
Mỗi trạng thái có lệnh tương ứng: `run`, `pause`, `stop`, `rm`

### 🛠️ Thực hành có giải thích
```bash
# Lệnh hello-world để xác nhận Docker hoạt động
docker run hello-world

# Chạy Ubuntu tương tác (-it = interactive + TTY, --name đặt tên)
docker run -it --name test-ubuntu ubuntu bash

# Bên trong container: cài vim
apt-get update && apt-get install -y vim

# Thoát container (container vẫn còn, chỉ dừng)
exit

# Xem tất cả containers (kể cả đã stopped)
docker ps -a

# Xoá container cũ
docker rm test-ubuntu

# Chạy container MỚI từ image ubuntu
docker run -it ubuntu bash
# → vim không còn nữa! Vì container mới = image gốc, không lưu thay đổi
```

### 🔥 Bài tập
- **Bài 1**: Chạy container Ubuntu, cài curl bên trong, thoát và xoá container. Sau đó chạy container Ubuntu mới → kiểm tra curl còn không. Giải thích tại sao.
    - 💡 *Gợi ý*: Thay đổi trong container chỉ tồn tại trong container đó. Image gốc không bị ảnh hưởng. Để lưu thay đổi, cần dùng `docker commit` hoặc viết Dockerfile.
- **Bài 2**: Tìm hiểu lệnh `docker images` và `docker image inspect ubuntu`. Quan sát cấu trúc layer của image.
    - 💡 *Gợi ý*: Image được xây bằng nhiều layer chồng lên nhau (union filesystem). Mỗi lệnh `RUN` trong Dockerfile tạo 1 layer mới.

**Câu hỏi tự kiểm tra**: Tại sao Docker container khởi động nhanh hơn VM? Namespace và cgroup có vai trò gì trong Docker?

---

## 🗓️ DAY 2 – Docker CLI & Container Management

### 🎯 Mục tiêu
- Thành thạo toàn bộ vòng đời container
- Hiểu và dùng được các flags quan trọng
- Chạy được nginx, map port, truy cập từ browser

### 📚 Kiến thức cần nắm
#### `docker run` với các flags phổ biến

| Flag | Ý nghĩa |
| :--- | :--- |
| `-d` | Chạy nền (detach) |
| `-it` | Interactive terminal |
| `--rm` | Tự xoá khi stop |
| `-p host:container` | Map port |
| `-v` | Mount volume |
| `-e KEY=VALUE` | Set env var |
| `--name` | Đặt tên container |

#### `docker exec` — vào container đang chạy
```bash
docker exec -it <name> bash   # Mở shell
docker exec <name> ls /app    # Chạy lệnh không cần vào shell
```
Khác với `attach`: `exec` tạo process mới, không làm gián đoạn process chính.

#### `docker logs` — xem output của container
```bash
docker logs <name>          # Xem toàn bộ log
docker logs -f <name>       # Follow (real-time)
docker logs --tail 50 <name>  # 50 dòng cuối
docker logs --since 1h <name> # Log 1 giờ qua
```

#### `docker inspect` — thông tin chi tiết container
Trả về JSON với toàn bộ config: IP address, mount points, env vars, network settings.
```bash
docker inspect --format '{{.NetworkSettings.IPAddress}}' <name>
```

#### `docker stats` — monitor tài nguyên realtime
Hiện CPU%, RAM, Network I/O, Block I/O của tất cả containers. Dùng để phát hiện container ăn quá nhiều tài nguyên.

### 🛠️ Thực hành có giải thích
```bash
# Chạy nginx ở port 8080 (host) → 80 (container)
docker run -d --name my-nginx -p 8080:80 nginx

# Vào xem file cấu hình nginx bên trong container
docker exec -it my-nginx bash

# Xem log realtime
docker logs -f my-nginx

# Monitor tài nguyên
docker stats my-nginx

# Dừng và xoá container
docker stop my-nginx && docker rm my-nginx

# Dùng --rm để tự xoá sau khi stop
docker run -d --rm --name temp-nginx -p 8081:80 nginx
```

### 🔥 Bài tập
- **Bài 1**: Chạy nginx ở port 8081. Truy cập từ browser: http://localhost:8081. Sau đó dùng `docker exec` vào container, thay đổi nội dung file `/usr/share/nginx/html/index.html`, refresh browser.
    - 💡 *Gợi ý*: `echo "<h1>Hello Docker</h1>" > /usr/share/nginx/html/index.html` bên trong container.
- **Bài 2**: Chạy 3 containers nginx ở port khác nhau (8081, 8082, 8083). Dùng `docker stats` quan sát tất cả. Sau đó dùng `docker stop $(docker ps -q)` để dừng tất cả.
    - 💡 *Gợi ý*: `docker ps -q` trả về chỉ list ID của containers đang chạy. `$(...)` là command substitution trong bash.
- **Bài 3**: Dùng `docker inspect my-nginx` và tìm: IP address của container, port mapping, và thư mục mount.

---

## 🗓️ DAY 3 – Dockerfile & Image Building

### 🎯 Mục tiêu
- Tự viết Dockerfile cho Java JAR và C++ binary
- Hiểu sự khác biệt `CMD` vs `ENTRYPOINT`
- Dùng `.dockerignore` để loại file rác

### 📚 Kiến thức cần nắm
#### Các Dockerfile instructions quan trọng
- **FROM** — base image: Luôn là dòng đầu tiên. Chọn image nhỏ nhất phù hợp: `openjdk:17-slim` thay vì `openjdk:17`. Dùng alpine khi có thể.
- **WORKDIR** — thư mục làm việc: Đặt working directory cho các lệnh tiếp theo. Dùng `/app` theo convention. Tự tạo nếu chưa tồn tại.
- **COPY vs ADD**: 
    - `COPY`: copy file/folder từ host vào image
    - `ADD`: thêm tính năng giải nén tar và download URL. Khuyên dùng `COPY` vì tường minh hơn.
- **CMD vs ENTRYPOINT**:
    - `CMD`: lệnh mặc định khi chạy container, có thể override
    - `ENTRYPOINT`: lệnh chính, không override được (chỉ append thêm args)
    - Kết hợp: `ENTRYPOINT` làm executable, `CMD` làm default args
- **ENV và ARG**:
    - `ARG`: chỉ dùng lúc build (`docker build --build-arg`)
    - `ENV`: tồn tại trong container lúc runtime
    - ⚠️ Secrets không được để trong `ENV` vì lộ trong `docker inspect`

### 🛠️ Dockerfile mẫu
**Java (Spring Boot JAR)**
```dockerfile
FROM openjdk:17-slim
WORKDIR /app

# Copy pom.xml trước để cache dependency
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

EXPOSE 8080
CMD ["java", "-jar", "target/app.jar"]
```

**C++ binary (Multi-stage)**
```dockerfile
FROM gcc:12 AS builder
WORKDIR /app
COPY . .
RUN g++ -O2 -o myapp main.cpp

# Image chạy nhỏ hơn, không cần gcc
FROM debian:slim
WORKDIR /app
COPY --from=builder /app/myapp .

CMD ["./myapp"]
```

**File `.dockerignore`**
```text
# .dockerignore — tương tự .gitignore
target/
build/
*.class
*.log
.git
.env
node_modules/
__pycache__/
# Tránh copy file secrets vào image!
*.pem
*.key
```

### 🔥 Bài tập
- **Bài 1**: Tạo một Java app đơn giản (main class in ra "Hello Docker"), build JAR, viết Dockerfile, build image và chạy container.
    - 💡 *Lệnh*: `docker build -t my-java-app .` rồi `docker run my-java-app`
- **Bài 2**: Thử sự khác biệt `CMD` vs `ENTRYPOINT`: viết 2 Dockerfile, 1 dùng `CMD`, 1 dùng `ENTRYPOINT`. Override khi chạy: `docker run my-image echo "overridden"`.
- **Bài 3**: So sánh kích thước image: build cùng Java app nhưng từ `openjdk:17` (full) vs `openjdk:17-slim`. Dùng `docker images` để so sánh.

---

## 🗓️ DAY 4 – Networking & Data Persistence (Volume)

### 🎯 Mục tiêu
- Hiểu 3 kiểu network: `bridge`, `host`, `none`
- Kết nối 2 container qua tên (DNS tự động)
- Phân biệt Bind Mount vs Named Volume và biết khi nào dùng loại nào

### 📚 Kiến thức cần nắm
#### Docker Networking
- **Bridge network (mặc định)**: Mỗi container nhận IP riêng. Network mặc định không hỗ trợ DNS name — phải tạo user-defined network.
- **User-defined Bridge network (khuyên dùng)**:
    ```bash
    docker network create my-net
    ```
    Hỗ trợ DNS: gọi container bằng `--name`. Ví dụ: từ container app, có thể curl `http://db:3306` nếu cả 2 cùng network.
- **Host network**: Container dùng thẳng network interface của host. Chỉ chạy trên Linux. Dùng khi cần performance cao.

#### Docker Storage
- **Bind Mount — dành cho dev**: `-v /home/user/code:/app`. Map folder thật trên host vào container. Code thay đổi trên host → thay đổi ngay trong container.
- **Named Volume — dành cho data persistence**: `-v mysql-data:/var/lib/mysql`. Docker tự quản lý. Xoá container → data vẫn còn.
    ```bash
    docker volume ls        # Liệt kê volumes
    docker volume rm <name> # Xoá volume
    ```

### 🛠️ Thực hành kết nối containers
```bash
# Tạo network
docker network create my-net

# Chạy MySQL với named volume, trong network
docker run -d --name mysql-db \
  --network my-net \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=mydb \
  mysql:8.0

# Chạy Ubuntu cùng network, test kết nối
docker run -it --rm --network my-net ubuntu bash

# Bên trong Ubuntu container:
apt-get install -y curl
# Gọi MySQL bằng tên container (DNS tự động)
curl mysql-db:3306
```

### 🔥 Bài tập
- **Bài 1**: Tạo network `dev-net`. Chạy nginx và Ubuntu cùng network. Từ Ubuntu dùng curl gọi nginx bằng tên container.
    - 💡 *Cài curl*: `apt-get update && apt-get install -y curl`. Gọi: `curl http://my-nginx:80`
- **Bài 2**: Chạy MySQL với named volume. Tạo 1 table trong MySQL. Xoá container. Chạy MySQL mới với cùng volume → kiểm tra data vẫn còn.
    - 💡 *Vào MySQL*: `docker exec -it mysql-db mysql -u root -proot`
- **Bài 3**: Thử bind mount: chạy nginx với `-v ./html:/usr/share/nginx/html`. Chỉnh sửa file html trên host → refresh browser ngay lập tức.

---

## 🗓️ DAY 5 – Docker Compose (Multi-Service)

### 🎯 Mục tiêu
- Hiểu cấu trúc `docker-compose.yml`
- Dựng stack: Java Backend + MySQL + Redis
- Thành thạo: `up`, `down`, `logs`, `build`, `ps`, `exec`

### 📚 Cấu trúc `docker-compose.yml` đầy đủ
```yaml
version: "3.8"

services:
  app:
    build: .                        # Build từ Dockerfile hiện tại
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=db                  # Tên service = hostname DNS
      - REDIS_HOST=cache
    depends_on:
      db:
        condition: service_healthy  # Chờ db healthy mới start
    volumes:
      - ./src:/app/src              # Bind mount cho dev
    networks:
      - backend

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: appdb
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - backend

  cache:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb
    volumes:
      - redis-data:/data
    networks:
      - backend

volumes:
  mysql-data:
  redis-data:

networks:
  backend:
    driver: bridge
```

### 📚 Các lệnh Compose quan trọng

| Lệnh | Ý nghĩa |
| :--- | :--- |
| `docker compose up -d` | Khởi động tất cả services ở background |
| `docker compose up --build` | Rebuild images rồi mới khởi động |
| `docker compose down` | Dừng và xoá containers + networks |
| `docker compose down -v` | Xoá luôn volumes (cẩn thận!) |
| `docker compose ps` | Xem trạng thái các services |
| `docker compose logs -f app` | Xem log realtime của service app |
| `docker compose exec db bash` | Vào shell của service |
| `docker compose restart app` | Restart 1 service |

### 🔥 Bài tập
- **Bài 1**: Viết `docker-compose.yml` cho stack: Spring Boot app + MySQL + Redis. Chạy `docker compose up -d` và kiểm tra bằng `docker compose ps`.
- **Bài 2**: Thêm healthcheck cho MySQL service. Thêm `depends_on` với `condition: service_healthy` cho app. Quan sát thứ tự khởi động.
- **Bài 3**: Dùng file `.env` để quản lý secrets (`DB_PASSWORD`, `REDIS_PASSWORD`). Tham chiếu trong compose: `${DB_PASSWORD}`.

---

## 🗓️ DAY 6 – Debug & Optimization (Level Up)

### 🎯 Mục tiêu
- Thành thạo Debug workflow chuyên nghiệp (logs, inspect, exec, stats)
- Multi-stage build: Giảm dung lượng image cực mạnh (Ví dụ: Java 800MB -> 150MB)
- Tối ưu hóa Layer Caching để tăng tốc độ build 2x-10x

### 📚 Debug Workflow
**Container không khởi động được**
```bash
docker logs <name>               # Xem error message
docker inspect <name>            # Kiểm tra ExitCode và Error
docker run -it <image> bash      # Vào shell debug thủ công
```

**Container chạy nhưng app lỗi**
```bash
docker exec -it <name> bash      # Vào trong kiểm tra
env                               # Xem env vars
ps aux                            # Xem process đang chạy
curl http://db:3306               # Test kết nối đến service khác
```

**Container ăn quá nhiều RAM/CPU**
```bash
docker stats                     # Xem realtime tất cả containers
# Giới hạn tài nguyên khi chạy:
docker run --memory 512m --cpus 0.5 my-app
```

### 📚 Multi-stage Build — giảm image size cực mạnh
```dockerfile
# Stage 1: Build (image lớn, đầy đủ tools)
FROM maven:3.9-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline    # Cache dependencies layer
COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Runtime (image nhỏ, chỉ cần JRE)
FROM openjdk:17-jre-slim
WORKDIR /app
# Chỉ copy JAR từ stage build
COPY --from=builder /app/target/app.jar .
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

### 📚 Layer Caching — sắp xếp đúng thứ tự
- ❌ **SAI** — cache miss liên tục:
    ```dockerfile
    COPY . .
    RUN mvn package
    ```
- ✅ **ĐÚNG** — tận dụng cache:
    ```dockerfile
    COPY pom.xml .
    RUN mvn dependency:go-offline
    COPY src ./src
    RUN mvn package
    ```
**Nguyên tắc**: Những thứ ít thay đổi (dependencies) → để trên. Những thứ hay thay đổi (source code) → để dưới.

---

## 🗓️ DAY 7 – CI/CD & Production Best Practices

### 🎯 Mục tiêu
- Push image lên Docker Hub
- Tự động build & push với GitHub Actions
- Chạy container an toàn với non-root user và security scanning

### 📚 Docker Registry Workflow
```bash
# 1. Đăng nhập Docker Hub
docker login

# 2. Build image với tag
docker build -t username/my-app:v1.0.0 .

# 3. Push lên Docker Hub
docker push username/my-app:v1.0.0
```

### 📚 GitHub Actions — Tự động build & push
```yaml
# .github/workflows/docker.yml
name: Build and Push Docker Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/my-app:latest
```

### 📚 Security Best Practices
- **Chạy với non-root user**:
    ```dockerfile
    RUN addgroup -S appgroup && adduser -S appuser -G appgroup
    USER appuser
    ```
- **Scan lỗ hổng bảo mật với Trivy**:
    ```bash
    trivy image my-app:latest
    ```
- **Không lưu secrets trong image**: Dùng BuildKit secrets hoặc env vars runtime.
- **Giới hạn tài nguyên**:
    ```bash
    docker run --memory 512m --cpus 1 my-app
    ```

### 🔥 Bài tập
- **Bài 1**: Tạo tài khoản Docker Hub. Build image Java app, tag và push lên Docker Hub.
- **Bài 2**: Tạo GitHub repo, setup GitHub Actions tự động build và push image.
- **Bài 3**: Sửa Dockerfile thêm non-root user. Cài Trivy và scan image.

---

## 🗓️ DAY 8 – CI/CD Advanced: Multi-environment, Health Checks & Deployment Strategies

### 🎯 Mục tiêu
- Xây dựng pipeline CI/CD đa môi trường (Dev → Staging → Production) với GitHub Actions.
- Hiểu và áp dụng Health Check trong Docker và Docker Compose (HEALTHCHECK, depends_on condition).
- Thực hành chiến lược Deploy: Rolling Update, Blue-Green, Canary.
- Tích hợp auto-test vào pipeline để đảm bảo chỉ deploy code đúng.
- Áp dụng Docker Compose cho môi trường Production (health check, Nginx router, multi-service).

### 📚 Kiến thức cần nắm
#### Health Check trong Docker
- `HEALTHCHECK` trong Dockerfile: Kiểm tra ứng dụng bên trong container có "khỏe" không.
- Trạng thái: `starting` → `healthy` → `unhealthy`.
- Docker KHÔNG tự kill container khi unhealthy — cần orchestrator (Swarm, K8s).
- `curl -f` là bắt buộc trong HEALTHCHECK CMD để fail khi HTTP >= 400.

#### Docker Compose healthcheck + depends_on
- `condition: service_healthy` — đợi service pass healthcheck mới start.
- `condition: service_started` — chỉ đợi container start, không đảm bảo app sẵn sàng.
- `start_period` — thời gian chờ trước khi bắt đầu check (tránh false-unhealthy).

#### Multi-environment Pipeline (GitHub Actions)
- `needs` — tạo chuỗi phụ thuộc giữa jobs (test → build → deploy).
- `environment` — gán job với GitHub Environment, hỗ trợ protection rules và secrets riêng.
- `if: always()` — step luôn chạy kể cả khi bước trước fail (dùng cho cleanup).
- `cache-from: type=gha` — cache Docker build layers trên GitHub Actions.

#### Chiến lược Deployment
- **Rolling Update**: Thay thế container cũ từng cái một. Zero downtime nhưng rollback chậm.
- **Blue-Green**: 2 version chạy song song. Switch traffic bằng Nginx. Zero downtime, rollback tức thì.
- **Canary**: Deploy cho % nhỏ traffic. Monitor rồi tăng dần. An toàn nhất nhưng phức tạp nhất.

### 🔥 Bài tập
- **Bài 1**: Viết Dockerfile với HEALTHCHECK, quan sát starting → healthy → unhealthy.
- **Bài 2**: Docker Compose multi-service với healthcheck + depends_on condition: service_healthy.
- **Bài 3**: Tạo GitHub Actions pipeline multi-environment (Dev, Staging, Prod) với manual approval.
- **Bài 4**: Thực hành Blue-Green Deployment với Nginx router + docker-compose.
- **Bài 5**: Tổng hợp auto-test script + Trivy + production-ready Dockerfile.

---

## 🧠 Bonus — Bước tiếp theo

- **Kubernetes (K8s)**: Orchestrate nhiều containers ở scale lớn.
- **Portainer**: UI web để quản lý Docker.
- **Docker Swarm**: Orchestration built-in của Docker.
- **Helm**: Package manager cho Kubernetes.
- **Docker BuildKit**: Tính năng build nâng cao.
