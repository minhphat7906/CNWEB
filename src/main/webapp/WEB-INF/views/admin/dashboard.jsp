<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Quản Trị Hệ Thống - QuizMaster" />
<c:set var="activePage" value="admin" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="admin-header">
    <div>
        <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Bảng Điều Khiển Quản Trị</h1>
        <p style="color: var(--text-secondary);">Thống kê toàn diện, kiểm duyệt nội dung và giám sát hệ thống QuizMaster</p>
    </div>
</div>

<!-- Thanh điều hướng Tab Quản trị -->
<div class="admin-nav">
    <a href="${pageContext.request.contextPath}/admin?tab=dashboard" class="admin-nav-item active">
        <i class="fas fa-chart-pie"></i> Tổng quan (Dashboard)
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=users" class="admin-nav-item">
        <i class="fas fa-users-cog"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=quizzes" class="admin-nav-item">
        <i class="fas fa-tasks"></i> Kiểm duyệt đề thi
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=tickets" class="admin-nav-item">
        <i class="fas fa-headset"></i> Hỗ trợ kỹ thuật (${pendingTickets})
    </a>
</div>

<!-- KPI Cards -->
<div class="kpi-grid">
    <div class="kpi-card">
        <div class="kpi-icon users"><i class="fas fa-users"></i></div>
        <div class="kpi-info">
            <h3>${totalUsers}</h3>
            <p>Tổng số tài khoản</p>
        </div>
    </div>

    <div class="kpi-card">
        <div class="kpi-icon quizzes"><i class="fas fa-book"></i></div>
        <div class="kpi-info">
            <h3>${totalQuizzes}</h3>
            <p>Bộ đề thi trên kho</p>
        </div>
    </div>

    <div class="kpi-card">
        <div class="kpi-icon attempts"><i class="fas fa-clipboard-check"></i></div>
        <div class="kpi-info">
            <h3>${totalAttempts}</h3>
            <p>Lượt làm bài khảo thí</p>
        </div>
    </div>

    <div class="kpi-card">
        <div class="kpi-icon tickets"><i class="fas fa-envelope-open-text"></i></div>
        <div class="kpi-info">
            <h3>${pendingTickets}</h3>
            <p>Yêu cầu hỗ trợ chờ xử lý</p>
        </div>
    </div>
</div>

<!-- Bảng đề thi gần đây & người dùng mới -->
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
    <div class="card" style="padding: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 style="font-size: 1.15rem; font-weight: 800;">Đề thi mới cập nhật</h3>
            <a href="${pageContext.request.contextPath}/admin?tab=quizzes" class="btn btn-outline btn-sm">Xem tất cả</a>
        </div>

        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Tiêu đề</th>
                        <th>Chủ đề</th>
                        <th>Tác giả</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${recentQuizzes}" var="q">
                        <tr>
                            <td><strong>${q.title}</strong></td>
                            <td><span class="badge badge-info">${q.categoryName}</span></td>
                            <td>${q.creatorName}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="card" style="padding: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 style="font-size: 1.15rem; font-weight: 800;">Thành viên mới gia nhập</h3>
            <a href="${pageContext.request.contextPath}/admin?tab=users" class="btn btn-outline btn-sm">Xem tất cả</a>
        </div>

        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Họ tên</th>
                        <th>Username</th>
                        <th>Vai trò</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${recentUsers}" var="u">
                        <tr>
                            <td><strong>${u.fullName}</strong></td>
                            <td>@${u.username}</td>
                            <td>
                                <span class="badge ${u.admin ? 'badge-danger' : (u.teacher ? 'badge-info' : 'badge-primary')}">
                                    ${u.role}
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
