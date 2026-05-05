#!/bin/bash

# Script verify bài tập Day 2 (Root Cause Analysis)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 2: Docker CLI & Port ===${NC}"

# 1. Kiểm tra container nginx
if docker ps --format '{{.Names}}' | grep -q "^my-nginx-8081$"; then
    echo -e "[${GREEN}PASS${NC}] 1. Container 'my-nginx-8081' đang chạy."
else
    echo -e "[${RED}FAIL${NC}] 1. Container 'my-nginx-8081' chưa chạy."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn chưa khởi chạy container với đúng tên yêu cầu hoặc container đã bị dừng (Exited)."
fi

# 2. Kiểm tra Port Mapping
if docker ps --format '{{.Names}} {{.Ports}}' | grep "^my-nginx-8081 " | grep -q "0.0.0.0:8081->80/tcp"; then
    echo -e "[${GREEN}PASS${NC}] 2. Port mapping (8081 -> 80) chính xác."
else
    echo -e "[${RED}FAIL${NC}] 2. Sai Port mapping."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Tham số '-p' bị sai (ví dụ dùng nhầm 80:8081 thay vì 8081:80) hoặc quên không khai báo port."
fi

# 3. Kiểm tra Web response
if curl -s --connect-timeout 2 localhost:8081 | grep -q "nginx"; then
    echo -e "[${GREEN}PASS${NC}] 3. Nginx đang phản hồi tại localhost:8081."
else
    echo -e "[${RED}FAIL${NC}] 3. Không thể kết nối HTTP tới localhost:8081."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Container có thể đang chạy nhưng service Nginx bên trong bị lỗi, hoặc tường lửa máy host đang chặn port 8081."
fi

echo -e "${BLUE}===================================${NC}"
