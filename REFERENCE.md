# DOCKER REFERENCE - Lenh, Sai lam & Production Checklist

---

## 1. CHEATSHEET - Lenh & Cu phap

### Container Lifecycle

```bash
docker run [flags] <image>             # Tao + chay container moi
docker ps                              # Xem container dang chay
docker ps -a                           # Xem TAT CA container (ke da dung)
docker start <name>                    # Khoi dong lai container da dung
docker stop <name>                     # Dung container (SIGTERM, cho 10s)
docker kill <name>                     # Dung container ngay (SIGKILL)
docker restart <name>                  # Stop + Start
docker rm <name>                       # Xoa container da dung
docker rm -f <name>                    # Ep xoa container dang chay
docker rename <old> <new>              # Doi ten container
```

### docker run Flags

```bash
-d                                     # Chay nen (detached)
-it                                    # Interactive terminal
--name myapp                           # Dat ten container
--rm                                   # Tu xoa khi container dung
-p 8080:80                             # Map port host:container
-e KEY=VALUE                           # Set bien moi truong
-v /host/path:/container/path          # Bind mount (dev)
-v vol-name:/container/path            # Named volume (prod)
--network my-net                       # Gan vao network
--memory 512m                          # Gioi han RAM
--cpus 0.5                             # Gioi han CPU
--restart unless-stopped               # Tu restart khi crash
--restart on-failure[:max]             # Restart chi khi loi
--user appuser                         # Chay voi user cu the
```

### Logs & Debug

```bash
docker logs <name>                     # Xem toan bo log
docker logs -f <name>                  # Follow realtime
docker logs --tail 50 <name>           # 50 dong cuoi
docker logs --since 10m <name>         # Log 10 phut qua

docker inspect <name>                  # Xem chi tiet JSON
docker inspect -f '{{.NetworkSettings.IPAddress}}' <name>    # Xem IP
docker inspect -f '{{.State.Health.Status}}' <name>          # Health status
docker inspect -f '{{.State.OOMKilled}}' <name>              # Kiem tra OOM
docker inspect -f '{{.HostConfig.Memory}}' <name>            # Memory limit
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' <name> # Restart policy
docker inspect -f '{{.RestartCount}}' <name>                  # So lan restart

docker exec -it <name> bash            # Vao terminal container
docker exec <name> ls /app             # Chay 1 lenh khong vao shell
docker exec <name> whoami              # Kiem tra user dang chay

docker stats                           # Monitor tat ca container realtime
docker stats <name> --no-stream        # Snapshot 1 lan
```

### Image Management

```bash
docker build -t myapp:v1 .             # Build image tu Dockerfile
docker build -f Dockerfile.prod .      # Build voi Dockerfile cu the
docker build --no-cache -t myapp .     # Build khong dung cache

docker images                          # Danh sach image local
docker rmi <image>                     # Xoa image
docker image prune                     # Xoa image rac (dangling)
docker image prune -a                  # Xoa toan bo image khong dung

docker tag local-img user/app:v1       # Tag image (tao alias, KHONG copy)
docker push user/app:v1                # Push len Docker Hub
docker pull user/app:v1                # Pull tu Docker Hub
docker login                           # Dang nhap Docker Hub

docker history <image>                 # Xem lich su cac layer
```

### Network

```bash
docker network create my-net            # Tao user-defined bridge
docker network ls                       # Danh sach network
docker network inspect my-net           # Chi tiet network (cac container trong do)
docker network connect my-net <c>       # Noi container vao network
docker network disconnect my-net <c>    # Ngat container khoi network
docker network rm my-net                # Xoa network
```

| Kieu | Lenh | Dac diem |
|------|------|---------|
| Bridge (mac dinh) | `--network bridge` | IP rieng, KHONG DNS |
| **User-defined** | `--network my-net` | Co DNS (goi bang ten) — KHUYEN DUNG |
| Host | `--network host` | Dung chung host network (Linux only) |
| None | `--network none` | Cach ly hoan toan |

### Volume

