# PROMPT TAO KHOA HOC TU HOC (STRUCTURED LEARNING ARCHITECTORY v2)

Duoi day la prompt "Master" de ban su dung. Hay copy toan bo noi dung trong khoi code duoi day va dan vao AI cua ban, sau do thay doi chu de (Topic) ma ban muon hoc.

**Cap nhat v2**: Dua tren kinh nghiem thuc te tu khoa hoc Docker 8 ngay — bo sung cau truc thu muc chi tiet, file tong hop, va workflow hoc tap thuc te.

---

```text
Ban la mot Chuyen gia Dao tao Ky thuat (Senior Technical Instructor). Hay thiet ke cho toi mot khoa hoc tu hoc ve [CHEN CHU DE VAO DAY - Vi du: Kubernetes, Python OOP, Git,...] trong vong 7 ngay (co the mo rong them neu can).

Khoa hoc phai tuan thu nghiem ngat "Kien truc Thuc hanh Nguyen tu" (Atomic Practice Architecture) voi cac yeu cau sau:

### 1. Triet ly thiet ke
- Lab-Driven: Giam ly thuyet toi da, tap trung vao thuc hanh.
- Atomic Verification: Moi bai tap phai co cach kiem tra ket qua ngay lap tuc.
- Root Cause Analysis (RCA): Script kiem tra khong chi bao Dung/Sai ma phai chi ra [NGUYEN NHAN] va goi y [DEBUG].
- Progressive Difficulty: Bai tap di tu de -> kho, moi ngay xay dung tren kien thuc ngay truoc.

### 2. Cau truc thu muc du an
Tao mot bo khung thu muc gom:

**File goc:**
- `Plan.md`: Lo trinh chi tiet 7 ngay voi muc tieu ro rang.
- `Progress.md`: Bang theo doi tien do (Checklist) + Nhat ky hoc tap chi tiet tung ngay + Tong hop kien thuc ngan gon theo tung Day.
- `REFERENCE.md`: Cheatsheet lenh/cu phap + Sai lam thuong gap (gotchas) + Debug kinh nghiem + Production/Best-practice Checklist.
- `MAINTAINER_GUIDE.md`: Huong dan cau truc du an cho cac AI Agent tiep theo.
- `Course_Generator_Prompt.md`: Prompt goc de tao khoa hoc moi (file nay).
- `Readme_Prompt.md`: Workflow quay lai hoc sau khi nghi.

**Thu muc ngay (Day01_Name/, Day02_Name/,...):**
Moi thu muc ngay phai chua:
- `README.md`: Tom tat ly thuyet cot loi (1 trang), danh sach 3-5 bai tap tu de den kho, va 3-5 cau hoi suy ngam.
- `verify_dayX.sh`: Script Bash tu dong kiem tra (RCA style).
- `Bai_1/`, `Bai_2/`,...: Thu muc bai tap chua code mau, Dockerfile, docker-compose.yml, script test, v.v.
  Moi Bai phai co: file chay duoc (khong chi code snippet), huong dan buoc buoc, va diem quan trong can hieu.

**Thu muc bo sung (neu can):**
- `.github/workflows/`: CI/CD pipeline files (neu khoa hoc lien quan DevOps).
- `.env`: Bien moi truong cho Docker Compose (luon them vao .gitignore!).

### 3. Tieu chuan Script Verify (Quan trong nhat)
Script Bash phai chuyen nghiep voi:
- Ma mau (Xanh cho PASS, Do cho FAIL, Vang cho WARN).
- Kiem tra hat nhan (Granular Checks): Kiem tra tung file, tung process, tung logic.
- Phan hoi RCA: Khi mot buoc that bai, hay in ra:
    [FAIL] <Ten buoc>
    [NGUYEN NHAN] <Giai thich tai sao loi>
    [DEBUG] <Goi y lenh hoac cach sua>

### 4. Tieu chuan README.md moi ngay
Moi README.md phai co:
- **Muc tieu bai hoc**: 3-5 bullet point ro rang.
- **Tom tat ly thuyet**: Chi cot loi, khong viet lai documentation. Dung bang (table) cho so sanh/phân biet.
- **Thuc hanh & Bai tap**: 3-5 bai, moi bai co:
  - Muc tieu ro rang
  - Huong dan buoc buoc (copy-paste chay duoc)
  - Diem quan trong can hieu (khong chi "lam gi" ma con "tai sao")
- **Cau hoi suy ngam**: 3-5 cau hoi mo, khong co dap an dung/sai — buoc suy luan.
- **Trang thai hoan thanh**: Checkbox list de danh dau tien do.

### 5. Tieu chuan Progress.md
Progress.md phai bao gom 3 phan:
- **Tong quan lo trinh**: Checklist 7 ngay voi ngay hoan thanh.
- **Tong hop kien thuc**: Ngan gon 5-7 dong moi Day — de review nhanh khong can mo lai README.
- **Nhat ky chi tiet**: Moi ngay ghi ro: Da hoan thanh gi, Kien thuc moi, Da fix gi, Chua lam gi.

### 6. Tieu chuan REFERENCE.md
REFERENCE.md phai bao gom 4 phan:
- **Cheatsheet**: Tat ca lenh, flags, cu phap hay dung (quick lookup).
- **Gotchas**: 10-15 sai lam thuong gap + cach fix (dinh kem code Sai/Dung).
- **Debug kinh nghiem**: Cac tinh huong loi thuc te + quy trinh chan doan.
- **Production/Best-practice Checklist**: Bang checklist co lenh kiem tra.

### 7. Output yeu cau ngay bay gio:
Hay bat dau bang viec tao ra noi dung cua:
1. File Plan.md (Lo trinh 7 ngay).
2. File Progress.md (Cau truc san voi checklist).
3. File REFERENCE.md (Khung san 4 phan).
4. Cau truc va noi dung chi tiet cho DAY 01 (bao gom README.md, script verify_day1.sh, va Bai_1/).

Hay giu giong van chuyen nghiep, thuc dung va tap trung vao cac tinh huong thuc te cua mot ky su.
```

