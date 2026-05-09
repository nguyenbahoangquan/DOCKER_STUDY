# Day 7: CI/CD & Production Best Practices

## Mục tiêu bài học
- Push image len Docker Hub va hieu quy trinh Registry workflow.
- Tu dong hoa build & push bang GitHub Actions CI/CD.
- Ap dung Production Best Practices: Non-root user, Security scanning, Resource limits, Restart policies.

---

## Tom tat ly thuyet quan trong

### 1. Docker Hub & Registry Workflow
Registry la noi luu tru tap trung cac Docker Images (nhu GitHub cho source code).
- **Lenh chinh**: `docker login`, `docker tag`, `docker push`, `docker pull`.
- **Convention dat ten**: `username/image-name:tag` (vi du: `quanswl24/my-java-app:v1.0.0`).
- **Tag strategy**:
  - `:latest` — tag mac dinh, chi dan cho "ban moi nhat" (khuyen khong dung trong Production).
  - `:v1.0.0` — version cu the, dam bao immutability (quy uoc Semantic Versioning).
  - `:sha-abc1234` — tag theo git commit short SHA, trace duoc chinh xac code.

### 2. CI/CD voi GitHub Actions
Khi ban push code len GitHub, GitHub Actions se tu dong:
1. **Checkout** code tu repository.
2. **Build** Docker Image tu Dockerfile.
3. **Login** Docker Hub (dung Secrets de bao mat token).
4. **Push** Image len Docker Hub voi tag tu dong (commit SHA hoac version).

**Cau truc quan trong cua file workflow**:
- `on:` — trigger event (push, pull_request).
- `jobs:` — nhom cac buoc lam viec.
- `steps:` — tung buoc thuc thi (checkout, login, build, push).
- `${{ secrets.XXX }}` — tham chieu bien mat tu GitHub Secrets.

### 3. Production Best Practices

#### a. Security — Non-root User
Mac dinh container chay voi `root`. Neu attacker exploit app ben trong, se co quyen root tren container.
- **Fix**: Tao user khong co quyen root va chuyen sang user do truoc khi `CMD`.
- **Lenh (Alpine)**: `addgroup -S appgroup && adduser -S appuser -G appgroup`
- **Lenh (Debian/Ubuntu)**: `groupadd -r appgroup && useradd -r -g appgroup appuser`
- **Kiem tra**: `docker exec <container> whoami` phai tra ve `appuser`, khong phai `root`.

#### b. Security Scanning — Trivy
Trivy la cong cu scan CVE (Common Vulnerabilities and Exposures) trong Docker Image.
- **Cai dat**: `sudo apt-get install trivy` hoac download binary tu GitHub releases.
- **Scan**: `trivy image my-java-app:latest`
- **Ket qua**: Hien thi danh sach CVE theo muc do CRITICAL / HIGH / MEDIUM / LOW.
- **Muc tieu**: Khong co CVE nao o muc CRITICAL hoac HIGH truoc khi push len Production. 

#### c. Resource Limits
Gioi han tai nguyen de container khong "an" het RAM/CPU cua host, gay anh huong cac service khac.
- `--memory 512m` — gioi han RAM toi da 512MB.
- `--cpus 0.5` — gioi han CPU toi da 0.5 core.
- `--memory-swap 1g` — gioi han swap (RAM + swap = 1g).
- **Kiem tra**: `docker stats <container>` de xem muc su dung thuc te.

#### d. Restart Policies
Dam bao container tu khoi dong lai khi bi crash hoac server restart.
- `--restart no` — mac dinh, khong tu restart.
- `--restart on-failure[:max-retry]` — restart chi khi container exit voi code != 0.
- `--restart always` — luon restart, bat ke exit code, bao gom sau khi Docker daemon restart.
- `--restart unless-stopped` — giong `always`, nhung khong restart neu ban da `docker stop` thu cong.

---

## Thu hanh & Bai tap

### Bai 1: Docker Hub — Tag, Push va Pull

**Muc tieu**: Hieu toan bo vong doi cua Image tu local len Docker Hub va keo ve may khac.

