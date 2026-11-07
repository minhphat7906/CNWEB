# 🧠 QuizMaster - Hệ Thống Thi Trắc Nghiệm & Khảo Thí Trực Tuyến

> **Đề tài Bài tập lớn / Đồ án môn học: Công nghệ Web**  
> **Khoa Công nghệ Thông tin - Trường Đại học Bách Khoa, Đại học Đà Nẵng (DUT)**  
> **Nền tảng:** Java Servlet / JSP (Java EE / Jakarta EE) &bull; Mô hình MVC &bull; MySQL 8.0 &bull; JDBC Transaction &bull; Vanilla HTML5/CSS3/JavaScript

---

## 📌 1. Giới thiệu tổng quan

**QuizMaster** là nền tảng khảo thí và thi trắc nghiệm trực tuyến được xây dựng theo chuẩn kiến trúc **MVC (Model - View - Controller)** hướng đối tượng trên nền tảng **Java Web thuần (Java Servlet & JSP)**, không sử dụng framework nặng (như Spring Boot) nhằm đáp ứng đúng chuẩn yêu cầu học phần Công nghệ Web.

Hệ thống cung cấp giải pháp toàn diện cho cả 3 đối tượng người dùng:
- **Học viên (Student):** Luyện thi trắc nghiệm theo chủ đề, xem giải thích chi tiết, duy trì chuỗi học tập (Streak), xem bảng xếp hạng (Leaderboard) và quản lý tiến độ cá nhân.
- **Giáo viên (Teacher):** Biên soạn bộ đề tương tác trong **Phòng Lab Studio**, cấu hình thời gian thi, mật khẩu phòng thi, tính năng chống gian lận (Anti-cheat), xáo trộn câu hỏi/đáp án.
- **Quản trị viên (Admin):** Quản lý người dùng, duyệt/khóa bộ đề thi, theo dõi vé hỗ trợ (Support Tickets) và thống kê hệ thống.

---

## 🏗️ 2. Kiến trúc & Cấu trúc thư mục chương trình (MVC Architecture)

Dự án áp dụng mô hình thiết kế **3 lớp (3-Tier Architecture) kết hợp MVC**:

```
Client (Browser) 
   │  ▲ (HTTP Request / Response)
   ▼  │
[ Controller: Java Servlets & Filters ]  (Điều phối nghiệp vụ, xác thực, phân quyền)
   │  ▲
   ▼  │
[ Model & DAO: JavaBeans & Data Access ]  (Xử lý logic, truy vấn CSDL qua JDBC)
   │  ▲
   ▼  │
[ Database: MySQL 8.0 / MariaDB ]  (Lưu trữ dữ liệu quan hệ, ràng buộc khóa ngoại)
```

### 📂 Cây thư mục chi tiết

