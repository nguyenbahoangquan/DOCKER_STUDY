#!/bin/bash

# Script verify bài tập Day 4 (Granular Checks with Advanced Debug Hints)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== Đang kiểm tra chi tiết bài tập Day 4 ===${NC}"

# --- Bài 1: User-defined Network & DNS ---
echo -e "${BLUE}--- Bài 1: User-defined Network & DNS ---${NC}"

# 1.1. Kiểm tra network
if docker network inspect my-custom-net >/dev/null 2>&1; then
    echo -e "[${GREEN}PASS${NC}] 1.1. Network 'my-custom-net' đã được tạo."
else
    echo -e "[${RED}FAIL${NC}] 1.1. Network 'my-custom-net' chưa được tạo."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn chưa thực hiện lệnh tạo network hoặc network đã bị xóa."
fi

# 1.2. Kiểm tra container web-server
if docker ps --format '{{.Names}}' | grep -q "^web-server$"; then
    echo -e "[${GREEN}PASS${NC}] 1.2. Container 'web-server' đang chạy."
    
    # 1.3. Kiểm tra container có trong network không
    if docker inspect web-server | grep -q "\"my-custom-net\":"; then
        echo -e "[${GREEN}PASS${NC}] 1.3. 'web-server' đã kết nối vào 'my-custom-net'."
    else
        echo -e "[${RED}FAIL${NC}] 1.3. 'web-server' CHƯA kết nối vào 'my-custom-net'."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Container được chạy nhưng thiếu tham số '--network my-custom-net'."
    fi

    # 1.4. Kiểm tra DNS
    echo -ne "      -> Đang kiểm tra DNS nội bộ... "
    RESOLVED_IP=$(docker run --rm --network my-custom-net alpine sh -c "ping -c 1 web-server 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1")
    
    if [ -n "$RESOLVED_IP" ]; then
        echo -e "[${GREEN}OK${NC}] (DNS giải quyết 'web-server' -> ${RESOLVED_IP})"
        if docker run --rm --network my-custom-net alpine sh -c "apk add --no-cache curl >/dev/null && curl -s --connect-timeout 5 http://web-server" >/dev/null 2>&1; then
            echo -e "      -> [${GREEN}PASS${NC}] Kết nối HTTP tới web-server thành công."
        else
            echo -e "      -> [${RED}FAIL${NC}] DNS thông nhưng không thể kết nối HTTP."
            echo -e "         ${CYAN}[DEBUG]${NC} Hãy thử dùng 'curl -v http://web-server' bên trong container để xem chi tiết lỗi kết nối."
        fi
    else
        echo -e "[${RED}FAIL${NC}] DNS không thể giải quyết tên 'web-server'."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Docker DNS chưa kịp cập nhật hoặc cấu hình network bị lỗi."
        echo -e "      ${CYAN}[DEBUG]${NC} Sử dụng 'nslookup web-server' hoặc 'ping web-server' để kiểm tra (Xem mục Debug trong README)."
    fi
else
    echo -e "[${RED}FAIL${NC}] 1.2. Container 'web-server' chưa chạy."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Bạn chưa khởi chạy container hoặc container đã bị dừng (Exited) do lỗi."
fi


# --- Bài 2: Named Volume với MySQL ---
echo -e "${BLUE}--- Bài 2: Named Volume với MySQL ---${NC}"

# 2.1. Kiểm tra volume
if docker volume inspect mysql-data >/dev/null 2>&1; then
    echo -e "[${GREEN}PASS${NC}] 2.1. Volume 'mysql-data' đã được tạo."
else
    echo -e "[${RED}FAIL${NC}] 2.1. Volume 'mysql-data' chưa được tạo."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Volume chưa được tạo tường minh và cũng chưa có container nào khởi tạo nó qua tham số '-v'."
fi

# 2.2. Kiểm tra container my-db
if docker ps --format '{{.Names}}' | grep -q "^my-db$"; then
    echo -e "[${GREEN}PASS${NC}] 2.2. Container 'my-db' đang chạy."
    
    # 2.3. Kiểm tra mount volume
    if docker inspect my-db | grep -q "\"Name\": \"mysql-data\""; then
        echo -e "[${GREEN}PASS${NC}] 2.3. 'my-db' đã gắn volume 'mysql-data' chính xác."
    else
        echo -e "[${RED}FAIL${NC}] 2.3. 'my-db' CHƯA gắn volume 'mysql-data'."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Container đang chạy nhưng dữ liệu đang lưu tạm thời bên trong nó, không được map ra Volume ngoài."
    fi

    # 2.4. Kiểm tra biến môi trường
    if docker inspect my-db --format '{{ .Config.Env }}' | grep -q "MYSQL_ROOT_PASSWORD=root"; then
        echo -e "[${GREEN}PASS${NC}] 2.4. Đã cấu hình biến môi trường chính xác."
    else
        echo -e "[${RED}FAIL${NC}] 2.4. Thiếu hoặc sai biến MYSQL_ROOT_PASSWORD."
        echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} DB không thể khởi động nếu thiếu cấu hình bảo mật bắt buộc."
    fi
else
    echo -e "[${RED}FAIL${NC}] 2.2. Container 'my-db' chưa chạy."
    echo -e "      ${CYAN}[NGUYÊN NHÂN]${NC} Có thể do lỗi image hoặc thiếu RAM hệ thống khiến DB bị crash ngay khi start."
fi


# --- Bài 3: Bind Mount cho Frontend ---
echo -e "${BLUE}--- Bài 3: Bind Mount cho Frontend ---${NC}"

# 3.1. Kiểm tra file index.html ở host
if [ -f "index.html" ]; then
    echo -e "[${GREEN}PASS${NC}] 3.1. Đã tìm thấy file 'index.html' tại máy host."
else
    echo -e "[${RED}FAIL${NC}] 3.1. Thiếu file 'index.html' ở thư mục hiện tại."
fi

# 3.2. Kiểm tra container my-web
if docker ps --format '{{.Names}}' | grep -q "^my-web$"; then
    echo -e "[${GREEN}PASS${NC}] 3.2. Container 'my-web' đang chạy."

    # 3.3. Kiểm tra Port mapping
    if docker inspect my-web | grep -q "\"HostPort\": \"8082\""; then
        echo -e "[${GREEN}PASS${NC}] 3.3. Đã map port 8082 -> 80."
    else
        echo -e "[${RED}FAIL${NC}] 3.3. Sai Port mapping."
    fi

    # 3.4. Kiểm tra Bind Mount
    if docker inspect my-web | grep -q "\"Type\": \"bind\"" && docker inspect my-web | grep -q "/usr/share/nginx/html/index.html"; then
        echo -e "[${GREEN}PASS${NC}] 3.4. Bind mount file index.html thành công."
    else
        echo -e "[${RED}FAIL${NC}] 3.4. Chưa cấu hình Bind mount đúng file index.html."
    fi
else
    echo -e "[${RED}FAIL${NC}] 3.2. Container 'my-web' chưa chạy."
fi

# --- Kiểm tra Câu hỏi suy ngẫm ---
echo -e "${BLUE}--- Câu hỏi suy ngẫm ---${NC}"
README_FILE="README.md"
if grep -q "> Trả lời: ." "$README_FILE"; then
    echo -e "[${GREEN}PASS${NC}] Bạn đã điền câu trả lời cho các câu hỏi suy ngẫm."
else
    echo -e "[${YELLOW}INFO${NC}] Đừng quên trả lời các câu hỏi suy ngẫm ở cuối file README để củng cố kiến thức!"
fi

echo -e "${BLUE}===================================${NC}"
