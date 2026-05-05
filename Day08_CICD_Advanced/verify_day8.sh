#!/bin/bash

# Script verify bai tap Day 8: CI/CD Advanced (RCA Style)

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

echo -e "${BLUE}=== Dang kiem tra chi tiet bai tap Day 8: CI/CD Advanced ===${NC}"

# Kiem tra quyen sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[WARN] Hay chay script bang 'sudo ./verify_day8.sh' de co ket qua chinh xac nhat.${NC}"
fi


# =============================================
# BAI 1: Health Check
# =============================================
echo -e "${BLUE}--- Bai 1: Health Check — Kiem tra suc khoe ung dung ---${NC}"

# 1.1. Kiem tra thu muc Bai_1
if [ -d "./Bai_1" ]; then
    pass "1.1. Thu muc Bai_1 da ton tai."
else
    fail "1.1. Khong tim thay thu muc Bai_1." "Tao thu muc Bai_1 va cac file theo huong dan README."
fi

# 1.2. Kiem tra file app.py
if [ -f "./Bai_1/app.py" ]; then
    pass "1.2. File app.py da ton tai."

    # Kiem tra co /health endpoint
    if grep -q "/health" "./Bai_1/app.py"; then
        pass "1.2.1. app.py co endpoint /health cho healthcheck."
    else
        fail "1.2.1. app.py THIEU endpoint /health." "Them endpoint /health tra ve HTTP 200 khi app khoe, HTTP 503 khi chua san sang."
    fi

    # Kiem tra co HEALTHCHECK response logic
    if grep -qE "503|starting|healthy" "./Bai_1/app.py"; then
        pass "1.2.2. app.py co logic phan biet starting vs healthy."
    else
        warn "1.2.2. app.py nen co logic phan biet trang thai starting (503) vs healthy (200)."
    fi
else
    fail "1.2. Khong tim thay file app.py trong Bai_1." "Tao file app.py theo huong dan README."
fi

# 1.3. Kiem tra Dockerfile Bai_1
DOCKERFILE_1="./Bai_1/Dockerfile"
if [ -f "$DOCKERFILE_1" ]; then
    pass "1.3. File Dockerfile da ton tai trong Bai_1."

    # Kiem tra HEALTHCHECK directive
    if grep -q "^HEALTHCHECK" "$DOCKERFILE_1"; then
        pass "1.3.1. Dockerfile co chi thi HEALTHCHECK."

        # Kiem tra cac tham so HEALTHCHECK
        if grep -q "start-period" "$DOCKERFILE_1"; then
            pass "1.3.2. HEALTHCHECK co --start-period (cho app khoi dong truoc khi check)."
        else
            warn "1.3.2. Nen them --start-period de tranh false-unhealthy khi app con dang start."
        fi

        if grep -q "interval" "$DOCKERFILE_1"; then
            pass "1.3.3. HEALTHCHECK co --interval (tan suat kiem tra)."
        else
            warn "1.3.3. Nen chi ro --interval (mac dinh 30s, nen dat 10s-30s cho dev)."
        fi

        if grep -q "retries" "$DOCKERFILE_1"; then
            pass "1.3.4. HEALTHCHECK co --retries (so lan fail truoc khi danh dau unhealthy)."
        else
            warn "1.3.4. Nen chi ro --retries (mac dinh 3, de dam bao khong false-positive)."
        fi

        # Kiem tra lenh check
        HEALTHCHECK_CMD=$(grep "^HEALTHCHECK" "$DOCKERFILE_1" | grep -oE "CMD .*")
        if echo "$HEALTHCHECK_CMD" | grep -q "curl.*-f"; then
            pass "1.3.5. HEALTHCHECK CMD dung 'curl -f' (flag -f la bat buoc de fail khi HTTP >= 400)."
        elif echo "$HEALTHCHECK_CMD" | grep -q "curl" && ! echo "$HEALTHCHECK_CMD" | grep -q "\-f"; then
            fail "1.3.5. HEALTHCHECK CMD dung curl NHUNG THIEU flag -f." "Them 'curl -f' de curl tra exit code 1 khi HTTP status >= 400. Khong co -f, curl luon tra 0 (success) bat ke server tra 500."
        else
            info "1.3.5. HEALTHCHECK CMD: $HEALTHCHECK_CMD"
        fi
    else
        fail "1.3.1. Dockerfile THIEU chi thi HEALTHCHECK." "Them: HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/health || exit 1"
    fi

    # Kiem tra co cai curl (Alpine khong co san)
    if grep -qE "apk.*curl|apt.*curl" "$DOCKERFILE_1"; then
        pass "1.3.6. Dockerfile cai dat curl cho HEALTHCHECK (Alpine khong co san curl)."
    else
        BASE_IMG=$(grep "^FROM" "$DOCKERFILE_1 | head -n 1")
        if echo "$BASE_IMG" | grep -q "alpine"; then
            fail "1.3.6. Base image la Alpine nhung KHONG cai curl cho HEALTHCHECK." "Alpine khong co curl san. Them: RUN apk add --no-cache curl"
        else
            info "1.3.6. Base image khong phai Alpine — co the da co curl san."
        fi
    fi
