#!/bin/bash

# Script verify bài tập Day 6

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 6 ===${NC}"

# 1. Kiểm tra xem có image nào được tag là 'optimized' hoặc tương tự không
# (Hỏi người học đặt tên image mới để phân biệt)
if docker images | grep -q "java-app-optimized" || docker images | grep -q "my-java-app"; then
    echo -e "[${GREEN}PASS${NC}] 1. Image Java đã được build."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy image Java để kiểm tra."
fi

# 2. Kiểm tra multi-stage build (thông qua image history)
# Nếu có lệnh COPY --from thì đó là multi-stage
if docker history my-java-app 2>/dev/null | grep -q "COPY --from"; then
    echo -e "[${GREEN}PASS${NC}] 2. Xác nhận đã sử dụng Multi-stage Build."
else
    echo -e "[${BLUE}INFO${NC}] 2. Không phát hiện 'COPY --from'. Hãy đảm bảo bạn đã dùng Multi-stage!"
fi

echo -e "${BLUE}===================================${NC}"
