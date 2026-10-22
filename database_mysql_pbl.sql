-- ========================================================
-- CƠ SỞ DỮ LIỆU: HỆ THỐNG THI TRẮC NGHIỆM TRỰC TUYẾN (QUIZ MASTER)
-- NỀN TẢNG: Java Servlet / JSP - MVC - MySQL 8.0
-- ĐỀ TÀI BÀI TẬP NHÓM MÔN CÔNG NGHỆ WEB
-- ========================================================

CREATE DATABASE IF NOT EXISTS `quiz_system` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `quiz_system`;

-- Tắt kiểm tra khóa ngoại để khởi tạo lại bảng sạch sẽ
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `support_tickets`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `favorites`;
DROP TABLE IF EXISTS `attempt_answers`;
DROP TABLE IF EXISTS `attempts`;
DROP TABLE IF EXISTS `questions`;
DROP TABLE IF EXISTS `quizzes`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- 1. BẢNG NGƯỜI DÙNG (users)
-- ========================================================
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `avatar_url` VARCHAR(255) DEFAULT 'default-avatar.png',
    `role` ENUM('ADMIN', 'TEACHER', 'STUDENT') NOT NULL DEFAULT 'STUDENT',
    `current_streak` INT NOT NULL DEFAULT 0 COMMENT 'Chuỗi ngày học liên tục',
    `last_active_date` DATE DEFAULT NULL COMMENT 'Ngày gần nhất tham gia thi/học',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 2. BẢNG DANH MỤC / CHỦ ĐỀ THI (categories)
-- ========================================================
CREATE TABLE `categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT DEFAULT NULL,
    `icon` VARCHAR(50) DEFAULT 'book',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 3. BẢNG ĐỀ THI (quizzes)
-- ========================================================
CREATE TABLE `quizzes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `category_id` INT NOT NULL,
    `creator_id` INT NOT NULL,
    `time_limit` INT NOT NULL DEFAULT 15 COMMENT 'Thời gian làm bài tính bằng phút',
    `difficulty` ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL DEFAULT 'MEDIUM',
    `is_public` BOOLEAN NOT NULL DEFAULT TRUE COMMENT '1: Công khai, 0: Riêng tư',
    `cover_image` VARCHAR(255) DEFAULT 'default-quiz-cover.jpg',
    `shuffle_questions` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đảo thứ tự câu hỏi khi thi',
    `shuffle_options` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đảo thứ tự các đáp án A/B/C/D',
    `show_answers` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Cho phép xem đáp án sau khi nộp bài',
    `access_code` VARCHAR(50) DEFAULT NULL COMMENT 'Mật khẩu/Mã pin vào phòng thi',
    `max_attempts` INT NOT NULL DEFAULT 0 COMMENT 'Số lần thi tối đa (0: không giới hạn)',
    `anti_cheat` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Bật giám sát phát hiện chuyển tab',
    `show_ranking` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Cho phép thí sinh xem bảng xếp hạng đề thi',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_quiz_category` FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_quiz_creator` FOREIGN KEY (`creator_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 4. BẢNG CÂU HỎI (questions)
