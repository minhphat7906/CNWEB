<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Kết quả bài thi: ${quiz.title} - QuizMaster" />
<c:set var="activePage" value="quiz" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Hero kết quả bài thi -->
<div class="result-hero">
    <div class="result-score-circle" style="background: ${attempt.passed ? 'linear-gradient(135deg, #10b981, #059669)' : 'linear-gradient(135deg, #f59e0b, #d97706)'};">
        <span class="score-num">${attempt.score}</span>
        <span class="score-denom">Thang điểm 10</span>
    </div>

    <h2 style="font-size: 1.8rem; font-weight: 800; margin-bottom: 8px;">
        <c:choose>
            <c:when test="${attempt.score >= 8.0}">🎉 Xuất sắc! Bạn đã làm chủ kiến thức bài học!</c:when>
            <c:when test="${attempt.passed}">👏 Chúc mừng! Bạn đã vượt qua bài kiểm tra!</c:when>
            <c:otherwise>💪 Đừng nản lòng! Hãy ôn tập lý thuyết và thử lại nhé!</c:otherwise>
        </c:choose>
    </h2>

    <p style="color: var(--text-secondary); font-size: 1rem; margin-bottom: 24px;">
        Bài thi: <strong>${quiz.title}</strong> &bull; Thí sinh: <strong>${sessionScope.currentUser.fullName}</strong>
    </p>

    <!-- Thống kê chi tiết -->
    <div class="result-stats-row" style="display: flex; justify-content: center; gap: 16px; flex-wrap: wrap;">
        <div class="result-stat-card correct">
            <h4>${attempt.correctAnswers} / ${attempt.totalQuestions}</h4>
            <p style="color: var(--text-secondary); font-size: 0.85rem; margin: 0;">Số câu đúng</p>
        </div>
        <div class="result-stat-card wrong">
            <h4>${attempt.totalQuestions - attempt.correctAnswers}</h4>
            <p style="color: var(--text-secondary); font-size: 0.85rem; margin: 0;">Số câu sai/bỏ qua</p>
        </div>
        <div class="result-stat-card time">
            <h4>${attempt.formattedTimeSpent}</h4>
            <p style="color: var(--text-secondary); font-size: 0.85rem; margin: 0;">Thời gian làm bài</p>
        </div>
        <c:if test="${quiz.antiCheat}">
            <div class="result-stat-card" style="border-color: ${attempt.tabSwitches > 0 ? '#fca5a5' : '#86efac'};">
                <h4 style="color: ${attempt.tabSwitches > 0 ? '#ef4444' : '#10b981'};">
                    <i class="fas fa-shield-alt"></i> ${attempt.tabSwitches}
                </h4>
                <p style="color: var(--text-secondary); font-size: 0.85rem; margin: 0;">Lần chuyển tab</p>
            </div>
        </c:if>
        <div class="result-stat-card">
            <h4 style="color: #ea580c;"><i class="fas fa-fire"></i> +1</h4>
            <p style="color: var(--text-secondary); font-size: 0.85rem; margin: 0;">Cập nhật chuỗi Streak</p>
        </div>
    </div>

    <!-- Nút hành động -->
    <div style="display: flex; justify-content: center; gap: 14px; margin-top: 24px; flex-wrap: wrap;">
        <a href="${pageContext.request.contextPath}/quiz-take?id=${quiz.id}" class="btn btn-primary">
            <i class="fas fa-redo"></i> Thi lại lần nữa
        </a>
        <a href="${pageContext.request.contextPath}/history" class="btn btn-outline">
            <i class="fas fa-history"></i> Lịch sử làm bài
        </a>
        <c:if test="${quiz.showRanking}">
            <a href="${pageContext.request.contextPath}/leaderboard?quizId=${quiz.id}" class="btn btn-outline">
                <i class="fas fa-trophy"></i> Xem xếp hạng đề này
            </a>
        </c:if>
        <a href="${pageContext.request.contextPath}/quiz" class="btn btn-outline">
            <i class="fas fa-book-open"></i> Kho đề thi
        </a>
    </div>
</div>

