# LO TRINH HOC DOCKER - 8 NGAY (CHI TIET)

> Cap nhat 10/05/2026 — Danh dau trang thai hoan thanh thuc te.

## Muc tieu sau 8 ngay

- Tu build Docker image cho project Java/C++
- Hieu va debug container chuyen nghiep (log, stats, inspect, exec)
- Su dung Docker Compose cho multi-service (Backend + Database + Cache)
- Tich hop Docker vao workflow dev/test (volume, networking)
- Doc, hieu va toi uu Dockerfile (multi-stage, Alpine, layer caching)
- Dua Docker vao CI/CD voi GitHub Actions
- Ap dung Production Best Practices (non-root, Trivy, health check, deployment strategies)

---

## DAY 1 - Hieu ban chat Docker [HOAN THANH 19/04]

### Muc tieu
- Hieu van de "Works on my machine" va ly do Docker ra doi
- Nhap kien truc: Docker Engine, Daemon, Client, Registry
- Phan biet duoc Container vs VM (Namespace, cgroup)

### Kien thuc can nap
#### Docker giai quyet bai toan gi?
Moi truong dev khac prod -> app chay duoc tren may dev nhung loi tren server. Docker dong goi app + runtime + dependencies vao 1 "hop" (container) chay duoc o bat cu dau.

#### Docker vs Virtual Machine
- **VM**: Ao hoa phan cung, can Guest OS rieng -> nang (GB), khoi dong cham (phut)
- **Docker**: Chia se kernel host, dung Linux Namespace + cgroup de co lap -> nhe (MB), khoi dong nhanh (giay)

#### Image vs Container (Khuon duc vs San pham)
- **Image**: file read-only, la "ban thiet ke" (nhu class)
- **Container**: instance dang chay tu image (nhu object)
- 1 image -> nhieu container. Container bi xoa khong anh huong image

#### Docker Architecture
Client (docker CLI) -> REST API -> Docker Daemon (dockerd) -> Registry (Docker Hub) -> Containers

#### Vong doi container
`created` -> `running` -> `paused` -> `stopped` -> `removed`
Moi trang thai co lenh tuong ung: `run`, `pause`, `stop`, `rm`

### Thuc hanh
- **Bai 1**: Chay `docker run hello-world` xac nhan Docker hoat dong.
- **Bai 2**: Chay Ubuntu tuong tac (`-it`), cai vim, thoat, xoa container, chay lai -> vim khong con (tinh chat Ephemeral).
- **Bai 3**: Tim hieu `docker images` va `docker image inspect ubuntu` — quan sat cau truc layer.

**Cau hoi tu kiem tra**: Tai sao Docker container khoi dong nhanh hon VM? Namespace va cgroup co vai tro gi trong Docker?

---

## DAY 2 - Docker CLI & Container Management [HOAN THANH 20/04]

### Muc tieu
- Thanh thao toan bo vong doi container
- Hieu va dung duoc cac flags quan trong
- Chay duoc nginx, map port, truy cap tu browser

### Kien thuc can nap
#### `docker run` voi cac flags pho bien

| Flag | Y nghia |
| :--- | :--- |
| `-d` | Chay nen (detach) |
| `-it` | Interactive terminal |
| `--rm` | Tu xoa khi stop |
| `-p host:container` | Map port |
| `-v` | Mount volume |
| `-e KEY=VALUE` | Set env var |
| `--name` | Dat ten container |

#### Stop vs Kill
- **`docker stop`**: Gui SIGTERM (lich su, cho 10s don dep) -> moi SIGKILL.
- **`docker kill`**: Gui SIGKILL ngay lap tuc (tho bao).

#### Restart Policy
- `--restart no`: Mac dinh.
- `--restart on-failure`: Chi restart khi exit code != 0.
- `--restart always`: Luon restart, ke ca sau Docker daemon restart.
- **`--restart unless-stopped`**: Uu tien hon cho Production — giong `always` nhung khong restart neu da `docker stop` thu cong.

### Thuc hanh
- **Bai 1**: Chay Nginx tai port 8080 (`-d -p 8080:80`), xem log, truy cap browser.
- **Bai 2**: Dung `docker exec` sua file index cua Nginx, refresh browser thay thay doi.
- **Bai 3**: Chay `docker stats` quan sat tai nguyen. Thu `docker stop` vs `docker kill`.
- **Bai 4**: Don dep: stop, rm, chay lai Nginx o port 8081.

---

## DAY 3 - Dockerfile & Image Building [HOAN THANH 21/04]

