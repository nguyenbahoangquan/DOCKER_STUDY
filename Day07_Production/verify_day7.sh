#!/bin/bash

# Script verify bai tap Day 7: CI/CD & Production Best Practices (RCA Style)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() {
    echo -e "[${GREEN}PASS${NC}] $1"
    ((PASS_COUNT++))
}
fail() {
    echo -e "[${RED}FAIL${NC}] $1"
    echo -e "      ${CYAN}[NGUYEN NHAN]${NC} $2"
    ((FAIL_COUNT++))
}
warn() {
    echo -e "[${YELLOW}WARN${NC}] $1"
    ((WARN_COUNT++))
}
info() {
    echo -e "[${YELLOW}INFO${NC}] $1"
}

echo -e "${BLUE}=== Dang kiem tra chi tiet bai tap Day 7: CI/CD & Production Best Practices ===${NC}"

# Kiem tra quyen sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[WARN] Hay chay script bang 'sudo ./verify_day7.sh' de co ket qua chinh xac nhat.${NC}"
fi


# =============================================
# BAI 1: Docker Hub — Tag, Push va Pull
# =============================================
echo -e "${BLUE}--- Bai 1: Docker Hub — Tag, Push va Pull ---${NC}"

# 1.1. Kiem tra thu muc Bai_1
if [ -d "./Bai_1" ]; then
    pass "1.1. Thu muc Bai_1 da ton tai."
else
    fail "1.1. Khong tim thay thu muc Bai_1." "Ban can tao thu muc Bai_1 va cac file thuc hanh ben trong."
fi

# 1.2. Kiem tra file app.py
if [ -f "./Bai_1/app.py" ]; then
    pass "1.2. File app.py da ton tai trong Bai_1."
    # Kiem tra noi dung co HTTP server
    if grep -qE "HTTPServer|http\.server" "./Bai_1/app.py"; then
        pass "1.2.1. app.py co HTTP server logic (dung cho viec test)."
    else
        warn "1.2.1. app.py chua co HTTP server logic. App co the khong phuc vu request tren port."
    fi
else
    fail "1.2. Khong tim thay file app.py trong Bai_1." "Tao file app.py voi noi dung HTTP server don gian theo huong dan README."
fi

# 1.3. Kiem tra Dockerfile trong Bai_1
DOCKERFILE_1="./Bai_1/Dockerfile"
if [ -f "$DOCKERFILE_1" ]; then
    pass "1.3. File Dockerfile da ton tai trong Bai_1."

    # Kiem tra base image
    if grep -qE "FROM python.*alpine|FROM python.*slim" "$DOCKERFILE_1"; then
        pass "1.3.1. Dockerfile su dung base image toi uu (alpine/slim)."
    else
        warn "1.3.1. Nen su dung python:*-alpine hoac python:*-slim de giam kich thuoc image."
    fi

    # Kiem tra EXPOSE
    if grep -q "EXPOSE" "$DOCKERFILE_1"; then
        pass "1.3.2. Dockerfile co chi thi EXPOSE port."
    else
        warn "1.3.2. Nen them EXPOSE de tai lieu port ma container su dung."
    fi
else
    fail "1.3. Khong tim thay Dockerfile trong Bai_1." "Tao file Dockerfile theo huong dan trong README."
fi

# 1.4. Kiem tra image da duoc build
IMAGE_B1=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "my-python-app" | head -n 1)
if [ ! -z "$IMAGE_B1" ]; then
    pass "1.4. Image 'my-python-app' da duoc build."
    sudo docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "my-python-app" | head -n 5
else
    info "1.4. Chua build image my-python-app. Chay: sudo docker build -t my-python-app:v1.0.0 Bai_1/"
fi

# 1.5. Kiem tra image da duoc tag theo Docker Hub convention
TAGGED_IMAGE=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "/my-python-app" | head -n 1)
if [ ! -z "$TAGGED_IMAGE" ]; then
    pass "1.5. Image da duoc tag theo Docker Hub convention: $TAGGED_IMAGE"