```text
BaiTap_Nhom/
├── database_mysql_pbl.sql          # Kịch bản DDL & DML khởi tạo CSDL MySQL (quiz_system)
├── pom.xml                         # Cấu hình dự án Maven, dependencies (JSTL, BCrypt, MySQL Driver, Gson)
├── README.md                       # Tài liệu hướng dẫn & cấu trúc hệ thống
│
└── src/
    └── main/
        ├── java/
        │   └── com/quizmaster/
        │       ├── config/         # Cấu hình hệ thống & kết nối CSDL
        │       │   └── DBContext.java          # Quản lý JDBC Connection Pool, kết nối MySQL
        │       │
        │       ├── controller/     # [CONTROLLER] Servlets tiếp nhận & điều hướng Request
        │       │   ├── AdminServlet.java       # Quản trị hệ thống, người dùng, bộ đề, hỗ trợ
        │       │   ├── AuthServlet.java        # Đăng ký, đăng nhập, đăng xuất, lưu phiên session
        │       │   ├── HistoryServlet.java     # Lịch sử làm bài thi của học viên
        │       │   ├── HomeServlet.java        # Trang chủ, hiển thị danh mục, đề thi nổi bật
        │       │   ├── LeaderboardServlet.java # Bảng xếp hạng vinh danh học viên xuất sắc
        │       │   ├── ProfileServlet.java     # Hồ sơ cá nhân, đổi mật khẩu, xem thống kê
        │       │   ├── QuizLabServlet.java     # Phòng Lab Studio: tạo mới & cập nhật đề thi
        │       │   ├── QuizManageServlet.java  # Quản lý danh sách đề thi của giáo viên/học viên
        │       │   ├── QuizServlet.java        # Kho đề thi công khai, lọc theo danh mục & tìm kiếm
        │       │   └── TakeQuizServlet.java    # Xử lý phòng thi, tính điểm, kiểm tra đáp án
        │       │
        │       ├── dao/            # [DATA ACCESS OBJECT] Thao tác trực tiếp với MySQL qua JDBC
        │       │   ├── AttemptDAO.java         # Lưu trữ lượt thi và chi tiết đáp án câu hỏi
        │       │   ├── CategoryDAO.java        # Truy vấn danh mục chủ đề môn học
        │       │   ├── QuestionDAO.java        # Quản lý ngân hàng câu hỏi, cập nhật câu hỏi
        │       │   ├── QuizDAO.java            # Nghiệp vụ bộ đề, JDBC Transaction, cập nhật in-place
        │       │   ├── ReviewDAO.java          # Đánh giá & nhận xét bộ đề thi
        │       │   ├── TicketDAO.java          # Tiếp nhận & xử lý vé hỗ trợ kỹ thuật
        │       │   └── UserDAO.java            # Quản lý tài khoản, phân quyền, chuỗi Streak
        │       │
        │       ├── filter/         # [FILTER] Bộ lọc trung gian an ninh & mã hóa
        │       │   ├── AdminFilter.java        # Ngăn chặn truy cập trái phép vào khu vực Admin
        │       │   ├── AuthFilter.java         # Bắt buộc đăng nhập với các trang yêu cầu tài khoản
        │       │   └── EncodingFilter.java     # Đồng bộ encoding UTF-8 cho toàn bộ request/response
        │       │
        │       ├── model/          # [MODEL] Các thực thể dữ liệu (JavaBeans / POJO)
        │       │   ├── Attempt.java            # Lượt làm bài thi (điểm, thời gian, số câu đúng)
        │       │   ├── AttemptAnswer.java      # Chi tiết từng câu trả lời của học viên
        │       │   ├── Category.java           # Chủ đề môn học
        │       │   ├── Notification.java       # Thông báo hệ thống
        │       │   ├── Question.java           # Câu hỏi trắc nghiệm (nội dung, A/B/C/D, đáp án đúng)
        │       │   ├── Quiz.java               # Bộ đề thi và các thiết lập quy chế
        │       │   ├── Review.java             # Đánh giá bộ đề
        │       │   ├── SupportTicket.java      # Vé khiếu nại / hỗ trợ
        │       │   └── User.java               # Người dùng (Admin, Teacher, Student)
        │       │
        │       └── util/           # [UTILITIES] Thư viện tiện ích dùng chung
        │           ├── PasswordUtils.java      # Băm và kiểm tra mật khẩu bằng thuật toán BCrypt
        │           └── ValidationUtils.java    # Kiểm tra tính hợp lệ dữ liệu (Email, Int, chuỗi rỗng)
        │
        ├── resources/              # File cấu hình ứng dụng
        │   └── db.properties                   # Tham số cấu hình CSDL (URL, user, password)
        │
        └── webapp/                 # [VIEW & WEB ASSETS] Giao diện người dùng
            ├── index.jsp                       # Trang đón khách, chuyển hướng đến trang chủ
            │
            ├── assets/             # Tài nguyên tĩnh phía Client
            │   ├── css/
            │   │   ├── admin.css               # Giao diện Dashboard quản trị viên
            │   │   ├── arena.css               # Hiệu ứng đấu trường & làm bài thi
            │   │   └── style.css               # CSS hệ thống, layout, theme, card, responsive
            │   │
            │   ├── js/
            │   │   ├── arena.js                # Đồng hồ đếm ngược, nộp bài tự động, Anti-cheat
            │   │   ├── main.js                 # Điều khiển sidebar thu phóng, theme, toast
            │   │   └── quiz-builder.js         # Engine sinh thẻ câu hỏi động phía client an toàn
            │   │
            │   └── images/                     # Ảnh đại diện, logo, banner
            │
            └── WEB-INF/            # Thư mục an toàn (Client không thể truy cập trực tiếp file JSP)
                ├── web.xml                     # Bộ điều hướng Servlet, Filter, cấu hình Session
                │
                ├── lib/                        # Thư viện JAR phụ thuộc (JSTL, BCrypt, MySQL Driver)
                │   ├── gson-2.10.1.jar
                │   ├── jbcrypt-0.4.jar
                │   ├── jstl-1.2.jar
                │   └── mysql-connector-j-8.0.33.jar
                │
                └── views/          # [VIEW] Giao diện JSP chuẩn MVC
                    ├── history.jsp             # Lịch sử thi & kết quả chi tiết
                    ├── home.jsp                # Trang chủ trực quan, thống kê nhanh
                    ├── leaderboard.jsp         # Bảng vàng thành tích học viên
                    ├── profile.jsp             # Quản lý trang cá nhân & đổi mật khẩu
                    │
                    ├── admin/                  # Giao diện dành riêng cho Quản trị viên
                    │   ├── dashboard.jsp       # Biểu đồ & số liệu tổng quan hệ thống
                    │   ├── manage-quizzes.jsp  # Quản lý toàn bộ đề thi trong hệ sinh thái
                    │   ├── manage-tickets.jsp  # Xử lý yêu cầu hỗ trợ từ sinh viên
                    │   └── manage-users.jsp    # Quản lý người dùng, đổi quyền, khóa tài khoản
                    │
                    ├── auth/                   # Trang xác thực người dùng
                    │   ├── login.jsp           # Đăng nhập (hỗ trợ điền nhanh tài khoản mẫu)
                    │   └── register.jsp        # Đăng ký tài khoản học viên mới
                    │
                    ├── common/                 # Các thành phần giao diện tái sử dụng
                    │   ├── alerts.jsp          # Khối hiển thị thông báo thành công/thất bại
                    │   ├── footer.jsp          # Chân trang bản quyền và import script dùng chung
                    │   └── header.jsp          # Thanh điều hướng Topbar & Sidebar đồng bộ
                    │
                    └── quiz/                   # Các màn hình nghiệp vụ khảo thí
                        ├── quiz-create.jsp     # Giao diện tạo đề thi chuẩn
                        ├── quiz-detail.jsp     # Chi tiết quy chế đề thi trước khi bắt đầu
                        ├── quiz-edit.jsp       # Chỉnh sửa đề thi cơ bản
                        ├── quiz-lab.jsp        # Phòng Lab Studio: Soạn đề 2 bước tương tác
                        ├── quiz-list.jsp       # Danh sách kho đề trắc nghiệm công khai
                        ├── quiz-manage.jsp     # Bảng quản lý đề thi cá nhân
                        ├── quiz-result.jsp     # Báo cáo kết quả bài thi sau khi nộp
                        └── quiz-take.jsp       # Phòng thi thực tế với hệ thống Anti-cheat
```

