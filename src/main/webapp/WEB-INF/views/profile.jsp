<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Hồ Sơ Cá Nhân - QuizMaster" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 32px; align-items: flex-start;">
    
    <!-- Cột 1: Thông tin người dùng & Đổi mật khẩu -->
    <div>
        <div class="card" style="padding: 28px; text-align: center; margin-bottom: 24px;">
            <div class="user-avatar" style="width: 80px; height: 80px; font-size: 2.2rem; margin: 0 auto 16px auto;">
                ${user.fullName.substring(0, 1).toUpperCase()}
            </div>

            <h2 style="font-size: 1.4rem; font-weight: 800; margin-bottom: 4px;">${user.fullName}</h2>
            <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 12px;">@${user.username} &bull; ${user.email}</p>

            <div style="display: flex; justify-content: center; gap: 8px; margin-bottom: 20px;">
                <span class="badge ${user.admin ? 'badge-danger' : (user.teacher ? 'badge-info' : 'badge-primary')}">
                    <i class="fas fa-user-tag"></i> ${user.role}
                </span>
                <span class="streak-badge">
                    <i class="fas fa-fire fire-icon"></i> ${user.currentStreak} ngày
                </span>
            </div>

            <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px; font-size: 0.88rem; text-align: left;">
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span style="color: var(--text-secondary);">Hoạt động gần nhất:</span>
                    <strong>${user.lastActiveDate != null ? user.lastActiveDate : 'Hôm nay'}</strong>
                </div>
                <div style="display: flex; justify-content: space-between;">
                    <span style="color: var(--text-secondary);">Ngày tham gia:</span>
                    <strong>${user.createdAt != null ? user.createdAt : '2026'}</strong>
                </div>
            </div>
        </div>

        <!-- Form đổi mật khẩu -->
        <div class="card" style="padding: 24px;">
            <h3 style="font-size: 1.15rem; font-weight: 800; margin-bottom: 16px; color: var(--primary);">
                <i class="fas fa-key"></i> Đổi Mật Khẩu
            </h3>

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="changePassword">

                <div class="form-group">
                    <label class="form-label">Mật khẩu hiện tại</label>
                    <input type="password" name="currentPassword" class="form-control" placeholder="••••••••" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Mật khẩu mới</label>
                    <input type="password" name="newPassword" class="form-control" placeholder="Tối thiểu 6 ký tự" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Xác nhận mật khẩu mới</label>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu mới" required>
                </div>

                <button type="submit" class="btn btn-outline btn-block">
                    <i class="fas fa-lock"></i> Lưu mật khẩu mới
                </button>
            </form>
        </div>
    </div>

    <!-- Cột 2: Thống kê & Lịch sử làm bài -->
    <div>
        <!-- KPI cá nhân -->
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px;">
            <div class="card" style="padding: 16px; text-align: center;">
                <h4 style="font-size: 1.6rem; font-weight: 800; color: var(--primary);">${totalAttempts}</h4>
                <p style="font-size: 0.8rem; color: var(--text-secondary); margin: 0;">Lượt đã thi</p>
            </div>
            <div class="card" style="padding: 16px; text-align: center;">
                <h4 style="font-size: 1.6rem; font-weight: 800; color: var(--success);">${passedCount}</h4>
                <p style="font-size: 0.8rem; color: var(--text-secondary); margin: 0;">Số lần đạt (>=5đ)</p>
            </div>
            <div class="card" style="padding: 16px; text-align: center;">
                <h4 style="font-size: 1.6rem; font-weight: 800; color: var(--secondary);">${avgScore}</h4>
                <p style="font-size: 0.8rem; color: var(--text-secondary); margin: 0;">Điểm trung bình</p>
            </div>
            <div class="card" style="padding: 16px; text-align: center;">
                <h4 style="font-size: 1.6rem; font-weight: 800; color: #ea580c;">${maxScore}</h4>
                <p style="font-size: 0.8rem; color: var(--text-secondary); margin: 0;">Điểm cao nhất</p>
            </div>
        </div>

        <!-- Lịch sử làm bài -->
        <div class="card" style="padding: 24px;">
            <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 20px;">
                <i class="fas fa-history"></i> Lịch Sử Khảo Thí & Ôn Tập
            </h3>

            <c:choose>
                <c:when test="${not empty attempts}">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>#ID</th>
                                    <th>Đề thi</th>
                                    <th>Điểm số</th>
                                    <th>Số câu đúng</th>
                                    <th>Thời gian</th>
                                    <th style="text-align: right;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${attempts}" var="att">
                                    <tr>
                                        <td>#${att.id}</td>
                                        <td>
                                            <div style="font-weight: 700;">${att.quizTitle}</div>
                                            <span class="badge badge-info" style="font-size: 0.72rem;">${att.categoryName}</span>
                                        </td>
                                        <td>
                                            <span class="badge ${att.score >= 5.0 ? 'badge-success' : 'badge-danger'}" style="font-size: 0.88rem;">
                                                ${att.score} đ
                                            </span>
                                        </td>
                                        <td><strong>${att.correctAnswers}</strong> / ${att.totalQuestions}</td>
                                        <td><i class="far fa-clock"></i> ${att.formattedTimeSpent}</td>
                                        <td style="text-align: right;">
                                            <a href="${pageContext.request.contextPath}/quiz-take?action=result&attemptId=${att.id}" class="btn btn-outline btn-sm">
                                                <i class="fas fa-eye"></i> Xem bài giải
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>

                <c:otherwise>
                    <div style="text-align: center; padding: 32px 0;">
                        <p style="color: var(--text-secondary); margin-bottom: 16px;">Bạn chưa thực hiện bài thi trắc nghiệm nào.</p>
                        <a href="${pageContext.request.contextPath}/quiz" class="btn btn-primary">Khám phá kho đề thi</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
