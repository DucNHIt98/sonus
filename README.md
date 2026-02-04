## PHẦN 1: NỘI DUNG FILE README.MD

# 🚀 Flutter Clean Architecture & Automation Tooling

Dự án này áp dụng cấu trúc **Clean Architecture** chuẩn Senior, kết hợp với các công cụ tự động hóa để tối ưu hóa tốc độ phát triển và đảm bảo tính nhất quán mã nguồn.

---

## 🛠 1. Các công cụ yêu cầu (Prerequisites)

Để vận hành hệ thống tự động hóa, hãy đảm bảo bạn đã cài đặt:
* **Mason CLI**: Công cụ scaffold (đúc) cấu trúc feature.
* **Build Runner**: Công cụ tạo code tự động cho `Freezed`, `Json Serializable`, `Isar` và `Riverpod`.

---

## 🏗 2. Cách tạo một Feature mới (Auto-gen)

Thay vì tạo thủ công hàng chục thư mục và file, chúng ta sử dụng **Mason**.

### Lệnh Terminal:
Mở terminal tại thư mục gốc dự án và chạy:
```bash
mason make clean_feature --name <tên_feature_viết_thường>
```
* **Ví dụ**: mason make clean_feature --name authentication


## ⚙️ 3. Chạy Code Generation (.g.dart, .freezed.dart)

Sau khi tạo feature, bạn cần chạy build_runner để sinh ra các phần code còn thiếu.

Mở terminal tại thư mục gốc dự án và chạy:
Chế độ Watch (Khuyên dùng):
```bash
dart run build_runner watch --delete-conflicting-outputs
```

Chế độ Build (Chạy 1 lần):
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 📂 4. Cấu trúc thư mục chuẩn (Project Structure)
Mỗi Feature được chia làm 3 lớp chính:

Domain: Chứa entities (Nghiệp vụ), repositories (Interface) và usecases.

Data: Chứa models (DTO), repositories_impl (Thực thi logic) và data_sources (API/Local DB).

Presentation: Chứa pages (UI Widget) và providers (Quản lý trạng thái bằng Riverpod).


---

## PHẦN 2: CẤU HÌNH PHÍM TẮT TRÊN ANDROID STUDIO (INTERNAL USE)

Để biến Android Studio thành một cỗ máy tạo code không cần dùng Terminal, hãy làm theo các bước sau:

### 1. Thiết lập External Tool (Công cụ bên ngoài)
1.  Vào **Settings** (Mac: `Cmd + ,` | Win: `File > Settings`).
2.  Tìm đến **Tools > External Tools**. Nhấn dấu **+** để thêm:
    * **Name:** `Mason: Create Feature`
    * **Description:** Tự động tạo cấu trúc Clean Architecture cho Feature mới.
    * **Program:** `mason` (Hoặc đường dẫn tuyệt đối: `/Users/tên_user/.pub-cache/bin/mason`).
    * **Arguments:** `make clean_feature --name $Prompt$`
    * **Working directory:** `$ProjectFileDir$`
3.  Nhấn **OK**.

### 2. Gán Phím tắt (Hotkey)
1.  Vẫn trong **Settings**, chọn mục **Keymap**.
2.  Tại ô tìm kiếm, gõ: `Mason: Create Feature`.
3.  Chuột phải vào kết quả tìm thấy > chọn **Add Keyboard Shortcut**.
4.  Nhấn tổ hợp phím mong muốn (Ví dụ: `Alt + Shift + G`).
5.  Nhấn **OK**.

### 3. Cách vận hành hàng ngày của một Senior
1.  Nhấn phím tắt `Alt + Shift + G`.
2.  Nhập tên feature mới (ví dụ: `order`).
3.  Mason tự tạo folder/file -> Terminal đang chạy `build_runner watch` tự gen code liên quan.
4.  Bắt đầu code logic ngay lập tức mà không tốn 1 giây nào cho việc khởi tạo.



---