else
    fail "1.3. Khong tim thay Dockerfile trong Bai_1." "Tao file Dockerfile theo huong dan README."
fi

# 1.4. Kiem tra image health-app da build
HEALTH_IMG=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "health-app" | head -n 1)
if [ ! -z "$HEALTH_IMG" ]; then
    pass "1.4. Image 'health-app' da duoc build: $HEALTH_IMG"
else
    info "1.4. Chua build image health-app. Chay: sudo docker build -t health-app:v1 Bai_1/"
fi

# 1.5. Kiem tra container health-check-demo
HEALTH_CONTAINER=$(sudo docker ps -a --format "{{.Names}}" | grep "health-check-demo" | head -n 1)
if [ ! -z "$HEALTH_CONTAINER" ]; then
    pass "1.5. Container 'health-check-demo' da duoc tao."

    HEALTH_STATUS=$(sudo docker inspect --format '{{.State.Health.Status}}' "$HEALTH_CONTAINER" 2>/dev/null)
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        pass "1.5.1. Container health status: healthy"
    elif [ "$HEALTH_STATUS" = "unhealthy" ]; then
        warn "1.5.1. Container health status: unhealthy — co the app dang bi loi hoac da dung."
    elif [ "$HEALTH_STATUS" = "starting" ]; then
        info "1.5.1. Container health status: starting — app con dang khoi dong, cho them."
    else
        info "1.5.1. Container chua co health status (co the Dockerfile chua co HEALTHCHECK hoac container vua tao)."
    fi
else
    info "1.5. Chua chay container health-check-demo. Chay theo huong dan Bai 1 README."
fi


# =============================================
# BAI 2: Docker Compose voi Health Check va depends_on
# =============================================
echo -e "${BLUE}--- Bai 2: Docker Compose voi Health Check va depends_on ---${NC}"

# 2.1. Kiem tra thu muc Bai_2
if [ -d "./Bai_2" ]; then
    pass "2.1. Thu muc Bai_2 da ton tai."
else
    fail "2.1. Khong tim thay thu muc Bai_2." "Tao thu muc Bai_2 va cac file theo huong dan README."
fi

# 2.2. Kiem tra docker-compose.yml
COMPOSE_FILE="./Bai_2/docker-compose.yml"
if [ -f "$COMPOSE_FILE" ]; then
    pass "2.2. File docker-compose.yml da ton tai."

    # Kiem tra YAML syntax
    YAML_CHECK=$(python3 -c "import yaml; yaml.safe_load(open('$COMPOSE_FILE')); print('OK')" 2>&1)
    if [ "$YAML_CHECK" = "OK" ]; then
        pass "2.2.1. Cu phap YAML hop le."
    else
        fail "2.2.1. Cu phap YAML KHONG hop le: $YAML_CHECK" "Kiem tra lai thut phan va dau cach."
    fi

    # Kiem tra co db service voi healthcheck
    if grep -q "mysqladmin.*ping" "$COMPOSE_FILE"; then
        pass "2.2.2. MySQL service co healthcheck (mysqladmin ping)."
    else
        fail "2.2.2. MySQL service THIEU healthcheck." "Them healthcheck: test: ['CMD', 'mysqladmin', 'ping', '-h', 'localhost']"
    fi

    # Kiem tra co cache service voi healthcheck
    if grep -q "redis-cli.*ping" "$COMPOSE_FILE"; then
        pass "2.2.3. Redis service co healthcheck (redis-cli ping)."
    else
        warn "2.2.3. Redis service nen co healthcheck. Them: test: ['CMD', 'redis-cli', 'ping']"
    fi

    # Kiem tra app service co healthcheck
    if grep -qA5 "app:" "$COMPOSE_FILE" && grep -q "curl.*health" "$COMPOSE_FILE"; then
        pass "2.2.4. App service co healthcheck (curl /health)."
    else
        fail "2.2.4. App service THIEU healthcheck." "Them healthcheck cho app service: test: ['CMD', 'curl', '-f', 'http://localhost:8080/health']"
    fi

    # Kiem tra depends_on voi condition
    if grep -q "service_healthy" "$COMPOSE_FILE"; then
        pass "2.2.5. App co depends_on voi condition: service_healthy (cho db healthy moi start)."
    else
        fail "2.2.5. App THIEU depends_on condition: service_healthy." "Them: depends_on: db: condition: service_healthy — dam bao app chi start khi DB thuc su san sang."
    fi

    # Kiem tra start_period
    if grep -q "start_period\|start-period" "$COMPOSE_FILE"; then
        pass "2.2.6. Co cau hinh start_period cho healthcheck (cho app khoi dong truoc khi check)."
    else
        warn "2.2.6. Nen them start_period cho cac service de tranh false-unhealthy khi app con dang start."
    fi