else
    info "1.5. Chua tag image theo Docker Hub convention. Chay: sudo docker tag my-python-app:v1.0.0 <username>/my-python-app:v1.0.0"
fi

# 1.6. Kiem tra Docker Hub login
LOGIN_STATUS=$(sudo docker login 2>&1 | head -n 1)
if echo "$LOGIN_STATUS" | grep -q "Login Succeeded" || sudo cat ~/.docker/config.json 2>/dev/null | grep -q "auths"; then
    pass "1.6. Da dang nhap Docker Hub (hoac co token luu tru)."
else
    info "1.6. Chua dang nhap Docker Hub. Chay: docker login"
fi


# =============================================
# BAI 2: Security — Non-root User va Resource Limits
# =============================================
echo -e "${BLUE}--- Bai 2: Security — Non-root User va Resource Limits ---${NC}"

# 2.1. Kiem tra thu muc Bai_2
if [ -d "./Bai_2" ]; then
    pass "2.1. Thu muc Bai_2 da ton tai."
else
    fail "2.1. Khong tim thay thu muc Bai_2." "Ban can tao thu muc Bai_2 va cac file thuc hanh ben trong."
fi

# 2.2. Kiem tra Dockerfile Bai_2
DOCKERFILE_2="./Bai_2/Dockerfile"
if [ -f "$DOCKERFILE_2" ]; then
    pass "2.2. File Dockerfile da ton tai trong Bai_2."

    # 2.2.1. Kiem tra lenh tao user
    if grep -qE "adduser|useradd" "$DOCKERFILE_2"; then
        pass "2.2.1. Dockerfile co lenh tao non-root user (adduser/useradd)."
    else
        fail "2.2.1. Dockerfile THIEU lenh tao user." "Them: RUN addgroup -S appgroup && adduser -S appuser -G appgroup (Alpine) hoac RUN groupadd -r appgroup && useradd -r -g appgroup appuser (Debian)."
    fi

    # 2.2.2. Kiem tra chi thi USER
    if grep -q "^USER " "$DOCKERFILE_2"; then
        USER_LINE=$(grep "^USER " "$DOCKERFILE_2")
        pass "2.2.2. Dockerfile co chi thi USER: $USER_LINE"
    else
        fail "2.2.2. Dockerfile THIEU chi thi USER." "Them 'USER appuser' truoc CMD/ENTRYPOINT de chay container voi user thuong."
    fi

    # 2.2.3. Kiem tra chown truoc USER
    USER_LINE_NUM=$(grep -n "^USER " "$DOCKERFILE_2" | head -n 1 | cut -d: -f1)
    CHOWN_LINE_NUM=$(grep -n "chown" "$DOCKERFILE_2" | head -n 1 | cut -d: -f1)
    if [ ! -z "$USER_LINE_NUM" ] && [ ! -z "$CHOWN_LINE_NUM" ]; then
        if [ "$CHOWN_LINE_NUM" -lt "$USER_LINE_NUM" ]; then
            pass "2.2.3. Thu tu dung: chown (dong $CHOWN_LINE_NUM) nam truoc USER (dong $USER_LINE_NUM)."
        else
            fail "2.2.3. Thu tu SAI: chown (dong $CHOWN_LINE_NUM) nam SAU USER (dong $USER_LINE_NUM)." "chown phai nam truoc USER vi sau khi chuyen sang appuser, khong con quyen chown file."
        fi
    else
        warn "2.2.3. Khong tim thay chown trong Dockerfile. Nen them 'RUN chown -R appuser:appgroup /app' truoc USER."
    fi

    # 2.2.4. Kiem tra base image
    if grep -qE "FROM python.*alpine" "$DOCKERFILE_2"; then
        pass "2.2.4. Base image la Alpine — lenh adduser/addgroup phu hop."
    elif grep -qE "FROM python.*slim|FROM debian|FROM ubuntu" "$DOCKERFILE_2"; then
        if grep -qE "adduser -S|addgroup -S" "$DOCKERFILE_2"; then
            fail "2.2.4. Dung lenh Alpine (adduser -S) tren base image Debian/Ubuntu." "Doi sang: groupadd -r appgroup && useradd -r -g appgroup appuser"
        else
            pass "2.2.4. Lenh tao user phu hop voi base image Debian/Ubuntu."
        fi
    fi