```bash
docker volume create my-vol             # Tao named volume
docker volume ls                        # Danh sach volume
docker volume inspect my-vol            # Chi tiet volume
docker volume rm my-vol                 # Xoa volume (XOA VINH VIEN data!)
docker volume prune                     # Xoa volume khong dung
```

| | Bind Mount | Named Volume |
|---|---|---|
| Cu phap | `-v /host/path:/container/path` | `-v vol-name:/container/path` |
| Dung khi | Dev (live reload code) | Prod (DB data, logs) |
| Quan ly | Ban tu quan ly folder | Docker tu quan ly |
| Xoa container | Data van con tren host | Data van con (cho den khi `volume rm`) |

### Docker Compose

```bash
docker compose up -d                    # Khoi dong tat ca services
docker compose up --build               # Rebuild + khoi dong
docker compose up -d --scale app=3      # Scale 3 instance

docker compose down                     # Dung + xoa containers + networks
docker compose down -v                  # Xoa luon volumes (CAN THAN!)
docker compose down --rmi all           # Xoa luon images

docker compose ps                       # Trang thai services
docker compose logs -f app              # Log realtime cua service
docker compose exec db bash             # Vao shell service
docker compose restart app              # Restart 1 service
docker compose config                   # Kiem tra YAML + bien moi truong
docker compose build                    # Build tat ca images
```

### Dockerfile Instructions

```dockerfile
FROM python:3.11-alpine                 # Base image (dong dau tien)
WORKDIR /app                            # Thu muc lam viec

COPY app.py .                           # Uu tien COPY hon ADD
# ADD tu giai nen tar + download URL (tranh dung)

RUN apk add --no-cache curl             # Chay lenh luc build
ENV APP_VERSION=v1.0.0                  # Bien runtime
ARG BUILD_VERSION=1.0                   # Bien build-time only
EXPOSE 8080                             # Tai lieu (khong publish)

ENTRYPOINT ["python"]                   # Khong override duoc
CMD ["app.py"]                          # Co the override
# Ket hop: python app.py (mac dinh), docker run img other.py (override CMD)

# Non-root user (Production bat buoc)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app      # PHAI truoc USER
USER appuser

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### Layer Caching — Thu tu chuan

```dockerfile
# DUNG - Tan dung cache
COPY pom.xml .                          # It thay doi
RUN mvn dependency:go-offline           # CACHED neu pom.xml khong doi
COPY src ./src                          # Hay thay doi
RUN mvn package                         # Build code

# SAI - Cache miss lien tuc
COPY . .                                # Moi lan sua code -> mat cache
RUN mvn package
```

### Multi-stage Build

```dockerfile
# Stage 1: Build (image lon, day du tools)
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Runtime (image nho, chi JRE)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

### Docker Compose YAML Template

```yaml
version: "3.8"

services:
  app:
    build: .
    ports:
      - "${APP_PORT:-8080}:8080"
    environment:
      - DB_HOST=db
      - DB_PASSWORD=${DB_PASS}
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./src:/app/src                  # Bind mount (dev)
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 15s

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASS}
      MYSQL_DATABASE: appdb
    volumes:
      - mysql-data:/var/lib/mysql       # Named volume (prod)
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

volumes:
  mysql-data:

networks:
  backend:
    driver: bridge
```

### Security & Production

```bash
# Security scanning
trivy image myapp:latest                                    # Scan toan bo
trivy image --severity CRITICAL,HIGH myapp                  # Chi CRITICAL/HIGH
trivy image --exit-code 1 --severity CRITICAL,HIGH myapp    # Fail neu co CVE
trivy image --format json --output report.json myapp        # Xuat JSON
trivy image --ignorefile .trivyignore myapp                 # Bo qua CVE cu the

# Fix CVE trong Dockerfile
RUN apk upgrade --no-cache              # Fix 60-70% CVE (1 dong!)

# Non-root user (Alpine)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

# Non-root user (Debian/Ubuntu)
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# PID 1 signal handling (fix Python/Node ignore SIGTERM)
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python", "app.py"]
```

### Cleanup (Don dep he thong)