---

## Huong dan su dung:
1. **Buoc 1:** Copy noi dung ben tren.
2. **Buoc 2:** Thay the cum `[CHEN CHU DE VAO DAY]` bang chu de ban muon (Vi du: `Linux Command Line`, `React Hooks`, `SQL Optimization`).
3. **Buoc 3:** AI se xuat ra cac file Markdown va Script. Ban chi can copy vao cac folder tuong ung la co ngay mot lab thuc hanh xinh xon!

---

## Cap nhat v2 so voi ban goc:

| Thay doi | Ly do |
|----------|-------|
| Them `REFERENCE.md` | Ban goc chi co Progress.md — thieu noi dung cheatsheet va sai lam. Thuc te khi review kien thuc, can 1 file quick lookup thay vi mo lai tat ca README. |
| Them thu muc `Bai_1/`, `Bai_2/` | Ban goc chi co README.md + verify script. Thuc te can code mau chay duoc (Dockerfile, app.py, docker-compose.yml) de copy-paste va thuc hanh. |
| Bo sung tieu chuan README.md | Ban goc khong quy dinh cau truc README. Thuc te moi README can muc tieu, ly thuyet, bai tap, cau hoi suy ngam, va checkbox tien do. |
| Bo sung tieu chuan Progress.md | Ban goc chi la checklist. Thuc te can them tong hop kien thuc (review nhanh) va nhat ky chi tiet tung ngay. |
| Bo sung tieu chuan REFERENCE.md | File moi — gop cheatsheet + gotchas + debug + checklist vao 1 noi. |
| Them `.env` va CI/CD | Khoa hoc DevOps luon can bien moi truong va pipeline. Can luu y .gitignore. |
| Mo rong tu 7 ngay -> "co the mo rong" | Thuc te khoa hoc Docker thanh 8 ngay vi CI/CD can 2 ngay. Khong nen cam cung 7 ngay. |
| Them `Progressive Difficulty` | Ban goc khong nhan manh tinh tich luy. Thuc te moi ngay phai xay dung tren ngay truoc (Day 5 Compose can kien thuc Day 4 Network). |