else
    fail "2.2. Khong tim thay Dockerfile trong Bai_2." "Tao file Dockerfile theo huong dan trong README."
fi

# 2.3. Kiem tra container secure-app dang chay
SECURE_CONTAINER=$(sudo docker ps --format "{{.Names}}" | grep "secure-app" | head -n 1)
if [ ! -z "$SECURE_CONTAINER" ]; then
    pass "2.3. Container 'secure-app' dang chay."

    # 2.3.1. Kiem tra user dang chay
    RUNNING_USER=$(sudo docker exec "$SECURE_CONTAINER" whoami 2>/dev/null)
    if [ "$RUNNING_USER" != "root" ] && [ ! -z "$RUNNING_USER" ]; then
        pass "2.3.1. Container dang chay voi user '$RUNNING_USER' (Non-root)."
    else
        fail "2.3.1. Container van dang chay voi quyen root." "Kiem tra Dockerfile co chi thi USER va build lai image."
    fi

    # 2.3.2. Kiem tra Memory limit
    MEM_LIMIT=$(sudo docker inspect "$SECURE_CONTAINER" --format '{{.HostConfig.Memory}}' 2>/dev/null)
    if [ ! -z "$MEM_LIMIT" ] && [ "$MEM_LIMIT" -gt 0 ]; then
        MEM_MB=$((MEM_LIMIT / 1024 / 1024))
        pass "2.3.2. Memory limit da duoc thiet lap: ${MEM_MB}MB."
    else
        fail "2.3.2. KHONG co Memory limit." "Chay voi --memory 256m hoac --memory 512m de gioi han RAM."
    fi

    # 2.3.3. Kiem tra CPU limit
    CPU_LIMIT=$(sudo docker inspect "$SECURE_CONTAINER" --format '{{.HostConfig.NanoCpus}}' 2>/dev/null)
    if [ ! -z "$CPU_LIMIT" ] && [ "$CPU_LIMIT" -gt 0 ]; then
        CPU_CORES=$(echo "scale=1; $CPU_LIMIT / 1000000000" | bc)
        pass "2.3.3. CPU limit da duoc thiet lap: ${CPU_CORES} core(s)."
    else
        fail "2.3.3. KHONG co CPU limit." "Chay voi --cpus 0.5 hoac --cpus 1 de gioi han CPU."
    fi

    # 2.3.4. Kiem tra Restart Policy
    RESTART_POLICY=$(sudo docker inspect "$SECURE_CONTAINER" --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)
    if [ "$RESTART_POLICY" != "no" ] && [ ! -z "$RESTART_POLICY" ]; then
        pass "2.3.4. Restart policy da duoc thiet lap: '$RESTART_POLICY'."
    else
        fail "2.3.4. Restart policy la 'no' (mac dinh)." "Chay voi --restart unless-stopped hoac --restart always."
    fi

    # 2.3.5. Kiem tra appuser khong the ghi vao /etc
    WRITE_TEST=$(sudo docker exec "$SECURE_CONTAINER" sh -c "touch /etc/test-write 2>&1")
    if echo "$WRITE_TEST" | grep -qi "permission denied\|denied\|read-only"; then
        pass "2.3.5. Non-root user KHONG the ghi vao /etc (bao mat dung)."
    else
        fail "2.3.5. User van co the ghi vao /etc." "Container co the van chay voi quyen root. Kiem tra lai USER trong Dockerfile."
    fi
else
    info "2.3. Chua co container 'secure-app' dang chay. Chay lenh docker run theo huong dan Bai 2."
fi


# =============================================
# BAI 3: Security Scanning voi Trivy
# =============================================
echo -e "${BLUE}--- Bai 3: Security Scanning voi Trivy ---${NC}"

# 3.1. Kiem tra Trivy da duoc cai dat
if command -v trivy &>/dev/null; then
    TRIVY_VERSION=$(trivy --version 2>/dev/null | head -n 1)
    pass "3.1. Trivy da duoc cai dat: $TRIVY_VERSION"