<!-- ======================================================== -->
<!-- KHỐI XEM LẠI CHI TIẾT ĐÁP ÁN ĐÚNG/SAI (AZOTA STYLE)       -->
<!-- ======================================================== -->
<c:choose>
    <c:when test="${not quiz.showAnswers and not sessionScope.currentUser.admin and sessionScope.currentUser.id != quiz.creatorId}">
        <!-- Trường hợp Giảng viên tắt tính năng xem đáp án -->
        <div class="card" style="padding: 32px; text-align: center; margin-bottom: 40px; background: #fffbeb; border: 1px dashed #f59e0b;">
            <div style="width: 56px; height: 56px; border-radius: var(--radius-full); background: #fef3c7; color: #b45309; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin: 0 auto 16px;">
                <i class="fas fa-lock"></i>
            </div>
            <h3 style="font-size: 1.3rem; font-weight: 800; color: #92400e; margin-bottom: 8px;">
                Đáp án chi tiết đã được bảo mật
            </h3>
            <p style="color: #b45309; max-width: 540px; margin: 0 auto; line-height: 1.6;">
                Tác giả/Giảng viên đã kích hoạt chế độ bảo mật không hiển thị đáp án và lời giải chi tiết cho đề thi này. Điểm số của bạn đã được lưu an toàn vào hệ thống.
            </p>
        </div>
    </c:when>

    <c:otherwise>
        <!-- Xem chi tiết đáp án tương tác -->
        <div style="margin-bottom: 40px;">
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h3 style="font-size: 1.4rem; font-weight: 800; margin: 0;">
                        <i class="fas fa-clipboard-check" style="color: var(--primary);"></i> Chi tiết bài làm & Lời giải thích
                    </h3>
                    <span style="font-size: 0.88rem; color: var(--text-secondary);">
                        Bấm vào số câu bên dưới để cuộn nhanh đến câu hỏi tương ứng
                    </span>
                </div>

                <!-- Bộ lọc Azota: Tất cả, Câu đúng, Câu sai -->
                <div style="display: flex; gap: 8px;">
                    <button type="button" class="btn btn-primary btn-sm review-filter-btn" onclick="filterReviewQuestions('all', this)">
                        Tất cả (${attempt.totalQuestions})
                    </button>
                    <button type="button" class="btn btn-outline btn-sm review-filter-btn" onclick="filterReviewQuestions('correct', this)" style="color: #15803d; border-color: #86efac;">
                        <i class="fas fa-check"></i> Đúng (${attempt.correctAnswers})
                    </button>
                    <button type="button" class="btn btn-outline btn-sm review-filter-btn" onclick="filterReviewQuestions('wrong', this)" style="color: #b91c1c; border-color: #fca5a5;">
                        <i class="fas fa-times"></i> Sai (${attempt.totalQuestions - attempt.correctAnswers})
                    </button>
                </div>
            </div>

            <!-- Ma trận số câu hỏi nhảy nhanh (Azota Quick Jump Palette) -->
            <div class="card" style="padding: 16px 20px; margin-bottom: 24px; background: var(--bg-surface);">
                <div style="font-size: 0.85rem; font-weight: 700; color: var(--text-secondary); margin-bottom: 10px;">
                    <i class="fas fa-th"></i> Ma trận kết quả câu hỏi:
                </div>
                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                    <c:forEach items="${attempt.answers}" var="ans" varStatus="loop">
                        <button type="button" 
                                class="btn btn-sm ${ans.correct ? 'btn-success' : 'btn-danger'}" 
                                style="width: 38px; height: 38px; padding: 0; font-weight: 700; font-size: 0.9rem;"
                                onclick="scrollToReviewQuestion(${loop.index + 1})"
                                title="Câu ${loop.index + 1}: ${ans.correct ? 'Chính xác' : 'Chưa đúng'}">
                            ${loop.index + 1}
                        </button>
                    </c:forEach>
                </div>
            </div>

            <!-- Danh sách từng câu hỏi kèm lựa chọn & đáp án chuẩn -->
            <c:forEach items="${attempt.answers}" var="ans" varStatus="loop">
                <div class="review-question-card ${ans.correct ? 'status-correct' : 'status-wrong'}" 
                     id="review-q-${loop.index + 1}"
                     data-status="${ans.correct ? 'correct' : 'wrong'}"
                     style="margin-bottom: 20px;">
                    
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">
                        <span style="font-weight: 800; font-size: 1.05rem; color: var(--primary);">
                            <i class="fas fa-question-circle"></i> Câu ${loop.index + 1}
                        </span>

                        <div style="display: flex; gap: 8px; align-items: center;">
                            <c:choose>
                                <c:when test="${ans.correct}">
                                    <span class="badge badge-success"><i class="fas fa-check-circle"></i> Trả lời đúng (+1 điểm)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger"><i class="fas fa-times-circle"></i> Trả lời sai (0 điểm)</span>
                                </c:otherwise>
                            </c:choose>

                            <span class="badge badge-info" style="font-size: 0.85rem;">
                                Bạn chọn: <strong>${not empty ans.selectedOption ? ans.selectedOption : 'Bỏ qua'}</strong>
                            </span>
                            <span class="badge badge-success" style="font-size: 0.85rem;">
                                Đáp án đúng: <strong>${ans.correctOption}</strong>
                            </span>
                        </div>
                    </div>

                    <div style="font-size: 1.1rem; font-weight: 600; margin-bottom: 16px; line-height: 1.5; color: var(--text-primary);">
                        ${ans.questionText}
                    </div>

                    <!-- Lưới các đáp án A, B, C, D -->
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <!-- Option A -->
                        <div class="review-option ${ans.correctOption eq 'A' ? 'is-correct-target' : (ans.selectedOption eq 'A' and !ans.correct ? 'is-user-wrong' : '')}">
                            <span style="font-weight: 700; width: 26px;">A.</span>
                            <span style="flex: 1;">${ans.optionA}</span>
                            <c:if test="${ans.correctOption eq 'A'}">
                                <span class="badge badge-success" style="font-size: 0.78rem;"><i class="fas fa-check"></i> Đáp án đúng</span>
                            </c:if>
                            <c:if test="${ans.selectedOption eq 'A' and !ans.correct}">
                                <span class="badge badge-danger" style="font-size: 0.78rem;"><i class="fas fa-times"></i> Bạn đã chọn</span>
                            </c:if>
                        </div>

                        <!-- Option B -->
                        <div class="review-option ${ans.correctOption eq 'B' ? 'is-correct-target' : (ans.selectedOption eq 'B' and !ans.correct ? 'is-user-wrong' : '')}">
                            <span style="font-weight: 700; width: 26px;">B.</span>
                            <span style="flex: 1;">${ans.optionB}</span>
                            <c:if test="${ans.correctOption eq 'B'}">
                                <span class="badge badge-success" style="font-size: 0.78rem;"><i class="fas fa-check"></i> Đáp án đúng</span>
                            </c:if>
                            <c:if test="${ans.selectedOption eq 'B' and !ans.correct}">
                                <span class="badge badge-danger" style="font-size: 0.78rem;"><i class="fas fa-times"></i> Bạn đã chọn</span>
                            </c:if>
                        </div>

                        <!-- Option C -->
                        <div class="review-option ${ans.correctOption eq 'C' ? 'is-correct-target' : (ans.selectedOption eq 'C' and !ans.correct ? 'is-user-wrong' : '')}">
                            <span style="font-weight: 700; width: 26px;">C.</span>
                            <span style="flex: 1;">${ans.optionC}</span>
                            <c:if test="${ans.correctOption eq 'C'}">
                                <span class="badge badge-success" style="font-size: 0.78rem;"><i class="fas fa-check"></i> Đáp án đúng</span>
                            </c:if>
                            <c:if test="${ans.selectedOption eq 'C' and !ans.correct}">
                                <span class="badge badge-danger" style="font-size: 0.78rem;"><i class="fas fa-times"></i> Bạn đã chọn</span>
                            </c:if>
                        </div>

                        <!-- Option D -->
                        <div class="review-option ${ans.correctOption eq 'D' ? 'is-correct-target' : (ans.selectedOption eq 'D' and !ans.correct ? 'is-user-wrong' : '')}">
                            <span style="font-weight: 700; width: 26px;">D.</span>
                            <span style="flex: 1;">${ans.optionD}</span>
                            <c:if test="${ans.correctOption eq 'D'}">
                                <span class="badge badge-success" style="font-size: 0.78rem;"><i class="fas fa-check"></i> Đáp án đúng</span>
                            </c:if>
                            <c:if test="${ans.selectedOption eq 'D' and !ans.correct}">
                                <span class="badge badge-danger" style="font-size: 0.78rem;"><i class="fas fa-times"></i> Bạn đã chọn</span>
                            </c:if>
                        </div>
                    </div>

                    <!-- Khung Lời giải thích chi tiết (Explanation) -->
                    <c:if test="${not empty ans.explanation}">
                        <div class="explanation-box" style="margin-top: 14px; background: #fffbeb; border: 1px solid #fde68a; border-radius: var(--radius-md); padding: 12px 16px; font-size: 0.92rem; color: #92400e; line-height: 1.5;">
                            <strong><i class="fas fa-lightbulb" style="color: #f59e0b;"></i> Lời giải thích từ giảng viên:</strong> ${ans.explanation}
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<!-- Script cho bộ lọc câu hỏi và cuộn nhanh -->
<script>
    function scrollToReviewQuestion(index) {
        const el = document.getElementById('review-q-' + index);
        if (el) {
            el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            el.style.boxShadow = '0 0 0 3px var(--primary-glow)';
            setTimeout(function() {
                el.style.boxShadow = '';
            }, 1500);
        }
    }

    function filterReviewQuestions(type, btn) {
        // Cập nhật trạng thái nút bấm
        const btns = document.querySelectorAll('.review-filter-btn');
        btns.forEach(b => {
            b.classList.remove('btn-primary');
            b.classList.add('btn-outline');
        });
        btn.classList.remove('btn-outline');
        btn.classList.add('btn-primary');

        // Lọc hiển thị danh sách thẻ câu hỏi
        const cards = document.querySelectorAll('.review-question-card');
        cards.forEach(card => {
            const status = card.getAttribute('data-status');
            if (type === 'all' || status === type) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