---

## ⚡ 3. Các tính năng cốt lõi (Core Features)

### 3.1. Xác thực & Phân quyền đa cấp (RBAC)
- Phân tách 3 nhóm quyền rõ ràng: `ADMIN`, `TEACHER`, `STUDENT`.
- Mật khẩu lưu trong CSDL được băm 1 chiều bằng giải thuật **BCrypt** độ an toàn cao (`$2a$10$...`), chống hoàn toàn tấn công Rainbow Table.
- `AuthFilter` và `AdminFilter` tự động chặn đứng các truy cập trái phép bằng URL trực tiếp.

### 3.2. Phòng Lab Soạn Đề Tương Tác (Quiz Lab Studio)
- **Quy trình 2 bước tiện lợi:**
  - *Bước 1:* Biên soạn thông tin đề & ngân hàng câu hỏi (hỗ trợ nhập 4 đáp án A/B/C/D, chọn đáp án đúng, kèm giải thích chi tiết sau khi thi, chèn câu hỏi mẫu nhanh).
  - *Bước 2:* Thiết lập quy chế phòng thi (thời gian làm bài tính bằng phút hoặc không giới hạn, mã PIN bảo mật, số lần làm tối đa, bật/tắt giám sát thi).
- **Cơ chế cập nhật In-Place thông minh (`QuizDAO.updateQuiz`):**
  - Cập nhật trực tiếp trên câu hỏi hiện có mà không dùng lệnh `DELETE CASCADE`, giữ nguyên 100% ID câu hỏi và không làm đứt gãy dữ liệu kết quả thi trong `attempt_answers`.
  - Bảo toàn 100% dữ liệu đã soạn thảo (không bao giờ bị mất dữ liệu form khi gặp lỗi kiểm tra tính hợp lệ).

