#!/bin/bash

# Script verify bài tập Day 7

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 7 ===${NC}"

# 1. Kiểm tra cấu trúc thư mục GitHub Actions
if [ -d "/home/quanswl24/Working/DOCKER_STUDY/.github/workflows" ]; then
    echo -e "[${GREEN}PASS${NC}] 1. Cấu trúc folder GitHub Actions đã được tạo."
else
    echo -e "[${BLUE}INFO${NC}] 1. Chưa thấy folder .github/workflows."
fi

# 2. Kiểm tra non-root user (nếu có container đang chạy)
# Thử tìm container từ image Java và check user
CONTAINER_ID=$(docker ps -q --filter "ancestor=my-java-app" | head -n 1)
if [ ! -z "$CONTAINER_ID" ]; then
    USER=$(docker exec $CONTAINER_ID whoami 2>/dev/null)
    if [[ "$USER" != "root" ]]; then
        echo -e "[${GREEN}PASS${NC}] 2. Container đang chạy với user '$USER' (Non-root)."
    else
        echo -e "[${RED}FAIL${NC}] 2. Container vẫn đang chạy với quyền root."
    fi
else
    echo -e "[${BLUE}INFO${NC}] 2. Hãy chạy container từ Day 6/7 để kiểm tra non-root user."
fi

echo -e "${BLUE}===================================${NC}"
echo -e "Chúc mừng bạn đã hoàn thành 7 ngày học Docker!"
