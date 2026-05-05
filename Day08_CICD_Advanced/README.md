# Day 8: CI/CD Advanced — Multi-environment, Health Checks & Deployment Strategies

## Muc tieu bai hoc
- Xay dung pipeline CI/CD da moi truong (Dev -> Staging -> Production) voi GitHub Actions.
- Hieu va ap dung Health Check trong Docker va Docker Compose.
- Thuc hanh cac chien luoc Deploy: Rolling Update, Blue-Green, Canary.
- Tich hop auto-test vao pipeline de dam bao chi deploy code dung.
- Ap dung Docker Compose cho moi truong Production (logging, monitoring, health check).

---

## Tom tat ly thuyet quan trong

### 1. CI/CD Pipeline da moi truong (Multi-environment Pipeline)

Trong thuc te, mot project luon co nhieu moi truong:

| Moi truong | Muc dich | Dac diem |
|---|---|---|
| **Dev** | Phat trien, test nhanh | Auto deploy moi commit, dung `:dev` tag |
| **Staging** | Test tich hop, UAT | Auto deploy tu branch main, dung `:staging` tag, giong Production nhat co the |
| **Production** | Phuc vu nguoi dung cuoi | Deploy thu cong (approval), dung `:v1.2.3` tag, can rollback |

**Luong di cua pipeline:**
```
Code Push → Lint + Unit Test → Build Image → Push to Registry → Deploy Dev
     ↓ (main branch only)
  Integration Test → Deploy Staging → Smoke Test → [Manual Approval] → Deploy Production
```

**GitHub Actions — Environment & Protection Rules:**
- **Environments**: Tao 3 environments (dev, staging, prod) trong GitHub repo Settings.
- **Protection Rules**: Yeu cau `approval` truoc khi deploy Production — 1 nguoi review va click "Approve" truoc khi job chay.
- **Environment Secrets**: Moi environment co the co secrets khac nhau (vd: `PROD_DB_PASSWORD` chi ton tai trong environment `production`).

### 2. Health Check — Kiem tra suc khoe container

Health Check la co che Docker tu dong kiem tra xem ung dung ben trong container co "khoẻ" khong.

#### a. Dockerfile HEALTHCHECK
```dockerfile
# Kiem tra moi 30 giay, timeout 5 giay, start period 10 giay, cho 3 lan thu
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1
```

**Cac trang thai Health Check:**
- `starting` — Container vua khoi dong, dang cho `start-period`.
- `healthy` — Ung dung phan hoi thanh cong.
- `unhealthy` — Sai lien tuc `retries` lan. Docker se danh dau `unhealthy` nhung KHONG tu kill container.

**Lenh kiem tra:**
```bash
docker inspect --format '{{.State.Health.Status}}' <container>
docker inspect --format '{{json .State.Health.Log}}' <container> | python3 -m json.tool
```

#### b. Docker Compose healthcheck
```yaml
services:
  app:
    build: .
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
  db:
    image: mysql:8.0
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**depends_on voi condition (QUAN TRONG):**
```yaml
  app:
    depends_on:
      db:
        condition: service_healthy   # Cho db "healthy" moi start app
      cache:
        condition: service_started   # Chi cho cache start, khong can healthy
```

### 3. Chien luoc Deployment

#### a. Rolling Update (Mac dinh cua Docker Swarm / K8s)
- Thay the cac container cu bang container moi TUNG CAI MOT.
- Luon co it nhat 1 instance dang chay → zero downtime.
- Mo phong bang Docker Compose:
  ```bash
  # Tang so luong replica
  docker compose up -d --scale app=3
  # Build version moi va deploy (cac container cu se bi thay the tung cai)
  docker compose up -d --build --scale app=3
  ```

#### b. Blue-Green Deployment
- **Blue** = version hien tai dang phuc vu (production).
- **Green** = version moi, da duoc deploy nhung KHONG nhan traffic.
- Khi Green pass tat ca test → chuyen traffic tu Blue sang Green (dao Nginx config hoac doi port).
- Neu Green loi → chuyen lai ve Blue (rollback ngay lap tuc).

```
         ┌─────────────┐
