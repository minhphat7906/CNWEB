<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Trang chủ - QuizMaster Khảo Thí Trực Tuyến" />
<c:set var="activePage" value="home" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<c:choose>
    <%-- ======================================================== --%>
    <%-- 1. BÀN LÀM VIỆC DÀNH CHO THÀNH VIÊN ĐÃ ĐĂNG NHẬP          --%>
    <%-- ======================================================== --%>
    <c:when test="${not empty sessionScope.currentUser}">
        <!-- Khối Chào mừng & Vào phòng thi nhanh -->
        <div class="card" style="padding: 28px 32px; margin-bottom: 28px; background: linear-gradient(135deg, #ffffff, #f8fafc); border-color: var(--border-color);">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 20px; margin-bottom: 24px;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
                        <span class="badge ${sessionScope.currentUser.admin ? 'badge-danger' : (sessionScope.currentUser.teacher ? 'badge-info' : 'badge-primary')}">
                            <c:choose>
                                <c:when test="${sessionScope.currentUser.admin}">Quản trị viên</c:when>
                                <c:when test="${sessionScope.currentUser.teacher}">Giảng viên</c:when>
                                <c:otherwise>Sinh viên</c:otherwise>
                            </c:choose>
                        </span>
                        <span style="font-size: 0.85rem; color: var(--text-muted);">Học kỳ 2025 - 2026</span>
                    </div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; margin: 0; color: var(--text-primary);">
                        Xin chào, ${sessionScope.currentUser.fullName}! 👋
                    </h1>
                    <p style="color: var(--text-secondary); margin-top: 6px; font-size: 0.95rem;">
                        Chào mừng bạn trở lại bàn làm việc. Nhập mã phòng thi của giáo viên hoặc chọn đề bên dưới để bắt đầu.
                    </p>
                </div>

                <div style="display: flex; align-items: center; gap: 12px;">
                    <div class="streak-badge" style="font-size: 0.95rem; padding: 8px 16px;">
                        <i class="fas fa-fire fire-icon"></i>
                        <span>Chuỗi <strong>${sessionScope.currentUser.currentStreak}</strong> ngày</span>
                    </div>
                    <c:if test="${sessionScope.currentUser.teacher or sessionScope.currentUser.admin}">
                        <a href="${pageContext.request.contextPath}/quiz-lab" class="btn btn-primary" style="height: 42px; display: inline-flex; align-items: center; gap: 8px;">
                            <i class="fas fa-plus"></i> Tạo đề thi mới
                        </a>
                    </c:if>
                </div>
            </div>

            <!-- Thanh Vào phòng thi nhanh (Fast Enter Quiz) chuẩn Azota/Quizizz -->
            <div style="background: var(--bg-page); border: 1.5px solid var(--border-color); border-radius: var(--radius-md); padding: 12px 16px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                <div style="display: flex; align-items: center; gap: 10px; color: var(--text-muted); font-size: 1.1rem; padding-left: 6px;">
                    <i class="fas fa-key" style="color: var(--primary);"></i>
                </div>
                <input type="text" id="fastQuizInput" 
                       placeholder="Nhập mã đề thi (Ví dụ: 7, 10...) hoặc dán liên kết bài thi để vào làm ngay..." 
                       style="flex: 1; min-width: 260px; border: none; background: transparent; font-size: 0.95rem; font-weight: 500; color: var(--text-primary); outline: none;"
                       onkeydown="if(event.key === 'Enter') handleFastEnter();">
                <button type="button" class="btn btn-primary btn-sm" onclick="handleFastEnter()" style="padding: 10px 22px; font-weight: 600;">
                    Vào thi ngay <i class="fas fa-arrow-right" style="margin-left: 4px;"></i>
                </button>
            </div>
        </div>

        <!-- 3 Thẻ chỉ số tinh gọn (Clean Metrics) -->
        <div class="grid grid-3" style="margin-bottom: 32px;">
            <a href="${pageContext.request.contextPath}/quiz" class="card" style="padding: 18px 22px; text-decoration: none; display: flex; align-items: center; gap: 16px;">
                <div style="width: 44px; height: 44px; border-radius: 10px; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-size: 1.2rem;">
                    <i class="fas fa-book-open"></i>
                </div>
                <div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); font-weight: 600;">Kho đề thi công khai</div>
                    <div style="font-size: 1.25rem; font-weight: 800; color: var(--text-primary);">${totalQuizzes} bộ đề</div>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/history" class="card" style="padding: 18px 22px; text-decoration: none; display: flex; align-items: center; gap: 16px;">
                <div style="width: 44px; height: 44px; border-radius: 10px; background: #dcfce7; color: #15803d; display: flex; align-items: center; justify-content: center; font-size: 1.2rem;">
                    <i class="fas fa-clipboard-check"></i>
                </div>
                <div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); font-weight: 600;">Bài thi của tôi</div>
                    <div style="font-size: 1.25rem; font-weight: 800; color: var(--text-primary);">Xem lịch sử nộp bài</div>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/profile" class="card" style="padding: 18px 22px; text-decoration: none; display: flex; align-items: center; gap: 16px;">
                <div style="width: 44px; height: 44px; border-radius: 10px; background: #fef3c7; color: #b45309; display: flex; align-items: center; justify-content: center; font-size: 1.2rem;">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); font-weight: 600;">Tài khoản & Hồ sơ</div>
                    <div style="font-size: 1.25rem; font-weight: 800; color: var(--text-primary);">@${sessionScope.currentUser.username}</div>
                </div>
            </a>
        </div>

        <!-- Danh sách Đề thi đề xuất -->
        <section style="margin-bottom: 40px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <div>
                    <h2 style="font-size: 1.35rem; font-weight: 800; color: var(--text-primary); margin: 0;">
                        Đề thi ôn tập nổi bật
                    </h2>
                    <p style="color: var(--text-muted); font-size: 0.88rem; margin-top: 4px;">Các bộ đề được biên soạn chọn lọc để bạn củng cố kiến thức</p>
                </div>
                <a href="${pageContext.request.contextPath}/quiz" class="btn btn-outline btn-sm">
                    Xem tất cả đề thi <i class="fas fa-arrow-right" style="margin-left: 4px;"></i>
                </a>
            </div>

            <div class="grid grid-3">
                <c:forEach items="${featuredQuizzes}" var="quiz">
                    <div class="card quiz-card">
                        <div>
                            <div class="quiz-card-header">
                                <div style="display: flex; gap: 6px; align-items: center; flex-wrap: wrap;">
                                    <span class="badge ${quiz.difficultyBadgeClass}">${quiz.difficultyLabel}</span>
                                    <c:if test="${quiz.hasAccessCode()}">
                                        <span class="badge badge-warning" title="Yêu cầu mã PIN phòng thi" style="font-size: 0.72rem; padding: 2px 6px;"><i class="fas fa-key"></i> Có mã</span>
                                    </c:if>
                                    <c:if test="${quiz.antiCheat}">
                                        <span class="badge badge-danger" title="Giám sát chống gian lận" style="font-size: 0.72rem; padding: 2px 6px;"><i class="fas fa-shield-alt"></i> Giám sát</span>
                                    </c:if>
                                </div>
                                <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 700;">#${quiz.id}</span>
                            </div>
                            <h3 class="quiz-card-title">
                                <a href="${pageContext.request.contextPath}/quiz?id=${quiz.id}" style="color: var(--text-primary); text-decoration: none;">
                                    ${quiz.title}
                                </a>
                            </h3>
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
                                <span><i class="fas fa-users"></i> ${quiz.attemptCount} lượt</span>
                            </div>

                            <div class="quiz-card-footer">
                                <button type="button" class="btn btn-outline btn-sm" onclick="copyQuizShareLink('${quiz.id}')" title="Sao chép link bài thi">
                                    <i class="fas fa-share-alt"></i>
                                </button>
                                <a href="${pageContext.request.contextPath}/quiz?id=${quiz.id}" class="btn btn-primary btn-sm">
                                    Vào làm bài <i class="fas fa-arrow-right" style="margin-left: 4px;"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>
    </c:when>

    <%-- ======================================================== --%>
    <%-- 2. GIAO DIỆN TRANG CHỦ DÀNH CHO KHÁCH (CHƯA ĐĂNG NHẬP)   --%>
    <%-- ======================================================== --%>
    <c:otherwise>
        <section class="card" style="padding: 48px 36px; margin-bottom: 32px; background: linear-gradient(135deg, #ffffff, #f8fafc);">
            <div style="max-width: 720px; margin: 0 auto; text-align: center;">
                <span class="badge badge-primary" style="margin-bottom: 14px; padding: 6px 14px; font-size: 0.85rem;">
                    <i class="fas fa-brain"></i> Hệ thống Khảo thí & Luyện thi Trắc nghiệm
                </span>
                <h1 style="font-size: 2.3rem; font-weight: 800; color: var(--text-primary); line-height: 1.3; margin-bottom: 12px; letter-spacing: -0.02em;">
                    Khảo Thí Thông Minh, Đánh Giá Chuẩn Xác
                </h1>
                <p style="color: var(--text-secondary); font-size: 1.05rem; line-height: 1.6; margin-bottom: 28px;">
                    Nền tảng kiểm tra trực tuyến chất lượng cao: chấm điểm an toàn tại máy chủ, giám sát chống gian lận thời gian thực và quản lý bộ đề thi chuyên sâu.
                </p>

                <!-- Thanh Vào phòng thi nhanh cho Khách -->
                <div style="background: var(--bg-page); border: 1.5px solid var(--border-color); border-radius: var(--radius-md); padding: 10px 14px; display: flex; align-items: center; gap: 10px; max-width: 580px; margin: 0 auto 28px auto; box-shadow: var(--shadow-sm);">
                    <i class="fas fa-key" style="color: var(--primary); font-size: 1.1rem; padding-left: 6px;"></i>
                    <input type="text" id="fastQuizInput" 
                           placeholder="Nhập mã đề thi (Ví dụ: 7, 10...) hoặc dán liên kết..." 
                           style="flex: 1; border: none; background: transparent; font-size: 0.95rem; font-weight: 500; outline: none; color: var(--text-primary);"
                           onkeydown="if(event.key === 'Enter') handleFastEnter();">
                    <button type="button" class="btn btn-primary btn-sm" onclick="handleFastEnter()" style="padding: 8px 18px;">
                        Vào thi ngay
                    </button>
                </div>

                <div style="display: flex; justify-content: center; gap: 12px; flex-wrap: wrap;">
                    <a href="${pageContext.request.contextPath}/quiz" class="btn btn-outline">
                        <i class="fas fa-book-open"></i> Xem tất cả kho đề (${totalQuizzes} đề)
                    </a>
                    <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-primary">
                        <i class="fas fa-sign-in-alt"></i> Đăng nhập hệ thống
                    </a>
                </div>
            </div>
        </section>

        <!-- Thẻ thông tin tài khoản mẫu phục vụ Thầy Cô chấm bài -->
        <section class="card" style="padding: 24px 28px; margin-bottom: 36px; border: 1px dashed var(--border-focus); background: #fdfefe;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h3 style="font-size: 1.05rem; font-weight: 800; color: var(--primary); margin: 0 0 6px;">
                        <i class="fas fa-info-circle"></i> Tài khoản mẫu dùng để nghiệm thu và kiểm thử (Mật khẩu: <code>123456</code>)
                    </h3>
                    <p style="color: var(--text-secondary); font-size: 0.88rem; margin: 0;">
                        • <strong>Giáo viên:</strong> <code>teacher_ha</code> (Thầy Mai Văn Hà - Soạn đề & Cài đặt khảo thí)<br>
                        • <strong>Học viên:</strong> <code>minhphat</code> (Vào thi, xem điểm & xếp hạng) &bull; <strong>Quản trị:</strong> <code>admin</code>
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-sm">
                    Đăng nhập tài khoản mẫu <i class="fas fa-arrow-right" style="margin-left: 4px;"></i>
                </a>
            </div>
        </section>
    </c:otherwise>
