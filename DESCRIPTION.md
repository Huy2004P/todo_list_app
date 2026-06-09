# 📝 Kế hoạch Nâng cấp Toàn diện Ứng dụng Todo List

Tài liệu này chi tiết toàn bộ kế hoạch nâng cấp, thiết kế giao diện (UI/UX), cấu trúc dữ liệu và các tính năng nâng cao cho ứng dụng **Todo List App** sử dụng Flutter, Clean Architecture và BLoC.

---

## 🌟 Định hướng Thiết kế & Trải nghiệm Người dùng (UI/UX)
Để biến ứng dụng thành một sản phẩm cao cấp, thu hút người dùng ngay từ cái nhìn đầu tiên:
1. **Thiết kế Hiện đại (Modern & Premium Visuals):**
   - Hỗ trợ **Dark Mode** và **Light Mode** với hệ màu được phối tinh tế (kết hợp Indigo, Teal, Neon Cyan trên nền tối Deep Midnight / nền sáng Soft Gray).
   - Sử dụng **Glassmorphism** (hiệu ứng kính mờ) nhẹ nhàng trên các thẻ công việc (Card).
   - Bo góc mềm mại (Border Radius `16px` - `24px`) và bóng đổ mờ ảo (Subtle Shadows) tạo chiều sâu.
2. **Micro-Animations:**
   - Hiệu ứng chuyển cảnh mượt mà khi thêm mới, chỉnh sửa hoặc đánh dấu hoàn thành.
   - Thao tác **Swipe-to-Action** (vuốt để xóa hoặc chỉnh sửa nhanh) bằng widget `Dismissible`.
3. **Thanh Thống kê trực quan (Interactive Dashboard):**
   - Đặt ở đầu trang chủ, hiển thị tiến độ hoàn thành dưới dạng thanh Progress bar sinh động.
   - Hiển thị các ô thống kê nhanh: *Tổng số*, *Đang làm*, *Đã hoàn thành*, *Quá hạn*.

---

## 💡 Các Tính năng Nâng cấp Chi tiết

### 1. Cấu trúc Dữ liệu Nâng cao (Advanced Data Model)
Mở rộng đối tượng `TodoEntity` và `TodoModel` để hỗ trợ:
*   **Chi tiết công việc (`description`):** Cho phép ghi chú chi tiết.
*   **Mức độ ưu tiên (`priority`):** *Cao (High)*, *Trung bình (Medium)*, *Thấp (Low)*.
*   **Danh mục (`category`):** Ví dụ: *Công việc (Work)*, *Cá nhân (Personal)*, *Học tập (Education)*, *Mua sắm (Shopping)*, *Khác (Others)*.
*   **Hạn chót (`dueDate`):** Lưu ngày và giờ cần hoàn thành công việc.
*   **Danh sách công việc con (`subtasks`):** Mỗi công việc lớn có thể chứa nhiều checklist con (mỗi checklist gồm tiêu đề và trạng thái hoàn thành).
*   **Thời gian tạo (`createdAt`):** Để sắp xếp công việc theo thời gian.

### 2. Tìm kiếm, Lọc và Sắp xếp Thông minh (Search, Filter & Sort)
*   **Tìm kiếm thời gian thực (Real-time Search):** Ô tìm kiếm phía trên cùng danh sách.
*   **Bộ lọc danh mục (Category Chips):** Thanh trượt ngang chứa các danh mục để lọc nhanh công việc.
*   **Bộ lọc trạng thái & Mức độ ưu tiên:** Lọc theo công việc chưa làm/đã làm hoặc mức độ ưu tiên.
*   **Sắp xếp đa dạng (Sorting Options):** Sắp xếp theo hạn chót (Due Date), độ ưu tiên (Priority), thời gian tạo (Creation Time) hoặc bảng chữ cái.

### 3. Quản lý Trạng thái & Giao diện Cải tiến
*   **ThemeBloc:** Quản lý cấu hình sáng/tối (Dark/Light Mode) và lưu trạng thái vào SharedPreferences để giữ nguyên lựa chọn của người dùng khi mở lại ứng dụng.
*   **TaskBloc nâng cấp:** Xử lý logic tìm kiếm, lọc và sắp xếp trực tiếp trong bộ nhớ để giao diện phản hồi ngay lập tức mà không cần đọc ghi liên tục vào ổ cứng.
*   **Trang Chi tiết Công việc (Todo Details Screen):** Hiển thị đầy đủ thông tin, quản lý danh sách công việc con (Subtasks) trực tiếp.