```bash
docker system prune                    # Xoa container da dung + network rac + cache
docker system prune -a                 # Xoa luon tat ca image khong dung
docker image prune                     # Xoa image rac (dangling)
docker image prune -a                  # Xoa tat ca image khong dung boi container
docker volume prune                    # Xoa volume khong dung
docker container prune                 # Xoa container da dung
docker rm -f $(docker ps -aq)          # Xoa TAT CA container (can than!)
```

### Exit Codes

| Code | Y nghia |
|------|---------|
| 0 | Thoat binh thuong |
| 1 | Loi ung dung (Application error) |
| 137 | **OOMKilled** — vuot memory limit |
| 139 | Segfault |
| 143 | Da nhan SIGTERM (docker stop) |

### GitHub Actions Workflow Template

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: echo "Add test commands here"

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/myapp:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-prod:
    runs-on: ubuntu-latest
    needs: build
    environment: production            # Can manual approval
    steps:
      - name: Deploy
        run: echo "Deploy commands here"
```

---

## 2. GOTCHAS - 12 Sai lam Thuong gap

### #1 Dung IP container de ket noi
**Sai**: `curl 172.17.0.2:3306` — IP container khong co dinh, moi lan restart co the doi.
**Dung**: Tao User-defined Network, dung ten container: `curl db:3306`
**Nguon**: Day 4

### #2 Sai thu tu COPY -> CHOWN -> USER
**Sai**:
```dockerfile
USER appuser                # Chuyen user qua som -> loi quyen
COPY app.py .
RUN chown -R appuser:appgroup /app  # appuser khong co quyen chown
```
**Dung**:
```dockerfile
COPY app.py .               # Copy voi quyen root
RUN chown -R appuser:appgroup /app  # Root chown cho appuser
USER appuser                # Chuyen user SAU khi da cap quyen
```
**Nguon**: Day 7 Bai 2

### #3 Dung `docker commit` tao Image Production
**Sai**: Chay container, cai thu cong, `docker commit` -> Image "hop den".
**Dung**: Luon viet Dockerfile — minh bach, version control, tai tao duoc.
**Nguon**: Day 6

### #4 Khong tach `COPY pom.xml` rieng trong Dockerfile
**Sai**:
```dockerfile
COPY . .                    # Moi lan sua code -> tai lai toan bo dependencies
RUN mvn package
```
**Dung**:
```dockerfile
COPY pom.xml .              # It thay doi -> CACHED
RUN mvn dependency:go-offline
COPY src ./src              # Hay thay doi
RUN mvn package
```
**Nguon**: Day 3, Day 6

### #5 HEALTHCHECK khong dung `curl -f`
**Sai**: `HEALTHCHECK CMD curl http://localhost:8080/ || exit 1`
Khong co `-f`, curl luon tra exit 0 bat ke HTTP 500/404 -> Docker luon coi "healthy".

**Dung**: `HEALTHCHECK CMD curl -f http://localhost:8080/ || exit 1`
Flag `-f` lam curl tra exit code 1 khi HTTP >= 400.
**Nguon**: Day 8 Bai 1

### #6 Dung `--restart always` thay vi `unless-stopped`
**Van de**: `always` restart container ngay ca khi ban da `docker stop` thu cong, sau khi server reboot.
**Dung**: `--restart unless-stopped` — giong `always` nhung NEU ban da `docker stop`, no KHONG restart lai.
**Nguon**: Day 7 Bai 2

### #7 Python/Node o PID 1 bi ignore SIGTERM
**Van de**: `docker stop` gui SIGTERM nhung Python/Node PID 1 ignore -> phai cho 10s roi SIGKILL.
**Fix**:
```dockerfile
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python", "app.py"]
```
**Nguon**: Day 7 Bai 2

### #8 Mo port DB/Cache ra host khong can thiet
**Sai**:
```yaml
db:
  ports:
    - "3306:3306"           # Mo DB ra Internet — rui ro bao mat!
```
**Dung**: Chi can internal network, khong can `ports`:
```yaml
db:
  networks:
    - backend               # Chi app trong cung network moi truy cap duoc
```
**Nguon**: Day 5

