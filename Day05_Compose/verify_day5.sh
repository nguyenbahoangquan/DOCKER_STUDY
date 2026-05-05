#!/bin/bash

# Script verify bài tập Day 5 (Follow Architecture of Day 04 - Improved Regex)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra chi tiết bài tập Day 5: Docker Compose ===${NC}"

# Kiểm tra quyền sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}[WARN] Hãy chạy script bằng 'sudo ./verify_day5.sh' để có kết quả chính xác nhất.${NC}"
fi

# --- Bài 1: Dựng stack Web + Cache + DB ---
echo -e "${BLUE}--- Bài 1: Cấu trúc Docker Compose Stack ---${NC}"

# 1.1. Kiểm tra file cấu hình
COMPOSE_FILE="./docker-compose.yml"
if [ -f "$COMPOSE_FILE" ]; then
    echo -e "[${GREEN}PASS${NC}] 1.1. File 'docker-compose.yml' đã được tạo."
else
    echo -e "[${RED}FAIL${NC}] 1.1. Không tìm thấy file 'docker-compose.yml'."
    exit 1
fi

# 1.2. Kiểm tra các Services
SERVICES=$(docker compose config --services 2>/dev/null)
for s in web cache db; do
    if echo "$SERVICES" | grep -q "^$s$"; then
        echo -e "[${GREEN}PASS${NC}] 1.2. Service '$s' đã được định nghĩa."
    else
        echo -e "[${RED}FAIL${NC}] 1.2. Thiếu service '$s' trong file cấu hình."
    fi
done

# 1.3. Kiểm tra Port Mapping của Web (Dùng lệnh config cho riêng web để chính xác)
WEB_CONFIG=$(docker compose config web 2>/dev/null)
if echo "$WEB_CONFIG" | grep -q "published:"; then
    echo -e "[${GREEN}PASS${NC}] 1.3. Port mapping đã được gán chính xác cho service 'web'."
    PORT_VAL=$(echo "$WEB_CONFIG" | grep "published:" | awk '{print $2}' | xargs)
    echo -e "      ${CYAN}[INFO]${NC} Cổng đang mở trên Host: $PORT_VAL"
else
    echo -e "[${RED}FAIL${NC}] 1.3. Service 'web' chưa được mở port ra máy host."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn cần thêm mục 'ports' vào service 'web' để có thể truy cập từ bên ngoài."
fi

# 1.4. Kiểm tra Dependencies
if docker compose config | grep -q "depends_on:"; then
    echo -e "[${GREEN}PASS${NC}] 1.4. Đã cấu hình thứ tự khởi động (depends_on)."
else
    echo -e "[${RED}FAIL${NC}] 1.4. Thiếu 'depends_on' trong cấu hình."
fi


# --- Bài 2: Biến môi trường (.env) ---
echo -e "${BLUE}--- Bài 2: Quản lý cấu hình với .env ---${NC}"

if [ -f ".env" ]; then
    echo -e "[${GREEN}PASS${NC}] 2.1. File '.env' đã được tạo."
    MYSQL_VAL=$(docker compose config db | grep "MYSQL_ROOT_PASSWORD" | awk '{print $2}')
    if [ ! -z "$MYSQL_VAL" ] && [ "$MYSQL_VAL" != "\${MYSQL_PASS}" ]; then
        echo -e "[${GREEN}PASS${NC}] 2.2. Docker Compose đã nạp biến thành công từ file .env."
    else
        echo -e "[${RED}FAIL${NC}] 2.2. Docker Compose CHƯA nạp được biến môi trường."
    fi
else
    echo -e "[${RED}FAIL${NC}] 2.1. Chưa tìm thấy file '.env'."
fi


# --- Bài 3: Trạng thái vận hành (Runtime) ---
echo -e "${BLUE}--- Bài 3: Trạng thái vận hành & Scaling ---${NC}"

if docker compose ps | grep -q "Up\|Running"; then
    echo -e "[${GREEN}PASS${NC}] 3.1. Các container trong stack đang hoạt động."
    WEB_COUNT=$(docker compose ps --format '{{.Service}}' | grep "web" | wc -l)
    if [ "$WEB_COUNT" -gt 1 ]; then
        echo -e "[${GREEN}PASS${NC}] 3.2. Đã thực hiện Scaling (Đang chạy $WEB_COUNT instances của 'web')."
    else
        echo -e "[${YELLOW}INFO${NC}] 3.2. Hệ thống đang chạy ở chế độ Single-instance."
    fi
else
    echo -e "[${RED}FAIL${NC}] 3.1. Stack chưa được khởi động. Hãy dùng 'docker compose up -d'."
fi

# --- Kiểm tra Câu hỏi suy ngẫm ---
echo -e "${BLUE}--- Câu hỏi suy ngẫm ---${NC}"
if grep -q "> Trả lời: ." "README.md"; then
    echo -e "[${GREEN}PASS${NC}] Bạn đã điền câu trả lời cho các câu hỏi suy ngẫm."
else
    echo -e "[${YELLOW}INFO${NC}] Đừng quên trả lời các câu hỏi suy ngẫm trong README."
fi

echo -e "${BLUE}===========================================${NC}"