### 3.3. Phòng Thi Trực Tuyến & Giám Sát Chống Gian Lận (Azota Anti-Cheat)
- **Đếm ngược thời gian thực (Countdown Timer):**
  - Đồng hồ đếm ngược trực quan. Khi hết thời gian, hệ thống tự động khóa form và nộp bài lên Server.
  - Hỗ trợ thời gian làm bài **không giới hạn** (nhập `0` phút) dành cho mục đích tự học.
- **Xáo trộn ngẫu nhiên (Shuffle):**
  - Tùy chọn đảo ngẫu nhiên thứ tự câu hỏi (`shuffle_questions`).
  - Tùy chọn đảo ngẫu nhiên các phương án lựa chọn A, B, C, D (`shuffle_options`).
- **Giám sát chuyển tab (Anti-Cheat Surveillance):**
  - Lắng nghe sự kiện `visibilitychange` và `window.blur` khi thí sinh chuyển tab hoặc mở ứng dụng khác.
  - Hiển thị hộp thoại cảnh báo vi phạm màu đỏ, ghi nhận số lần chuyển tab vào cơ sở dữ liệu để giáo viên đánh giá tính minh bạch.

### 3.4. Điểm Danh Chuỗi Học Tập (Streak) & Bảng Xếp Hạng (Leaderboard)
- **Cơ chế Streak:** Tự động tăng chuỗi khi học viên đăng nhập và làm bài mỗi ngày liên tiếp. Nếu nghỉ quá 1 ngày (khoảng cách $\ge 2$ ngày), hệ thống tự động reset chuỗi về `0` để thúc đẩy thói quen học tập đều đặn.
- **Bảng Vinh Danh (Leaderboard):** Xếp hạng thí sinh theo điểm số đạt được (thang 10), ưu tiên thời gian làm bài ngắn hơn khi đồng điểm.

---

## 💻 4. Yêu cầu hệ thống & Hướng dẫn cài đặt

### 4.1. Yêu cầu tiên quyết (Prerequisites)
- **Java Development Kit (JDK):** Phiên bản **JDK 17, JDK 21 hoặc JDK 25**.
- **Web Server:** **Apache Tomcat 9.0.x** (hoặc Tomcat 8.5.x hỗ trợ chuẩn Java EE `javax.servlet.*`).
- **Cơ sở dữ liệu:** **MySQL Server 8.0+** hoặc **MariaDB 10.4+** (qua XAMPP).
- **Build Tool / IDE:** IntelliJ IDEA (khuyến nghị dùng plugin *Smart Tomcat*), Eclipse EE, hoặc Apache NetBeans.

