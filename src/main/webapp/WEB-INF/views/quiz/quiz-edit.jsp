<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Chỉnh Sửa Đề Thi: ${quiz.title} - QuizMaster" />
<c:set var="activePage" value="quiz-manage" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="margin-bottom: 28px;">
    <a href="${pageContext.request.contextPath}/quiz-manage" class="btn btn-outline btn-sm" style="margin-bottom: 12px;">
        <i class="fas fa-arrow-left"></i> Quay lại quản lý đề
    </a>
    <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Chỉnh Sửa Đề Thi</h1>
    <p style="color: var(--text-secondary);">Cập nhật thông tin và chỉnh sửa/bổ sung câu hỏi trắc nghiệm</p>
</div>

<form id="editQuizForm" action="${pageContext.request.contextPath}/quiz-manage" method="POST">
    <input type="hidden" name="action" value="edit">
    <input type="hidden" name="id" value="${quiz.id}">

    <!-- Khối Thông tin tổng quan đề thi -->
    <div class="card" style="padding: 28px; margin-bottom: 28px;">
        <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 20px; color: var(--primary);">
            <i class="fas fa-info-circle"></i> 1. Thông tin bộ đề
        </h3>

        <div class="form-group">
            <label class="form-label">Tiêu đề bộ đề thi <span style="color: red;">*</span></label>
            <input type="text" name="title" class="form-control" value="${quiz.title}" required>
        </div>

        <div class="form-group">
            <label class="form-label">Mô tả tóm tắt nội dung kiến thức</label>
            <textarea name="description" class="form-control" rows="2">${quiz.description}</textarea>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div class="form-group">
                <label class="form-label">Chủ đề môn học <span style="color: red;">*</span></label>
                <select name="categoryId" class="form-control" required>
                    <c:forEach items="${categories}" var="c">
                        <option value="${c.id}" ${quiz.categoryId == c.id ? 'selected' : ''}>${c.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Thời gian thi (Phút) <span style="font-size: 0.8rem; color: var(--text-muted);">(0 = Không giới hạn)</span></label>
                <input type="number" name="timeLimit" class="form-control" value="${quiz.timeLimit}" min="0" max="300" required>
            </div>

            <div class="form-group">
                <label class="form-label">Mức độ thử thách <span style="color: red;">*</span></label>
                <select name="difficulty" class="form-control">
                    <option value="EASY" ${quiz.difficulty eq 'EASY' ? 'selected' : ''}>Dễ</option>
                    <option value="MEDIUM" ${quiz.difficulty eq 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                    <option value="HARD" ${quiz.difficulty eq 'HARD' ? 'selected' : ''}>Khó</option>
                </select>
            </div>
        </div>

        <!-- Cài đặt phòng thi Azota -->
        <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 16px; margin-bottom: 16px;">
            <h4 style="font-size: 0.95rem; font-weight: 700; color: #b45309; margin-bottom: 12px;">
                <i class="fas fa-sliders-h"></i> Cài đặt nâng cao (Azota Features):
            </h4>
            
            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px; margin-bottom: 14px;">
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-size: 0.9rem;">
                    <input type="checkbox" name="shuffleQuestions" ${quiz.shuffleQuestions ? 'checked' : ''} style="width: 18px; height: 18px;">
                    <span><i class="fas fa-random" style="color: var(--primary);"></i> Đảo ngẫu nhiên câu hỏi</span>
                </label>
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-size: 0.9rem;">
                    <input type="checkbox" name="shuffleOptions" ${quiz.shuffleOptions ? 'checked' : ''} style="width: 18px; height: 18px;">
                    <span><i class="fas fa-sort-alpha-down" style="color: #06b6d4;"></i> Đảo ngẫu nhiên đáp án</span>
                </label>
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-size: 0.9rem;">
                    <input type="checkbox" name="showAnswers" ${quiz.showAnswers ? 'checked' : ''} style="width: 18px; height: 18px;">
                    <span><i class="fas fa-eye" style="color: #10b981;"></i> Cho xem đáp án sau khi thi</span>
                </label>
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-size: 0.9rem;">
                    <input type="checkbox" name="antiCheat" ${quiz.antiCheat ? 'checked' : ''} style="width: 18px; height: 18px;">
                    <span><i class="fas fa-shield-alt" style="color: #ef4444;"></i> Giám sát thi (Chống chuyển tab)</span>
                </label>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                <div>
                    <label class="form-label" style="font-size: 0.85rem;"><i class="fas fa-key"></i> Mật khẩu phòng thi (Mã bảo vệ)</label>
                    <input type="text" name="accessCode" class="form-control" value="${quiz.accessCode}" placeholder="Để trống nếu vào tự do...">
                </div>
                <div>
                    <label class="form-label" style="font-size: 0.85rem;"><i class="fas fa-redo-alt"></i> Số lượt thi tối đa</label>
                    <select name="maxAttempts" class="form-control">
                        <option value="0" ${quiz.maxAttempts == 0 ? 'selected' : ''}>0: Không giới hạn số lần thi</option>
                        <option value="1" ${quiz.maxAttempts == 1 ? 'selected' : ''}>1: Chỉ được thi 1 lần duy nhất</option>
                        <option value="2" ${quiz.maxAttempts == 2 ? 'selected' : ''}>2: Tối đa 2 lần làm bài</option>
                        <option value="3" ${quiz.maxAttempts == 3 ? 'selected' : ''}>3: Tối đa 3 lần làm bài</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="form-group" style="margin-bottom: 0;">
            <label style="display: inline-flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600;">
                <input type="checkbox" name="isPublic" ${quiz.isPublic ? 'checked' : ''} style="width: 18px; height: 18px;">
                <span>Công khai bộ đề này trên kho đề chung</span>
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

    <div id="initialQuestionsData" style="display: none;">
        <c:forEach items="${quiz.questions}" var="q">
            <div class="initial-q-item">
                <input type="hidden" class="raw-id" value="${q.id}" />
                <textarea class="raw-text"><c:out value="${q.questionText}"/></textarea>
                <textarea class="raw-a"><c:out value="${q.optionA}"/></textarea>
                <textarea class="raw-b"><c:out value="${q.optionB}"/></textarea>
                <textarea class="raw-c"><c:out value="${q.optionC}"/></textarea>
                <textarea class="raw-d"><c:out value="${q.optionD}"/></textarea>
                <input type="hidden" class="raw-correct" value="<c:out value='${q.correctOption}'/>" />
                <textarea class="raw-exp"><c:out value="${q.explanation}"/></textarea>
            </div>
        </c:forEach>
    </div>

    <div id="questionsContainer">
        <!-- Sẽ được populate dữ liệu cũ qua script bên dưới -->
    </div>

    <!-- Thanh nút hành động cuối trang -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--border-color);">
        <button type="button" class="btn btn-outline" onclick="addQuestionCard()">
            <i class="fas fa-plus-circle"></i> Thêm câu hỏi nữa
        </button>
        <button type="submit" class="btn btn-primary btn-lg">
            <i class="fas fa-save"></i> Cập nhật đề thi
        </button>
    </div>
</form>

<script>
    function initEditQuestions() {
        const initialCards = document.querySelectorAll('#initialQuestionsData .initial-q-item');
        if (initialCards && initialCards.length > 0) {
            initialCards.forEach(item => {
                const qId = parseInt(item.querySelector('.raw-id')?.value) || 0;
                const text = item.querySelector('.raw-text')?.value || '';
                const a = item.querySelector('.raw-a')?.value || '';
                const b = item.querySelector('.raw-b')?.value || '';
                const c = item.querySelector('.raw-c')?.value || '';
                const d = item.querySelector('.raw-d')?.value || '';
                const correct = item.querySelector('.raw-correct')?.value || 'A';
                const exp = item.querySelector('.raw-exp')?.value || '';

                addQuestionCard({
                    id: qId,
                    text: text,
                    a: a,
                    b: b,
                    c: c,
                    d: d,
                    correct: correct,
                    points: 1,
                    explanation: exp
                });
            });
        } else {
            addQuestionCard();
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initEditQuestions);
    } else {
        initEditQuestions();
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
