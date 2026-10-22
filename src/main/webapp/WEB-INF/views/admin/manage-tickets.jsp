<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Hỗ Trợ Kỹ Thuật - QuizMaster" />
<c:set var="activePage" value="admin" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="admin-header">
    <div>
        <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Hòm Thư Yêu Cầu Hỗ Trợ (Tickets)</h1>
        <p style="color: var(--text-secondary);">Tiếp nhận và giải quyết phản hồi kỹ thuật từ sinh viên và giảng viên</p>
    </div>
</div>

<!-- Thanh điều hướng Tab Quản trị -->
<div class="admin-nav">
    <a href="${pageContext.request.contextPath}/admin?tab=dashboard" class="admin-nav-item">
        <i class="fas fa-chart-pie"></i> Tổng quan (Dashboard)
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=users" class="admin-nav-item">
        <i class="fas fa-users-cog"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=quizzes" class="admin-nav-item">
        <i class="fas fa-tasks"></i> Kiểm duyệt đề thi
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=tickets" class="admin-nav-item active">
        <i class="fas fa-headset"></i> Hỗ trợ kỹ thuật
    </a>
</div>

<!-- Lọc Ticket -->
<div class="card" style="padding: 16px 20px; margin-bottom: 24px;">
    <form action="${pageContext.request.contextPath}/admin" method="GET" style="display: flex; gap: 14px; align-items: flex-end;">
        <input type="hidden" name="tab" value="tickets">

        <div style="flex: 1;">
            <label class="form-label">Lọc theo trạng thái xử lý</label>
            <select name="status" class="form-control" onchange="this.form.submit()">
                <option value="ALL">Tất cả yêu cầu</option>
                <option value="PENDING" ${selectedStatus eq 'PENDING' ? 'selected' : ''}>Chờ xử lý (PENDING)</option>
                <option value="IN_PROGRESS" ${selectedStatus eq 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý (IN_PROGRESS)</option>
                <option value="RESOLVED" ${selectedStatus eq 'RESOLVED' ? 'selected' : ''}>Đã giải quyết (RESOLVED)</option>
            </select>
        </div>

        <button type="submit" class="btn btn-primary" style="height: 44px;">
            <i class="fas fa-filter"></i> Lọc
        </button>
    </form>
</div>

<!-- Danh sách Tickets -->
<c:choose>
    <c:when test="${not empty tickets}">
        <div style="display: flex; flex-direction: column; gap: 16px;">
            <c:forEach items="${tickets}" var="t">
                <div class="card" style="padding: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                        <div>
                            <span class="badge ${t.statusBadgeClass}" style="margin-bottom: 6px;">${t.statusLabel}</span>
                            <h3 style="font-size: 1.15rem; font-weight: 700; margin: 0;">${t.subject}</h3>
                            <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 4px;">
                                Gửi bởi: <strong>${t.name}</strong> (${t.email}) &bull; Thời gian: ${t.createdAt}
                            </div>
                        </div>

                        <!-- Cập nhật trạng thái -->
                        <form action="${pageContext.request.contextPath}/admin" method="POST" style="display: flex; gap: 8px;">
                            <input type="hidden" name="action" value="updateTicket">
                            <input type="hidden" name="ticketId" value="${t.id}">
                            <select name="status" class="form-control" style="padding: 6px 10px; font-size: 0.85rem; width: auto;">
                                <option value="PENDING" ${t.status eq 'PENDING' ? 'selected' : ''}>Chờ xử lý</option>
                                <option value="IN_PROGRESS" ${t.status eq 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                                <option value="RESOLVED" ${t.status eq 'RESOLVED' ? 'selected' : ''}>Đã giải quyết</option>
                            </select>
                            <button type="submit" class="btn btn-outline btn-sm">
                                <i class="fas fa-check"></i> Cập nhật
                            </button>
                        </form>
                    </div>

                    <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 14px; font-size: 0.92rem; color: var(--text-secondary); line-height: 1.6;">
                        ${t.message}
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:when>

    <c:otherwise>
        <div class="card" style="text-align: center; padding: 48px;">
            <div style="font-size: 3rem; color: var(--text-muted); margin-bottom: 16px;">
                <i class="fas fa-inbox"></i>
            </div>
            <h3 style="margin-bottom: 8px;">Không có yêu cầu hỗ trợ nào</h3>
            <p style="color: var(--text-secondary); margin: 0;">Mọi phản hồi kỹ thuật từ người dùng đã được giải quyết xong!</p>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
