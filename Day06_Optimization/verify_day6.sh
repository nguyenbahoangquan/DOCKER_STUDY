#!/bin/bash

# Script verify bài tập Day 6 (Debug & Optimization - RCA Style)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra chi tiết bài tập Day 6: Debug & Optimization ===${NC}"

# Kiểm tra quyền sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}[WARN] Hãy chạy script bằng 'sudo ./verify_day6.sh' để có kết quả chính xác nhất.${NC}"
fi

# --- Bài 1: Multi-stage Build & Image Size ---
echo -e "${BLUE}--- Bài 1: Multi-stage Build & Image Optimization ---${NC}"

DOCKERFILE="./Bai_1/Dockerfile"
if [ -f "$DOCKERFILE" ]; then
    echo -e "[${GREEN}PASS${NC}] 1.1. Đã tìm thấy file 'Dockerfile' trong thư mục Bai_1."
    
    # 1.2. Kiểm tra Multi-stage pattern
    STAGE_COUNT=$(grep -c "^FROM" "$DOCKERFILE")
    if [ "$STAGE_COUNT" -gt 1 ]; then
        echo -e "[${GREEN}PASS${NC}] 1.2. Dockerfile sử dụng Multi-stage build ($STAGE_COUNT stages)."
    else
        echo -e "[${RED}FAIL${NC}] 1.2. Dockerfile chỉ có 1 stage."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Multi-stage yêu cầu ít nhất 2 lệnh FROM."
    fi

    # 1.3. Kiểm tra Base Image ở stage cuối
    LAST_FROM=$(grep "^FROM" "$DOCKERFILE" | tail -n 1)
    if echo "$LAST_FROM" | grep -qE "slim|alpine|distroless|jre"; then
        echo -e "[${GREEN}PASS${NC}] 1.3. Stage cuối sử dụng base image tối ưu ($LAST_FROM)."
    else
        echo -e "[${YELLOW}WARN${NC}] 1.3. Stage cuối nên dùng '-slim' hoặc '-alpine' để giảm size."
    fi

    # 1.4. So sánh thực tế
    echo -e "      ${CYAN}[SO SÁNH KÍCH THƯỚC IMAGE]${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "java-app|optimized|java" | head -n 5
else
    echo -e "[${RED}FAIL${NC}] 1.1. Không tìm thấy file 'Dockerfile' tại ./Bai_1/Dockerfile."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn cần tạo thư mục Bai_1 và viết Dockerfile trong đó."
fi


# --- Bài 2: Layer Caching Optimization ---
echo -e "${BLUE}--- Bài 2: Layer Caching Optimization ---${NC}"

if [ -f "$DOCKERFILE" ]; then
    # Kiểm tra xem có copy file quản lý thư viện trước khi copy code không
    if grep -qE "COPY.*pom\.xml|COPY.*package\.json" "$DOCKERFILE"; then
        LINE_POM=$(grep -nE "COPY.*pom\.xml|COPY.*package\.json" "$DOCKERFILE" | head -n 1 | cut -d: -f1)
        LINE_CODE=$(grep -nE "COPY \.|COPY src" "$DOCKERFILE" | head -n 1 | cut -d: -f1)
        
        if [ ! -z "$LINE_CODE" ] && [ "$LINE_POM" -lt "$LINE_CODE" ]; then
            echo -e "[${GREEN}PASS${NC}] 2.1. Đã tối ưu Layer Caching (Dependencies đặt trước Code)."
        else
            echo -e "[${RED}FAIL${NC}] 2.1. Thứ tự Layer chưa tối ưu."
            echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn nên COPY pom.xml TRƯỚC KHI COPY src để tận dụng Cache khi sửa code."
        fi
    else
        echo -e "[${YELLOW}INFO${NC}] 2.1. Không tìm thấy lệnh copy file dependencies. Bỏ qua kiểm tra caching."
    fi
fi


# --- Bài 3: Network Troubleshooting Lab ---
echo -e "${BLUE}--- Bài 3: Network Debugging Lab (MySQL & Alpine) ---${NC}"

# 3.1. Kiểm tra sự tồn tại của các container lab
if docker ps -a --format '{{.Names}}' | grep -q "db-server" && docker ps -a --format '{{.Names}}' | grep -q "my-app"; then
    echo -e "[${GREEN}PASS${NC}] 3.1. Đã khởi tạo các container lab (db-server, my-app)."
    
    # 3.2. Kiểm tra kết nối Network
    if docker inspect my-app | grep -q "\"db-net\":"; then
        echo -e "[${GREEN}PASS${NC}] 3.2. Container 'my-app' đã được nối vào network 'db-net' thành công."
        
        # 3.3. Thử nghiệm kết nối thực tế
        echo -ne "      -> Đang kiểm tra DNS/Port... "
        # Thử ping hoặc curl (nếu container đã cài)
        if docker exec my-app ping -c 1 db-server >/dev/null 2>&1 || docker exec my-app curl -s --connect-timeout 2 db-server:3306 >/dev/null 2>&1; then
             echo -e "[${GREEN}SUCCESS${NC}]"
             echo -e "      ${CYAN}[KẾT LUẬN]${NC} Bạn đã thực hiện đúng quy trình Debug và Fix mạng!"
        else
             echo -e "[${RED}FAIL${NC}] Cổng kết nối vẫn chưa thông."
             echo -e "      ${CYAN}[DEBUG]${NC} Đảm bảo container db-server đang chạy và my-app có thể phân giải DNS."
        fi
    else
        echo -e "[${RED}FAIL${NC}] 3.2. Container 'my-app' CHƯA được nối vào network 'db-net'."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} 2 container đang nằm ở 2 mạng khác nhau nên không thấy nhau."
        echo -e "      ${CYAN}[FIX]${NC} Chạy lệnh: docker network connect db-net my-app"
    fi
else
    echo -e "[${YELLOW}INFO${NC}] 3.1. Chưa tìm thấy các container lab. Hãy thực hiện thiết lập ở Bài 3 trong README."
fi

# --- Kiểm tra Câu hỏi suy ngẫm ---
echo -e "${BLUE}--- Câu hỏi suy ngẫm ---${NC}"
README_FILE="README.md"
if [ -f "$README_FILE" ]; then
    if grep -q "> Trả lời: ." "$README_FILE"; then
        echo -e "[${GREEN}PASS${NC}] Bạn đã điền câu trả lời cho các câu hỏi suy ngẫm."
    else
        echo -e "[${YELLOW}INFO${NC}] Đừng quên trả lời các câu hỏi cuối README để củng cố kiến thức tối ưu hóa Image."
    fi
fi

echo -e "${BLUE}===========================================${NC}"