---

## 🛠️ Thay đổi Cấu trúc File & Mã nguồn

### 1. Domain Layer (Thực thể & Nghiệp vụ)
*   **Modify** [todo_entity.dart](file:///d:/TodoApp/todo_list_app/lib/domain/entities/todo_entity.dart): Thêm các trường dữ liệu mới (`description`, `priority`, `category`, `dueDate`, `createdAt`, `subtasks`).
*   **New** `subtask_entity.dart` (hoặc định nghĩa ngay trong `todo_entity.dart`): Cấu trúc cho công việc con.
*   **Modify** Usecases (`add_todos_usecase.dart`, `update_todos_usecase.dart`, v.v.) để truyền tải đầy đủ tham số mới.

### 2. Data Layer (Mô hình & Lưu trữ)
*   **Modify** [todo_model.dart](file:///d:/TodoApp/todo_list_app/lib/data/models/todo_model.dart): Cập nhật phương thức `fromJson` và `toJson` tương thích với cấu trúc mới.
*   **Modify** [todo_local_datasource_prefs.dart](file:///d:/TodoApp/todo_list_app/lib/data/datasources/todo_local_datasource_prefs.dart): Đọc ghi dữ liệu JSON phức tạp hơn một cách an toàn.

### 3. Application Layer (Quản lý trạng thái BLoC)
*   **Modify** [task_bloc.dart](file:///d:/TodoApp/todo_list_app/lib/application/bloc/task_bloc.dart) & [task_state.dart](file:///d:/TodoApp/todo_list_app/lib/application/bloc/task_state.dart) & [task_event.dart](file:///d:/TodoApp/todo_list_app/lib/application/bloc/task_event.dart):
    *   Thêm các sự kiện: `ChangeFilterEvent`, `ChangeSearchQueryEvent`, `ChangeSortEvent`, `ToggleSubtaskEvent`.
    *   Lưu trữ cả `allTodos` và `filteredTodos` trong state để tìm kiếm/lọc siêu nhanh.
*   **New** `theme_bloc.dart` để quản lý giao diện sáng/tối.

### 4. Presentation Layer (Giao diện)
*   **Modify** [app_theme.dart](file:///d:/TodoApp/todo_list_app/lib/core/theme/app_theme.dart): Thiết kế hệ màu sắc tối giản nhưng cao cấp cho Light & Dark Theme.
*   **Modify** [home_page.dart](file:///d:/TodoApp/todo_list_app/lib/presentation/pages/home_page.dart):
    *   Tích hợp Thanh tìm kiếm & chip danh mục.
    *   Tích hợp thanh thống kê tiến độ công việc.
    *   Sử dụng nút chuyển đổi giao diện sáng/tối ở thanh tiêu đề (AppBar).
*   **Modify** [todo_title.dart](file:///d:/TodoApp/todo_list_app/lib/presentation/widgets/todo_title.dart): Tái thiết kế card hiển thị, hiển thị tag danh mục, cờ mức độ ưu tiên, ngày hết hạn và thanh tiến độ công việc con.
*   **Modify** [add_todo_page.dart](file:///d:/TodoApp/todo_list_app/lib/presentation/pages/add_todo_page.dart) & [edit_todo_page.dart](file:///d:/TodoApp/todo_list_app/lib/presentation/pages/edit_todo_page.dart): Nâng cấp form để nhập: Ghi chú, Danh mục (Dropdown), Mức độ ưu tiên (Segmented/Chips), Ngày hết hạn (Date-Time Picker) và thêm công việc con nhanh.
*   **New** `todo_detail_page.dart`: Xem chi tiết, thêm/xóa/đánh dấu hoàn thành các subtask trực tiếp bằng danh sách checkbox.

---

## 📈 Kế hoạch Kiểm thử (Verification Plan)
*   **Kiểm thử tự động:** Chạy `flutter test` để đảm bảo code không lỗi cú pháp.
*   **Kiểm thử thủ công:**
    1. Kiểm tra lưu trữ: Thêm/sửa/xóa công việc và khởi động lại app xem dữ liệu có được giữ nguyên không.
    2. Kiểm tra bộ lọc: Chọn từng danh mục/mức độ ưu tiên xem danh sách hiển thị có đúng không.
    3. Kiểm tra Dark Mode: Chuyển đổi và đảm bảo giao diện hiển thị sắc nét, không bị lỗi màu chữ.