**Buoc 1: Dang nhap Docker Hub**
```bash
# Kiem tra da dang nhap chua
docker login
# Nhap username va password (hoac Access Token)
# Neu thanh cong: "Login Succeeded"
```
> **Luu y**: Nen dung Access Token thay vi password (tao tai https://hub.docker.com > Account Settings > Security).

**Buoc 2: Tao mot app don gian de build image**
Tao thu muc `Bai_1/` voi cac file sau:

**`Bai_1/app.py`** — Python app don gian:
```python
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        version = os.getenv("APP_VERSION", "v1.0.0")
        self.wfile.write(f"<h1>Hello from Docker! Version: {version}</h1>".encode())

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

**`Bai_1/Dockerfile`**:
```dockerfile
FROM python:3.11-alpine
WORKDIR /app
COPY app.py .
ENV APP_VERSION=v1.0.0
EXPOSE 8080
CMD ["python", "app.py"]
```

**Buoc 3: Build va tag image**
```bash
# Build image voi tag local
sudo docker build -t my-python-app:v1.0.0 Bai_1/

# Tag image theo convention Docker Hub: <username>/<image>:<tag>
# THAY <username> bang Docker Hub username cua ban
sudo docker tag my-python-app:v1.0.0 <username>/my-python-app:v1.0.0

# Kiem tra tag moi da xuat hien
sudo docker images | grep my-python-app
```

**Buoc 4: Push len Docker Hub**
```bash
sudo docker push <username>/my-python-app:v1.0.0
```
> **Xac nhan**: Vao https://hub.docker.com/repositories, kiem tra image da xuat hien.

**Buoc 5: Pull va chay tu Docker Hub (mo phong may khac)**
```bash
# Xoa image local de mo phong may moi
sudo docker rmi <username>/my-python-app:v1.0.0
sudo docker rmi my-python-app:v1.0.0

# Pull tu Docker Hub
sudo docker pull <username>/my-python-app:v1.0.0

# Chay container
sudo docker run -d --name test-pull -p 8080:8080 <username>/my-python-app:v1.0.0

# Kiem tra
curl http://localhost:8080
# Ket qua mong doi: <h1>Hello from Docker! Version: v1.0.0</h1>

# Don dep
sudo docker stop test-pull && sudo docker rm test-pull
```

**Diem quan trong can hieu**:
- `docker tag` KHONG tao ban sao image — no chi la alias (cung image ID, nhieu ten).
- Khi `docker push`, cac layer da ton tai tren Registry se duoc skip (da duoc upload truoc do).
- Khi `docker pull`, chi cac layer chua co tren local moi duoc download.

---

### Bai 2: Security — Non-root User va Resource Limits

**Muc tieu**: Harden Dockerfile de chay container an toan trong Production, gioi han tai nguyen va kiem tra hieu qua.

**Buoc 1: Tao Dockerfile voi non-root user**
Tao thu muc `Bai_2/` voi cac file sau:

**`Bai_2/Dockerfile`** — Dockerfile an toan Production:
```dockerfile
FROM python:3.11-alpine

WORKDIR /app

# Tao group va user khong co quyen root
# -S: tao system user/group (khong co password, khong co home dir)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy source code VOI quyen root (quyen mac dinh)
COPY app.py .

# Chown file cho appuser (QUAN TRONG: phai cho quyen truoc khi chuyen USER)
RUN chown -R appuser:appgroup /app

# Chuyen sang chay voi user thuong
USER appuser

# Kiem tra: lenh nay se chay duoi quyen appuser
RUN whoami

ENV APP_VERSION=v2.0.0-secure
EXPOSE 8080

CMD ["python", "app.py"]
#  Giải thích từng dòng, theo thứ tự quan trọng nhất là thứ tự thực hiện:
#   ---                                                                                                                                               
#   1. FROM python:3.11-alpine                                                                                                                        
#   Dùng image Python Alpine làm nền. Alpine = nhỏ gọn (~50MB thay vì ~900MB).
#   2. WORKDIR /app
#   Tạo và vào thư mục /app bên trong container.
#   3. RUN addgroup -S appgroup && adduser -S appuser -G appgroup
#   Tạo 1 group appgroup và 1 user appuser thuộc group đó.
#   - -S = system user (không có password, không có home dir — nhẹ và đủ dùng)
#   4. COPY app.py .
#   Copy file app.py từ host vào /app trong container. Lúc này file thuộc quyền root vì vẫn đang chạy với root.
#   5. RUN chown -R appuser:appgroup /app
#   Chuyển quyền sở hữu thư mục /app (và tất cả file bên trong) từ root sang appuser.
#   6. USER appuser
#   Từ dòng này trở đi, mọi lệnh (RUN, CMD, ENTRYPOINT) đều chạy dưới quyền appuser, không còn là root.
#   7. RUN whoami
#   Chạy thử để xác nhận — kết quả sẽ là appuser (in ra trong build log).
#   8-10. ENV, EXPOSE, CMD
#   - Đặt biến môi trường APP_VERSION=v2.0.0-secure
#   - Khai báo port 8080
#   - Chạy app khi container khởi động
#   ---
#   Tại sao thứ tự QUAN TRỌNG?
#   COPY app.py .          ← Bước 4: file thuộc root
#   RUN chown -R ...       ← Bước 5: chuyển quyền cho appuser
#   USER appuser           ← Bước 6: chuyển sang chạy bằng appuser
#   Nếu đổi thứ tự sai — đặt USER appuser trước chown:
#   - appuser không có quyền chown file → lỗi!
#   - Chỉ root mới có thể thay đổi quyền file
#   Nếu bỏ luôn chown:
#   - File app.py vẫn thuộc root, appuser có thể đọc nhưng không thể ghi → app có thể lỗi nếu cần ghi file
#   ---
#   Tóm tắt dễ nhớ: COPY → CHOWN → USER — copy file trước, cấp quyền sau, rồi mới chuyển user. Giống như bạn đưa chìa khóa nhà cho người thuê trước
#   khi họ vào ở.

```

> Copy `app.py` tu Bai_1 sang Bai_2: `cp Bai_1/app.py Bai_2/app.py`

**Buoc 2: Build va chay voi resource limits**
```bash
# Build image
sudo docker build -t my-python-app:secure Bai_2/

# Chay container GIOI HAN tai nguyen
sudo docker run -d \
  --name secure-app \
  --memory 256m \
  --cpus 0.5 \
  --restart unless-stopped \
  -p 8081:8080 \
  my-python-app:secure

# Kiem tra user dang chay
sudo docker exec secure-app whoami
# Ket qua mong doi: appuser

# Kiem tra user khong the ghi vao thu muc he thong
sudo docker exec secure-app touch /etc/test-write 2>&1
# Ket qua mong doi: Permission denied (vi appuser khong co quyen ghi /etc)

# Kiem tra resource limits
sudo docker inspect secure-app --format '{{.HostConfig.Memory}}'
# Ket qua mong doi: 268435456 (256MB = 256 * 1024 * 1024)

sudo docker inspect secure-app --format '{{.HostConfig.NanoCpus}}'
# Ket qua mong doi: 500000000 (0.5 CPU = 500,000,000 nanoseconds)

# Xem stats realtime
sudo docker stats secure-app --no-stream
```

**Buoc 3: Thu nghiem Restart Policy**
```bash
# Xem restart policy hien tai
sudo docker inspect secure-app --format '{{.HostConfig.RestartPolicy.Name}}'
# Ket qua mong doi: unless-stopped

# Mo phong app crash: kill process chinh
sudo docker exec secure-app sh -c "kill 1"

# Doi 2 giay roi kiem tra — container phai tu khoi dong lai
sleep 2
sudo docker ps | grep secure-app
# Ket qua mong doi: Container van dang chay (da restart)

# Xem so lan restart
sudo docker inspect secure-app --format '{{.RestartCount}}'
# Ket qua mong doi: >= 1

# Don dep
sudo docker stop secure-app && sudo docker rm secure-app
```

**Diem quan trong can hieu**:
- **Thu tu QUAN TRONG**: `COPY` truoc, `chown` sau, roi moi `USER`. Neu de `USER appuser` truoc `COPY`, se bi loi quyen vi appuser khong co quyen copy file.
- **`chown -R`** la bat buoc — neu khong, appuser khong the doc file ma root da copy vao.
- **`--memory 256m`**: Neu app vuot 256MB, container bi OOMKilled (Exit code 137). Kiem tra bang `docker inspect --format '{{.State.OOMKilled}}'`.
- **`--restart unless-stopped`**: Container tu restart khi crash, nhung `docker stop` thu cong se khong bi restart lai ngay ca khi Docker daemon restart.

---

### Bai 3: Security Scanning voi Trivy

**Muc tieu**: Cai dat Trivy, scan image de tim CVE, hieu cach doc va phan tich ket qua.

**Buoc 1: Cai dat Trivy**
```bash
# Cai dat Trivy (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y wget apt-transport-https gnupg lsb-release

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

# QUAN TRONG: Phai co URL https://aquasecurity.github.io/trivy-repo/deb truoc $(lsb_release -sc)
# Neu thieu URL, apt se bao loi: "Malformed entry (URI parse)"
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list

# Xac nhan noi dung file da dung (phai thay URL trong dong deb)
cat /etc/apt/sources.list.d/trivy.list
# Ket qua mong doi: deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb noble main

sudo apt-get update
sudo apt-get install -y trivy

# Kiem tra cai dat
trivy --version
```

**Buoc 2: Scan image va phan tich ket qua**
```bash
# Scan image ma ban vua build (Bai 2)
trivy image my-python-app:secure

# Scan chi loi CRITICAL va HIGH
trivy image --severity CRITICAL,HIGH my-python-app:secure

# Scan va xuat ket qua ra file JSON de phan tich
trivy image --format json --output trivy-report.json my-python-app:secure

# Scan image base (python:3.11-alpine) de so sanh
trivy image python:3.11-alpine
```

**Buoc 3: So sanh image lon vs image nho**
```bash
# Scan mot image lon (nhieu tools, nhieu CVE)
trivy image python:3.11

# Scan image nho (Alpine, it CVE hon)
trivy image python:3.11-alpine

# Quan sat: Image dung Alpine thuong co IT CVE hon vi it package hon.
# Day la ly do nen dung base image nho (slim, alpine) trong Production.
```

**Buoc 4: Ghim ket qua vao Dockerfile (Co che .trivyignore)**
Trong thuc te, mot so CVE chua co patch. Ban co the tam bo qua bang file `.trivyignore`:
```bash
# Tao file .trivyignore liet ke CVE ID can bo qua
echo "# CVE chua co patch, tam bo qua" > Bai_3/.trivyignore
echo "CVE-XXXX-XXXXX" >> Bai_3/.trivyignore

# Scan lai voi ignore file
trivy image --ignorefile Bai_3/.trivyignore my-python-app:secure
```

**Diem quan trong can hieu**:
- **Muc do uu tien**: CRITICAL > HIGH > MEDIUM > LOW > UNKNOWN. Trong Production, can fix tat ca CRITICAL va HIGH.
- **Base image nho = It CVE**: `alpine` < `slim` < `full`. Day la ly do Day 6 khuyen dung multi-stage build voi base image nho.
- **Trivy scan LAYER**: Neu ban dung multi-stage build (Day 6), chi stage cuoi cung duoc scan — stage build bi loai bo, khong anh huong bao mat.
- **CI/CD tich hop**: Trong GitHub Actions, co the them buoc `trivy image` de fail pipeline neu phat hien CVE CRITICAL.

---

### Bai 3.5: Fix CVE — Sửa Dockerfile để Giảm Severity

**Mục tiêu**: Thực hành fix CVE CRITICAL/HIGH trong Dockerfile bằng cách upgrade packages, đổi base image, và pin version — rồi scan lại để xác nhận.

**Bước 1: Tạo Dockerfile có nhiều CVE (base image cũ, không upgrade)**
Tạo thư mục `Bai_3_5/` với file sau:

**`Bai_3_5/app.py`** — Copy từ Bài 1: `cp Bai_1/app.py Bai_3_5/app.py`

**`Bai_3_5/Dockerfile.vulnerable`** — Dockerfile CÓ lỗ hổng:
```dockerfile
# Dùng base image cũ → có nhiều CVE chưa được patch
FROM python:3.11-alpine

WORKDIR /app
COPY app.py .

# KHÔNG chạy apk upgrade → các package trong base image vẫn giữ version cũ, đầy CVE
# Đây là lỗi phổ biến trong Production: build xong, không update security patches

ENV APP_VERSION=v3.0.0-vulnerable
EXPOSE 8080
CMD ["python", "app.py"]
```

Build và scan để thấy CVE:
```bash
# Build image có lỗ hổng
sudo docker build -t my-python-app:vulnerable -f Bai_3_5/Dockerfile.vulnerable Bai_3_5/

# Scan image này — ghi nhận SỐ LƯỢNG CVE CRITICAL/HIGH
trivy image --severity CRITICAL,HIGH my-python-app:vulnerable
# Kết quả: Sẽ thấy nhiều CVE CRITICAL/HIGH (vì base image chưa được update security patches)
```

**Bước 2: Fix Dockerfile — 3 kỹ thuật chính**

**`Bai_3_5/Dockerfile.fixed`** — Dockerfile đã FIX CVE:
```dockerfile
# [FIX 1] Dùng base image version CỤ THỂ (pin version) thay vì tag trôi nổi
# Tránh dùng :latest vì không kiểm soát được base image thay đổi thế nào
FROM python:3.11.9-alpine3.19

WORKDIR /app

# [FIX 2] Chạy apk upgrade ĐỂ PATCH tất cả security vulnerabilities trong OS packages
# --no-cache: Không lưu cache index → giảm image size
# Đây là bước QUAN TRỌNG NHẤT để giảm CVE trong Production
RUN apk upgrade --no-cache

# [FIX 3] Ghim version của package bổ sung (nếu có cài thêm)
# Ví dụ: RUN apk add --no-cache curl=8.5.0-r0
# → Đảm bảo build reproducible, không bị surprise khi package update

COPY app.py .

# Non-root user (Best Practice từ Bài 2)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

ENV APP_VERSION=v3.0.0-fixed
EXPOSE 8080
CMD ["python", "app.py"]
```

Build và scan lại:
```bash
# Build image đã fix
sudo docker build -t my-python-app:fixed -f Bai_3_5/Dockerfile.fixed Bai_3_5/

# Scan lại — so sánh với image vulnerable
trivy image --severity CRITICAL,HIGH my-python-app:fixed
# Kết quả mong đợi: SỐ LƯỢNG CVE CRITICAL/HIGH giảm đáng kể hoặc bằng 0
```

**Bước 3: So sánh kết quả trước/sau khi fix**
```bash
# So sánh số lượng CVE giữa 2 image
echo "=== VULNERABLE IMAGE ==="
trivy image --format json my-python-app:vulnerable | python3 -c "
import json,sys
data=json.load(sys.stdin)
for target in data.get('Results',[]):
    type_=target.get('Type','')
    vulns=target.get('Vulnerabilities',[])
    crit=sum(1 for v in vulns if v.get('Severity')=='CRITICAL')
    high=sum(1 for v in vulns if v.get('Severity')=='HIGH')
    med=sum(1 for v in vulns if v.get('Severity')=='MEDIUM')
    low=sum(1 for v in vulns if v.get('Severity')=='LOW')
    print(f'  [{type_}] CRITICAL:{crit} HIGH:{high} MEDIUM:{med} LOW:{low}')
"

echo ""
echo "=== FIXED IMAGE ==="
trivy image --format json my-python-app:fixed | python3 -c "
import json,sys
data=json.load(sys.stdin)
for target in data.get('Results',[]):
    type_=target.get('Type','')
    vulns=target.get('Vulnerabilities',[])
    crit=sum(1 for v in vulns if v.get('Severity')=='CRITICAL')
    high=sum(1 for v in vulns if v.get('Severity')=='HIGH')
    med=sum(1 for v in vulns if v.get('Severity')=='MEDIUM')
    low=sum(1 for v in vulns if v.get('Severity')=='LOW')
    print(f'  [{type_}] CRITICAL:{crit} HIGH:{high} MEDIUM:{med} LOW:{low}')
"
```

**Bước 4: Kịch bản fix CVE thực tế**

Khi Trivy phát hiện CVE, thứ tự ưu tiên fix như sau:

| Ưu tiên | Kỹ thuật | Khi nào dùng | Ví dụ |
|---|---|---|---|
| 1 | `apk upgrade --no-cache` | Fix CVE trong OS packages (Alpine) | CVE trong `libssl`, `musl` |
| 2 | Pin base image version | Tránh base image bị thay đổi bất ngờ | `python:3.11.9-alpine3.19` thay vì `:latest` |
| 3 | Pin package version | Fix CVE trong package bổ sung | `apk add curl=8.5.0-r0` |
| 4 | Đổi base image nhỏ hơn | Giảm bề mặt tấn công | Dùng `alpine` thay vì `full`, dùng `slim` thay vì `full` |
| 5 | Multi-stage build | Loại bỏ build tools khỏi runtime image | Xem lại Day 6 — chỉ giữ JRE, bỏ JDK |
| 6 | `.trivyignore` (CUỐI CÙNG) | CVE chưa có patch, tạm bỏ qua | Ghi lý do + link issue trong comment |

```bash
# Dọn dẹp
sudo docker rmi my-python-app:vulnerable my-python-app:fixed
```

**Điểm quan trọng cần hiểu**:
- **`apk upgrade` là bước rẻ nhất**: Không cần đổi code, chỉ cần 1 dòng RUN → fix phần lớn CVE OS packages.
- **Pin version = Reproducible build**: `python:3.11.9-alpine3.19` luôn cho cùng kết quả, `python:3.11-alpine` có thể thay đổi nội dung khi Docker Hub update.
- **`.trivyignore` KHÔNG PHẢI là fix**: Nó chỉ ẩn CVE khỏi report, lỗ hổng vẫn tồn tại. Chỉ dùng khi chưa có patch và phải ghi lý do + deadline fix.
- **Scan trong CI/CD**: Luôn thêm `trivy image --exit-code 1 --severity CRITICAL,HIGH` vào pipeline. Nếu có CVE mới → build FAIL → buộc phải fix trước khi deploy.

---

### Góc nhìn thực tế: Trivy trong Production — Sự thật phía sau

#### Trivy là gì?

Trivy (by Aqua Security) là scanner mã nguồn mở, quét CVE trong:
- **Docker Image** — OS packages (apk, apt, rpm)
- **Library dependencies** — npm, pip, maven, go...
- **IaC files** — Terraform, Dockerfile, K8s manifest
- **Secrets** — API key, password leak trong code

#### Thực tế: Dự án có dùng Trivy để fix không?

**Có, nhưng tỷ lệ fix thực tế thấp hơn bạn nghĩ.**

| Loại dự án | Dùng Trivy? | Fix thực tế? |
|---|---|---|
| **Large tech** (Google, Meta, Netflix) | Có, tích hợp chặt vào CI/CD | Fix CRITICAL ngay, HIGH theo sprint |
| **Fintech / Banking** | Bắt buộc — compliance (PCI-DSS, SOC2) | Fix CRITICAL/HIGH trước release |
| **Startup / SMB** | Thỉnh thoảng scan | Thường chỉ `.trivyignore` hoặc bỏ qua |
| **Open source** | Ít — thường thiếu CI/CD chặt | Rất hiếm fix, trừ khi có security team |
| **Government** | Bắt buộc — audit định kỳ | Fix theo quy trình, chậm nhưng chắc |

#### Workflow thực tế trong dự án chuyên nghiệp

```
Code Push → CI/CD Pipeline
                │
                ▼
        ┌───────────────┐
        │  Trivy Scan   │
        └──────┬────────┘
               │
        ┌──────▼────────┐     CRITICAL/HIGH
        │  Có CVE?      │─────►  FAIL pipeline
        │               │     → Block deploy
        └──────┬────────┘
               │ 0 CRITICAL/HIGH
        ┌──────▼────────┐
        │  Allow deploy │
        └───────────────┘
```

#### Tỷ lệ fix CVE thực tế

```
100% CVE phát hiện bởi Trivy
     │
     ├── 60-70%: Fix bằng apk/apt upgrade → XONG (1 dòng RUN)
     ├── 15-20%: .trivyignore (chưa có patch, false positive)
     ├──  5-10%: Đổi base image / upgrade dependency
     └──  5-10%: Thực sự fix code / config
```

#### Xu hướng mới: Build image sạch từ đầu thay vì scan sau

| Xu hướng | Mô tả | Ví dụ |
|---|---|---|
| **Chainguard Images** | Base image được build để **0 CVE** ngay từ đầu | `cgr.dev/chainguard/python:latest` |
| **Docker Scout** | Tích hợp sẵn trong Docker Desktop, UI dễ dùng | `docker scout cves <image>` |
| **SBOM** | Software Bill of Materials — liệt kê mọi thành phần trong image | `trivy sbom <image>` |
| **Distroless** | Image không có shell, package manager → bề mặt tấn công cực nhỏ | `gcr.io/distroless/python3` |

#### Trivy vs các scanner khác

| Công cụ | Ưu điểm | Nhược điểm |
|---|---|---|
| **Trivy** | Miễn phí, nhanh, dễ dùng, scan nhiều loại | Chỉ scan, không tự fix |
| **Snyk** | Scan + auto fix PR, UI tốt | Trả phí cho tính năng đủ dùng |
| **Grype** | Nhanh, bởi Anchore (cộng đồng security) | Ít tính năng hơn Trivy |
| **Docker Scout** | Tích hợp sẵn trong Docker Desktop | Mới, cộng đồng ít |

#### Bài học rút ra

1. **Scan ≠ Fix**: Trivy chỉ chỉ ra vấn đề, fix là trách nhiệm của team.
2. **`apk upgrade` fix được 60-70% CVE** — chỉ 1 dòng, không lý do gì không làm.
3. **`.trivyignore` là "nút snooze"** — tạm ẩn thay vì fix thật. Phải ghi lý do + deadline, không được quên.
4. **Xu hướng đang đổi**: Từ "build xong scan" → "build image sạch từ đầu" (Chainguard, Distroless, SBOM).

---

### Bai 4: GitHub Actions — Tu dong Build & Push

**Muc tieu**: Hieu va tao workflow GitHub Actions tu dong build Docker image va push len Docker Hub khi push code.

**Buoc 1: Tao cau truc thu muc**
```bash
# Tu thu muc goc cua project
cd /home/quanswl24/Working/DOCKER_STUDY
mkdir -p .github/workflows
```

**Buoc 2: Tao file workflow**
Tao file `.github/workflows/docker.yml` voi noi dung sau:

```yaml
name: Build and Push Docker Image

# Trigger: Chay khi push code len branch main
on:
  push:
    branches: [ main ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      # Buoc 1: Lay code tu repository
      - name: Checkout code
        uses: actions/checkout@v4

      # Buoc 2: Cai dat Docker Buildx (ho tro build nang cao)
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Buoc 3: Dang nhap Docker Hub bang Secrets
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      # Buoc 4: Build va Push image
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./Day07_Production/Bai_1
          push: true
          # Tag tu dong: latest + commit SHA short
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/my-python-app:latest
            ${{ secrets.DOCKER_USERNAME }}/my-python-app:sha-${{ github.sha }}

      # Buoc 5: Scan CVE voi Trivy (FAIL pipeline neu co CRITICAL)
      - name: Scan image with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ secrets.DOCKER_USERNAME }}/my-python-app:latest
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
```

**Buoc 3: Cau hinh GitHub Secrets**
Truoc khi workflow chay, ban can them Secrets vao GitHub repo:

1. Vao repo tren GitHub > **Settings** > **Secrets and variables** > **Actions**.
2. Them 2 secrets:
   - `DOCKER_USERNAME`: Docker Hub username cua ban.
   - `DOCKER_TOKEN`: Docker Hub Access Token (tao tai https://hub.docker.com > Account Settings > Security > New Access Token).

**Buoc 4: Hieu tung phan cua workflow**

| Phan | Y nghia |
|---|---|
| `on: push: branches: [main]` | Chi chay khi push len branch main — tranh build khi lam viec tren feature branch |
| `actions/checkout@v4` | Clone code tu repository vao runner de co Dockerfile |
| `docker/setup-buildx-action@v3` | Cai Buildx — ho tro build cache, multi-platform |
| `docker/login-action@v3` | Dang nhap Docker Hub an toan (khong hien token trong log) |
| `docker/build-push-action@v5` | Build image va push len Registry chi voi 1 step |
| `${{ secrets.DOCKER_TOKEN }}` | Tham chieu Secret — GitHub mask gia tri nay trong log (hien dau ***) |
| `severity: 'CRITICAL,HIGH'` | Chi fail neu co CVE o muc CRITICAL hoac HIGH |
| `exit-code: '1'` | Neu tim thay CVE > fail pipeline, khong cho deploy |

**Buoc 5: Mo phong kiem tra workflow (khong can push len GitHub)**
```bash
# Cai dat act (chay GitHub Actions local)
# https://github.com/nektos/act
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Chay workflow local (mo phong push event)
act -j build-and-push