else
    fail "2.2. Khong tim thay file docker-compose.yml trong Bai_2." "Tao file docker-compose.yml theo huong dan README."
fi

# 2.3. Kiem tra Dockerfile Bai_2
DOCKERFILE_2="./Bai_2/Dockerfile"
if [ -f "$DOCKERFILE_2" ]; then
    pass "2.3. File Dockerfile da ton tai trong Bai_2."

    if grep -q "^HEALTHCHECK" "$DOCKERFILE_2"; then
        pass "2.3.1. Dockerfile co chi thi HEALTHCHECK."
    else
        fail "2.3.1. Dockerfile THIEU HEALTHCHECK." "Them HEALTHCHECK de Docker Compose co the kiem tra suc khoe container."
    fi

    # Kiem tra cai mysql-client (app.py can de check DB)
    if grep -qE "mysql-client|mariadb-client" "$DOCKERFILE_2"; then
        pass "2.3.2. Dockerfile cai dat mysql-client (cho app.py kiem tra ket noi DB)."
    else
        warn "2.3.2. Dockerfile nen cai mysql-client de app.py co the kiem tra ket noi DB trong healthcheck."
    fi
else
    fail "2.3. Khong tim thay Dockerfile trong Bai_2." "Tao file Dockerfile theo huong dan README."
fi

# 2.4. Kiem tra Compose stack dang chay
COMPOSE_RUNNING=$(sudo docker compose -f "$COMPOSE_FILE" ps --format "{{.Name}}" 2>/dev/null | head -n 1)
if [ ! -z "$COMPOSE_RUNNING" ]; then
    pass "2.4. Docker Compose stack dang chay."
    sudo docker compose -f "$COMPOSE_FILE" ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null
else
    info "2.4. Docker Compose stack chua chay. Chay: cd Bai_2 && sudo docker compose up -d --build"
fi


# =============================================
# BAI 3: Multi-environment Pipeline
# =============================================
echo -e "${BLUE}--- Bai 3: Multi-environment Pipeline voi GitHub Actions ---${NC}"

# 3.1. Kiem tra file workflow
WORKFLOW_DIR="/home/quanswl24/Working/DOCKER_STUDY/.github/workflows"
CICD_FILE="$WORKFLOW_DIR/cicd-pipeline.yml"
DOCKER_FILE="$WORKFLOW_DIR/docker.yml"

