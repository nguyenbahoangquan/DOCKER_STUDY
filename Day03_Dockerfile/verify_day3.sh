#!/bin/bash

# Script verify bài tập Day 3 (Root Cause Analysis)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra bài tập Day 3: Dockerfile Deep Dive ===${NC}"

# --- Bài 1 & 4: Java App & Caching ---
echo -e "${BLUE}--- Bài 1 & 4: Java App & Caching ---${NC}"
if docker images --format '{{.Repository}}' | grep -q "^my-java-app$"; then
    echo -e "[${GREEN}PASS${NC}] 1. Image 'my-java-app' đã được build."
    OUTPUT=$(docker run --rm my-java-app 2>&1)
    if [[ "$OUTPUT" == *"Hello from Dockerized Java!"* ]]; then
        echo -e "[${GREEN}PASS${NC}]    -> Container chạy và in output đúng."
    else
        echo -e "[${RED}FAIL${NC}]    -> Container chạy nhưng output sai."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} File Hello.java có nội dung không khớp yêu cầu hoặc quá trình biên dịch (javac) gặp lỗi."
    fi
else
    echo -e "[${RED}FAIL${NC}] 1. Thiếu image 'my-java-app'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Lệnh 'docker build' chưa được thực hiện hoặc Dockerfile trong thư mục java-app bị lỗi cú pháp."
fi

# --- Bài 2: CMD vs ENTRYPOINT ---
echo -e "${BLUE}--- Bài 2: CMD vs ENTRYPOINT ---${NC}"
if docker images --format '{{.Repository}}' | grep -q "^test-cmd$"; then
    echo -e "[${GREEN}PASS${NC}] 2.1. Image 'test-cmd' đã được build."
    if [[ "$(docker run --rm test-cmd 2>/dev/null)" == "Hello World" ]]; then
        echo -e "[${GREEN}PASS${NC}] 2.2. Output mặc định đúng (Hello World)."
    else
        echo -e "[${RED}FAIL${NC}] 2.2. Sai output mặc định."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Chỉ thị CMD trong Dockerfile chưa được thiết lập đúng giá trị 'World'."
    fi
    
    if [[ "$(docker run --rm test-cmd Docker 2>/dev/null)" == "Hello Docker" ]]; then
        echo -e "[${GREEN}PASS${NC}] 2.3. Ghi đè tham số (CMD) thành công."
    else
        echo -e "[${RED}FAIL${NC}] 2.3. Không thể ghi đè tham số."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Có thể bạn đang dùng ENTRYPOINT dạng 'Shell form' thay vì 'Exec form', khiến nó không nhận tham số truyền vào."
    fi
else
    echo -e "[${RED}FAIL${NC}] 2.1. Thiếu image 'test-cmd'."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn chưa thực hiện build cho bài tập Bài 2."
fi

# --- Bài 3: .dockerignore ---
echo -e "${BLUE}--- Bài 3: .dockerignore ---${NC}"
DOCKERIGNORE="/home/quanswl24/Working/DOCKER_STUDY/Day03_Dockerfile/java-app/.dockerignore"
if [ -f "$DOCKERIGNORE" ] && grep -q "*.log" "$DOCKERIGNORE"; then
    echo -e "[${GREEN}PASS${NC}] 3. .dockerignore đã cấu hình loại bỏ *.log."
else
    echo -e "[${RED}FAIL${NC}] 3. .dockerignore chưa đúng cấu hình."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} File .dockerignore thiếu dòng '*.log' hoặc file này đặt sai vị trí (phải nằm cùng cấp với Dockerfile)."
fi

# --- Bài 5: ADD vs COPY ---
echo -e "${BLUE}--- Bài 5: ADD vs COPY ---${NC}"
if docker images | grep -q "test-add"; then
    if docker run --rm test-add ls 2>/dev/null | grep -q "Hello.java"; then
        echo -e "[${GREEN}PASS${NC}] 5. ADD đã tự động giải nén file tar thành công."
    else
        echo -e "[${RED}FAIL${NC}] 5. File tar chưa được giải nén."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn có thể đã dùng lệnh 'COPY' thay vì 'ADD', hoặc file nguồn không phải là định dạng tar/gzip chuẩn."
    fi
else
    echo -e "[${YELLOW}INFO${NC}] 5. Chưa tìm thấy image 'test-add' để kiểm tra."
fi

# --- Bài 6: Secrets ---
echo -e "${BLUE}--- Bài 6: Secrets ---${NC}"
if docker images | grep -q "secret-test"; then
    if ! docker history secret-test | grep -q "my_super_secret"; then
        echo -e "[${GREEN}PASS${NC}] 6.1. BuildKit Secret thành công (Secret không lộ trong history)."
    else
        echo -e "[${RED}FAIL${NC}] 6.1. Secret bị lộ trong history!"
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn đã dùng lệnh 'RUN echo' thông thường thay vì sử dụng '--mount=type=secret'."
    fi
fi

if docker images | grep -q "multi-stage-test"; then
    if ! docker history multi-stage-test | grep -q "MY_KEY="; then
        echo -e "[${GREEN}PASS${NC}] 6.2. Multi-stage build thành công (ARG không bị lộ ở Stage cuối)."
    else
        echo -e "[${RED}FAIL${NC}] 6.2. ARG vẫn bị lộ trong history."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Stage cuối cùng của bạn vẫn chứa lệnh liên quan đến ARG, hoặc bạn chưa tách Stage 'builder' và 'final' rõ rệt."
    fi
fi

echo -e "${BLUE}===================================${NC}"