Users ──→│   Nginx     │──→ Blue (v1.0) ← Dang phuc vu
         │  (router)   │──→ Green (v2.0) ← Cho test, chua nhan traffic
         └─────────────┘
                  ↓ (sau khi test xong)
Users ──→ Nginx ──→ Green (v2.0) ← Phuc vu
         Nginx ──→ Blue (v1.0) ← Idle, giu lai de rollback
```

#### c. Canary Deployment
- Deploy version moi cho MOT PHAN nho nguoi dung (vd: 5% traffic).
- Monitor metrics (error rate, latency). Neu on → tang dan len 100%.
- Neu co loi → rollback chi anh huong 5% nguoi dung, khong phai tat ca.

### 4. Auto-test trong CI/CD Pipeline

**3 cap do test quan trong:**
| Cap do | Khi nao chay | Thoi gian | Vi du |
|---|---|---|---|
| **Unit Test** | Moi commit, moi PR | Giay - Phut | `mvn test`, `pytest` |
| **Integration Test** | Sau khi build image | Phut | Chay container + test API endpoint |
| **Smoke Test** | Sau khi deploy staging | Giay | `curl /health`, kiem tra HTTP 200 |

**Integration Test trong GitHub Actions (chay container roi test):**
```yaml
- name: Build and run container for integration test
  run: |
    docker build -t test-app .
    docker run -d --name test-container -p 8080:8080 test-app
    sleep 5  # Cho app khoi dong

- name: Run integration tests
  run: |
    # Smoke test
    curl -f http://localhost:8080/ || exit 1
    # API test
    curl -f http://localhost:8080/api/health || exit 1

- name: Cleanup
  if: always()
  run: |
    docker stop test-container
    docker rm test-container
```

---

## Thu hanh & Bai tap

### Bai 1: Health Check — Kiem tra suc khoe ung dung

**Muc tieu**: Hieu cu phap HEALTHCHECK, quan sat trang thai healthy/unhealthy, va tich hop voi Docker Compose `depends_on`.

**Buoc 1: Tao Dockerfile voi HEALTHCHECK**
Tao thu muc `Bai_1/` voi cac file:

**`Bai_1/app.py`** — Python app co endpoint `/health`:
```python
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os, time

START_TIME = time.time()

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            uptime = time.time() - START_TIME
            if uptime > 5:  # App "khoẻ" sau 5 giay start-up
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(f'{{"status": "healthy", "uptime": {uptime:.0f}}}'.encode())
            else:
                self.send_response(503)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(b'{"status": "starting"}')
        else:
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            version = os.getenv("APP_VERSION", "v1.0.0")
            self.wfile.write(f"<h1>App {version}</h1>".encode())

print("Server starting on port 8080...")
HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

**`Bai_1/Dockerfile`**:
```dockerfile
FROM python:3.11-alpine

WORKDIR /app

# Cai curl cho healthcheck (Alpine khong co san curl)
RUN apk add --no-cache curl

COPY app.py .

# HEALTHCHECK: Kiem tra moi 10s, timeout 3s, cho 5s start, 3 lan retry
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENV APP_VERSION=v1.0.0
EXPOSE 8080

CMD ["python", "app.py"]
```

**Buoc 2: Build, chay va quan sat Health Check**
```bash
# Build
sudo docker build -t health-app:v1 Bai_1/

# Chay container
sudo docker run -d --name health-check-demo -p 8080:8080 health-app:v1

# NGAY SAU KHI CHAY: Kiem tra trang thai (se la "starting")
sudo docker inspect --format '{{.State.Health.Status}}' health-check-demo
# Ket qua: starting (hoac chua co)

# Doi 15 giay roi kiem tra lai
sleep 15
sudo docker inspect --format '{{.State.Health.Status}}' health-check-demo
# Ket qua: healthy

# Xem chi tiet log cua health check
sudo docker inspect --format '{{json .State.Health.Log}}' health-check-demo | python3 -m json.tool

# Test endpoint /health
curl http://localhost:8080/health
# Ket qua: {"status": "healthy", "uptime": XX}

# Test endpoint /
curl http://localhost:8080/
# Ket qua: <h1>App v1.0.0</h1>
```