---

### 4.2. Các bước triển khai chi tiết

#### Bước 1: Khởi tạo Cơ sở dữ liệu MySQL
1. Mở **XAMPP Control Panel** và bật dịch vụ **MySQL** (hoặc mở dịch vụ MySQL Service).
2. Mở công cụ quản trị CSDL (phpMyAdmin, MySQL Workbench, DBeaver, hoặc MySQL CLI).
3. Chạy toàn bộ nội dung file [`database_mysql_pbl.sql`](database_mysql_pbl.sql) có sẵn tại thư mục gốc:
   ```bash
   mysql -u root -p < database_mysql_pbl.sql
   ```
   *File SQL này sẽ tự động tạo database `quiz_system`, thiết lập 9 bảng dữ liệu quan hệ có khóa ngoại đầy đủ, và nạp sẵn dữ liệu mẫu (danh mục, người dùng, đề thi, câu hỏi trắc nghiệm).*

#### Bước 2: Cấu hình thông tin kết nối CSDL
Mở file cấu hình [`src/main/resources/db.properties`](src/main/resources/db.properties) và chỉnh sửa thông số phù hợp với MySQL của máy bạn (nếu có mật khẩu root):
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/quiz_system?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh&characterEncoding=UTF-8
db.username=root
db.password=
```
*(Nếu dùng XAMPP mặc định, `username=root` và `password` để trống).*

#### Bước 3: Build và Chạy ứng dụng

##### Cách 1: Chạy bằng IntelliJ IDEA với Smart Tomcat (Khuyến nghị)
1. Mở thư mục dự án `BaiTap_Nhom` trong IntelliJ IDEA.
2. Cài đặt plugin **Smart Tomcat** từ Marketplace (Settings $\rightarrow$ Plugins $\rightarrow$ Smart Tomcat).
3. Tạo cấu hình chạy mới (Run/Debug Configurations):
   - Chọn template: **Smart Tomcat**
   - **Tomcat Server:** Chọn đường dẫn đến thư mục cài đặt Tomcat (ví dụ `C:\apache-tomcat-9.0.96`).
   - **Deployment Directory:** Chọn thư mục `src/main/webapp`.
   - **Context Path:** `/QuizMaster-Web`
   - **Server Port:** `8080`
4. Bấm nút **Run** (mũi tên xanh) để khởi động ứng dụng.

##### Cách 2: Build gói WAR bằng Maven
Chạy lệnh sau tại thư mục gốc để biên dịch và đóng gói:
```bash
mvn clean package
```
File `QuizMaster.war` sẽ được tạo trong thư mục `target/`. Bạn chỉ cần copy file này vào thư mục `webapps/` của Apache Tomcat và khởi động server.

#### Bước 4: Truy cập ứng dụng
Mở trình duyệt web bất kỳ và truy cập theo đường dẫn:
```text
http://localhost:8080/QuizMaster-Web
```

---

## 🔑 5. Danh sách tài khoản mẫu để kiểm thử hệ thống

Tất cả các tài khoản thử nghiệm bên dưới đều có mật khẩu mặc định là: **`123456`**

| Vai trò (Role) | Tên đăng nhập (Username) | Email | Họ và tên | Chức năng nổi bật để test |
| :--- | :--- | :--- | :--- | :--- |
| 👑 **ADMIN** | `admin` | `admin@quizmaster.edu.vn` | Quản trị viên Hệ thống | Toàn quyền quản trị Dashboard, quản lý người dùng, quản lý tất cả đề thi, trả lời hỗ trợ |
| 👨‍🏫 **TEACHER** | `teacher_ha` | `ha.mai@quizmaster.edu.vn` | Thầy Mai Văn Hà | Soạn đề trong Phòng Lab Studio, xem đề thi của tôi, chỉnh sửa và tạo ngân hàng câu hỏi |
| 🎓 **STUDENT** | `minhphat` | `minhphat@student.edu.vn` | Nguyễn Minh Phát | Thi trắc nghiệm, trải nghiệm chống gian lận Anti-cheat, xem lịch sử làm bài, chuỗi Streak (5 ngày) |
| 🎓 **STUDENT** | `hoangnam` | `hoangnam@student.edu.vn` | Lê Hoàng Nam | Làm bài thi, đánh giá sao đề thi, bảng xếp hạng |
| 🎓 **STUDENT** | `thuytrang` | `thuytrang@student.edu.vn` | Trần Thụy Trang | Làm bài thi, chuỗi Streak (8 ngày), xem giải thích đáp án |

> 💡 **Mẹo:** Trang Đăng nhập (`/auth?action=login`) đã tích hợp sẵn các nút **"Điền nhanh tài khoản mẫu"** giúp thầy cô và bạn bè kiểm thử nhanh chóng chỉ với 1 click mà không cần gõ bàn phím.

---

## 📊 6. Mô hình Cơ sở Dữ liệu Quan hệ (Database Schema)

Hệ thống gồm 9 bảng được chuẩn hóa, hỗ trợ toàn vẹn tham chiếu qua Foreign Keys:

1. **`users`**: Quản lý tài khoản, mã băm mật khẩu BCrypt, vai trò (`ADMIN`, `TEACHER`, `STUDENT`), chuỗi `current_streak`, `last_active_date`.
2. **`categories`**: Danh mục môn học (Lập trình Web, Cơ sở dữ liệu, v.v.).
3. **`quizzes`**: Bộ đề thi trắc nghiệm, thời gian làm bài, độ khó, trạng thái công khai, cờ chống gian lận (`anti_cheat`), xáo trộn (`shuffle_questions`, `shuffle_options`), mã bảo vệ (`access_code`).
4. **`questions`**: Danh sách câu hỏi trắc nghiệm thuộc từng đề, 4 đáp án A/B/C/D, đáp án đúng (`correct_option`), điểm số, lời giải thích.
5. **`attempts`**: Phiên làm bài của học viên, lưu điểm số (thang 10), số câu đúng, thời gian làm thực tế (giây), số lần chuyển tab vi phạm (`tab_switches`).
6. **`attempt_answers`**: Chi tiết từng câu trả lời của học viên trong một lượt thi (lựa chọn phương án nào, đúng hay sai).
7. **`favorites`**: Bộ đề thi yêu thích được học viên đánh dấu.
8. **`reviews`**: Đánh giá số sao (1 - 5) và bình luận nhận xét về bộ đề.
9. **`support_tickets`**: Hòm thư trợ giúp và phản hồi giữa học viên với Ban quản trị.

---

## 🛠️ 7. Công nghệ sử dụng trong dự án

- **Backend:** Java Servlet 4.0, Java Server Pages (JSP), JSTL 1.2, Expression Language (EL).
- **Mã hóa & Tiện ích:** jBCrypt 0.4 (băm mật khẩu an toàn), Google Gson 2.10.1 (JSON serialization).
- **Cơ sở dữ liệu & Kết nối:** MySQL 8.0, JDBC Driver 8.0.33, JDBC Transactions.
- **Frontend:** Vanilla HTML5, Modern CSS3 (CSS Variables, Flexbox, CSS Grid), Vanilla JavaScript (ES6+), FontAwesome 5.15 Icons.
- **Kiến trúc:** Mô hình MVC thuần (Model - View - Controller), Layered Architecture (Controller $\rightarrow$ DAO $\rightarrow$ Database).

---

## 👥 8. Thông tin tác giả & Bản quyền

- **Môn học:** Công nghệ Web (Web Technology)
- **Đơn vị đào tạo:** Khoa Công nghệ Thông tin - Trường Đại học Bách Khoa, Đại học Đà Nẵng
- **Năm thực hiện:** 2026
- **Bản quyền:** Mã nguồn phục vụ mục đích học tập và nghiên cứu môn học.
