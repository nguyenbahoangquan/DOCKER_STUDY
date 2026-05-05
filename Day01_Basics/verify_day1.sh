#!/bin/bash

# Script verify bài tập Day 1 (Root Cause Analysis)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 1: Docker Basics ===${NC}"

# 1. Kiểm tra Docker installation
if command -v docker >/dev/null 2>&1; then
    echo -e "[${GREEN}PASS${NC}] 1. Docker đã được cài đặt."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy lệnh 'docker'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Docker Engine chưa được cài đặt trên máy hoặc chưa được thêm vào biến môi trường PATH."
fi

# 2. Kiểm tra Image hello-world
if docker images --format '{{.Repository}}' | grep -q "^hello-world$"; then
    echo -e "[${GREEN}PASS${NC}] 2. Image 'hello-world' đã tồn tại."
else
    echo -e "[${RED}FAIL${NC}] 2. Thiếu image 'hello-world'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn chưa bao giờ chạy lệnh 'docker run hello-world' hoặc đã xóa image này đi."
fi

# 3. Kiểm tra Image ubuntu
if docker images --format '{{.Repository}}' | grep -q "^ubuntu$"; then
    echo -e "[${GREEN}PASS${NC}] 3. Image 'ubuntu' đã tồn tại."
else
    echo -e "[${RED}FAIL${NC}] 3. Thiếu image 'ubuntu'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Lệnh 'docker pull ubuntu' chưa được thực hiện thành công hoặc image đã bị xóa."
fi

# 4. Kiểm tra container test-ubuntu
if docker ps -a --format '{{.Names}}' | grep -q "^test-ubuntu$"; then
    echo -e "[${GREEN}PASS${NC}] 4. Đã tìm thấy container 'test-ubuntu'."
else
    echo -e "[${RED}FAIL${NC}] 4. Không tìm thấy container 'test-ubuntu'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn chưa khởi chạy container với tham số '--name test-ubuntu' hoặc container đã bị xóa bằng 'docker rm'."
fi

# 5. Kiểm tra container test-ubuntu-new
if docker ps -a --format '{{.Names}}' | grep -q "^test-ubuntu-new$"; then
    echo -e "[${GREEN}PASS${NC}] 5. Đã tìm thấy container 'test-ubuntu-new' (Bài tập 3)."
else
    echo -e "[${RED}FAIL${NC}] 5. Thiếu container 'test-ubuntu-new'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Đây là yêu cầu của Bài tập 3 (về cơ chế thoát container), có thể bạn chưa hoàn thành bước này."
fi

echo -e "${BLUE}===================================${NC}"