else
    fail "3.1. Trivy CHUA duoc cai dat." "Cai dat: sudo apt-get install -y trivy hoac tai tu https://github.com/aquasecurity/trivy/releases"
fi

# 3.2. Kiem tra scan da chay (neu co report file)
if [ -f "./trivy-report.json" ]; then
    pass "3.2. File trivy-report.json da ton tai (scan da duoc chay va xuat ra file)."

    # Kiem tra so luong CVE
    CRITICAL_COUNT=$(python3 -c "import json; d=json.load(open('./trivy-report.json')); print(sum(len(r.get('Vulnerabilities',[])) for r in d.get('Results',[]) if r.get('Vulnerabilities')))" 2>/dev/null)
    if [ ! -z "$CRITICAL_COUNT" ]; then
        info "3.2.1. Tong so CVE tim thay: $CRITICAL_COUNT"
    fi
else
    info "3.2. Chua chay scan xuat ra file JSON. Chay: trivy image --format json --output trivy-report.json my-python-app:secure"
fi

# 3.3. Kiem tra file .trivyignore
if [ -f "./Bai_2/.trivyignore" ]; then
    pass "3.3. File .trivyignore da ton tai."
    IGNORE_COUNT=$(grep -c "^CVE-" "./Bai_2/.trivyignore" 2>/dev/null || echo "0")
    info "3.3.1. So CVE duoc bo qua trong .trivyignore: $IGNORE_COUNT"
else
    info "3.3. Chua tao file .trivyignore. Day la optional nhung huu ich khi co CVE chua co patch."
fi

# 3.4. Thu scan image (neu co image va trivy)
if command -v trivy &>/dev/null; then
    SECURE_IMAGE=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "secure" | head -n 1)
    if [ ! -z "$SECURE_IMAGE" ]; then
        echo -e "      ${CYAN}[SCAN]${NC} Dang scan image '$SECURE_IMAGE'..."
        trivy image --severity CRITICAL,HIGH --no-progress "$SECURE_IMAGE" 2>/dev/null | tail -n 20
    else
        info "3.4. Chua build image 'my-python-app:secure'. Khong the scan."
    fi
fi


# =============================================
# BAI 4: GitHub Actions — Tu dong Build & Push
# =============================================
echo -e "${BLUE}--- Bai 4: GitHub Actions — Tu dong Build & Push ---${NC}"

# 4.1. Kiem tra thu muc .github/workflows
WORKFLOW_DIR="/home/quanswl24/Working/DOCKER_STUDY/.github/workflows"
if [ -d "$WORKFLOW_DIR" ]; then
    pass "4.1. Thu muc .github/workflows da ton tai."
else
    fail "4.1. Khong tim thay thu muc .github/workflows." "Tao cau truc: mkdir -p .github/workflows (tu thu muc goc cua project)."
fi