### Muc tieu
- Tu viet Dockerfile cho project Java/C++
- Hieu su khac biet `CMD` vs `ENTRYPOINT`
- Dung `.dockerignore` de toi uu build va bao mat

### Kien thuc can nap
#### Cac Dockerfile instructions quan trong
- **FROM** — base image: Luon la dong dau tien. Chon image nho nhat phu hop: `openjdk:17-slim` thay vi `openjdk:17`.
- **WORKDIR** — thu muc lam viec: Tu tao neu chua ton tai.
- **COPY vs ADD**: Uu tien `COPY` (tuong minh). `ADD` tu giai nen tar + download URL (tranh dung).
- **CMD vs ENTRYPOINT**:
    - `CMD`: lenh mac dinh, co the override.
    - `ENTRYPOINT`: lenh chinh, khong override duoc (chi append args).
    - Ket hop: `ENTRYPOINT` lam executable, `CMD` lam default args.
- **ENV va ARG**: `ARG` chi dung luc build, `ENV` ton tai runtime. Secrets khong de trong `ENV` vi lo trong `docker inspect`.

### Thuc hanh
- **Bai 1**: Viet Dockerfile cho Java App don gian (Hello.java), build va chay.
- **Bai 2**: Thu nghiem CMD vs ENTRYPOINT — override khi `docker run`.
- **Bai 3**: Tao `.dockerignore` loai file `*.log` -> giam build context tu 10MB xuong 3KB.
- **Bai 4**: Kiem chung Layer Caching — sua 1 dong code, xem CACHED trong build output.
- **Bai 5**: Phan biet COPY vs ADD — `ADD` tu giai nen file tar, `COPY` giu nguyen.
- **Bai 6**: Bao mat Secrets — BuildKit `--mount=type=secret` va Multi-stage build.

---

## DAY 4 - Networking & Data Persistence (Volume) [HOAN THANH 22/04]

### Muc tieu
- Hieu 3 kieu network: `bridge`, `host`, `none`
- Ket noi 2 container qua ten (DNS tu dong)
- Phan biet Bind Mount vs Named Volume va biet khi nao dung loai nao

### Kien thuc can nap
#### Docker Networking
- **Bridge network (mac dinh)**: Container co IP rieng, KHONG ho tro DNS.
- **User-defined Bridge network (khuyen dung)**: Ho tro DNS — goi container bang `--name`.
- **Host network**: Container dung thang network cua host. Chi Linux.

#### Docker Storage
- **Bind Mount — danh cho dev**: `-v /home/user/code:/app`. Code thay doi ngay lap tuc.
- **Named Volume — danh cho data persistence**: `-v mysql-data:/var/lib/mysql`. Docker tu quan ly. Xoa container -> data van con.

### Thuc hanh
- **Bai 1**: Tao User-defined Network, chay Nginx va Ubuntu cung network, tu Ubuntu dung curl goi Nginx bang ten.
- **Bai 2**: Chay MySQL voi Named Volume, tao table, xoa container, chay lai -> data van con.
- **Bai 3**: Bind Mount file `index.html` vao Nginx — sua file host, refresh browser thay thay doi ngay.

---

## DAY 5 - Docker Compose (Multi-Service) [HOAN THANH 26/04]

### Muc tieu
- Hieu cau truc `docker-compose.yml`
- Dung stack: Nginx/Java Backend + MySQL + Redis
- Thanh thao: `up`, `down`, `logs`, `build`, `ps`, `exec`

### Kien thuc can nap
#### Tai sao dung Compose?
Thay vi 10 lenh `docker run` thu cong -> khai bao tat ca vao `docker-compose.yml`.
- Infrastructure as Code: Cau hinh luu vet, version control duoc.
- Tu dong tao Network rieng + DNS noi bo (service goi nhau bang ten).

#### Quan ly bien moi truong voi .env
- File `.env`: `KEY=VALUE` (tu dong duoc Compose doc).
- Trong `.yml`: `${KEY}` hoac `${KEY:-default_value}`.
- Kiem tra: `docker compose config`.

### Thuc hanh
- **Bai 1**: Dung stack Nginx + Redis + MySQL voi `docker-compose.yml`. Map port dung cho dich vu can thiet.
- **Bai 2**: Dung `docker compose config` kiem tra bien moi truong duoc nap dung.
- **Bai 3**: Thu dừng `db` va xem `web` co bi anh huong khong. Thu `--scale web=3`.
- **Bai 4**: Don dep voi `docker compose down -v`.

---

## DAY 6 - Debug & Optimization (Level Up) [HOAN THANH 27/04]