**Buoc 3: Mo phong ung dung bi "benh" (unhealthy)**
```bash
# Vao container va dung app (nhung giu container chay)
sudo docker exec health-check-demo sh -c "kill $(pgrep -f 'python app.py')"

# Doi 30 giay de health check chay va fail
sleep 30

# Kiem tra trang thai
sudo docker inspect --format '{{.State.Health.Status}}' health-check-demo
# Ket qua: unhealthy (sau 3 lan fail lien tiep)

# Xem log chi tiet — se thay "exit code 1" cua curl
sudo docker inspect --format '{{json .State.Health.Log}}' health-check-demo | python3 -m json.tool

# Don dep
sudo docker rm -f health-check-demo
```

**Diem quan trong can hieu**:
- **`start-period`** la "thoi gian cho" — Docker KHONG tinh fail trong khoang thoi gian nay vi app con dang khoi dong.
- **Docker KHONG tu kill container khi `unhealthy`** — no chi danh dau. Ban can cong cu ben ngoai (nhu Docker Swarm, Kubernetes) de tu dong replace.
- **`curl -f`** la bat buoc: flag `-f` (fail silently) lam curl tra exit code 1 khi HTTP status >= 400. Neu khong co `-f`, curl luon tra 0 (success) bat ke server tra HTTP 500.

---

### Bai 2: Docker Compose voi Health Check va depends_on

**Muc tieu**: Xay dung stack da dich vu voi health check va thu tu khoi dong dung.

**Buoc 1: Tao docker-compose.yml**
Tao thu muc `Bai_2/` voi cac file:

**`Bai_2/app.py`** — App kiem tra MySQL connection:
```python
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os, subprocess, time

START_TIME = time.time()

def check_db():
    """Kiem tra MySQL co san sang khong bang mysqladmin ping"""
    try:
        result = subprocess.run(
            ["mysqladmin", "ping", "-h", "db", "-u", "root", "-proot"],
            capture_output=True, timeout=3
        )
        return result.returncode == 0
    except:
        return False

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            uptime = time.time() - START_TIME
            db_ok = check_db()
            if uptime > 10 and db_ok:
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(f'{{"status": "healthy", "db": "connected", "uptime": {uptime:.0f}}}'.encode())
            else:
                self.send_response(503)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(f'{{"status": "starting", "db": {"connected" if db_ok else "disconnected"}, "uptime": {uptime:.0f}}}'.encode())
        elif self.path == '/':
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(b"<h1>App is running</h1>")
        else:
            self.send_response(404)
            self.end_headers()

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

**`Bai_2/Dockerfile`**:
```dockerfile
FROM python:3.11-alpine

WORKDIR /app

# Cai curl (healthcheck) va mysql-client (check_db)
RUN apk add --no-cache curl mysql-client

COPY app.py .

HEALTHCHECK --interval=10s --timeout=3s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

CMD ["python", "app.py"]
```

**`Bai_2/docker-compose.yml`**:
```yaml
version: "3.8"

services:
  # MySQL Database
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: appdb
    volumes:
      - mysql-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - backend

  # Redis Cache
  cache:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    networks:
      - backend

  # Application
  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      db:
        condition: service_healthy    # CHO db healthy moi start
      cache:
        condition: service_started    # Chi cho cache bat dau
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 15s
    networks:
      - backend

volumes:
  mysql-data:

networks:
  backend:
    driver: bridge
```

**Buoc 2: Chay va quan sat thu tu khoi dong**
```bash
cd Bai_2

# Chay stack
sudo docker compose up -d --build

# Quan sat trang thai cac services
sudo docker compose ps
# Quan sat: app se co trang thai "health: starting" cho den khi db "healthy"

# Xem chi tiet health status
sudo docker compose ps --format "table {{.Name}}\t{{.Status}}"

# Doi 30 giay roi kiem tra lai — tat ca phai "healthy"
sleep 30
sudo docker compose ps