# Hoac kiem tra cu phap YAML truoc
cat .github/workflows/docker.yml | python3 -c "import yaml,sys; yaml.safe_load(sys.stdin); print('YAML syntax OK')"
```

**Diem quan trong can hieu**:
- **Secrets KHONG bao gio hien trong log**: GitHub tu dong mask cac gia tri `${{ secrets.* }}` thanh `***` trong build log.
- **`exit-code: '1'`** la "cong bao chay" — neu Trivy tim thay CVE CRITICAL, pipeline se FAIL va chan deploy.
- **Tag `sha-<commit>`** giup trace chinh xac image nao tu commit nao — rat quan trong khi rollback.
- **Workflow chi chay tren branch main** — dam bao chi code da review moi duoc build va push.

---

### Bai 5: Tong hop — Production-ready Dockerfile

**Muc tieu**: Ket hop TAT CA kien thuc tu Day 1-7 de viet mot Dockerfile chuan Production.

Tao thu muc `Bai_5/` va viet `Dockerfile` ap dung tat ca best practices:

```dockerfile
# ============================================
# PRODUCTION-READY DOCKERFILE
# Ap dung tat ca best practices tu Day 1-7
# ============================================

# [DAY 6] Multi-stage build: Stage 1 - Build
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# [DAY 6] Layer caching: Copy pom.xml truoc de cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# [DAY 6] Copy source code sau (hay thay doi hon pom.xml)
COPY src ./src
RUN mvn package -DskipTests