# Kiem tra it nhat 1 workflow file
if [ -f "$CICD_FILE" ] || [ -f "$DOCKER_FILE" ]; then
    pass "3.1. Co it nhat 1 file workflow trong .github/workflows/."

    # Chon file de kiem tra
    CHECK_FILE=""
    if [ -f "$CICD_FILE" ]; then
        CHECK_FILE="$CICD_FILE"
        info "3.1.1. Dang kiem tra file: cicd-pipeline.yml"
    elif [ -f "$DOCKER_FILE" ]; then
        CHECK_FILE="$DOCKER_FILE"
        info "3.1.1. Dang kiem tra file: docker.yml"
    fi

    if [ ! -z "$CHECK_FILE" ]; then
        # Kiem tra YAML syntax
        YAML_CHECK=$(python3 -c "import yaml; yaml.safe_load(open('$CHECK_FILE')); print('OK')" 2>&1)
        if [ "$YAML_CHECK" = "OK" ]; then
            pass "3.1.2. Cu phap YAML hop le."
        else
            fail "3.1.2. Cu phap YAML KHONG hop le: $YAML_CHECK" "Kiem tra lai thut phan va dau cach."
        fi

        # Kiem tra co nhieu jobs
        JOB_COUNT=$(grep -c "^  [a-z].*:$" "$CHECK_FILE" 2>/dev/null || echo "0")
        if [ "$JOB_COUNT" -ge 3 ]; then
            pass "3.1.3. Pipeline co $JOB_COUNT jobs (multi-step pipeline)."
        else
            warn "3.1.3. Pipeline chi co $JOB_COUNT job(s). Nen tach thanh nhieu jobs: test, build, deploy."
        fi

        # Kiem tra co `needs` (job dependencies)
        if grep -q "needs:" "$CHECK_FILE"; then
            pass "3.1.4. Pipeline co `needs` — tao chuoi phu thuoc giua cac jobs."
        else
            fail "3.1.4. Pipeline THIEU `needs` — cac jobs chay doc lap, khong dam bao test pass truoc khi build." "Them 'needs: test' vao job build de chi build khi test pass."
        fi

        # Kiem tra co `environment`
        if grep -q "environment:" "$CHECK_FILE"; then
            ENV_COUNT=$(grep -c "environment:" "$CHECK_FILE")
            pass "3.1.5. Pipeline co $ENV_COUNT environment(s) — ho tro multi-environment deploy."
        else
            warn "3.1.5. Pipeline chua su dung `environment`. Nen gan environment cho deploy jobs de ho tro protection rules."
        fi

        # Kiem tra co integration test
        if grep -qiE "integration|smoke|curl.*localhost" "$CHECK_FILE"; then
            pass "3.1.6. Pipeline co buoc integration/smoke test (chay container roi test)."
        else
            fail "3.1.6. Pipeline THIEU integration test — chi build image ma khong verify no chay dung." "Them step: chay container, sleep, curl /health, kiem tra HTTP 200."
        fi

        # Kiem tra co cleanup step voi if: always()
        if grep -q "if: always()" "$CHECK_FILE" || grep -q "if: always" "$CHECK_FILE"; then
            pass "3.1.7. Pipeline co cleanup step voi 'if: always()' — don dep container du pipeline pass hay fail."
        else
            warn "3.1.7. Nen them cleanup step voi 'if: always()' de don dep container test khi pipeline fail."
        fi

        # Kiem tra co Trivy scan
        if grep -qi "trivy" "$CHECK_FILE"; then
            pass "3.1.8. Pipeline co buoc Trivy security scan."
        else
            warn "3.1.8. Nen them Trivy scan vao pipeline de quet CVE truoc khi deploy."
        fi

        # Kiem tra cache
        if grep -qE "cache-from|cache-to|type=gha" "$CHECK_FILE"; then
            pass "3.1.9. Pipeline su dung build cache (type=gha) — tang toc do build lan 2+."
        else
            warn "3.1.9. Nen su dung build cache (cache-from: type=gha) de tang toc do build."
        fi
    fi
else
    fail "3.1. Khong tim thay file workflow trong .github/workflows/." "Tao file .github/workflows/cicd-pipeline.yml theo huong dan README Bai 3."
fi


# =============================================
# BAI 4: Blue-Green Deployment
# =============================================
echo -e "${BLUE}--- Bai 4: Blue-Green Deployment voi Docker Compose ---${NC}"

# 4.1. Kiem tra thu muc Bai_4
if [ -d "./Bai_4" ]; then
    pass "4.1. Thu muc Bai_4 da ton tai."
else
    fail "4.1. Khong tim thay thu muc Bai_4." "Tao thu muc Bai_4 va cac file theo huong dan README."
fi

