<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Quản Lý Tài Khoản - QuizMaster" />
<c:set var="activePage" value="admin" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="admin-header">
    <div>
        <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Quản Lý Người Dùng & Phân Quyền</h1>
        <p style="color: var(--text-secondary);">Quản trị danh sách tài khoản, gán quyền Giáo viên/Quản trị viên và khóa tài khoản</p>
    </div>
</div>

<!-- Thanh điều hướng Tab Quản trị -->
<div class="admin-nav">
    <a href="${pageContext.request.contextPath}/admin?tab=dashboard" class="admin-nav-item">
        <i class="fas fa-chart-pie"></i> Tổng quan (Dashboard)
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=users" class="admin-nav-item active">
        <i class="fas fa-users-cog"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=quizzes" class="admin-nav-item">
        <i class="fas fa-tasks"></i> Kiểm duyệt đề thi
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=tickets" class="admin-nav-item">
        <i class="fas fa-headset"></i> Hỗ trợ kỹ thuật
    </a>
</div>

<!-- Lọc người dùng -->
<div class="card" style="padding: 20px; margin-bottom: 24px;">
    <form action="${pageContext.request.contextPath}/admin" method="GET" style="display: flex; gap: 14px; align-items: flex-end;">
        <input type="hidden" name="tab" value="users">

        <div style="flex: 2;">
            <label class="form-label">Tìm kiếm tài khoản</label>
            <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="Tìm theo username, họ tên, email...">
        </div>

        <div style="flex: 1;">
            <label class="form-label">Vai trò (Role)</label>
            <select name="role" class="form-control">
                <option value="ALL">Tất cả vai trò</option>
                <option value="STUDENT" ${selectedRole eq 'STUDENT' ? 'selected' : ''}>Học viên (STUDENT)</option>
                <option value="TEACHER" ${selectedRole eq 'TEACHER' ? 'selected' : ''}>Giáo viên (TEACHER)</option>
                <option value="ADMIN" ${selectedRole eq 'ADMIN' ? 'selected' : ''}>Quản trị (ADMIN)</option>
            </select>
        </div>

        <button type="submit" class="btn btn-primary" style="height: 44px;">
            <i class="fas fa-filter"></i> Lọc
        </button>
    </form>
</div>

<!-- Bảng người dùng -->
<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Người dùng</th>
                <th>Email</th>
                <th>Vai trò hiện tại</th>
                <th>Streak</th>
                <th>Thay đổi vai trò</th>
                <th style="text-align: right;">Hành động</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${users}" var="u">
                <tr>
                    <td>#${u.id}</td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div class="user-avatar" style="width: 34px; height: 34px; font-size: 0.9rem;">
                                ${u.fullName.substring(0, 1).toUpperCase()}
                            </div>
                            <div>
                                <div style="font-weight: 700;">${u.fullName}</div>
                                <div style="font-size: 0.8rem; color: var(--text-muted);">@${u.username}</div>
                            </div>
                        </div>
                    </td>
                    <td>${u.email}</td>
                    <td>
                        <span class="badge ${u.admin ? 'badge-danger' : (u.teacher ? 'badge-info' : 'badge-primary')}">
                            ${u.role}
                        </span>
                    </td>
                    <td>
                        <span class="streak-badge" style="padding: 2px 8px; font-size: 0.8rem;">
                            <i class="fas fa-fire"></i> ${u.currentStreak}
                        </span>
                    </td>
                    <td>
                        <form action="${pageContext.request.contextPath}/admin" method="POST" style="display: flex; gap: 6px; align-items: center;">
                            <input type="hidden" name="action" value="updateRole">
                            <input type="hidden" name="userId" value="${u.id}">
                            <select name="newRole" class="form-control" style="padding: 4px 8px; font-size: 0.85rem; width: auto;">
                                <option value="STUDENT" ${u.role eq 'STUDENT' ? 'selected' : ''}>STUDENT</option>
                                <option value="TEACHER" ${u.role eq 'TEACHER' ? 'selected' : ''}>TEACHER</option>
                                <option value="ADMIN" ${u.role eq 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                            </select>
                            <button type="submit" class="btn btn-outline btn-sm" title="Lưu phân quyền">
                                <i class="fas fa-save"></i>
                            </button>
                        </form>
                    </td>
                    <td style="text-align: right;">
                        <c:if test="${u.id != sessionScope.currentUser.id}">
                            <form action="${pageContext.request.contextPath}/admin" method="POST" style="display: inline;" 
                                  onsubmit="return confirm('Bạn chắc chắn muốn xóa tài khoản này? Toàn bộ dữ liệu liên quan sẽ bị xóa vĩnh viễn!');">
                                <input type="hidden" name="action" value="deleteUser">
                                <input type="hidden" name="userId" value="${u.id}">
                                <button type="submit" class="btn btn-danger btn-sm" title="Xóa người dùng">
                                    <i class="fas fa-trash"></i> Xóa
                                </button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
