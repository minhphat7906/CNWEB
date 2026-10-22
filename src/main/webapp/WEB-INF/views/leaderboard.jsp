<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Bảng Vàng Thành Tích - QuizMaster" />
<c:set var="activePage" value="leaderboard" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="margin-bottom: 28px;">
    <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Bảng Vàng Xếp Hạng Bài Thi</h1>
    <p style="color: var(--text-secondary);">Vinh danh các kỷ lục điểm số và thời gian làm bài của các thí sinh trong bài thi</p>
</div>

<c:choose>
    <c:when test="${empty quizzes}">
        <!-- Chưa từng làm bài kiểm tra nào -->
        <div class="card" style="text-align: center; padding: 60px 24px;">
            <div style="width: 72px; height: 72px; border-radius: var(--radius-full); background: #fef3c7; color: #d97706; display: flex; align-items: center; justify-content: center; font-size: 2rem; margin: 0 auto 20px;">
                <i class="fas fa-trophy"></i>
            </div>
            <h2 style="font-size: 1.5rem; font-weight: 800; margin-bottom: 10px;">Bạn chưa hoàn thành bài thi nào</h2>
            <p style="color: var(--text-secondary); max-width: 520px; margin: 0 auto 24px; line-height: 1.6;">
                Hệ thống chỉ cho phép xem bảng xếp hạng đối với các bài kiểm tra bạn đã trực tiếp tham gia và hoàn thành. Hãy vào Kho đề thi để thử sức ngay nhé!
            </p>
            <a href="${pageContext.request.contextPath}/quiz" class="btn btn-primary btn-lg">
                <i class="fas fa-book-open"></i> Khám phá Kho đề thi
            </a>
        </div>
    </c:when>

    <c:otherwise>
        <!-- Bộ lọc chọn bài thi đã làm -->
        <div class="card" style="padding: 20px 24px; margin-bottom: 24px;">
            <form action="${pageContext.request.contextPath}/leaderboard" method="GET" style="display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap;">
                <div style="flex: 1; min-width: 280px;">
                    <label class="form-label" style="font-weight: 700; margin-bottom: 8px;">
                        <i class="fas fa-check-circle" style="color: var(--success);"></i> Chọn bài thi của bạn để xem bảng xếp hạng:
                    </label>
                    <select name="quizId" class="form-control" onchange="this.form.submit()" style="font-size: 0.95rem; font-weight: 600;">
                        <c:forEach items="${quizzes}" var="q">
                            <option value="${q.id}" ${selectedQuizId == q.id ? 'selected' : ''}>
                                ${q.title} <c:if test="${q.timeLimit > 0}">(${q.timeLimit} phút)</c:if>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" style="height: 44px; padding: 0 24px;">
                    <i class="fas fa-filter"></i> Xem xếp hạng
                </button>
            </form>
        </div>

        <!-- Kiểm tra điều kiện xem -->
        <c:choose>
            <c:when test="${not canView}">
                <c:choose>
                    <c:when test="${blockReason eq 'NOT_ATTEMPTED'}">
                        <div class="card" style="text-align: center; padding: 50px 24px; background: #fffbeb; border: 1px dashed #f59e0b;">
                            <div style="width: 60px; height: 60px; border-radius: var(--radius-full); background: #fef3c7; color: #b45309; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto 16px;">
                                <i class="fas fa-lock"></i>
                            </div>
                            <h3 style="font-size: 1.35rem; font-weight: 800; color: #92400e; margin-bottom: 8px;">
                                Bạn chưa hoàn thành bài thi này
                            </h3>
                            <p style="color: #b45309; max-width: 540px; margin: 0 auto 24px; line-height: 1.6;">
                                Quy định khảo thí: Thí sinh cần hoàn thành bài kiểm tra trước khi được xem bảng điểm và thứ hạng của các thí sinh khác.
                            </p>
                            <a href="${pageContext.request.contextPath}/quiz-take?id=${selectedQuiz.id}" class="btn btn-primary">
                                <i class="fas fa-play"></i> Vào làm bài thi ngay
                            </a>
                        </div>
                    </c:when>

                    <c:when test="${blockReason eq 'RANKING_DISABLED'}">
                        <div class="card" style="text-align: center; padding: 50px 24px; background: var(--bg-surface);">
                            <div style="font-size: 3rem; color: var(--text-muted); margin-bottom: 12px;">
                                <i class="fas fa-eye-slash"></i>
                            </div>
                            <h3 style="font-size: 1.3rem; font-weight: 800; margin-bottom: 8px;">
                                Bảng xếp hạng không công khai
                            </h3>
                            <p style="color: var(--text-secondary); margin: 0;">
                                Giảng viên / Người tạo đề đã tắt chế độ hiển thị bảng xếp hạng cho bài kiểm tra này.
                            </p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="card" style="text-align: center; padding: 50px 24px;">
                            <p style="color: var(--text-secondary); margin: 0;">Không tìm thấy bài thi yêu cầu.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:when>

            <c:otherwise>
                <!-- Hiển thị bảng xếp hạng của bài thi -->
                <div style="margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h3 style="font-size: 1.25rem; font-weight: 800; margin: 0; color: var(--text-primary);">
                            ${selectedQuiz.title}
                        </h3>
                        <span style="font-size: 0.85rem; color: var(--text-muted);">
                            <i class="fas fa-users"></i> Tổng số lượt nộp bài đã ghi nhận: ${topAttempts.size()}
                        </span>
                    </div>
                    <a href="${pageContext.request.contextPath}/quiz-take?id=${selectedQuiz.id}" class="btn btn-outline btn-sm">
                        <i class="fas fa-redo"></i> Thi lại bài này
                    </a>
                </div>

                <c:choose>
                    <c:when test="${not empty topAttempts}">
                        <div class="card" style="padding: 0; overflow: hidden;">
                            <div class="table-responsive">
                                <table class="table" style="margin-bottom: 0;">
                                    <thead style="background: var(--bg-page);">
                                        <tr>
                                            <th style="width: 80px; text-align: center;">Hạng</th>
                                            <th>Thí sinh</th>
                                            <th style="text-align: center;">Điểm số</th>
                                            <th style="text-align: center;">Số câu đúng</th>
                                            <th style="text-align: center;">Thời gian làm</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${topAttempts}" var="att" varStatus="loop">
                                            <tr style="${att.userId == sessionScope.currentUser.id ? 'background: #eff6ff;' : ''}">
                                                <td style="text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${loop.index == 0}">
                                                            <span style="font-size: 1.3rem; color: #eab308; font-weight: 800;"><i class="fas fa-crown"></i> 1</span>
                                                        </c:when>
                                                        <c:when test="${loop.index == 1}">
                                                            <span style="font-size: 1.15rem; color: #94a3b8; font-weight: 800;"><i class="fas fa-medal"></i> 2</span>
                                                        </c:when>
                                                        <c:when test="${loop.index == 2}">
                                                            <span style="font-size: 1.15rem; color: #b45309; font-weight: 800;"><i class="fas fa-medal"></i> 3</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="font-weight: 700; color: var(--text-muted); font-size: 0.95rem;">#${loop.index + 1}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div style="display: flex; align-items: center; gap: 12px;">
                                                        <div class="user-avatar" style="width: 36px; height: 36px; font-size: 0.9rem; font-weight: 700;">
                                                            ${att.userFullName.substring(0, 1).toUpperCase()}
                                                        </div>
                                                        <div>
                                                            <div style="font-weight: 700; font-size: 0.95rem;">
                                                                ${att.userFullName}
                                                                <c:if test="${att.userId == sessionScope.currentUser.id}">
                                                                    <span class="badge badge-primary" style="font-size: 0.7rem; margin-left: 6px;">Bạn</span>
                                                                </c:if>
                                                            </div>
                                                            <div style="font-size: 0.8rem; color: var(--text-muted);">@${att.userName}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td style="text-align: center;">
                                                    <span class="badge ${att.score >= 8.0 ? 'badge-success' : (att.score >= 5.0 ? 'badge-primary' : 'badge-warning')}" style="font-size: 0.95rem; padding: 6px 12px; font-weight: 800;">
                                                        ${att.score} đ
                                                    </span>
                                                </td>
                                                <td style="text-align: center; font-weight: 600;">
                                                    <span style="color: var(--success); font-weight: 800;">${att.correctAnswers}</span> / ${att.totalQuestions}
                                                </td>
                                                <td style="text-align: center; color: var(--text-secondary); font-size: 0.9rem;">
                                                    <i class="far fa-clock"></i> ${att.formattedTimeSpent}
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="card" style="text-align: center; padding: 50px 24px;">
                            <div style="font-size: 3rem; color: var(--text-muted); margin-bottom: 12px;">
                                <i class="fas fa-trophy"></i>
                            </div>
                            <h3 style="margin-bottom: 8px;">Chưa có lượt nộp bài nào</h3>
                            <p style="color: var(--text-secondary); margin: 0;">Hãy là người đầu tiên ghi danh trên bảng xếp hạng của bài thi này!</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
