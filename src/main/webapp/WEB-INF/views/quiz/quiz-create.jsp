<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Soạn Đề Thi Mới - QuizMaster" />
<c:set var="activePage" value="quiz-manage" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="margin-bottom: 28px;">
    <a href="${pageContext.request.contextPath}/quiz-manage" class="btn btn-outline btn-sm" style="margin-bottom: 12px;">
        <i class="fas fa-arrow-left"></i> Quay lại quản lý đề
    </a>
    <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Biên Soạn Đề Thi Trắc Nghiệm Mới</h1>
    <p style="color: var(--text-secondary);">Nhập thông tin đề thi và thêm không giới hạn các câu hỏi trắc nghiệm 4 đáp án (A, B, C, D)</p>
</div>

<form id="createQuizForm" action="${pageContext.request.contextPath}/quiz-manage" method="POST">
    <input type="hidden" name="action" value="create">

    <!-- Khối Thông tin tổng quan đề thi -->
    <div class="card" style="padding: 28px; margin-bottom: 28px;">
        <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 20px; color: var(--primary);">
            <i class="fas fa-info-circle"></i> 1. Thông tin bộ đề
        </h3>

        <div class="form-group">
            <label class="form-label">Tiêu đề bộ đề thi <span style="color: red;">*</span></label>
            <input type="text" name="title" class="form-control" placeholder="Ví dụ: Ôn tập Kiểm tra Giữa kỳ Công nghệ Web..." required autofocus>
        </div>

        <div class="form-group">
            <label class="form-label">Mô tả tóm tắt nội dung kiến thức</label>
            <textarea name="description" class="form-control" rows="2" placeholder="Bộ đề kiểm tra kiến thức về..."></textarea>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div class="form-group">
                <label class="form-label">Chủ đề môn học <span style="color: red;">*</span></label>
                <select name="categoryId" class="form-control" required>
                    <c:forEach items="${categories}" var="c">
                        <option value="${c.id}">${c.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Thời gian làm bài (Phút) <span style="color: red;">*</span></label>
                <input type="number" name="timeLimit" class="form-control" value="15" min="1" max="180" required>
            </div>

            <div class="form-group">
                <label class="form-label">Mức độ thử thách <span style="color: red;">*</span></label>
                <select name="difficulty" class="form-control">
                    <option value="EASY">Dễ (Dành cho người mới)</option>
                    <option value="MEDIUM" selected>Trung bình (Chuẩn kiến thức)</option>
                    <option value="HARD">Khó (Nâng cao & Chuyên sâu)</option>
                </select>
            </div>
        </div>

        <div class="form-group" style="margin-bottom: 0;">
            <label style="display: inline-flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600;">
                <input type="checkbox" name="isPublic" checked style="width: 18px; height: 18px;">
                <span>Công khai bộ đề này trên kho đề chung cho tất cả học viên ôn tập</span>
            </label>
        </div>
    </div>

    <!-- Khối Danh sách câu hỏi động -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h3 style="font-size: 1.25rem; font-weight: 800; color: var(--primary);">
            <i class="fas fa-list-ol"></i> 2. Ngân hàng câu hỏi (<span id="totalQuestionsCount">0</span> câu)
        </h3>
        <button type="button" class="btn btn-outline btn-sm" onclick="addQuestionCard()">
            <i class="fas fa-plus"></i> Thêm câu hỏi
        </button>
    </div>

    <div id="questionsContainer">
        <!-- Các câu hỏi động sẽ được render vào đây qua quiz-builder.js -->
    </div>

    <!-- Thanh nút hành động cuối trang -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--border-color);">
        <button type="button" class="btn btn-outline" onclick="addQuestionCard()">
            <i class="fas fa-plus-circle"></i> Thêm câu hỏi nữa
        </button>
        <button type="submit" class="btn btn-primary btn-lg">
            <i class="fas fa-save"></i> Lưu & Xuất bản đề thi
        </button>
    </div>
</form>

<script>
    function initCreateQuestions() {
        if (document.querySelectorAll('.question-builder-card').length === 0) {
            addQuestionCard();
            addQuestionCard();
        }
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initCreateQuestions);
    } else {
        initCreateQuestions();
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
