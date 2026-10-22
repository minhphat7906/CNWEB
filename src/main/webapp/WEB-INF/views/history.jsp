<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Lịch Sử Làm Bài - QuizMaster" />
<c:set var="activePage" value="history" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">
            <i class="fas fa-history" style="color: var(--primary);"></i> 
            <c:choose>
                <c:when test="${not empty selectedQuiz}">Lịch sử làm bài: <c:out value="${selectedQuiz.title}" /></c:when>
                <c:otherwise>Lịch Sử Thi & Làm Bài Của Tôi</c:otherwise>
            </c:choose>
        </h1>
        <p style="color: var(--text-secondary); margin: 0;">
            <c:choose>
                <c:when test="${not empty selectedQuiz}">
                    Danh sách tất cả các lần bạn đã làm bài đối với bộ đề này
                </c:when>
                <c:otherwise>
                    Theo dõi tiến độ học tập, xem lại chi tiết đáp án đúng/sai của từng bài thi đã nộp
                </c:otherwise>
            </c:choose>
        </p>
    </div>

    <div style="display: flex; gap: 10px;">
        <c:if test="${not empty selectedQuiz}">
            <a href="${pageContext.request.contextPath}/history" class="btn btn-outline">
                <i class="fas fa-list"></i> Xem tất cả bài thi
            </a>
            <a href="${pageContext.request.contextPath}/quiz?id=${selectedQuiz.id}" class="btn btn-primary">
                <i class="fas fa-play"></i> Làm lại đề này
            </a>
        </c:if>
        <c:if test="${empty selectedQuiz}">
            <a href="${pageContext.request.contextPath}/quiz" class="btn btn-primary">
                <i class="fas fa-book-open"></i> Khám phá kho đề thi
            </a>
        </c:if>
    </div>
</div>

<!-- Lưới 4 thẻ thống kê tổng quan -->
<div class="grid grid-4" style="margin-bottom: 28px;">
    <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #eef2ff; color: #4f46e5; display: flex; align-items: center; justify-content: center; font-size: 1.4rem;">
            <i class="fas fa-clipboard-list"></i>
        </div>
        <div>
            <div style="font-size: 0.85rem; color: var(--text-secondary); font-weight: 600;">Tổng lượt làm bài</div>
            <div style="font-size: 1.6rem; font-weight: 800; color: var(--text-primary);">${totalAttempts}</div>
        </div>
    </div>

    <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #f0fdf4; color: #16a34a; display: flex; align-items: center; justify-content: center; font-size: 1.4rem;">
            <i class="fas fa-check-circle"></i>
        </div>
        <div>
            <div style="font-size: 0.85rem; color: var(--text-secondary); font-weight: 600;">Đã hoàn thành</div>
            <div style="font-size: 1.6rem; font-weight: 800; color: #16a34a;">${completedCount}</div>
        </div>
    </div>

    <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #fef3c7; color: #d97706; display: flex; align-items: center; justify-content: center; font-size: 1.4rem;">
            <i class="fas fa-chart-line"></i>
        </div>
        <div>
            <div style="font-size: 0.85rem; color: var(--text-secondary); font-weight: 600;">Điểm trung bình</div>
            <div style="font-size: 1.6rem; font-weight: 800; color: #d97706;">${avgScore} <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted);">/10</span></div>
        </div>
    </div>

    <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: #fae8ff; color: #a21caf; display: flex; align-items: center; justify-content: center; font-size: 1.4rem;">
            <i class="fas fa-medal"></i>
        </div>
        <div>
            <div style="font-size: 0.85rem; color: var(--text-secondary); font-weight: 600;">Điểm cao nhất</div>
            <div style="font-size: 1.6rem; font-weight: 800; color: #a21caf;">${highestScore} <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted);">/10</span></div>
        </div>
    </div>
</div>

<!-- Danh sách chi tiết các lần thi -->
<c:choose>
    <c:when test="${not empty attempts}">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Mã lượt</th>
                        <th>Bộ đề thi</th>
                        <th>Điểm số</th>
                        <th>Số câu đúng</th>
                        <th>Thời gian làm</th>
                        <th>Thời điểm nộp</th>
                        <th style="text-align: right;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${attempts}" var="att">
                        <tr>
                            <td>
                                <strong style="color: var(--text-muted);">#${att.id}</strong>
                            </td>
                            <td>
                                <div>
                                    <strong><a href="${pageContext.request.contextPath}/quiz?id=${att.quizId}">${att.quizTitle}</a></strong>
                                </div>
                                <c:if test="${att.tabSwitches > 0}">
                                    <span class="badge badge-danger" style="font-size: 0.72rem; padding: 2px 6px;">
                                        <i class="fas fa-exclamation-triangle"></i> Rời màn hình ${att.tabSwitches} lần
                                    </span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${att.score >= 8.0}">
                                        <span class="badge badge-success" style="font-size: 0.95rem; font-weight: 800; padding: 4px 10px;">
                                            ${att.score}
                                        </span>
                                    </c:when>
                                    <c:when test="${att.score >= 5.0}">
                                        <span class="badge badge-warning" style="font-size: 0.95rem; font-weight: 800; padding: 4px 10px;">
                                            ${att.score}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-danger" style="font-size: 0.95rem; font-weight: 800; padding: 4px 10px;">
                                            ${att.score}
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <strong>${att.correctAnswers}</strong> / ${att.totalQuestions} câu
                            </td>
                            <td>
                                <c:set var="totalSecs" value="${att.timeSpent}" />
                                <c:set var="mins" value="${totalSecs / 60}" />
                                <c:set var="secs" value="${totalSecs % 60}" />
                                <fmt:formatNumber var="fMins" value="${mins}" maxFractionDigits="0" />
                                <span><i class="far fa-clock" style="color: var(--text-muted);"></i> ${fMins}p ${secs}s</span>
                            </td>
                            <td>
                                <span style="font-size: 0.85rem; color: var(--text-secondary);">${att.createdAt}</span>
                            </td>
                            <td style="text-align: right;">
                                <div class="table-actions" style="justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/quiz-take?action=result&attemptId=${att.id}" class="btn btn-outline btn-sm" title="Xem chi tiết kết quả & lời giải">
                                        <i class="fas fa-eye"></i> Xem bài làm
                                    </a>
                                    <a href="${pageContext.request.contextPath}/quiz-take?id=${att.quizId}" class="btn btn-primary btn-sm" title="Làm lại đề thi này">
                                        <i class="fas fa-redo"></i> Thi lại
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:when>

    <c:otherwise>
        <div class="card" style="text-align: center; padding: 48px;">
            <div style="font-size: 3rem; color: var(--text-muted); margin-bottom: 16px;">
                <i class="fas fa-file-signature"></i>
            </div>
            <h3 style="margin-bottom: 8px;">Chưa có lịch sử làm bài</h3>
            <p style="color: var(--text-secondary); margin-bottom: 24px;">Bạn chưa thực hiện bài thi nào. Hãy bắt đầu thử sức với các bộ đề thi trắc nghiệm!</p>
            <a href="${pageContext.request.contextPath}/quiz" class="btn btn-primary">
                <i class="fas fa-search"></i> Khám phá kho đề thi ngay
            </a>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