-- ========================================================
CREATE TABLE `questions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `quiz_id` INT NOT NULL,
    `question_text` TEXT NOT NULL,
    `option_a` TEXT NOT NULL,
    `option_b` TEXT NOT NULL,
    `option_c` TEXT NOT NULL,
    `option_d` TEXT NOT NULL,
    `correct_option` ENUM('A', 'B', 'C', 'D') NOT NULL,
    `points` INT NOT NULL DEFAULT 1 COMMENT 'Trọng số/Điểm của câu',
    `explanation` TEXT DEFAULT NULL COMMENT 'Lời giải thích đáp án khi xem lại kết quả',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_question_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 5. BẢNG LƯỢT THI / PHIÊN THI (attempts)
-- ========================================================
CREATE TABLE `attempts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `quiz_id` INT NOT NULL,
    `start_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `end_time` TIMESTAMP NULL DEFAULT NULL,
    `status` ENUM('IN_PROGRESS', 'COMPLETED', 'ABANDONED') NOT NULL DEFAULT 'IN_PROGRESS',
    `score` DOUBLE NOT NULL DEFAULT 0.0 COMMENT 'Điểm số thang 10',
    `correct_answers` INT NOT NULL DEFAULT 0 COMMENT 'Số câu trả lời đúng',
    `total_questions` INT NOT NULL DEFAULT 0 COMMENT 'Tổng số câu của đề thi',
    `time_spent` INT NOT NULL DEFAULT 0 COMMENT 'Thời gian thực tế làm bài (giây)',
    `tab_switches` INT NOT NULL DEFAULT 0 COMMENT 'Số lần chuyển tab/rời màn hình thi (Azota Anti-cheat)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_attempt_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_attempt_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 6. BẢNG CHI TIẾT ĐÁP ÁN BÀI THI (attempt_answers)
-- ========================================================
CREATE TABLE `attempt_answers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `attempt_id` INT NOT NULL,
    `question_id` INT NOT NULL,
    `selected_option` ENUM('A', 'B', 'C', 'D') DEFAULT NULL COMMENT 'NULL nếu học viên không chọn',
    `is_correct` BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT `fk_ans_attempt` FOREIGN KEY (`attempt_id`) REFERENCES `attempts`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ans_question` FOREIGN KEY (`question_id`) REFERENCES `questions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 7. BẢNG BỘ ĐỀ YÊU THÍCH (favorites)
-- ========================================================
CREATE TABLE `favorites` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `quiz_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_quiz_fav` (`user_id`, `quiz_id`),
    CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_fav_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 8. BẢNG ĐÁNH GIÁ & BÌNH LUẬN (reviews)
-- ========================================================
CREATE TABLE `reviews` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `quiz_id` INT NOT NULL,
    `rating` INT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
    `comment` TEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_quiz_review` (`user_id`, `quiz_id`),
    CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_review_quiz` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 9. BẢNG THÔNG BÁO (notifications)
