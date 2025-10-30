# 📝 Todo List App

**Todo List App** là một ứng dụng quản lý công việc được xây dựng bằng **Flutter**, mang phong cách đơn giản – trực quan – hiện đại.  
Ứng dụng giúp người dùng theo dõi, thêm, chỉnh sửa và đánh dấu hoàn thành các công việc hằng ngày một cách dễ dàng.

---

## 🌟 Giới thiệu

Ứng dụng được thiết kế dành cho những ai muốn quản lý danh sách công việc cá nhân gọn gàng và hiệu quả.  
Người dùng có thể:
- Thêm các công việc cần làm (Todo)
- Cập nhật nội dung hoặc trạng thái hoàn thành
- Xóa các công việc đã hoàn tất
- Lưu trữ dữ liệu ngay trên thiết bị (offline)

Giao diện được tối ưu theo phong cách **Material Design**, phù hợp cả trên điện thoại và máy tính bảng.

---

## 📸 Giao diện minh họa

<!-- 🖼️ Chèn hình HomePage, AddTodoPage, EditTodoPage tại đây -->
Ví dụ:

![Home Page](images/home_page.png)
![Add Todo Page](images/add_page.png)
![Edit Todo Page](images/edit_page.png)

---

## 💡 Các tính năng chính

- 🆕 **Thêm công việc mới:** Nhập tiêu đề công việc, lưu lại chỉ với một nút bấm.  
- 🗑️ **Xóa công việc:** Loại bỏ những việc đã hoàn thành hoặc không còn cần thiết.  
- ✏️ **Chỉnh sửa nội dung:** Dễ dàng cập nhật nội dung Todo mà không mất dữ liệu cũ.  
- ✅ **Đánh dấu hoàn thành:** Bật/tắt trạng thái bằng checkbox hoặc nút trạng thái.  
- 💾 **Lưu trữ cục bộ:** Dữ liệu được lưu trực tiếp trên thiết bị bằng SharedPreferences/SQLite.  
- 🔄 **Tự động làm mới:** Danh sách cập nhật ngay sau khi thao tác.  

---

## ⚙️ Công nghệ sử dụng

- **Flutter** – Framework xây dựng giao diện đa nền tảng  
- **Dart** – Ngôn ngữ lập trình chính  
- **BLoC Pattern** – Quản lý trạng thái rõ ràng, tách biệt UI và logic  
- **Clean Architecture** – Phân lớp Domain, Data, Presentation giúp dễ mở rộng và bảo trì  
- **SharedPreferences / SQLite** – Lưu dữ liệu Todo cục bộ  

---

## 🚀 Cài đặt và chạy thử

```bash
# Clone repository
git clone https://github.com/Huy2004P/todo_list_app.git
cd todo_list_app

# Cài đặt gói cần thiết
flutter pub get

# Chạy ứng dụng
flutter run