### #9 Alpine loi "missing shared library"
**Van de**: Alpine dung **musl libc** thay vi **glibc**. Nhieu thu vien dich san cho glibc khong chay.
**Fix**: `apk add --no-cache gcompat` hoac dung `-slim` (Debian-based) thay vi `alpine`.
**Nguon**: Day 6

### #10 `depends_on` khong dam bao app san sang
**Van de**: `depends_on: db` chi cho container MySQL start, nhung MySQL ben trong co the van dang khoi tao.
**Fix**: Dung `healthcheck` + `condition: service_healthy`:
```yaml
depends_on:
  db:
    condition: service_healthy
```
**Nguon**: Day 5, Day 8

### #11 Luu secrets trong Dockerfile (ARG/ENV)
**Sai**: `ARG DB_PASSWORD=my_secret` (lo trong `docker history`), `ENV API_KEY=abc123` (lo khi `docker inspect`).
**Dung**:
- Runtime: `docker run -e API_KEY=xxx` hoac `--env-file`
- Build time: BuildKit `--mount=type=secret`
- Production: Docker Secrets (Swarm) hoac Kubernetes Secrets
**Nguon**: Day 3 Bai 6, Day 7

### #12 Dung `:latest` tag trong Production
**Van de**: `:latest` khong co dinh — image co the thay doi noi dung khi Docker Hub update. Rollback kho.
**Dung**: `:v1.2.3` (semver) cho release, `:sha-abc1234` (commit SHA) cho CI/CD.
**Nguon**: Day 7

---

## 3. DEBUG - Kinh nghiem thuc te

### Container khong khoi dong duoc
```bash
docker logs <name>                 # Tim error message
docker inspect <name>              # Kiem tra ExitCode va Error
docker run -it <image> bash        # Vao shell debug thu cong
```

### Container chay nhung app loi
```bash
docker exec -it <name> bash        # Vao trong kiem tra
env                                # Xem env vars
ps aux                             # Xem process dang chay
curl http://db:3306                # Test ket noi den service khac
```

### Container an qua nhieu RAM/CPU
```bash
docker stats                       # Xem realtime tat ca containers
docker inspect -f '{{.State.OOMKilled}}' <name>  # Kiem tra bi kill vi vuot RAM
# Fix: Tang --memory hoac fix memory leak trong app
```

### Hai container khong cung network khong ket noi duoc
```bash
# Chan doan
docker exec -it <app> sh
ping <db-name>                     # Loi: Could not resolve host

# Fix: Noi container vao cung network
docker network connect <net-name> <container>

# Kiem tra lai
ping <db-name>                     # OK: DNS da thong
```

---

## 4. PRODUCTION-READY CHECKLIST

| # | Thuoc tinh | Lenh kiem tra |
|---|-----------|---------------|
| 1 | Multi-stage build | `docker images` — so sanh size |
| 2 | Non-root user | `docker exec <c> whoami` -> appuser |
| 3 | COPY -> CHOWN -> USER (thu tu dung) | Build khong loi + app doc ghi duoc file |
| 4 | Layer caching (it thay doi tren) | Build lan 2, xem CACHED |
| 5 | .dockerignore | Build context nho, khong copy file rac |
| 6 | Version tag (khong dung :latest) | `docker images` — xem tag cu the |
| 7 | Resource limits | `docker inspect` — Memory/CPU |
| 8 | Restart policy (unless-stopped) | `docker inspect` — RestartPolicy |
| 9 | HEALTHCHECK voi curl -f | `docker inspect -f '{{.State.Health.Status}}'` |
| 10 | Trivy scan (0 CRITICAL) | `trivy image --severity CRITICAL` |
| 11 | apk upgrade --no-cache | Scan lai — so sanh so CVE truoc/sau |
| 12 | ENTRYPOINT + CMD | `docker run <img> --help` — override duoc args |
| 13 | LABEL metadata | `docker inspect -f '{{.Config.Labels}}'` |
| 14 | PID 1 signal handling (tini) | `docker stop` dung nhanh, khong cho 10s |