-- ========================================================
CREATE TABLE `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `type` VARCHAR(50) NOT NULL DEFAULT 'SYSTEM' COMMENT 'SYSTEM, QUIZ, STREAK, WARNING',
    `title` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `is_read` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_notify_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 10. BẢNG YÊU CẦU TRỢ GIÚP / HỖ TRỢ (support_tickets)
-- ========================================================
CREATE TABLE `support_tickets` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL COMMENT 'NULL nếu khách vãng lai gửi',
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `subject` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `status` ENUM('PENDING', 'IN_PROGRESS', 'RESOLVED') NOT NULL DEFAULT 'PENDING',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_ticket_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- DỮ LIỆU MẪU (SEED DATA) ĐỂ TEST HỆ THỐNG
-- ========================================================

-- Mật khẩu mặc định cho các tài khoản là '123456' 
-- (BCrypt hash: $2a$10$wK1Wk9m0d40KzB8YvI0JmeW4u1K4f9mQeQz1eU9p6N9Xy2Ue6M1S2)
INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `full_name`, `role`, `current_streak`, `last_active_date`) VALUES
(1, 'admin', 'admin@quizmaster.edu.vn', '$2a$10$e8R6.yW96cRkM1P0k.K8n.mY2P5s.hE6N7o8k7Y3n3l4V5c6X7y8Z', 'Quản trị viên Hệ thống', 'ADMIN', 15, CURDATE()),
(2, 'teacher_ha', 'ha.mai@quizmaster.edu.vn', '$2a$10$e8R6.yW96cRkM1P0k.K8n.mY2P5s.hE6N7o8k7Y3n3l4V5c6X7y8Z', 'Thầy Mai Văn Hà', 'TEACHER', 12, CURDATE()),
(3, 'minhphat', 'minhphat@student.edu.vn', '$2a$10$e8R6.yW96cRkM1P0k.K8n.mY2P5s.hE6N7o8k7Y3n3l4V5c6X7y8Z', 'Nguyễn Minh Phát', 'STUDENT', 5, CURDATE()),
(4, 'hoangnam', 'hoangnam@student.edu.vn', '$2a$10$e8R6.yW96cRkM1P0k.K8n.mY2P5s.hE6N7o8k7Y3n3l4V5c6X7y8Z', 'Lê Hoàng Nam', 'STUDENT', 3, SUBDATE(CURDATE(), 1)),
(5, 'thuytrang', 'thuytrang@student.edu.vn', '$2a$10$e8R6.yW96cRkM1P0k.K8n.mY2P5s.hE6N7o8k7Y3n3l4V5c6X7y8Z', 'Trần Thụy Trang', 'STUDENT', 8, CURDATE());

-- Danh mục bài học
INSERT INTO `categories` (`id`, `name`, `description`, `icon`) VALUES
(1, 'Lập trình Java & JSP/Servlet', 'Kiến thức cốt lõi về Java Core, Servlet Lifecycle, JSP, JSTL và kiến trúc MVC', 'code'),
(2, 'Cơ sở dữ liệu MySQL', 'Truy vấn SQL, Indexing, Khóa chính, Khóa ngoại, Transaction và chuẩn hóa dữ liệu', 'database'),
(3, 'Công nghệ Web Frontend', 'HTML5, CSS3, JavaScript ES6, Responsive Design và DOM manipulation', 'layout'),
(4, 'Mạng máy tính & Bảo mật Web', 'Mô hình OSI, TCP/IP, Giao thức HTTP/HTTPS, Session, Cookie và chống tấn công XSS/SQLi', 'shield-check');

-- Đề thi
INSERT INTO `quizzes` (`id`, `title`, `description`, `category_id`, `creator_id`, `time_limit`, `difficulty`, `is_public`) VALUES
(1, 'Ôn tập Kiến thức Java Web & MVC', 'Bộ đề tổng hợp kiến thức về vòng đời Servlet, JSP Taglib và mô hình MVC trong Java Web.', 1, 2, 10, 'MEDIUM', TRUE),
(2, 'Truy vấn & Thiết kế Cơ sở dữ liệu MySQL 8.0', 'Kiểm tra kỹ năng viết câu lệnh DDL, DML, JOIN và tối ưu hóa câu truy vấn.', 2, 2, 15, 'HARD', TRUE),
(3, 'Cốt lõi HTML5 & JavaScript căn bản', 'Bộ câu hỏi trắc nghiệm nền tảng dành cho sinh viên mới tiếp cận môn Công nghệ Web.', 3, 3, 10, 'EASY', TRUE);

-- Câu hỏi cho Đề 1 (Java Web & MVC)
INSERT INTO `questions` (`quiz_id`, `question_text`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `points`, `explanation`) VALUES
(1, 'Trong kiến trúc MVC của ứng dụng Java Web, Servlet đóng vai trò là thành phần nào?', 'Model', 'View', 'Controller', 'Service', 'C', 1, 'Servlet tiếp nhận Request từ Client, điều phối dữ liệu qua Model/DAO và chuyển tiếp kết quả đến View (JSP). Do đó Servlet đóng vai trò là Controller.'),
(1, 'Phương thức nào trong Servlet được gọi đúng MỘT lần duy nhất khi Servlet được nạp vào bộ nhớ Web Container?', 'service()', 'init()', 'doGet()', 'destroy()', 'B', 1, 'Phương thức init() chỉ được gọi một lần duy nhất trong suốt vòng đời của Servlet khi Servlet được khởi tạo.'),
(1, 'Thẻ thư viện JSTL nào sau đây được sử dụng để duyệt qua một danh sách (List/Collection) trong file JSP?', '<c:out>', '<c:choose>', '<c:if>', '<c:forEach>', 'D', 1, 'Thẻ <c:forEach items="${list}" var="item"> trong JSTL core dùng để lặp qua tập hợp dữ liệu.'),
(1, 'Để chuyển tiếp một Request từ Servlet sang trang JSP kèm theo dữ liệu mà không làm thay đổi URL trên trình duyệt, lập trình viên sử dụng phương thức nào?', 'response.sendRedirect()', 'request.getRequestDispatcher().forward()', 'request.setAttribute()', 'response.getWriter().write()', 'B', 1, 'RequestDispatcher.forward() chuyển hướng xử lý nội bộ phía server, giữ nguyên dữ liệu trong request scope và không làm đổi URL trình duyệt.'),
(1, 'Đối tượng ngầm định (Implicit Object) nào trong JSP được dùng để lưu trữ thông tin đăng nhập của người dùng qua nhiều request khác nhau?', 'request', 'response', 'session', 'application', 'C', 1, 'HttpSession (đối tượng session) duy trì trạng thái đăng nhập của người dùng trong suốt phiên làm việc.');

-- Câu hỏi cho Đề 2 (MySQL)
INSERT INTO `questions` (`quiz_id`, `question_text`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `points`, `explanation`) VALUES
(2, 'Từ khóa nào trong MySQL được sử dụng để lọc kết quả dựa trên các hàm tổng hợp (Aggregate Functions như COUNT, AVG, SUM)?', 'WHERE', 'HAVING', 'GROUP BY', 'ORDER BY', 'B', 1, 'Mệnh đề HAVING được dùng để lọc dữ liệu sau khi đã gom nhóm (GROUP BY) và áp dụng các hàm tổng hợp.'),
(2, 'Cơ chế nào của MySQL đảm bảo tính toàn vẹn dữ liệu theo nguyên tắc ACID?', 'Indexing', 'Transactions (Giao dịch)', 'View', 'Trigger', 'B', 1, 'Transactions (Giao dịch) với COMMIT và ROLLBACK đảm bảo 4 thuộc tính ACID: Atomicity, Consistency, Isolation, Durability.'),
(2, 'Trong JDBC, đối tượng nào được khuyến nghị sử dụng để thực thi câu lệnh SQL có tham số nhằm chống tấn công SQL Injection?', 'Statement', 'PreparedStatement', 'CallableStatement', 'Connection', 'B', 1, 'PreparedStatement biên dịch trước câu lệnh SQL và dùng tham số dấu hỏi (?), ngăn chặn hoàn toàn việc chèn mã độc SQL Injection.');

-- Thêm một số lượt thi mẫu
INSERT INTO `attempts` (`id`, `user_id`, `quiz_id`, `start_time`, `end_time`, `status`, `score`, `correct_answers`, `total_questions`, `time_spent`) VALUES
(1, 3, 1, DATE_SUB(NOW(), INTERVAL 120 MINUTE), DATE_SUB(NOW(), INTERVAL 112 MINUTE), 'COMPLETED', 10.0, 5, 5, 480),
(2, 4, 1, DATE_SUB(NOW(), INTERVAL 1440 MINUTE), DATE_SUB(NOW(), INTERVAL 1432 MINUTE), 'COMPLETED', 8.0, 4, 5, 510),
(3, 5, 1, DATE_SUB(NOW(), INTERVAL 30 MINUTE), DATE_SUB(NOW(), INTERVAL 22 MINUTE), 'COMPLETED', 10.0, 5, 5, 450);

-- Chi tiết đáp án bài thi mẫu
INSERT INTO `attempt_answers` (`attempt_id`, `question_id`, `selected_option`, `is_correct`) VALUES
(1, 1, 'C', TRUE),
(1, 2, 'B', TRUE),
(1, 3, 'D', TRUE),
(1, 4, 'B', TRUE),
(1, 5, 'C', TRUE);

-- Đánh giá mẫu
INSERT INTO `reviews` (`user_id`, `quiz_id`, `rating`, `comment`) VALUES
(3, 1, 5, 'Đề thi rất sát với nội dung lý thuyết môn học Java Web của thầy Hà!'),
(4, 1, 4, 'Câu hỏi về Servlet Lifecycle rất hay và bẫy.');

-- Yêu thích mẫu
INSERT INTO `favorites` (`user_id`, `quiz_id`) VALUES
(3, 1),
(4, 1),
(5, 2);

-- Thông báo mẫu
INSERT INTO `notifications` (`user_id`, `type`, `title`, `message`, `is_read`) VALUES
(3, 'QUIZ', 'Hoàn thành bài thi', 'Bạn đã xuất sắc đạt 10.0 điểm trong bài thi Ôn tập Kiến thức Java Web & MVC!', FALSE),
(3, 'STREAK', 'Duy trì chuỗi học tập', 'Chúc mừng bạn đã đạt chuỗi 5 ngày học liên tục!', TRUE);