# Test endpoint
curl http://localhost:8080/health
# Ket qua: {"status": "healthy", "db": "connected", "uptime": XX}

curl http://localhost:8080/
# Ket qua: <h1>App is running</h1>
```

**Buoc 3: Thu nghiem — Mo phong DB die**
```bash
# Dung MySQL
sudo docker compose stop db

# Doi va kiem tra app health
sleep 15
curl http://localhost:8080/health
# Ket qua: {"status": "starting", "db": "disconnected", ...}

# Kiem tra Docker health status cua app
sudo docker compose ps
# app se chuyen sang "unhealthy" vi khong ket noi duoc db

# Khoi dong lai db
sudo docker compose start db

# Doi va kiem tra — app phai tro lai "healthy"
sleep 20
curl http://localhost:8080/health
# Ket qua: {"status": "healthy", "db": "connected", ...}

# Don dep
sudo docker compose down -v
```

**Diem quan trong can hieu**:
- **`condition: service_healthy`** la dieu kien manh nhat — dam bao app CHI bat dau khi DB thuc su san sang (khong chi container chay, ma con phai pass healthcheck).
- **`condition: service_started`** yeu hon — chi cho container bat dau, khong dam bao ung dung ben trong da san sang.
- **Thu tu khoi dong**: db (30s start_period) → db "healthy" → app start → app healthcheck → app "healthy".

---

### Bai 3: Multi-environment Pipeline voi GitHub Actions

**Muc tieu**: Xay dung pipeline CI/CD voi 3 environments (Dev, Staging, Prod) bao gom auto-test va manual approval.

**Buoc 1: Tao cau truc workflow**
Tao file `.github/workflows/cicd-pipeline.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ secrets.DOCKER_USERNAME }}/my-python-app

