<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${quiz.title} - QuizMaster" />
<c:set var="activePage" value="quiz" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="max-width: 680px; margin: 20px auto 50px;">
    <!-- Nút Quay lại -->
    <div style="margin-bottom: 20px;">
        <a href="${pageContext.request.contextPath}/quiz" style="color: var(--text-secondary); text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px;">
            <i class="fas fa-chevron-left"></i> Quay lại kho đề
        </a>
    </div>

    <!-- Khối thẻ trung tâm thông tin đề thi (Theo phong cách phòng thi chuẩn) -->
    <div class="card" style="padding: 36px 32px; border-radius: 14px; box-shadow: var(--shadow-lg); background: var(--bg-surface); border: 1px solid var(--border-color);">
        <!-- Tiêu đề đề thi -->
        <h2 style="font-size: 1.85rem; font-weight: 800; text-align: center; margin: 0 0 10px; color: var(--text-primary); line-height: 1.3;">
            <c:out value="${quiz.title}" />
        </h2>

        <!-- Mã đề thi -->
        <div style="display: flex; justify-content: center; align-items: center; gap: 8px; color: var(--text-secondary); font-size: 0.95rem; margin-bottom: 28px;">
            <span>Mã đề thi: <strong style="color: var(--primary);">#${quiz.id}</strong></span>
            <i class="fas fa-qrcode" style="font-size: 1.1rem; color: var(--text-muted);" title="Mã đề trực tuyến"></i>
        </div>

        <c:if test="${not empty quiz.description}">
            <p style="text-align: center; color: var(--text-secondary); font-size: 0.95rem; line-height: 1.6; margin: 0 0 24px; padding: 0 10px;">
                <c:out value="${quiz.description}" />
            </p>
        </c:if>

        <form action="${pageContext.request.contextPath}/quiz-take" method="GET" id="startExamForm">
            <input type="hidden" name="id" value="${quiz.id}">

            <!-- Danh sách hàng thông số chi tiết -->
            <div style="display: flex; flex-direction: column; gap: 16px; margin-bottom: 28px; border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); padding: 20px 8px;">
                <!-- 1. Thời gian làm bài -->
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                    <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                        <i class="far fa-clock" style="width: 18px;"></i> Thời gian làm bài
                    </span>
                    <strong style="color: var(--text-primary);">
                        <c:choose>
                            <c:when test="${quiz.timeLimit <= 0}">Không giới hạn</c:when>
                            <c:otherwise>${quiz.timeLimit} phút</c:otherwise>
                        </c:choose>
                    </strong>
                </div>

                <!-- 2. Thời gian vào thi -->
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                    <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                        <i class="far fa-calendar-alt" style="width: 18px;"></i> Thời gian vào thi
                    </span>
                    <strong style="color: var(--text-primary);">Không thời hạn (Tự do)</strong>
                </div>

                <!-- 3. Số lượng câu hỏi -->
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                    <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                        <i class="far fa-question-circle" style="width: 18px;"></i> Số lượng câu hỏi
                    </span>
                    <strong style="color: var(--text-primary); font-size: 1.05rem;">${quiz.questionCount} câu</strong>
                </div>

                <!-- 4. Loại đề -->
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                    <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                        <i class="far fa-file-alt" style="width: 18px;"></i> Loại đề
                    </span>
                    <strong style="color: var(--text-primary);">Trắc nghiệm khách quan</strong>
                </div>

                <!-- 5. Tổng lượt đã làm của đề -->
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                    <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-users" style="width: 18px;"></i> Tổng lượt đã làm của đề
                    </span>
                    <strong style="color: var(--text-primary);">${quiz.attemptCount} lượt</strong>
                </div>

                <!-- 6. Số lượt thi tối đa cho phép -->
                <c:if test="${quiz.maxAttempts > 0}">
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                        <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-redo-alt" style="width: 18px;"></i> Số lượt thi tối đa
                        </span>
                        <strong style="color: #ef4444;">${quiz.maxAttempts} lần</strong>
                    </div>
                </c:if>

                <!-- 7. Giám sát thi chống chuyển tab -->
                <c:if test="${quiz.antiCheat}">
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.95rem;">
                        <span style="color: var(--text-secondary); display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-shield-alt" style="width: 18px; color: #ef4444;"></i> Giám sát thi
                        </span>
                        <span class="badge badge-warning" style="font-size: 0.78rem;">Phát hiện rời màn hình</span>
                    </div>
                </c:if>
            </div>

            <!-- Nếu đề yêu cầu mật khẩu -->
            <c:if test="${quiz.hasAccessCode()}">
                <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: var(--radius-md); padding: 16px; margin-bottom: 24px;">
                    <label style="display: block; font-weight: 700; color: #92400e; font-size: 0.9rem; margin-bottom: 8px;">
                        <i class="fas fa-key"></i> Đề thi yêu cầu Mật khẩu phòng thi:
                    </label>
                    <input type="password" name="accessCode" class="form-control" placeholder="Nhập mã pin hoặc mật khẩu..." required autofocus>
                </div>
            </c:if>

            <!-- Nút chính: Bắt đầu thi (Màu cam nổi bật chuẩn Entrance) -->
            <button type="submit" class="btn btn-block btn-lg" style="background: #ea580c; border-color: #ea580c; color: #ffffff; font-size: 1.15rem; font-weight: 700; padding: 14px; border-radius: 8px; box-shadow: 0 4px 14px rgba(234, 88, 12, 0.35); transition: all 0.2s ease;">
                Bắt đầu thi <i class="fas fa-chevron-right" style="font-size: 0.95rem; margin-left: 6px;"></i>
            </button>
        </form>

        <!-- Nút phụ: Xem lịch sử làm bài & Chia sẻ link -->
        <div style="display: flex; justify-content: center; gap: 12px; margin-top: 24px; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/history?quizId=${quiz.id}" class="btn btn-outline" style="font-size: 0.92rem; padding: 8px 18px;">
                <i class="fas fa-history"></i> Xem lịch sử làm bài
            </a>
            <button type="button" class="btn btn-outline" onclick="copyQuizShareLink('${quiz.id}')" style="font-size: 0.92rem; padding: 8px 18px;">
                <i class="fas fa-share-alt"></i> Lấy link chia sẻ đề thi
            </button>
        </div>

        <div id="copyToast" style="display: none; text-align: center; margin-top: 14px; color: #16a34a; font-weight: 700; font-size: 0.88rem; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 8px 14px; border-radius: 6px;">
            <i class="fas fa-check-circle"></i> Đã sao chép link đề thi vào bộ nhớ tạm! Bạn có thể gửi link này cho thí sinh.
        </div>

        <!-- Tùy chọn Bảng xếp hạng (Chỉ hiển thị khi Tác giả BẬT tính năng này VÀ người dùng ĐÃ LÀM bài này rồi) -->
        <c:if test="${quiz.showRanking and userHasAttempted}">
            <div style="text-align: center; margin-top: 14px; font-size: 0.85rem;">
                <a href="${pageContext.request.contextPath}/leaderboard?quizId=${quiz.id}" style="color: var(--text-muted); text-decoration: underline;">
                    <i class="fas fa-trophy"></i> Xem bảng xếp hạng bài thi này
                </a>
            </div>
        </c:if>
    </div>
</div>

<script>
    function copyQuizShareLink(id) {
        const url = window.location.origin + '${pageContext.request.contextPath}/quiz?id=' + id;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(url).then(function() {
                const toast = document.getElementById('copyToast');
                if (toast) {
                    toast.style.display = 'block';
                    setTimeout(() => toast.style.display = 'none', 3500);
                }
            }).catch(function() {
                prompt('Sao chép liên kết đề thi bên dưới:', url);
            });
        } else {
            prompt('Sao chép liên kết đề thi bên dưới:', url);
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