# 4.2. Kiem tra docker-compose.yml Bai_4
COMPOSE_FILE_4="./Bai_4/docker-compose.yml"
if [ -f "$COMPOSE_FILE_4" ]; then
    pass "4.2. File docker-compose.yml da ton tai trong Bai_4."

    # Kiem tra co 2 version app (blue va green)
    if grep -q "blue" "$COMPOSE_FILE_4" && grep -q "green" "$COMPOSE_FILE_4"; then
        pass "4.2.1. Co 2 app services: blue va green (Blue-Green pattern)."
    else
        fail "4.2.1. THIEU 2 app services (blue va green)." "Blue-Green can 2 version app chay dong thoi: app-blue (production) va app-green (version moi)."
    fi

    # Kiem tra co Nginx router
    if grep -q "nginx" "$COMPOSE_FILE_4"; then
        pass "4.2.2. Co Nginx router de dieu huong traffic giua Blue va Green."
    else
        fail "4.2.2. THIEU Nginx router." "Can Nginx lam router de chuyen traffic tu Blue sang Green ma khong downtime."
    fi

    # Kiem tra app co healthcheck
    if grep -q "healthcheck" "$COMPOSE_FILE_4"; then
        pass "4.2.3. App services co healthcheck — dam bao Green duoc kiem tra truoc khi nhan traffic."
    else
        warn "4.2.3. App services nen co healthcheck de kiem tra Green da san sang truoc khi switch traffic."
    fi

    # Kiem tra 2 version khac nhau (APP_VERSION)
    BLUE_VER=$(grep -A5 "app-blue" "$COMPOSE_FILE_4" | grep "APP_VERSION" | grep -oE "v[0-9.]+" | head -n 1)
    GREEN_VER=$(grep -A5 "app-green" "$COMPOSE_FILE_4" | grep "APP_VERSION" | grep -oE "v[0-9.]+" | head -n 1)
    if [ ! -z "$BLUE_VER" ] && [ ! -z "$GREEN_VER" ] && [ "$BLUE_VER" != "$GREEN_VER" ]; then
        pass "4.2.4. Blue ($BLUE_VER) va Green ($GREEN_VER) co version khac nhau — de phan biet khi test."
    else
        warn "4.2.4. Blue va Green nen co APP_VERSION khac nhau de phan biet khi switch traffic."
    fi
else
    fail "4.2. Khong tim thay docker-compose.yml trong Bai_4." "Tao file docker-compose.yml theo huong dan README."
fi

# 4.3. Kiem tra nginx.conf
NGINX_CONF="./Bai_4/nginx.conf"
if [ -f "$NGINX_CONF" ]; then
    pass "4.3. File nginx.conf da ton tai."

    # Kiem tra co upstream block
    if grep -q "upstream" "$NGINX_CONF"; then
        pass "4.3.1. Co upstream block — Nginx co the dieu huong traffic."

        # Kiem tra hien tai dang tro vao ai
        if grep -v "^#" "$NGINX_CONF" | grep -q "app-blue"; then
            info "4.3.2. Hien tai traffic dang di vao BLUE (production)."
        elif grep -v "^#" "$NGINX_CONF" | grep -q "app-green"; then
            info "4.3.2. Hien tai traffic dang di vao GREEN (version moi)."
        fi
    else
        fail "4.3.1. THIEU upstream block trong nginx.conf." "Can upstream de dinh nghia backend server va de dang switch giua Blue/Green."
    fi

    # Kiem tra co proxy_pass
    if grep -q "proxy_pass" "$NGINX_CONF"; then
        pass "4.3.3. Co proxy_pass — Nginx dang lam reverse proxy."
    else
        fail "4.3.3. THIEU proxy_pass trong nginx.conf." "Them 'proxy_pass http://app_backend;' de Nginx chuyen request den app."
    fi
else
    fail "4.3. Khong tim thay file nginx.conf trong Bai_4." "Tao file nginx.conf voi upstream block de switch traffic giua Blue va Green."
fi

