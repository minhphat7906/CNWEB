<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Kiểm Duyệt Đề Thi - QuizMaster" />
<c:set var="activePage" value="admin" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="admin-header">
    <div>
        <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Kiểm Duyệt & Quản Trị Đề Thi</h1>
        <p style="color: var(--text-secondary);">Kiểm duyệt tính hợp lệ, ẩn hoặc xóa các bộ đề vi phạm quy chuẩn khảo thí</p>
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
    <a href="${pageContext.request.contextPath}/admin?tab=quizzes" class="admin-nav-item active">
        <i class="fas fa-tasks"></i> Kiểm duyệt đề thi
    </a>
    <a href="${pageContext.request.contextPath}/admin?tab=tickets" class="admin-nav-item">
        <i class="fas fa-headset"></i> Hỗ trợ kỹ thuật
    </a>
</div>

<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Tiêu đề đề thi</th>
                <th>Chủ đề</th>
                <th>Tác giả</th>
                <th>Số câu</th>
                <th>Trạng thái</th>
                <th>Lượt thi</th>
                <th style="text-align: right;">Hành động quản trị</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${quizzes}" var="q">
                <tr>
                    <td>#${q.id}</td>
                    <td>
                        <strong><a href="${pageContext.request.contextPath}/quiz?id=${q.id}">${q.title}</a></strong>
                        <div style="font-size: 0.8rem; color: var(--text-muted);">${q.timeLimit} phút &bull; ${q.difficultyLabel}</div>
                    </td>
                    <td><span class="badge badge-info">${q.categoryName}</span></td>
                    <td>${q.creatorName}</td>
                    <td><strong>${q.questionCount}</strong> câu</td>
                    <td>
                        <c:choose>
                            <c:when test="${q.isPublic}">
                                <span class="badge badge-success"><i class="fas fa-check-circle"></i> Đang hiển thị</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-warning"><i class="fas fa-eye-slash"></i> Đang ẩn</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>${q.attemptCount} lượt</td>
                    <td style="text-align: right;">
                        <div class="table-actions" style="justify-content: flex-end;">
                            <!-- Nút ẩn / hiện -->
                            <form action="${pageContext.request.contextPath}/admin" method="POST" style="display: inline;">
                                <input type="hidden" name="action" value="toggleQuiz">
                                <input type="hidden" name="quizId" value="${q.id}">
                                <button type="submit" class="btn btn-outline btn-sm" title="${q.isPublic ? 'Ẩn bộ đề này' : 'Công khai bộ đề'}">
                                    <i class="fas ${q.isPublic ? 'fa-eye-slash' : 'fa-eye'}"></i> ${q.isPublic ? 'Ẩn' : 'Hiện'}
                                </button>
                            </form>

                            <!-- Nút sửa -->
                            <a href="${pageContext.request.contextPath}/quiz-lab?action=edit&id=${q.id}" class="btn btn-outline btn-sm" title="Sửa nội dung trong Lab">
                                <i class="fas fa-edit"></i> Sửa
                            </a>

                            <!-- Nút xóa -->
                            <form action="${pageContext.request.contextPath}/admin" method="POST" style="display: inline;"
                                  onsubmit="return confirm('Bạn chắc chắn muốn xóa bộ đề này khỏi toàn hệ thống?');">
                                <input type="hidden" name="action" value="deleteQuiz">
                                <input type="hidden" name="quizId" value="${q.id}">
                                <button type="submit" class="btn btn-danger btn-sm" title="Xóa vĩnh viễn">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
