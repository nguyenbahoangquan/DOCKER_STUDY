#!/bin/bash

# Script verify bài tập Day 3

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 3 ===${NC}"

# 1. Kiểm tra image my-java-app tồn tại
if docker images | grep -q "my-java-app"; then
    echo -e "[${GREEN}PASS${NC}] 1. Image 'my-java-app' đã được build thành công."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy image 'my-java-app'."
fi

# 2. Kiểm tra output của container
OUTPUT=$(docker run --rm my-java-app 2>&1)
if [[ "$OUTPUT" == *"Hello from Dockerized Java!"* ]]; then
    echo -e "[${GREEN}PASS${NC}] 2. Container 'my-java-app' chạy và in đúng output."
else
    echo -e "[${RED}FAIL${NC}] 2. Output của container không chính xác."
fi

# 3. Kiểm tra .dockerignore (khuyến khích người học tạo)
if [ -f "/home/quanswl24/Working/DOCKER_STUDY/Day03_Dockerfile/.dockerignore" ]; then
    echo -e "[${GREEN}PASS${NC}] 3. File .dockerignore đã tồn tại."
else
    echo -e "[${BLUE}INFO${NC}] 3. Chưa thấy file .dockerignore (Không bắt buộc nhưng nên có)."
fi

echo -e "${BLUE}===================================${NC}"