### Muc tieu
- Thanh thao Debug workflow chuyen nghiep (logs, inspect, exec, stats)
- Multi-stage build: Giam dung luong image cuc manh (800MB -> 100MB)
- Toi uu hoa Layer Caching de tang toc do build

### Kien thuc can nap
#### Debug Workflow (4 buoc)
1. **`docker logs`**: Tim Error Stacktrace (`-f`, `--tail`, `--since`).
2. **`docker inspect`**: Soi "noi tang" container (IP, Mount, Env, ExitCode).
3. **`docker exec -it`**: Dot nhap ben trong kiem tra file, mang, process.
4. **`docker stats`**: Kiem tra tai nguyen CPU/RAM realtime.

#### Multi-stage Build
Tach stage build (to, day du tools) va stage runtime (nho, chi JRE). Chi copy "san pham cuoi" tu stage build sang.
```dockerfile
FROM maven:3.8-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

#### Layer Caching — sap xep dung thu tu
- **SAI** — cache miss lien tuc: `COPY . .` -> `RUN mvn package`
- **DUNG** — tan dung cache: `COPY pom.xml` -> `RUN mvn dependency:go-offline` -> `COPY src` -> `RUN mvn package`
- **Nguyen tac**: It thay doi (dependencies) -> TREN. Hay thay doi (source code) -> DUOI.

#### Alpine vs glibc
Alpine dung **musl libc** thay vi **glibc** -> mot so thu vien bao loi "missing shared library". Fix bang `gcompat` hoac dung `-slim`.

### Thuc hanh
- **Bai 1**: Multi-stage Build thuc te — Java app, so sanh size voi ban build Day 3.
- **Bai 2**: Thu thach Layer Caching — sua code, build lai, xem buoc nao CACHED.
- **Bai 3**: Lab "kham chua benh" — hai container khac network khong ket noi duoc, chan doan va fix bang `docker network connect`.

---

## DAY 7 - CI/CD & Production Best Practices [BAI 1-2 HOAN THANH 09/05, CON BAI 3-5]

### Muc tieu
- Push image len Docker Hub va hieu quy trinh Registry workflow
- Tu dong hoa build & push bang GitHub Actions CI/CD
- Ap dung Production Best Practices: Non-root user, Security scanning, Resource limits, Restart policies

### Kien thuc can nap
#### Docker Hub & Registry Workflow
- **Lenh chinh**: `docker login`, `docker tag`, `docker push`, `docker pull`.
- **Convention dat ten**: `username/image-name:tag`.
- **Tag strategy**: `:v1.0.0` (semver, Prod), `:sha-abc1234` (commit SHA, CI/CD trace), tranh `:latest` trong Prod.
- **`docker tag` chi tao alias** (cung image ID, khong copy image).

#### Production Security
- **Non-root User** (bat buoc): Thu tu `COPY` -> `chown` -> `USER`. Sai thu tu = loi quyen.
- **Resource Limits**: `--memory 256m --cpus 0.5`. Exit code 137 = OOMKilled.
- **Restart Policy**: `--restart unless-stopped` uu tien hon `always`.
- **PID 1 Signal Handling**: Python/Node PID 1 ignore SIGTERM. Fix bang `tini`.

#### Trivy Security Scanning
- Scan CVE: `trivy image --severity CRITICAL,HIGH my-app`.
- **Fix CVE**: `apk upgrade --no-cache` fix 60-70% CVE (chi 1 dong RUN).
- **`.trivyignore`**: Tam an CVE chua co patch (KHONG PHAI fix thuc su).
- **Base image nho = It CVE**: `alpine` < `slim` < `full`.

#### GitHub Actions CI/CD
- Workflow: Checkout -> Login Docker Hub -> Build & Push -> Trivy Scan.
- **Secrets**: `DOCKER_USERNAME`, `DOCKER_TOKEN` luu trong GitHub Settings.
- **`exit-code: '1'`**: Trivy fail pipeline neu co CVE CRITICAL.

### Thuc hanh
- **Bai 1**: [x] Docker Hub — Tag, Push, Pull. Build image, push len Docker Hub, xoa local, pull lai va chay.
- **Bai 2**: [x] Non-root User + Resource Limits. Dockerfile voi `addgroup/adduser`, `chown`, `USER`. Chay voi `--memory --cpus --restart unless-stopped`. Test restart policy voi `tini`.
- **Bai 3**: [ ] Trivy Security Scanning — install, scan, severity filter, JSON export, .trivyignore.
- **Bai 3.5**: [ ] Fix CVE — Sua Dockerfile giam severity (apk upgrade, pin version, doi base image).
- **Bai 4**: [ ] GitHub Actions — Tu dong Build & Push (workflow file, Secrets, Trivy trong pipeline, commit SHA tagging).
- **Bai 5**: [ ] Tong hop — Production-ready Dockerfile (checklist 14 items).

---

## DAY 8 - CI/CD Advanced: Health Check & Deployment Strategies [CHUA THUC HANH]

### Muc tieu
- Xay dung pipeline CI/CD da moi truong (Dev -> Staging -> Production) voi GitHub Actions.
- Hieu va ap dung Health Check trong Docker va Docker Compose.
- Thuc hanh chien luoc Deploy: Rolling Update, Blue-Green, Canary.
- Tich hop auto-test vao pipeline de dam bao chi deploy code dung.

### Kien thuc can nap
#### Health Check trong Docker
- `HEALTHCHECK` trong Dockerfile: Kiem tra ung dung ben trong container co "khoe" khong.
- Trang thai: `starting` -> `healthy` -> `unhealthy`.
- Docker KHONG tu kill container khi unhealthy — can orchestrator (Swarm, K8s).
- **`curl -f` la bat buoc** trong HEALTHCHECK CMD — khong co `-f`, curl luon tra exit 0 bat ke HTTP 500.

#### Docker Compose healthcheck + depends_on
- `condition: service_healthy` — doi service pass healthcheck moi start.
- `condition: service_started` — chi doi container start, khong dam bao app san sang.
- `start_period` — thoi gian cho truoc khi bat dau check (tranh false-unhealthy).

#### Multi-environment Pipeline (GitHub Actions)
- `needs` — tao chuoi phu thuoc giua jobs (test -> build -> deploy). 1 job fail -> tat ca job phia sau bi skip.
- `environment` — gan job voi GitHub Environment, ho tro protection rules va secrets rieng.
- `environment: production` voi "Required reviewers" — can approval truoc deploy.
- `if: always()` — step luon chay ke ca khi buoc truoc fail (dung cho cleanup).
- `cache-from: type=gha` — cache Docker build layers tren GitHub Actions.

#### Chien luoc Deployment
| Chien luoc | Mo ta | Uu diem | Nhuoc diem |
|-----------|-------|---------|-----------|
| **Rolling Update** | Thay the container cu tung cai mot | Zero downtime | Rollback cham |
| **Blue-Green** | 2 version chay song song, switch traffic bang Nginx `nginx -s reload` | Zero downtime, rollback tuc thi | Can gap doi tai nguyen |
| **Canary** | Deploy cho % nho traffic, tang dan | An toan nhat | Phuc tap nhat |

#### Auto-test trong CI/CD
| Cap do | Khi nao | Thoi gian | Vi du |
|--------|---------|-----------|-------|
| Unit Test | Moi commit | Giay-Phut | `pytest`, `mvn test` |
| Integration Test | Sau build image | Phut | Chay container + test API |
| Smoke Test | Sau deploy staging | Giay | `curl /health`, HTTP 200 |

### Thuc hanh
- **Bai 1**: [ ] Dockerfile voi HEALTHCHECK, quan sat starting -> healthy -> unhealthy. Mo phong ung dung bi "benh".
- **Bai 2**: [ ] Docker Compose multi-service voi healthcheck + `depends_on` condition: `service_healthy` vs `service_started`. Mo phong DB die va khoi phuc.
- **Bai 3**: [ ] Multi-environment Pipeline — 6 jobs GitHub Actions (test->build->integration-test->deploy-dev->deploy-staging->deploy-prod voi manual approval).
- **Bai 4**: [ ] Blue-Green Deployment voi Nginx router + docker-compose. Switch traffic, rollback tuc thi.
- **Bai 5**: [ ] Tong hop auto-test script + Trivy + production-ready Dockerfile.

---

## Cau truc file tong hop

| File | Vai tro |
|------|---------|
| `Progress.md` | Nhat ky hoc tap + tong hop kien thuc 8 ngay (review nhanh) |
| `REFERENCE.md` | Cheatsheet lenh + 12 sai lam + debug kinh nghiem + production checklist |
| `Plan.md` | Lo trinh chi tiet (file nay) |

---

## Bonus - Buoc tiep theo

- **Kubernetes (K8s)**: Orchestrate nhieu containers o scale lon.
- **Portainer**: UI web de quan ly Docker.
- **Docker Swarm**: Orchestration built-in cua Docker.
- **Helm**: Package manager cho Kubernetes.
- **Docker BuildKit**: Tinh nang build nang cao.
- **Chainguard Images / Distroless**: Base image 0 CVE tu dau.
