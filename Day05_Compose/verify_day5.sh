#!/bin/bash

# Script verify bài tập Day 5

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 5 ===${NC}"

# 1. Kiểm tra file docker-compose.yml tồn tại
if [ -f "/home/quanswl24/Working/DOCKER_STUDY/Day05_Compose/docker-compose.yml" ]; then
    echo -e "[${GREEN}PASS${NC}] 1. File 'docker-compose.yml' đã được tạo."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy file 'docker-compose.yml'."
fi

# 2. Kiểm tra các service đang chạy qua compose
# Lưu ý: Chạy lệnh này tại folder của compose
cd /home/quanswl24/Working/DOCKER_STUDY/Day05_Compose
if docker compose ps | grep -q "web"; then
    echo -e "[${GREEN}PASS${NC}] 2. Services trong Compose đang hoạt động."
else
    echo -e "[${RED}FAIL${NC}] 2. Services chưa được khởi động (Dùng 'docker compose up -d')."
fi

# 3. Kiểm tra biến môi trường .env (Nếu có làm Bài 2)
if [ -f "/home/quanswl24/Working/DOCKER_STUDY/Day05_Compose/.env" ]; then
    echo -e "[${GREEN}PASS${NC}] 3. File '.env' đã được tạo."
else
    echo -e "[${BLUE}INFO${NC}] 3. Chưa thấy file '.env' (Không bắt buộc)."
fi

echo -e "${BLUE}===================================${NC}"