# 4.2. Kiem tra file docker.yml
WORKFLOW_FILE="$WORKFLOW_DIR/docker.yml"
if [ -f "$WORKFLOW_FILE" ]; then
    pass "4.2. File docker.yml da ton tai."

    # 4.2.1. Kiem tra cu phap YAML
    YAML_CHECK=$(python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW_FILE')); print('OK')" 2>&1)
    if [ "$YAML_CHECK" = "OK" ]; then
        pass "4.2.1. Cu phap YAML hop le."
    else
        fail "4.2.1. Cu phap YAML KHONG hop le: $YAML_CHECK" "Kiem tra lai thut phan va dau cach trong file docker.yml."
    fi

    # 4.2.2. Kiem tra trigger event
    if grep -qE "on:|push:|branches:" "$WORKFLOW_FILE"; then
        TRIGGER_BRANCH=$(grep -A2 "branches:" "$WORKFLOW_FILE" | head -n 3)
        pass "4.2.2. Workflow co trigger event: $TRIGGER_BRANCH"
    else
        fail "4.2.2. Workflow thieu trigger event (on:)." "Them 'on: push: branches: [main]' de tu dong chay khi push code."
    fi

    # 4.2.3. Kiem tra Docker Hub login step
    if grep -q "docker/login-action" "$WORKFLOW_FILE"; then
        pass "4.2.3. Co buoc dang nhap Docker Hub (docker/login-action)."
    else
        fail "4.2.3. Thieu buoc dang nhap Docker Hub." "Them step su dung docker/login-action@v3 voi secrets.DOCKER_USERNAME va secrets.DOCKER_TOKEN."
    fi

    # 4.2.4. Kiem tra secrets su dung
    if grep -qE "secrets\.DOCKER_USERNAME|secrets\.DOCKER_TOKEN" "$WORKFLOW_FILE"; then
        pass "4.2.4. Workflow su dung GitHub Secrets cho credentials (bao mat)."
    else
        warn "4.2.4. Workflow chua su dung secrets cho Docker Hub credentials. KHONG bao gio hardcode password vao file YAML."
    fi

    # 4.2.5. Kiem tra build va push step
    if grep -q "docker/build-push-action" "$WORKFLOW_FILE"; then
        pass "4.2.5. Co buoc Build va Push image (docker/build-push-action)."
    else
        fail "4.2.5. Thieu buoc Build va Push." "Them step su dung docker/build-push-action@v5."
    fi

    # 4.2.6. Kiem tra Trivy scan step
    if grep -q "trivy" "$WORKFLOW_FILE"; then
        pass "4.2.6. Co buoc Security Scan voi Trivy (CI/CD bao mat)."
        # Kiem tra exit-code
        if grep -qE "exit-code.*1|exit-code.*'1'" "$WORKFLOW_FILE"; then
            pass "4.2.6.1. Trivy scan co exit-code: 1 — pipeline se FAIL neu phat hien CVE CRITICAL/HIGH."
        else
            warn "4.2.6.1. Trivy scan khong co exit-code: 1 — pipeline se KHONG fail du co CVE. Nen them exit-code: '1'."
        fi
    else
        warn "4.2.6. Chua co buoc Security Scan trong workflow. Nen them Trivy action de bao mat CI/CD."
    fi

    # 4.2.7. Kiem tra tag strategy (co tag theo commit SHA?)
    if grep -qE "github\.sha|sha-" "$WORKFLOW_FILE"; then
        pass "4.2.7. Workflow tag image theo git commit SHA (trace duoc code)."
    else
        warn "4.2.7. Nen tag them theo commit SHA (vd: sha-\${{ github.sha }}) de trace image ve dung commit."
    fi

else
    fail "4.2. Khong tim thay file docker.yml." "Tao file .github/workflows/docker.yml theo huong dan trong README."
fi


# =============================================
# BAI 5: Tong hop — Production-ready Dockerfile
# =============================================
echo -e "${BLUE}--- Bai 5: Tong hop — Production-ready Dockerfile ---${NC}"

# 5.1. Kiem tra thu muc Bai_5
if [ -d "./Bai_5" ]; then
    pass "5.1. Thu muc Bai_5 da ton tai."
else
    fail "5.1. Khong tim thay thu muc Bai_5." "Ban can tao thu muc Bai_5 va viet Production-ready Dockerfile."
fi

# 5.2. Kiem tra Dockerfile Bai_5
DOCKERFILE_5="./Bai_5/Dockerfile"
if [ -f "$DOCKERFILE_5" ]; then
    pass "5.2. File Dockerfile da ton tai trong Bai_5."

    # 5.2.1. Multi-stage build
    STAGE_COUNT=$(grep -c "^FROM" "$DOCKERFILE_5")
    if [ "$STAGE_COUNT" -gt 1 ]; then
        pass "5.2.1. Multi-stage build: $STAGE_COUNT stages."
    else
        fail "5.2.1. Dockerfile chi co 1 stage (KHONG phai multi-stage)." "Them it nhat 2 lenh FROM: 1 stage build, 1 stage runtime."
    fi

    # 5.2.2. Non-root user
    if grep -q "^USER " "$DOCKERFILE_5"; then
        PROD_USER=$(grep "^USER " "$DOCKERFILE_5" | awk '{print $2}')
        if [ "$PROD_USER" != "root" ]; then
            pass "5.2.2. Chay voi non-root user: $PROD_USER"
        else
            fail "5.2.2. USER la 'root' — khong an toan cho Production." "Doi sang user thuong (appuser)."
        fi
    else
        fail "5.2.2. Thieu chi thi USER." "Them 'USER appuser' truoc CMD/ENTRYPOINT."
    fi

    # 5.2.3. Layer caching (copy dependencies truoc code)
    if grep -qE "COPY.*pom\.xml|COPY.*package\.json" "$DOCKERFILE_5"; then
        LINE_DEP=$(grep -nE "COPY.*pom\.xml|COPY.*package\.json" "$DOCKERFILE_5" | head -n 1 | cut -d: -f1)
        LINE_CODE=$(grep -nE "COPY src|COPY \. \." "$DOCKERFILE_5" | head -n 1 | cut -d: -f1)
        if [ ! -z "$LINE_CODE" ] && [ "$LINE_DEP" -lt "$LINE_CODE" ]; then
            pass "5.2.3. Layer caching toi uu: Dependencies (dong $LINE_DEP) truoc Code (dong $LINE_CODE)."
        else
            fail "5.2.3. Layer caching CHUA toi uu." "COPY pom.xml/package.json TRUOC khi COPY src de tan dung cache."
        fi
    else
        warn "5.2.3. Khong thay pattern copy dependencies truoc code. Kiem tra lai thu tu cac lenh COPY."
    fi

    # 5.2.4. ENTRYPOINT + CMD
    if grep -q "ENTRYPOINT" "$DOCKERFILE_5"; then
        pass "5.2.4. Co chi thi ENTRYPOINT (executable chinh)."
        if grep -q "^CMD " "$DOCKERFILE_5"; then
            pass "5.2.4.1. Co chi thi CMD (default args) — cho phep override linh hoat."
        else
            warn "5.2.4.1. Co ENTRYPOINT nhung thieu CMD — nen them CMD de cho phep override args mac dinh."
        fi
    else
        warn "5.2.4. Chua co ENTRYPOINT. Nen ket hop ENTRYPOINT + CMD de flexible hon cho Production."
    fi

    # 5.2.5. LABEL metadata
    if grep -q "^LABEL " "$DOCKERFILE_5"; then
        LABEL_COUNT=$(grep -c "^LABEL " "$DOCKERFILE_5")
        pass "5.2.5. Co $LABEL_COUNT chi thi LABEL (metadata cho image)."
    else
        warn "5.2.5. Thieu LABEL. Nen them LABEL maintainer, version, description de quan ly image."
    fi

    # 5.2.6. .dockerignore
    if [ -f "./Bai_5/.dockerignore" ]; then
        pass "5.2.6. File .dockerignore da ton tai."
    else
        warn "5.2.6. Thieu .dockerignore — nen tao de loai bo file rac (log, .git, node_modules, v.v.)."
    fi

    # 5.2.7. Base image runtime stage
    LAST_FROM=$(grep "^FROM" "$DOCKERFILE_5" | tail -n 1)
    if echo "$LAST_FROM" | grep -qE "alpine|slim|jre|distroless"; then
        pass "5.2.7. Stage runtime su dung base image toi uu: $LAST_FROM"
    else
        warn "5.2.7. Stage runtime nen dung base image nho (alpine/slim/jre/distroless). Hien tai: $LAST_FROM"
    fi

else
    fail "5.2. Khong tim thay Dockerfile trong Bai_5." "Tao file Dockerfile ap dung tat ca best practices theo huong dan README."
fi

# 5.3. Kiem tra production image da build
PROD_IMAGE=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "prod" | head -n 1)
if [ ! -z "$PROD_IMAGE" ]; then
    pass "5.3. Production image da duoc build: $PROD_IMAGE"

    # So sanh size
    echo -e "      ${CYAN}[SIZE COMPARISON]${NC}"
    sudo docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "java-app|python-app" | head -n 10
