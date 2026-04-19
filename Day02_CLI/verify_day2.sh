#!/bin/bash

# Script verify bài tập Day 2

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 2 ===${NC}"

# 1. Kiểm tra container nginx chạy ở port 8081
if docker ps --format '{{.Names}} {{.Ports}}' | grep -q "my-nginx-8081" && docker ps --format '{{.Ports}}' | grep -q "8081->80"; then
    echo -e "[${GREEN}PASS${NC}] 1. Container 'my-nginx-8081' đang chạy đúng port 8081."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy container 'my-nginx-8081' chạy ở port 8081."
fi

# 2. Kiểm tra xem user đã dùng docker logs chưa (qua lịch sử lệnh hoặc dấu vết - cái này khó kiểm tra trực tiếp nên ta check container đã từng tồn tại)
if docker ps -a | grep -q "my-nginx-8081"; then
    echo -e "[${GREEN}PASS${NC}] 2. Đã khởi tạo container cho bài tập."
else
    echo -e "[${RED}FAIL${NC}] 2. Chưa thấy container cho bài tập Day 2."
fi

# 3. Thử curl tới port 8081
if curl -s localhost:8081 | grep -q "nginx"; then
    echo -e "[${GREEN}PASS${NC}] 3. Web Server Nginx phản hồi thành công tại localhost:8081."
else
    echo -e "[${RED}FAIL${NC}] 3. Không thể kết nối tới Nginx tại localhost:8081."
fi

echo -e "${BLUE}===================================${NC}"
echo -e "Hãy đảm bảo bạn đã thử lệnh 'docker stats' và 'docker logs -f'!"