# 4.4. Kiem tra Blue-Green stack dang chay
BG_RUNNING=$(sudo docker compose -f "$COMPOSE_FILE_4" ps --format "{{.Name}}" 2>/dev/null | head -n 1)
if [ ! -z "$BG_RUNNING" ]; then
    pass "4.4. Blue-Green stack dang chay."
    sudo docker compose -f "$COMPOSE_FILE_4" ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null

    # Kiem tra Nginx router phuc vu
    ROUTER_PORT=$(sudo docker compose -f "$COMPOSE_FILE_4" port router 80 2>/dev/null | cut -d: -f2)
    if [ ! -z "$ROUTER_PORT" ]; then
        ROUTER_RESPONSE=$(curl -s --connect-timeout 3 http://localhost:$ROUTER_PORT/ 2>/dev/null | head -n 5)
        if [ ! -z "$ROUTER_RESPONSE" ]; then
            pass "4.4.1. Nginx router dang phuc vu tren port $ROUTER_PORT."
        else
            warn "4.4.1. Nginx router khong phan hoi tren port $ROUTER_PORT."
        fi
    fi
else
    info "4.4. Blue-Green stack chua chay. Chay: cd Bai_4 && sudo docker compose up -d --build"
fi


# =============================================
# BAI 5: Auto-test va Trivy tong hop
# =============================================
echo -e "${BLUE}--- Bai 5: Auto-test va Trivy trong Pipeline — Tong hop ---${NC}"

# 5.1. Kiem tra thu muc Bai_5
if [ -d "./Bai_5" ]; then
    pass "5.1. Thu muc Bai_5 da ton tai."
else
    fail "5.1. Khong tim thay thu muc Bai_5." "Tao thu muc Bai_5 va cac file theo huong dan README."
fi

# 5.2. Kiem tra app.py Bai_5
if [ -f "./Bai_5/app.py" ]; then
    pass "5.2. File app.py da ton tai trong Bai_5."

    # Kiem tra co nhieu endpoint cho testing
    ENDPOINT_COUNT=$(grep -cE "def handle_|/health|/api/" "./Bai_5/app.py")
    if [ "$ENDPOINT_COUNT" -ge 3 ]; then
        pass "5.2.1. App co nhieu endpoint ($ENDPOINT_COUNT) cho auto-testing: /, /health, /api/info."
    else
        warn "5.2.1. App nen co nhieu endpoint de test day du: / (root), /health, /api/info, /unknown (404)."
    fi

    # Kiem tra co JSON response
    if grep -q "json" "./Bai_5/app.py"; then
        pass "5.2.2. App co JSON response — de auto-test parse va verify."
    else
        warn "5.2.2. Nen tra ve JSON response cho /health va /api/info de auto-test co the parse."
    fi
else
    fail "5.2. Khong tim thay file app.py trong Bai_5." "Tao file app.py voi day du endpoint theo huong dan README."
fi

# 5.3. Kiem tra Dockerfile Bai_5
DOCKERFILE_5="./Bai_5/Dockerfile"
if [ -f "$DOCKERFILE_5" ]; then
    pass "5.3. File Dockerfile da ton tai trong Bai_5."

    # Kiem tra toan bo best practices
    BEST_PRACTICE_COUNT=0

    if grep -q "^HEALTHCHECK" "$DOCKERFILE_5"; then
        ((BEST_PRACTICE_COUNT++))
    fi
    if grep -q "^USER " "$DOCKERFILE_5"; then
        ((BEST_PRACTICE_COUNT++))
    fi
    if grep -q "adduser\|useradd" "$DOCKERFILE_5"; then
        ((BEST_PRACTICE_COUNT++))
    fi
    if grep -q "chown" "$DOCKERFILE_5"; then
        ((BEST_PRACTICE_COUNT++))
    fi
    if grep -qE "alpine|slim|jre" "$DOCKERFILE_5"; then
        ((BEST_PRACTICE_COUNT++))
    fi
    if grep -q "ENTRYPOINT" "$DOCKERFILE_5"; then
        ((BEST_PRACTICE_COUNT++))
    fi

    if [ "$BEST_PRACTICE_COUNT" -ge 5 ]; then
        pass "5.3.1. Dockerfile ap dung $BEST_PRACTICE_COUNT/6 best practices (HEALTHCHECK, non-root, chown, slim image, ENTRYPOINT)."
    else
        warn "5.3.1. Dockerfile ap dung $BEST_PRACTICE_COUNT/6 best practices. Nen them: HEALTHCHECK, USER, chown, base image nho."
    fi
else
    fail "5.3. Khong tim thay Dockerfile trong Bai_5." "Tao file Dockerfile ap dung tat ca best practices Day 7 + Day 8."
fi

# 5.4. Kiem tra test.sh
TEST_SCRIPT="./Bai_5/test.sh"
if [ -f "$TEST_SCRIPT" ]; then
    pass "5.4. File test.sh (auto-test script) da ton tai."

    # Kiem tra co set -e
    if grep -q "set -e" "$TEST_SCRIPT"; then
        pass "5.4.1. test.sh co 'set -e' — script se fail ngay khi mot test loi (quan trong cho CI/CD)."
    else
        fail "5.4.1. test.sh THIEU 'set -e'." "Them 'set -e' vao dau script. Khong co no, script se tiep tuc chay bat ke test co fail, va luon tra exit code 0 (success)."
    fi

    # Kiem tra so luong test cases
    TEST_CASE_COUNT=$(grep -cE "Test [0-9]|echo.*Test" "$TEST_SCRIPT" 2>/dev/null || echo "0")
    if [ "$TEST_CASE_COUNT" -ge 3 ]; then
        pass "5.4.2. test.sh co $TEST_CASE_COUNT test cases — du day de kiem tra ung dung."
    else
        warn "5.4.2. test.sh chi co $TEST_CASE_COUNT test case(s). Nen co it nhat 3: root endpoint, health endpoint, 404 handling."
    fi

    # Kiem tra co kiem tra HTTP status code
    if grep -qE "http_code|HTTP_CODE" "$TEST_SCRIPT"; then
        pass "5.4.3. test.sh kiem tra HTTP status code — khong chi test 'co phan hoi' ma con test 'phan hoi dung'."
    else
        warn "5.4.4. test.sh nen kiem tra HTTP status code cu the (200, 404) thay vi chi kiem tra co phan hoi."
    fi

    # Kiem tra co kiem tra JSON format
    if grep -qE "json\.load|jq|python.*json" "$TEST_SCRIPT"; then
        pass "5.4.4. test.sh kiem tra JSON format cua response — dam bao API tra ve dung cau truc."
    else
        warn "5.4.4. test.sh nen kiem tra JSON format cua /health response (vd: 'status' field = 'healthy')."
    fi
else
    fail "5.4. Khong tim thay file test.sh trong Bai_5." "Tao file test.sh voi auto-test script theo huong dan README."
fi

# 5.5. Kiem tra test.sh da duoc chay thanh cong
if [ -f "./Bai_5/test.sh" ]; then
    TEST_CONTAINER=$(sudo docker ps --format "{{.Names}}" | grep "test-container" | head -n 1)
    if [ ! -z "$TEST_CONTAINER" ]; then
        pass "5.5. Container 'test-container' dang chay — san sang de chay auto-test."
        info "5.5.1. Chay auto-test: cd Bai_5 && ./test.sh"
    else
        info "5.5. Chua chay container test. Build va chay theo huong dan Bai 5 README."
    fi
fi


# =============================================
# CAU HOI SUY NGAM
# =============================================
echo -e "${BLUE}--- Cau hoi suy ngam ---${NC}"

README_FILE="./README.md"
if [ -f "$README_FILE" ]; then
    ANSWER_COUNT=$(grep -c "> Tra loi:" "$README_FILE")
    EMPTY_COUNT=$(grep -c "> Tra loi: *$" "$README_FILE")
    FILLED_COUNT=$((ANSWER_COUNT - EMPTY_COUNT))

    if [ "$FILLED_COUNT" -ge 3 ]; then
        pass "Da tra loi $FILLED_COUNT/$ANSWER_COUNT cau hoi suy ngam."
    elif [ "$FILLED_COUNT" -gt 0 ]; then
        info "Moi tra loi $FILLED_COUNT/$ANSWER_COUNT cau hoi. Hay dien them vao phan '> Tra loi:' trong README."
    else
        info "Chua tra loi cau hoi suy ngam nao. Hay dien vao phan '> Tra loi:' trong README."
    fi
fi


# =============================================
# TONG KET
# =============================================
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}TONG KET DAY 8${NC}"
echo -e "  ${GREEN}PASS${NC}: $PASS_COUNT"
echo -e "  ${RED}FAIL${NC}: $FAIL_COUNT"
echo -e "  ${YELLOW}WARN${NC}: $WARN_COUNT"
echo -e ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Tuyet voi! Ban da nhan manh kien thuc CI/CD Advanced va Deployment Strategies!${NC}"
else
    echo -e "${YELLOW}Con $FAIL_COUNT muc chua dat. Hay xem [NGUYEN NHAN] va sua lai.${NC}"
fi

echo -e "${BLUE}=============================================${NC}"