else
    info "5.3. Chua build production image. Chay: sudo docker build -t my-java-app:prod Bai_5/"
fi

# 5.4. Kiem tra production container (neu dang chay)
PROD_CONTAINER=$(sudo docker ps --format "{{.Names}}" | grep "prod-app" | head -n 1)
if [ ! -z "$PROD_CONTAINER" ]; then
    pass "5.4. Production container 'prod-app' dang chay."

    # Kiem tra non-root
    PROD_USER=$(sudo docker exec "$PROD_CONTAINER" whoami 2>/dev/null)
    if [ "$PROD_USER" != "root" ] && [ ! -z "$PROD_USER" ]; then
        pass "5.4.1. Production container chay voi user: $PROD_USER"
    else
        fail "5.4.1. Production container van chay voi root!" "Sua Dockerfile them USER appuser."
    fi

    # Kiem tra resource limits
    PROD_MEM=$(sudo docker inspect "$PROD_CONTAINER" --format '{{.HostConfig.Memory}}' 2>/dev/null)
    PROD_CPU=$(sudo docker inspect "$PROD_CONTAINER" --format '{{.HostConfig.NanoCpus}}' 2>/dev/null)
    PROD_RESTART=$(sudo docker inspect "$PROD_CONTAINER" --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)

    if [ ! -z "$PROD_MEM" ] && [ "$PROD_MEM" -gt 0 ]; then
        pass "5.4.2. Memory limit: $((PROD_MEM / 1024 / 1024))MB"
    else
        fail "5.4.2. KHONG co Memory limit — nguy hiem cho Production!" "Chay voi --memory 512m."
    fi

    if [ ! -z "$PROD_CPU" ] && [ "$PROD_CPU" -gt 0 ]; then
        pass "5.4.3. CPU limit: $(echo "scale=1; $PROD_CPU / 1000000000" | bc) core(s)"
    else
        fail "5.4.3. KHONG co CPU limit." "Chay voi --cpus 1."
    fi

    if [ "$PROD_RESTART" != "no" ] && [ ! -z "$PROD_RESTART" ]; then
        pass "5.4.4. Restart policy: $PROD_RESTART"
    else
        fail "5.4.4. Restart policy la 'no' — container khong tu khoi dong lai khi crash." "Chay voi --restart unless-stopped."
    fi
