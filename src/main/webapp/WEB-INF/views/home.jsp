<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Trang chủ - QuizMaster Khảo Thí Trực Tuyến" />
<c:set var="activePage" value="home" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<c:choose>
    <%-- ======================================================== --%>
    <%-- 1. GIAO DIỆN BÀN LÀM VIỆC DÀNH CHO THÀNH VIÊN ĐÃ ĐĂNG NHẬP --%>
    <%-- ======================================================== --%>
    <c:when test="${not empty sessionScope.currentUser}">
        <div style="margin-bottom: 32px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; background: linear-gradient(135deg, #eef2ff, #f8fafc); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 28px 32px; box-shadow: var(--shadow-sm);">
                <div>
                    <span class="badge ${sessionScope.currentUser.admin ? 'badge-danger' : (sessionScope.currentUser.teacher ? 'badge-info' : 'badge-primary')}" style="margin-bottom: 8px;">
                        <i class="fas fa-user-tag"></i> Vai trò: ${sessionScope.currentUser.role}
                    </span>
                    <h1 style="font-size: 2rem; font-weight: 800; margin: 0; color: var(--text-primary);">
                        Xin chào, ${sessionScope.currentUser.fullName}! 👋
                    </h1>
                    <p style="color: var(--text-secondary); margin-top: 6px; font-size: 0.95rem;">
                        Chào mừng bạn quay trở lại Bàn làm việc. Hãy tiếp tục duy trì chuỗi học tập hôm nay nhé!
                    </p>
                </div>

                <div style="text-align: right;">
                    <div class="streak-badge" style="font-size: 1.1rem; padding: 8px 18px;">
                        <i class="fas fa-fire fire-icon"></i>
                        <span>Chuỗi ${sessionScope.currentUser.currentStreak} ngày liên tục</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4 Khối chức năng thao tác nhanh (Quick Actions) -->
        <section style="margin-bottom: 40px;">
            <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 16px; color: var(--primary);">
                <i class="fas fa-bolt"></i> Lối tắt chức năng
            </h3>

            <div class="grid grid-4">
                <!-- Phím 1: Vào thi -->
                <a href="${pageContext.request.contextPath}/quiz" class="card" style="text-decoration: none; display: flex; align-items: center; gap: 16px; padding: 20px;">
                    <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                        <i class="fas fa-play"></i>
                    </div>
                    <div>
                        <h4 style="font-size: 1rem; font-weight: 700; color: var(--text-primary); margin: 0;">Kho Đề Thi</h4>
                        <span style="font-size: 0.82rem; color: var(--text-muted);">Khám phá và vào phòng thi</span>
                    </div>
                </a>

                <!-- Phím 2: Phòng Lab -->
                <a href="${pageContext.request.contextPath}/quiz-lab" class="card" style="text-decoration: none; display: flex; align-items: center; gap: 16px; padding: 20px; border-color: var(--border-focus);">
                    <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #fef3c7; color: #b45309; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                        <i class="fas fa-flask"></i>
                    </div>
                    <div>
                        <h4 style="font-size: 1rem; font-weight: 700; color: var(--text-primary); margin: 0;">Phòng Lab Soạn Đề</h4>
                        <span style="font-size: 0.82rem; color: var(--text-muted);">Sáng tạo câu hỏi & bộ đề</span>
                    </div>
                </a>

                <!-- Phím 3: Lịch sử làm bài -->
                <a href="${pageContext.request.contextPath}/history" class="card" style="text-decoration: none; display: flex; align-items: center; gap: 16px; padding: 20px;">
                    <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #dcfce7; color: #15803d; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                        <i class="fas fa-history"></i>
                    </div>
                    <div>
                        <h4 style="font-size: 1rem; font-weight: 700; color: var(--text-primary); margin: 0;">Lịch Sử Làm Bài</h4>
                        <span style="font-size: 0.82rem; color: var(--text-muted);">Xem lại chi tiết các bài thi đã làm</span>
                    </div>
                </a>

                <!-- Phím 4: Hồ sơ cá nhân -->
                <a href="${pageContext.request.contextPath}/profile" class="card" style="text-decoration: none; display: flex; align-items: center; gap: 16px; padding: 20px;">
                    <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #fce7f3; color: #be185d; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div>
                        <h4 style="font-size: 1rem; font-weight: 700; color: var(--text-primary); margin: 0;">Hồ Sơ Cá Nhân</h4>
                        <span style="font-size: 0.82rem; color: var(--text-muted);">Cập nhật tài khoản & mật khẩu</span>
                    </div>
                </a>
            </div>
        </section>

        <!-- Đề thi tiêu biểu cho thành viên -->
        <section style="margin-bottom: 40px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="font-size: 1.25rem; font-weight: 800; color: var(--text-primary); margin: 0;">
                    <i class="fas fa-star" style="color: #f59e0b;"></i> Đề thi gợi ý ôn tập
                </h3>
                <a href="${pageContext.request.contextPath}/quiz" class="btn btn-outline btn-sm">Xem tất cả kho đề <i class="fas fa-arrow-right"></i></a>
            </div>

            <div class="grid grid-3">
                <c:forEach items="${featuredQuizzes}" var="quiz">
                    <div class="card quiz-card">
                        <div>
                            <div class="quiz-card-header">
                                <span class="badge ${quiz.difficultyBadgeClass}">${quiz.difficultyLabel}</span>
                                <span class="badge badge-info" style="font-size: 0.75rem;">${quiz.categoryName}</span>
                            </div>
                            <h3 class="quiz-card-title">${quiz.title}</h3>
                            <p class="quiz-card-desc">${quiz.description}</p>
                        </div>

                        <div>
                            <div class="quiz-card-meta">
                                <span>
                                    <i class="far fa-clock"></i> 
                                    <c:choose>
                                        <c:when test="${quiz.timeLimit == 0}">Không giới hạn</c:when>
                                        <c:otherwise>${quiz.timeLimit} phút</c:otherwise>
                                    </c:choose>
                                </span>
                                <span><i class="fas fa-question-circle"></i> ${quiz.questionCount} câu</span>
                            </div>

                            <div class="quiz-card-footer">
                                <span style="font-size: 0.85rem; color: var(--text-secondary);">
                                    <i class="fas fa-user-edit"></i> ${quiz.creatorName}
                                </span>
                                <a href="${pageContext.request.contextPath}/quiz-take?id=${quiz.id}" class="btn btn-primary btn-sm">
                                    Vào thi <i class="fas fa-play"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>
    </c:when>

    <%-- ======================================================== --%>
    <%-- 2. GIAO DIỆN LANDING PAGE CHUẨN DÀNH CHO KHÁCH VÃNG LAI   --%>
    <%-- ======================================================== --%>
    <c:otherwise>
        <!-- Hero Section Landing Page -->
        <section class="hero-section" style="margin-top: 0; padding: 32px 0 48px;">
            <div class="hero-grid">
                    <div>
                        <span class="badge badge-primary" style="margin-bottom: 14px;">
                            <i class="fas fa-sparkles"></i> Hệ thống Khảo thí Trực tuyến MVC
                        </span>
                        <h1 class="hero-title">Đo Lường Tri Thức, Bứt Phá Giới Hạn</h1>
                        <p class="hero-subtitle">
                            Nền tảng thi trắc nghiệm trực tuyến chuẩn mực: bảo mật chấm điểm Zero-Trust, phòng Lab biên soạn đề độc lập, đồng hồ đếm ngược thời gian thực và chuỗi chuyên cần (Streak) vinh danh thành tích.
                        </p>

                        <div class="hero-actions">
                            <a href="${pageContext.request.contextPath}/quiz" class="btn btn-primary btn-lg">
                                <i class="fas fa-play"></i> Khám phá kho đề thi
                            </a>
                            <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-lg">
                                <i class="fas fa-sign-in-alt"></i> Đăng nhập hệ thống
                            </a>
                        </div>

                        <div class="hero-stats-banner">
                            <div class="hero-stat-item">
                                <h3>${totalQuizzes}+</h3>
                                <p>Bộ đề chuẩn hóa</p>
                            </div>
                            <div class="hero-stat-item">
                                <h3>${totalAttempts}+</h3>
                                <p>Lượt làm bài thi</p>
                            </div>
                            <div class="hero-stat-item">
                                <h3>${totalUsers}+</h3>
                                <p>Học viên & Giảng viên</p>
                            </div>
                        </div>
                    </div>

                    <div>
                        <!-- Thẻ Xem trước Đề thi nổi bật -->
                        <div class="hero-card-preview">
                            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
                                <span class="badge badge-success"><i class="fas fa-bolt"></i> Thử thách hôm nay</span>
                                <span class="streak-badge"><i class="fas fa-fire fire-icon"></i> Tích lũy Streak</span>
                            </div>
                            <h3 style="font-size: 1.3rem; margin-bottom: 8px;">Ôn tập Kiến thức Java Web & MVC</h3>
                            <p style="font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 16px;">
                                Bộ câu hỏi trọng tâm về vòng đời Servlet, JSP Taglib và mô hình kiến trúc MVC trong Java Web.
                            </p>
                            <div style="background: var(--bg-page); padding: 12px; border-radius: var(--radius-md); margin-bottom: 20px; font-size: 0.88rem;">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                                    <span><i class="far fa-clock"></i> Thời lượng:</span> <strong>10 phút</strong>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                                    <span><i class="fas fa-list-ol"></i> Quy mô:</span> <strong>5 câu trắc nghiệm</strong>
                                </div>
                                <div style="display: flex; justify-content: space-between;">
                                    <span><i class="fas fa-user-tie"></i> Biên soạn:</span> <strong>Thầy Mai Văn Hà</strong>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/quiz?id=1" class="btn btn-primary btn-block">
                                <i class="fas fa-arrow-right"></i> Xem chi tiết & Thi ngay
                            </a>
                        </div>
                    </div>
                </div>
        </section>

        <!-- 3 Trụ cột tính năng công nghệ -->
        <section style="margin-bottom: 48px;">
            <div style="text-align: center; max-width: 650px; margin: 0 auto 36px auto;">
                <h2 style="font-size: 1.8rem; font-weight: 800; margin-bottom: 8px;">Kiến Trúc & Điểm Nhấn Công Nghệ</h2>
                <p style="color: var(--text-secondary); font-size: 0.95rem;">Được xây dựng thuần Java Servlet / JSP tuân thủ chuẩn mô hình MVC nghiêm ngặt</p>
            </div>

            <div class="grid grid-3">
                <div class="card" style="padding: 28px;">
                    <div style="width: 52px; height: 52px; border-radius: var(--radius-md); background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 18px;">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 10px;">Bảo Mật Zero-Trust</h3>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6;">
                        Đáp án đúng và lời giải được ẩn hoàn toàn khỏi trình duyệt trong suốt thời gian làm bài, triệt tiêu nguy cơ xem trộm mã nguồn.
                    </p>
                </div>

                <div class="card" style="padding: 28px; border-color: var(--border-focus);">
                    <div style="width: 52px; height: 52px; border-radius: var(--radius-md); background: #fef3c7; color: #b45309; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 18px;">
                        <i class="fas fa-flask"></i>
                    </div>
                    <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 10px;">Phòng Lab Soạn Đề</h3>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6;">
                        Không gian sáng tạo câu hỏi trực quan với Transaction JDBC nguyên khối, gán điểm và lời giải thích tỉ mỉ cho học viên.
                    </p>
                </div>

                <div class="card" style="padding: 28px;">
                    <div style="width: 52px; height: 52px; border-radius: var(--radius-md); background: #ffedd5; color: #c2410c; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 18px;">
                        <i class="fas fa-fire"></i>
                    </div>
                    <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 10px;">Chuỗi Chuyên Cần (Streak)</h3>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6;">
                        Tự động tính chuỗi ngày học tập liên tục, thúc đẩy thói quen tự giác ôn tập và vinh danh trên Bảng vàng thành tích.
                    </p>
                </div>
            </div>
        </section>

        <!-- Thẻ Hướng dẫn Tài khoản mẫu dành cho Giảng viên -->
        <section style="background: linear-gradient(135deg, #eef2ff, #f8fafc); border: 1px dashed var(--border-focus); border-radius: var(--radius-lg); padding: 24px 32px; margin-bottom: 30px;">
            <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h3 style="color: var(--primary); font-size: 1.15rem; font-weight: 800; margin-bottom: 6px;">
                        <i class="fas fa-info-circle"></i> Tài khoản mẫu dùng để nghiệm thu và chấm bài (Mật khẩu: <code>123456</code>)
                    </h3>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); margin: 0;">
                        • <strong>Giáo viên:</strong> <code>teacher_ha</code> (Thầy Mai Văn Hà - Dùng thử Phòng Lab soạn đề)
                        &bull; <strong>Học viên:</strong> <code>minhphat</code> (Vào thi & nhận điểm)
                        &bull; <strong>Quản trị:</strong> <code>admin</code> (Bảng điều khiển)
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-primary btn-sm">
                    <i class="fas fa-sign-in-alt"></i> Đăng nhập ngay
                </a>
            </div>
        </section>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
