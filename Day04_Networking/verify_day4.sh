#!/bin/bash

# Script verify bài tập Day 4

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 4 ===${NC}"

# 1. Kiểm tra network my-custom-net
if docker network ls | grep -q "my-custom-net"; then
    echo -e "[${GREEN}PASS${NC}] 1. Network 'my-custom-net' đã được tạo."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy network 'my-custom-net'."
fi

# 2. Kiểm tra volume mysql-data
if docker volume ls | grep -q "mysql-data"; then
    echo -e "[${GREEN}PASS${NC}] 2. Volume 'mysql-data' đã được tạo."
else
    echo -e "[${RED}FAIL${NC}] 2. Không tìm thấy volume 'mysql-data'."
fi

# 3. Kiểm tra container web-server trong network
if docker ps --format '{{.Names}}' | grep -q "web-server"; then
    echo -e "[${GREEN}PASS${NC}] 3. Container 'web-server' đang chạy."
else
    echo -e "[${RED}FAIL${NC}] 3. Container 'web-server' chưa chạy."
fi

echo -e "${BLUE}===================================${NC}"