else
    info "5.4. Chua chay production container. Chay docker run theo huong dan Bai 5."
fi


# =============================================
# CAU HOI SUY NGAM
# =============================================
echo -e "${BLUE}--- Cau hoi suy ngam ---${NC}"

README_FILE="./README.md"
if [ -f "$README_FILE" ]; then
    # Dem cac cau tra loi da dien (khong con trong sau "> Tra loi:")
    ANSWER_COUNT=$(grep -c "> Tra loi:" "$README_FILE")
    EMPTY_COUNT=$(grep -c "> Tra loi: *$" "$README_FILE")
    FILLED_COUNT=$((ANSWER_COUNT - EMPTY_COUNT))

    if [ "$FILLED_COUNT" -ge 3 ]; then
        pass "Da tra loi $FILLED_COUNT/$ANSWER_COUNT cau hoi suy ngam."
    else
        info "Moi tra loi $FILLED_COUNT/$ANSWER_COUNT cau hoi. Hay dien them vao phan '> Tra loi:' trong README."
    fi
fi


# =============================================
# TONG KET
# =============================================
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}TONG KET DAY 7${NC}"
echo -e "  ${GREEN}PASS${NC}: $PASS_COUNT"
echo -e "  ${RED}FAIL${NC}: $FAIL_COUNT"
echo -e "  ${YELLOW}WARN${NC}: $WARN_COUNT"
echo -e ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Chuc mung ban da hoan thanh tron ven 7 ngay hoc Docker!${NC}"
else
    echo -e "${YELLOW}Con $FAIL_COUNT muc chua dat. Hay xem [NGUYEN NHAN] va sua lai.${NC}"
fi

echo -e "${BLUE}=============================================${NC}"
