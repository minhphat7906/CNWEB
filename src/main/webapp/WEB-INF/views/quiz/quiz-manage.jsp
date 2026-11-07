<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Quản Lý Đề Thi - QuizMaster" />
<c:set var="activePage" value="quiz-manage" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
    <div>
        <h1 style="font-size: 1.85rem; font-weight: 800; margin-bottom: 6px; letter-spacing: -0.02em;">Đề Thi Đã Tạo</h1>
        <p style="color: var(--text-secondary); margin: 0; font-size: 0.95rem;">Quản lý danh sách, chỉnh sửa câu hỏi và thông số các bộ đề do bạn biên soạn</p>
    </div>
    <a href="${pageContext.request.contextPath}/quiz-lab" class="btn btn-primary">
        <i class="fas fa-plus"></i> Tạo đề thi mới
    </a>
</div>

<c:if test="${param.success eq 'updated'}">
    <div class="alert alert-success" style="margin-bottom: 20px;">
        <i class="fas fa-check-circle"></i> Đã cập nhật thành công nội dung đề thi và danh sách câu hỏi!
    </div>
</c:if>
<c:if test="${param.success eq 'created'}">
    <div class="alert alert-success" style="margin-bottom: 20px;">
        <i class="fas fa-check-circle"></i> Đã tạo mới thành công bộ đề thi!
    </div>
</c:if>
<c:if test="${param.success eq 'deleted'}">
    <div class="alert alert-success" style="margin-bottom: 20px;">
        <i class="fas fa-check-circle"></i> Đã xóa thành công bộ đề thi!
    </div>
</c:if>
<c:if test="${param.error eq 'forbidden'}">
    <div class="alert alert-danger" style="margin-bottom: 20px;">
        <i class="fas fa-exclamation-triangle"></i> Bạn không có quyền chỉnh sửa bộ đề này. Chỉ Quản trị viên, Giáo viên hoặc Tác giả tạo đề mới có quyền chỉnh sửa.
    </div>
</c:if>
<c:if test="${param.error eq 'notfound'}">
    <div class="alert alert-warning" style="margin-bottom: 20px;">
        <i class="fas fa-exclamation-circle"></i> Không tìm thấy bộ đề thi yêu cầu.
    </div>
</c:if>

<c:choose>
    <c:when test="${not empty quizzes}">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tiêu đề bộ đề thi</th>
                        <th>Số câu</th>
                        <th>Thời gian</th>
                        <th>Độ khó</th>
                        <th>Trạng thái</th>
                        <th>Lượt thi</th>
                        <th style="text-align: right;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${quizzes}" var="q">
                        <tr>
                            <td>#${q.id}</td>
                            <td>
                                <strong><a href="${pageContext.request.contextPath}/quiz?id=${q.id}">${q.title}</a></strong>
                                <div style="font-size: 0.8rem; color: var(--text-muted);">${q.description}</div>
                            </td>
                            <td><strong>${q.questionCount}</strong> câu</td>
                            <td>
                                <c:choose>
                                    <c:when test="${q.timeLimit == 0}">
                                        <span class="badge badge-success" style="font-size: 0.75rem;"><i class="fas fa-infinity"></i> Không giới hạn</span>
                                    </c:when>
                                    <c:otherwise>
                                        ${q.timeLimit} phút
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><span class="badge ${q.difficultyBadgeClass}">${q.difficultyLabel}</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${q.isPublic}">
                                        <span class="badge badge-success"><i class="fas fa-globe"></i> Công khai</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-warning"><i class="fas fa-lock"></i> Riêng tư</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${q.attemptCount} lượt</td>
                            <td style="text-align: right;">
                                <div class="table-actions" style="justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/quiz-take?id=${q.id}" class="btn btn-outline btn-sm" title="Vào thi thử">
                                        <i class="fas fa-play"></i> Thi thử
                                    </a>
                                    <a href="${pageContext.request.contextPath}/quiz-lab?action=edit&id=${q.id}" class="btn btn-outline btn-sm" title="Chỉnh sửa đề thi">
                                        <i class="fas fa-edit"></i> Sửa
                                    </a>
                                    <a href="${pageContext.request.contextPath}/quiz-manage?action=delete&id=${q.id}" 
                                       class="btn btn-danger btn-sm" 
                                       onclick="return confirm('Bạn chắc chắn muốn xóa bộ đề này cùng toàn bộ câu hỏi liên quan?');"
                                       title="Xóa đề">
                                        <i class="fas fa-trash"></i>
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
        <div class="card" style="text-align: center; padding: 48px 24px; border-radius: 12px;">
            <div style="width: 64px; height: 64px; border-radius: 50%; background: #f1f5f9; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; color: var(--text-muted); font-size: 1.8rem;">
                <i class="fas fa-folder-open"></i>
            </div>
            <h3 style="margin-bottom: 8px; font-weight: 700;">Bạn chưa có đề thi nào</h3>
            <p style="color: var(--text-secondary); margin-bottom: 20px; font-size: 0.95rem;">Bắt đầu biên soạn bộ đề kiểm tra trắc nghiệm đầu tiên của bạn!</p>
            <a href="${pageContext.request.contextPath}/quiz-lab" class="btn btn-primary">
                <i class="fas fa-plus"></i> Tạo đề thi mới
            </a>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
