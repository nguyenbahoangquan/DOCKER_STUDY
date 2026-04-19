#!/bin/bash

# Script verify bài tập Day 1 (Updated)

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 1 ===${NC}"

# 1. Kiểm tra Docker installation
if command -v docker >/dev/null 2>&1; then
    echo -e "[${GREEN}PASS${NC}] 1. Docker đã được cài đặt."
else
    echo -e "[${RED}FAIL${NC}] 1. Không tìm thấy Docker. Hãy cài đặt Docker trước."
fi

# 2. Kiểm tra Image hello-world
if docker images | grep -q "hello-world"; then
    echo -e "[${GREEN}PASS${NC}] 2. Image hello-world đã tồn tại."
else
    echo -e "[${RED}FAIL${NC}] 2. Không tìm thấy image hello-world. Hãy chạy 'docker run hello-world'."
fi

# 3. Kiểm tra Image ubuntu
if docker images | grep -q "ubuntu"; then
    echo -e "[${GREEN}PASS${NC}] 3. Image ubuntu đã được tải về."
else
    echo -e "[${RED}FAIL${NC}] 3. Không tìm thấy image ubuntu. Hãy chạy 'docker run ... ubuntu'."
fi

# 4. Kiểm tra lịch sử container test-ubuntu
if docker ps -a | grep -q "test-ubuntu"; then
    echo -e "[${GREEN}PASS${NC}] 4. Đã từng khởi tạo container 'test-ubuntu'."
else
    echo -e "[${RED}FAIL${NC}] 4. Chưa thấy lịch sử chạy container 'test-ubuntu'. Hãy chạy 'docker run --name test-ubuntu ...'."
fi

# 5. Kiểm tra lịch sử container test-ubuntu-new
if docker ps -a | grep -q "test-ubuntu-new"; then
    echo -e "[${GREEN}PASS${NC}] 5. Đã từng khởi tạo container 'test-ubuntu-new' (Bài tập 3)."
else
    echo -e "[${RED}FAIL${NC}] 5. Chưa thấy lịch sử chạy container 'test-ubuntu-new'. Hãy hoàn thành Bài tập 3."
fi

echo -e "${BLUE}===================================${NC}"
echo -e "Lưu ý: Script này chỉ kiểm tra các dấu vết trên hệ thống."
echo -e "Hãy đảm bảo bạn đã hiểu TẠI SAO kết quả ở Bài 3 lại như vậy!"