# [DAY 6] Multi-stage build: Stage 2 - Runtime (chi JRE, nho gon)
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# [DAY 7] SECURITY: Tao non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# [DAY 7] Copy JAR tu stage build (chi lay san pham cuoi)
COPY --from=builder /app/target/*.jar app.jar

# [DAY 7] SECURITY: Chown file cho appuser truoc khi chuyen USER
RUN chown -R appuser:appgroup /app

# [DAY 7] SECURITY: Chay voi user thuong (khong phai root)
USER appuser

# [DAY 3] EXPOSE: Tai lieu port (khong thuc su publish)
EXPOSE 8080

# [DAY 3] CMD vs ENTRYPOINT: Dung ENTRYPOINT + CMD de flexible
ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]

# [DAY 7] LABEL: Metadata cho image (huu ich khi search/trace)
LABEL maintainer="your-email@example.com"
LABEL version="1.0.0"
LABEL description="Production-ready Java app"
```

**Kiem tra tong hop**:
```bash
# Build image production
sudo docker build -t my-java-app:prod Bai_5/

# Chay voi toan bo production flags
sudo docker run -d \
  --name prod-app \
  --memory 512m \
  --cpus 1 \
  --restart unless-stopped \
  -p 8082:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  my-java-app:prod

# KIEM TRA 1: Non-root user
sudo docker exec prod-app whoami
# Mong doi: appuser

# KIEM TRA 2: Resource limits
sudo docker inspect prod-app --format 'Memory: {{.HostConfig.Memory}} | CPU: {{.HostConfig.NanoCpus}}'
# Mong doi: Memory: 536870912 | CPU: 1000000000

# KIEM TRA 3: Restart policy
sudo docker inspect prod-app --format '{{.HostConfig.RestartPolicy.Name}}'
# Mong doi: unless-stopped

# KIEM TRA 4: Security scan
trivy image --severity CRITICAL,HIGH my-java-app:prod

# KIEM TRA 5: Image size (so sanh voi Day 3 build don gian)
sudo docker images | grep my-java-app
# Mong doi: prod image nho hon nhieu so voi build don gian (multi-stage)

# KIEM TRA 6: Override CMD (vi du them JVM flags)
sudo docker run --rm my-java-app:prod -Xmx256m -jar app.jar
# Mong doi: App van chay binh thuong vi ENTRYPOINT la "java", CMD bi override thanh args moi

# Don dep
sudo docker stop prod-app && sudo docker rm prod-app
```

**Checklist Production-Ready** (tong hop):

| Thuoc tinh | Da ap dung? | Lenh kiem tra |
|---|---|---|
| Multi-stage build | `[ ]` | `docker images` — so sanh size |
| Non-root user | `[ ]` | `docker exec <c> whoami` |
| Layer caching order | `[ ]` | Build lan 2, xem `CACHED` |
| `.dockerignore` | `[ ]` | `docker build --no-cache` — kiem tra khong copy file rac |
| Version tag (khong dung :latest) | `[ ]` | `docker images` — xem tag |
| Resource limits | `[ ]` | `docker inspect` — Memory/CPU |
| Restart policy | `[ ]` | `docker inspect` — RestartPolicy |
| Trivy scan (0 CRITICAL) | `[ ]` | `trivy image --severity CRITICAL` |
| ENTRYPOINT + CMD | `[ ]` | `docker run <img> --help` — override duoc args |
| LABEL metadata | `[ ]` | `docker inspect --format '{{.Config.Labels}}'` |

---

## Câu hỏi suy ngẫm

1. **Tại sao không nên lưu file `.env` hoặc API Key trực tiếp vào Docker Image?**
   > Trả lời: Vì bất kỳ ai có quyền `docker inspect` image đều có thể đọc được tất cả ENV variables (kể cả khi container không chạy). Đây là nguyên nhân chính khi credentials bị lộ ra ngoài. Thay vào đó, dùng:
   > - `docker run -e API_KEY=xxx` (env vars tại runtime).
   > - Docker Secrets (Docker Swarm) hoặc Kubernetes Secrets.
   > - BuildKit `--mount=type=secret` (đã học ở Day 3).

2. **Làm thế nào để Docker container tự khởi động lại khi Server bị Restart?**
   > Trả lời: Dùng `--restart always` hoặc `--restart unless-stopped` khi `docker run`.
   > - `--restart always`: Container tự khởi động lại SAU KHI Docker daemon restart (khi server boot). Nhưng lưu ý: ngay cả khi bạn `docker stop` thủ công, nó vẫn restart khi daemon restart.
   > - `--restart unless-stopped`: Ưu tiên hơn — giống `always` nhưng NẾU bạn đã `docker stop` thủ công, nó SẼ KHÔNG restart lại sau khi daemon restart. Đây là lựa chọn an toàn hơn cho Production.

3. **Ý nghĩa của việc dùng `docker push` so với việc dùng `docker save` ra file `.tar`?**
   > Trả lời:
   > - `docker push`: Upload image lên Registry (Docker Hub, ECR, GCR). Phù hợp cho CI/CD, chia sẻ giữa teams, deploy từ bất kỳ đâu có internet. Tự động quản lý version qua tags.
   > - `docker save`: Xuất image ra file `.tar` local. Phù hợp cho "air-gapped" environments (không có internet), transfer bằng USB hoặc internal network. Không có version management, phải tự quản lý file tar.
   > - **Trong Production**: Luôn dùng `docker push` + Registry vì nó tích hợp với CI/CD, hỗ trợ RBAC (phân quyền), và có audit log.

4. **Nếu container bị OOMKilled (Exit code 137), bạn làm gì?**
   > Trả lời:
   > 1. Kiểm tra: `docker inspect <c> --format '{{.State.OOMKilled}}'` — nếu `true`, container bị kill vì vượt quá giới hạn RAM.
   > 2. Tăng memory limit: `--memory 1g` thay vì `256m`.
   > 3. Phân tích memory leak trong app: `docker stats <c>` để xem xu hướng RAM theo thời gian.
   > 4. Nếu app cần nhiều RAM để xử lý (ví dụ: Java heap), cấu hình JVM flags: `-Xmx512m -Xms256m`.

---

## Trang thai hoan thanh (Status)
- [x] Bai 1: Docker Hub — Tag, Push, Pull (09/05)
- [x] Bai 2: Security — Non-root User va Resource Limits (09/05)
- [ ] Bai 3: Security Scanning voi Trivy
- [ ] Bai 3.5: Fix CVE — Sua Dockerfile de Giam Severity
- [ ] Goc nhin thuc te: Trivy trong Production
- [ ] Bai 4: GitHub Actions — Tu dong Build & Push
- [ ] Bai 5: Tong hop — Production-ready Dockerfile
- [ ] Tra loi cac cau hoi suy ngam