</c:choose>

<!-- Toast thông báo sao chép link -->
<div id="copyToast" style="display: none; position: fixed; bottom: 30px; right: 30px; z-index: 9999; background: #0f172a; color: white; padding: 12px 20px; border-radius: 8px; box-shadow: var(--shadow-lg); font-weight: 600; font-size: 0.9rem;">
    <i class="fas fa-check-circle" style="color: #10b981; margin-right: 8px;"></i> Đã sao chép link đề thi vào bộ nhớ tạm!
</div>

<script>
    function handleFastEnter() {
        const input = document.getElementById('fastQuizInput');
        if (!input) return;
        let val = input.value.trim();
        if (!val) {
            alert('Vui lòng nhập mã số đề thi (Ví dụ: 7) hoặc liên kết đề thi!');
            input.focus();
            return;
        }

        // Nếu người dùng dán cả URL (ví dụ http://localhost:8080/QuizMaster/quiz?id=7)
        if (val.includes('id=')) {
            const match = val.match(/id=(\d+)/);
            if (match && match[1]) {
                val = match[1];
            }
        } else if (val.startsWith('#')) {
            val = val.substring(1).trim();
        }

        const quizId = parseInt(val, 10);
        if (isNaN(quizId) || quizId <= 0) {
            alert('Mã đề thi không hợp lệ. Vui lòng nhập số ID của bộ đề (Ví dụ: 7, 10)!');
            return;
        }

        window.location.href = '${pageContext.request.contextPath}/quiz?id=' + quizId;
    }

    function copyQuizShareLink(id) {
        const url = window.location.origin + '${pageContext.request.contextPath}/quiz?id=' + id;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(url).then(function() {
                const toast = document.getElementById('copyToast');
                if (toast) {
                    toast.style.display = 'block';
                    setTimeout(() => toast.style.display = 'none', 3000);
                }
            });
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