jobs:
  # ============================================
  # JOB 1: LINT + UNIT TEST (Chay moi commit)
  # ============================================
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install flake8 pytest
          # Neu co requirements.txt: pip install -r requirements.txt

      - name: Lint with flake8
        run: |
          # Kiem tra syntax error va warnings
          flake8 Day08_CICD_Advanced/Bai_1/app.py --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 Day08_CICD_Advanced/Bai_1/app.py --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

      - name: Run unit tests
        run: |
          echo "Running unit tests..."
          # Neu co test folder: pytest tests/
          # Vi du don gian: kiem tra app.py co the import
          python3 -c "import ast; ast.parse(open('Day08_CICD_Advanced/Bai_1/app.py').read())"
          echo "Unit tests passed!"

  # ============================================
  # JOB 2: BUILD + PUSH IMAGE (Sau khi test pass)
  # ============================================
  build:
    runs-on: ubuntu-latest
    needs: test                  # Chi chay SAU KHI test pass
    outputs:
      image_tag: ${{ steps.meta.outputs.tags }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Extract metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            # Branch name tag (vd: main, develop)
            type=ref,event=branch
            # Git commit SHA short
            type=sha,prefix=sha-
            # Semantic version tu git tag (vd: v1.2.3)
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./Day08_CICD_Advanced/Bai_1
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ============================================
  # JOB 3: INTEGRATION TEST (Chay container roi test)
  # ============================================
  integration-test:
    runs-on: ubuntu-latest
    needs: build                 # Chi chay SAU KHI build xong
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Pull and run container
        run: |
          docker pull ${{ secrets.DOCKER_USERNAME }}/my-python-app:sha-${{ github.sha }}
          docker run -d --name test-app -p 8080:8080 \
            ${{ secrets.DOCKER_USERNAME }}/my-python-app:sha-${{ github.sha }}
          sleep 10  # Cho app khoi dong

      - name: Run integration tests
        run: |
          # Smoke test: App co phan hoi khong?
          curl -f http://localhost:8080/ || exit 1
          echo "Smoke test PASSED"

          # Health check test
          HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
          if [ "$HTTP_CODE" -eq 200 ]; then
            echo "Health check PASSED (HTTP 200)"
          else
            echo "Health check FAILED (HTTP $HTTP_CODE)"
            exit 1
          fi

      - name: Cleanup
        if: always()            # Luon chay, ke ca khi buoc truoc fail
        run: |
          docker stop test-app 2>/dev/null || true
          docker rm test-app 2>/dev/null || true

  # ============================================
  # JOB 4: DEPLOY TO DEV (Tu dong, moi commit)
  # ============================================
  deploy-dev:
    runs-on: ubuntu-latest
    needs: integration-test
    environment: dev             # GitHub Environment "dev"
    if: github.ref == 'refs/heads/develop'
    steps:
      - name: Deploy to Dev
        run: |
          echo "=== Deploying to DEV ==="
          echo "Image: ${{ secrets.DOCKER_USERNAME }}/my-python-app:sha-${{ github.sha }}"
          echo "In real project: docker pull + docker run on dev server"
          echo "Dev deploy completed!"

  # ============================================
  # JOB 5: DEPLOY TO STAGING (Tu dong, main branch)
  # ============================================
  deploy-staging:
    runs-on: ubuntu-latest
    needs: integration-test
    environment: staging         # GitHub Environment "staging"
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to Staging
        run: |
          echo "=== Deploying to STAGING ==="
          echo "Image: ${{ secrets.DOCKER_USERNAME }}/my-python-app:sha-${{ github.sha }}"
          echo "In real project: docker pull + docker run on staging server"
          echo "Staging deploy completed!"

      - name: Run smoke tests on staging
        run: |
          echo "Running smoke tests on staging environment..."
          echo "In real project: curl staging URL, check DB connection, etc."

  # ============================================
  # JOB 6: DEPLOY TO PRODUCTION (CAN APPROVAL)
  # ============================================
  deploy-prod:
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment:                 # Production environment voi protection rule
      name: production
    # Protection rule: Can 1 nguoi approve trong GitHub Settings > Environments > production
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to Production
        run: |
          echo "=== Deploying to PRODUCTION ==="
          echo "Image: ${{ secrets.DOCKER_USERNAME }}/my-python-app:sha-${{ github.sha }}"
          echo "In real project: docker pull + docker run on prod server"
          echo "Production deploy completed!"

      - name: Verify production
        run: |
          echo "Verifying production deployment..."
          echo "In real project: curl production URL, check health endpoint"
```

**Buoc 2: Hieu cac khai niem moi trong workflow**

| Khai niem | Y nghia |
|---|---|
| `needs: test` | Job `build` CHI chay khi job `test` PASS — tao chuoi phu thuoc |
| `if: github.ref == 'refs/heads/main'` | Chi chay job khi push len branch cu the |
| `environment: dev` | Gan job voi GitHub Environment — ho tro protection rules va secrets rieng |
| `environment: name: production` | Environment "production" — nen cau hinh "Required reviewers" trong GitHub Settings |
| `if: always()` | Step luon chay ke ca khi buoc truoc fail — dung cho cleanup |
| `cache-from: type=gha` | Su dung GitHub Actions cache cho Docker build layers — tang toc do build |
| `docker/metadata-action@v5` | Tu dong tao tags thong minh (branch, SHA, semver) thay vi hardcode |

**Buoc 3: Hieu luong pipeline**

```
Push to ANY branch:
  test → [PASS] → build → integration-test

Push to develop:
  test → build → integration-test → deploy-dev

Push to main:
  test → build → integration-test → deploy-staging → [MANUAL APPROVAL] → deploy-prod
```

**Buoc 4: Kiem tra cu phap YAML (local)**
```bash
# Tu thu muc goc project
cd /home/quanswl24/Working/DOCKER_STUDY

# Kiem tra cu phap
cat .github/workflows/cicd-pipeline.yml | python3 -c "import yaml,sys; yaml.safe_load(sys.stdin); print('YAML syntax OK')"
```

**Diem quan trong can hieu**:
- **`needs`** tao "chuoi phu thuoc" — neu 1 job fail, tat ca job phia sau bi skip. Khong bao gio deploy code loi.
- **`environment: production`** voi "Required reviewers" la co gat an toan nhat — khong ai co the deploy len Production ma khong co su dong y cua team lead.
- **`cache-from: type=gha`** su dung GitHub Actions cache de luu Docker build layers — build lan 2 chi mat vai giay thay vi vai phut.
- **`if: always()`** cho cleanup la bat buoc — neu khong co, container test se bi bo lai chay mai tren runner khi pipeline fail.

---

### Bai 4: Blue-Green Deployment voi Docker Compose

**Muc tieu**: Thuc hanh chien luoc Blue-Green Deployment — deploy version moi ma KHONG co downtime, co the rollback ngay lap tuc.

**Buoc 1: Tao cau truc Blue-Green**
Tao thu muc `Bai_4/` voi cac file:

**`Bai_4/app.py`** — App hien thi version (de phan biet Blue vs Green):
```python
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        version = os.getenv("APP_VERSION", "v1.0.0")
        color = os.getenv("DEPLOY_COLOR", "blue")
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(f"""
        <html><body style='background: {"#0074D9" if color == "blue" else "#2ECC40"}; color: white; font-family: Arial;'>
        <h1>App Version: {version}</h1>
        <h2>Deploy Color: {color.upper()}</h2>
        <p>This is the {color.upper()} environment</p>
        </body></html>
        """.encode())

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

**`Bai_4/Dockerfile`**:
```dockerfile
FROM python:3.11-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY app.py .
HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1
EXPOSE 8080
CMD ["python", "app.py"]
```

**`Bai_4/docker-compose.yml`** — Blue-Green setup voi Nginx router:
```yaml
version: "3.8"

services:
  # Nginx lam router — dieu huong traffic den Blue hoac Green
  router:
    image: nginx:alpine
    ports:
      - "9090:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      app-blue:
        condition: service_healthy
    networks:
      - app-net

  # BLUE = Version hien tai (Production)
  app-blue:
    build: .
    environment:
      - APP_VERSION=v1.0.0
      - DEPLOY_COLOR=blue
    ports:
      - "8081:8080"
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 5s
      timeout: 3s
      retries: 3

  # GREEN = Version moi (Staging, chua nhan traffic)
  app-green:
    build: .
    environment:
      - APP_VERSION=v2.0.0
      - DEPLOY_COLOR=green
    ports:
      - "8082:8080"
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 5s
      timeout: 3s
      retries: 3

networks:
  app-net:
    driver: bridge
```

**`Bai_4/nginx.conf`** — Nginx dieu huong (MAC DINH: traffic di vao Blue):
```nginx
upstream app_backend {
    # THAY DOI DAY DE CHUYEN TRAFFIC
    # Blue (production hien tai):
    server app-blue:8080;
    # Green (version moi, chua nhan traffic):
    # server app-green:8080;
}

server {
    listen 80;

    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Status page — hien thi config hien tai
    location /status {
        return 200 'Traffic is going to BLUE (v1.0.0)\n';
        add_header Content-Type text/plain;
    }
}
```

**Buoc 2: Deploy Blue (version hien tai)**
```bash
cd Bai_4

# Chay toan bo stack
sudo docker compose up -d --build

# Test qua Nginx router (port 9090) → di vao Blue
curl http://localhost:9090/status
# Ket qua: Traffic is going to BLUE (v1.0.0)

curl -s http://localhost:9090/ | grep "Version"
# Ket qua: App Version: v1.0.0

# Test truc tiep Blue va Green
curl -s http://localhost:8081/ | grep "Version"
# Ket qua: App Version: v1.0.0 (BLUE)

curl -s http://localhost:8082/ | grep "Version"
# Ket qua: App Version: v2.0.0 (GREEN) — nhung chua nhan traffic tu Nginx
```

**Buoc 3: Switch traffic sang Green (Deploy version moi)**
Sua file `nginx.conf` — doi `app-blue` thanh `app-green`:
```nginx
upstream app_backend {
    # Blue (da cu, giu lai de rollback):
    # server app-blue:8080;
    # Green (version moi, nhan traffic):
    server app-green:8080;
}
```

```bash
# Reload Nginx config (KHONG can restart, KHONG downtime)
sudo docker compose exec router nginx -s reload

# Test lai qua router → da chuyen sang Green
curl http://localhost:9090/status
# Ket qua: Traffic is going to BLUE... (can update status page too)

curl -s http://localhost:9090/ | grep "Version"
# Ket qua: App Version: v2.0.0 (GREEN) — Traffic da chuyen!
```

**Buoc 4: Rollback (Neu Green co loi)**
```bash
# Sua lai nginx.conf: uncomment app-blue, comment app-green
# Reload Nginx
sudo docker compose exec router nginx -s reload

# Test → da quay lai Blue
curl -s http://localhost:9090/ | grep "Version"
# Ket qua: App Version: v1.0.0 (BLUE) — Rollback thanh cong!
```

**Don dep:**
```bash
sudo docker compose down
```

**Diem quan trong can hieu**:
- **`nginx -s reload`** la "mau chot" — Nginx reload config MAI KHONG ngat ket noi hien tai. Zero downtime.
- **Luon giu Blue chay** cho den khi ban chac chan Green on dinh. Chi tat Blue khi da confirm Green hoat dong tot.
- **Thu tu chuan**: Deploy Green → Test Green truc tiep (port 8082) → Switch Nginx → Monitor → Tat Blue hoac Rollback.

---

### Bai 5: Auto-test va Trivy trong Pipeline — Tong hop

**Muc tieu**: Ket hop tat ca kien thuc Day 7 + Day 8 de tao mot Dockerfile va workflow chuan Production voi auto-test, security scan va multi-environment deploy.

**Buoc 1: Tao production-ready app voi tests**
Tao thu muc `Bai_5/` voi cac file:

**`Bai_5/app.py`** — App co day du endpoint cho testing:
```python
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os, time, json

START_TIME = time.time()

def get_health():
    uptime = time.time() - START_TIME
    status = "healthy" if uptime > 5 else "starting"
    return {"status": status, "version": os.getenv("APP_VERSION", "v1.0.0"), "uptime": int(uptime)}

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        routes = {
            "/": self.handle_root,
            "/health": self.handle_health,
            "/api/info": self.handle_info,
        }
        handler = routes.get(self.path)
        if handler:
            handler()
        else:
            self.send_response(404)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"error": "not found"}')

    def handle_root(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        version = os.getenv("APP_VERSION", "v1.0.0")
        self.wfile.write(f"<h1>App {version}</h1>".encode())

    def handle_health(self):
        health = get_health()
        code = 200 if health["status"] == "healthy" else 503
        self.send_response(code)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(health).encode())

    def handle_info(self):
        info = {
            "app": "my-python-app",
            "version": os.getenv("APP_VERSION", "v1.0.0"),
            "user": os.getenv("USER", "unknown"),
        }
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(info).encode())

if __name__ == "__main__":
    print(f"Server starting on port 8080...")
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

**`Bai_5/Dockerfile`** — Production-ready (ket hop tat ca best practices):
```dockerfile
FROM python:3.11-alpine

WORKDIR /app

# Security: Non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy and set permissions
COPY app.py .
RUN chown -R appuser:appgroup /app

USER appuser

# Healthcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENV APP_VERSION=v1.0.0
EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["app.py"]
```

**`Bai_5/test.sh`** — Script auto-test chay trong CI/CD:
```bash
#!/bin/bash
# Auto-test script — chay sau khi container da start
set -e  # Fail ngay khi mot lenh loi

echo "=== Running Auto Tests ==="

# Test 1: Root endpoint
echo -n "Test 1: GET / ... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "PASS (HTTP 200)"
else
    echo "FAIL (HTTP $HTTP_CODE)"
    exit 1
fi

# Test 2: Health endpoint
echo -n "Test 2: GET /health ... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "PASS (HTTP 200)"
else
    echo "FAIL (HTTP $HTTP_CODE)"
    exit 1
fi

# Test 3: Health response format
echo -n "Test 3: /health JSON format ... "
BODY=$(curl -s http://localhost:8080/health)
STATUS=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['status'])" 2>/dev/null)
if [ "$STATUS" = "healthy" ]; then
    echo "PASS (status=healthy)"
else
    echo "FAIL (status=$STATUS)"
    exit 1
fi

# Test 4: API info endpoint
echo -n "Test 4: GET /api/info ... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/info)
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "PASS (HTTP 200)"
else
    echo "FAIL (HTTP $HTTP_CODE)"
    exit 1
fi

# Test 5: 404 for unknown route
echo -n "Test 5: GET /unknown (expect 404) ... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/unknown)
if [ "$HTTP_CODE" -eq 404 ]; then
    echo "PASS (HTTP 404)"
else
    echo "FAIL (HTTP $HTTP_CODE, expected 404)"
    exit 1
fi

echo "=== All Auto Tests PASSED ==="
```

**Buoc 2: Chay auto-test local**
```bash
cd Bai_5

# Build va chay
sudo docker build -t test-app:latest .
sudo docker run -d --name test-container -p 8080:8080 -e APP_VERSION=v1.0.0 test-app:latest

# Doi app khoi dong va tro thanh "healthy"
echo "Dang cho app khoi dong..."
for i in $(seq 1 10); do
    STATUS=$(sudo docker inspect --format '{{.State.Health.Status}}' test-container 2>/dev/null)
    echo "  [$i/10] Health status: $STATUS"
    if [ "$STATUS" = "healthy" ]; then
        break
    fi
    sleep 3
done

# Chay auto-test
chmod +x test.sh
./test.sh

# Kiem tra ket qua
# Mong doi: === All Auto Tests PASSED ===

# Don dep
sudo docker stop test-container && sudo docker rm test-container
```

**Buoc 3: Chay Trivy scan**
```bash
# Scan image vua build
trivy image --severity CRITICAL,HIGH test-app:latest

# Neu co CVE CRITICAL → can fix truoc khi deploy
# Neu khong co → OK de push len Registry
```

**Diem quan trong can hieu**:
- **`set -e`** trong test.sh la bat buoc — neu bat ky test nao fail, script exit voi code != 0, dieu nay lam GitHub Actions job FAIL.
- **Test thu tu**: Test endpoint don gian (/, /health) truoc, test phuc tap (/api/info, 404) sau. Neu test don gian da fail thi khong can test phuc tap.
- **Health check + Auto-test** la 2 lop bao ve: Health check dam bao container "khoẻ" (Docker tu kiem tra), Auto-test dam bao business logic dung (CI/CD kiem tra).
- **Trong Production**: Test.sh se duoc goi boi GitHub Actions integration-test job (nhu Bai 3) — neu fail, pipeline dung lai, khong deploy.

---

## Cau hoi suy ngam

1. **Su khac biet giua `condition: service_healthy` va `condition: service_started` trong Docker Compose `depends_on`? Khi nao nen dung loai nao?**
   > Tra loi:

2. **Tai sao Blue-Green Deployment lai an toan hon Rolling Update khi deploy len Production? Cho vi du khi Green version co loi nghiem trong.**
   > Tra loi:

3. **Neu Health Check cua container tra ve "unhealthy", Docker co tu dong kill va restart container khong? Neu khong, ai se lam viec do trong mo truong Production?**
   > Tra loi:

4. **Tai sao `if: always()` la bat buoc cho step "Cleanup" trong GitHub Actions? Dieu gi xay ra neu khong co?**
   > Tra loi:

5. **Trong pipeline CI/CD, tai sao can chay Unit Test truoc Build Image, nhung Integration Test lai chay SAU Build Image?**
   > Tra loi:

---

## Trang thai hoan thanh (Status)
- [ ] Bai 1: Health Check — Kiem tra suc khoe ung dung
- [ ] Bai 2: Docker Compose voi Health Check va depends_on
- [ ] Bai 3: Multi-environment Pipeline voi GitHub Actions
- [ ] Bai 4: Blue-Green Deployment voi Docker Compose
- [ ] Bai 5: Auto-test va Trivy trong Pipeline — Tong hop
- [ ] Tra loi cac cau hoi suy ngam
