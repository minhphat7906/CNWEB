<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="isEdit" value="${not empty quiz and quiz.id > 0}" />
<c:set var="pageTitle" value="${isEdit ? 'Chỉnh Sửa Đề Thi - QuizMaster' : 'Biên Soạn Đề Thi - QuizMaster'}" />
<c:set var="activePage" value="quiz-lab" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Tiêu đề trang -->
<div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
            <span class="badge ${isEdit ? 'badge-primary' : 'badge-info'}" style="font-size: 0.8rem; padding: 4px 10px;">
                <i class="fas ${isEdit ? 'fa-pen-square' : 'fa-plus-circle'}"></i> ${isEdit ? 'Chế độ chỉnh sửa' : 'Tạo mới'}
            </span>
            <span style="font-size: 0.85rem; color: var(--text-muted);">${isEdit ? 'Cập nhật nội dung câu hỏi và thông số đề thi' : 'Soạn câu hỏi và thiết lập quy chế phòng thi'}</span>
        </div>
        <h1 style="font-size: 1.85rem; font-weight: 800; color: var(--text-primary); margin: 0; letter-spacing: -0.02em;">
            <c:choose>
                <c:when test="${isEdit}">Chỉnh Sửa: <c:out value="${quiz.title}"/></c:when>
                <c:otherwise>Biên Soạn Đề Thi Trắc Nghiệm</c:otherwise>
            </c:choose>
        </h1>
    </div>

    <div style="display: flex; gap: 10px;">
        <a href="${pageContext.request.contextPath}/quiz-manage" class="btn btn-outline">
            <i class="fas fa-folder"></i> Đề thi của tôi (${myQuizzesCount})
        </a>
        <c:if test="${isEdit}">
            <a href="${pageContext.request.contextPath}/quiz-lab" class="btn btn-primary">
                <i class="fas fa-plus"></i> Tạo đề mới
            </a>
        </c:if>
    </div>
</div>

<!-- Thanh chuyển bước quy trình biên soạn -->
<div style="display: flex; gap: 10px; margin-bottom: 24px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px;">
    <button type="button" id="tabBtn1" class="btn btn-primary" onclick="switchLabStep(1)" style="padding: 9px 20px; font-weight: 600; font-size: 0.92rem; border-radius: 8px;">
        <i class="fas fa-list-ol"></i> Bước 1: Soạn câu hỏi & Nội dung
    </button>
    <button type="button" id="tabBtn2" class="btn btn-outline" onclick="switchLabStep(2)" style="padding: 9px 20px; font-weight: 600; font-size: 0.92rem; border-radius: 8px;">
        <i class="fas fa-sliders-h"></i> Bước 2: Cài đặt đề thi
    </button>
</div>

<form id="quizLabForm" action="${pageContext.request.contextPath}/quiz-lab" method="POST" onsubmit="return validateAndCleanFormBeforeSubmit();">
    <c:if test="${isEdit}">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" value="${quiz.id}">
    </c:if>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: flex-start;">
        
        <!-- Cột trái: Khu vực soạn thảo chính theo từng bước -->
        <div>
            <!-- ======================================================== -->
            <!-- BƯỚC 1: SOẠN THẢO THÔNG TIN BỘ ĐỀ & NGÂN HÀNG CÂU HỎI      -->
            <!-- ======================================================== -->
            <div id="step1Container">
                <!-- Khối 1: Thông tin cơ bản bộ đề -->
                <div class="card" style="padding: 22px; margin-bottom: 20px; border-radius: 12px;">
                    <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 16px; color: var(--text-primary); display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-info-circle" style="color: var(--primary);"></i> Thông tin cơ bản đề thi
                    </h3>

                    <div class="form-group">
                        <label class="form-label">Tiêu đề bài thi <span style="color: red;">*</span></label>
                        <input type="text" id="quizTitleInput" name="title" class="form-control" value="<c:out value='${not empty quiz ? quiz.title : ""}'/>" placeholder="Ví dụ: Kiểm tra giữa kỳ Lập trình Web..." required autofocus>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mô tả & Hướng dẫn làm bài</label>
                        <textarea name="description" class="form-control" rows="2" placeholder="Ghi chú hướng dẫn cho thí sinh (tùy chọn)..."><c:out value="${not empty quiz ? quiz.description : ''}"/></textarea>
                    </div>

                    <input type="hidden" name="categoryId" value="${not empty quiz ? quiz.categoryId : 1}">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label class="form-label">Mức độ thử thách <span style="color: red;">*</span></label>
                        <select name="difficulty" class="form-control" style="max-width: 200px;">
                            <option value="EASY" ${not empty quiz && quiz.difficulty == 'EASY' ? 'selected' : ''}>Dễ</option>
                            <option value="MEDIUM" ${(empty quiz) || quiz.difficulty == 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                            <option value="HARD" ${not empty quiz && quiz.difficulty == 'HARD' ? 'selected' : ''}>Nâng cao</option>
                        </select>
                    </div>
                </div>

                <!-- Khối 2: Ngân hàng câu hỏi -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="font-size: 1.15rem; font-weight: 700; color: var(--text-primary); margin: 0; display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-tasks" style="color: var(--primary);"></i> Danh sách câu hỏi (<span id="totalQuestionsCount" style="color: var(--primary);">0</span>)
                    </h3>

                    <div style="display: flex; gap: 8px;">
                        <button type="button" class="btn btn-outline btn-sm" onclick="insertSampleQuestion()">
                            <i class="fas fa-magic"></i> Chèn câu mẫu
                        </button>
                        <button type="button" class="btn btn-primary btn-sm" onclick="addQuestionCard()">
                            <i class="fas fa-plus"></i> Thêm câu hỏi
                        </button>
                    </div>
                </div>

                <!-- Dữ liệu câu hỏi ban đầu khi Edit hoặc khi Form lỗi quay lại -->
                <!-- Sử dụng các trường textarea ẩn để bảo toàn 100% nội dung (kể cả ngoặc kép, nháy đơn, thẻ HTML hay newline) -->
                <div id="initialQuestionsData" style="display: none;">
                    <c:if test="${not empty quiz and not empty quiz.questions}">
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
                    </c:if>
                </div>

                <!-- Container chứa các câu hỏi động -->
                <div id="questionsContainer"></div>

                <div style="margin-top: 20px; display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
                    <button type="button" class="btn btn-outline" onclick="addQuestionCard()">
                        <i class="fas fa-plus-circle"></i> Thêm câu hỏi tiếp theo
                    </button>
                    <div style="margin-left: auto; display: flex; gap: 10px;">
                        <button type="submit" form="quizLabForm" class="btn btn-success" style="padding: 10px 22px; font-weight: 600;">
                            <i class="fas fa-save"></i> ${isEdit ? 'Lưu thay đổi ngay' : 'Lưu bộ đề'}
                        </button>
                        <button type="button" class="btn btn-primary" style="padding: 10px 22px;" onclick="switchLabStep(2)">
                            Cài đặt quy chế <i class="fas fa-arrow-right" style="margin-left: 6px;"></i>
                        </button>
                    </div>
                </div>
            </div>

            <!-- ======================================================== -->
            <!-- BƯỚC 2: CÀI ĐẶT CHO ĐỀ THI (THỜI GIAN, BẢO MẬT, XẾP HẠNG) -->
            <!-- ======================================================== -->
            <div id="step2Container" style="display: none;">
                <div class="card" style="padding: 24px; margin-bottom: 20px; border-radius: 12px;">
                    <div style="margin-bottom: 18px;">
                        <h3 style="font-size: 1.15rem; font-weight: 700; color: var(--text-primary); margin: 0 0 4px; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-sliders-h" style="color: var(--primary);"></i> Cài đặt quy chế đề thi
                        </h3>
                        <p style="color: var(--text-secondary); margin: 0; font-size: 0.88rem;">
                            Thiết lập thời gian làm bài, chống gian lận, đảo đề và quyền xem kết quả
                        </p>
                    </div>

                    <!-- 1. Cài đặt thời gian thi: Hỗ trợ 0 = Không giới hạn -->
                    <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 16px; margin-bottom: 18px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <label class="form-label" style="margin: 0; font-weight: 600;">
                                <i class="far fa-clock" style="color: var(--primary);"></i> Thời gian làm bài (Phút):
                            </label>
                            <span id="timeLimitBadge" class="badge badge-primary" style="font-size: 0.82rem;">15 phút</span>
                        </div>

                        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
                            <input type="number" id="timeLimitInput" name="timeLimit" class="form-control" value="${isEdit ? quiz.timeLimit : 15}" min="0" max="300" style="max-width: 120px; font-weight: 700; font-size: 1.05rem;" oninput="onTimeLimitChange(this.value)">
                            <span style="font-size: 0.85rem; color: var(--text-muted);">(Nhập <strong>0</strong> để làm bài <strong>không giới hạn thời gian</strong>)</span>
                        </div>

                        <!-- Nút chọn nhanh thời gian -->
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(0)"><i class="fas fa-infinity"></i> Không giới hạn</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(15)">15 phút</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(45)">45 phút</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(60)">60 phút</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(90)">90 phút</button>
                        </div>
                    </div>

                    <!-- 2. Lưới các cấu hình đề thi -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px;">
                        <!-- Đảo câu hỏi -->
                        <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="shuffleQuestions" id="shuffleQuestions" ${!isEdit || quiz.shuffleQuestions ? 'checked' : ''} style="width: 18px; height: 18px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.92rem; color: var(--text-primary);"><i class="fas fa-random" style="color: var(--primary);"></i> Đảo thứ tự câu hỏi</strong>
                                    <span style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.4;">Xáo trộn câu hỏi mỗi lượt thi tránh nhìn bài.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Đảo đáp án -->
                        <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="shuffleOptions" id="shuffleOptions" ${isEdit && quiz.shuffleOptions ? 'checked' : ''} style="width: 18px; height: 18px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.92rem; color: var(--text-primary);"><i class="fas fa-sort-alpha-down" style="color: #06b6d4;"></i> Đảo thứ tự đáp án</strong>
                                    <span style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.4;">Xáo trộn các lựa chọn A, B, C, D của từng câu.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Cho xem đáp án sau khi thi -->
                        <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="showAnswers" id="showAnswers" ${!isEdit || quiz.showAnswers ? 'checked' : ''} style="width: 18px; height: 18px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.92rem; color: var(--text-primary);"><i class="fas fa-check-double" style="color: #10b981;"></i> Xem đáp án & Lời giải</strong>
                                    <span style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.4;">Hiển thị đáp án đúng sau khi hoàn tất nộp bài.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Cho phép xem bảng xếp hạng -->
                        <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="showRanking" id="showRanking" ${isEdit && quiz.showRanking ? 'checked' : ''} style="width: 18px; height: 18px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.92rem; color: var(--text-primary);"><i class="fas fa-trophy" style="color: #f59e0b;"></i> Bảng xếp hạng điểm</strong>
                                    <span style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.4;">Cho phép thí sinh xem danh sách điểm cao nhất.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Giám sát chống gian lận -->
                        <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 14px; grid-column: span 2;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="antiCheat" id="antiCheat" ${!isEdit || quiz.antiCheat ? 'checked' : ''} style="width: 18px; height: 18px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.92rem; color: var(--text-primary);"><i class="fas fa-shield-alt" style="color: #ef4444;"></i> Giám sát thi (Cảnh báo chuyển tab)</strong>
                                    <span style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.4;">Tự động ghi nhận số lần thí sinh rời khỏi màn hình làm bài thi.</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- 3. Mật khẩu phòng thi & Số lần thi tối đa -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label"><i class="fas fa-key" style="color: #f59e0b;"></i> Mã PIN phòng thi</label>
                            <input type="text" name="accessCode" class="form-control" value="<c:out value='${isEdit ? quiz.accessCode : ""}'/>" placeholder="Để trống nếu vào thi tự do...">
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label"><i class="fas fa-redo-alt" style="color: var(--primary);"></i> Số lần làm bài tối đa</label>
                            <select name="maxAttempts" class="form-control">
                                <option value="0" ${!isEdit || quiz.maxAttempts == 0 ? 'selected' : ''}>Không giới hạn số lần làm</option>
                                <option value="1" ${isEdit && quiz.maxAttempts == 1 ? 'selected' : ''}>Chỉ làm 1 lần duy nhất</option>
                                <option value="2" ${isEdit && quiz.maxAttempts == 2 ? 'selected' : ''}>Tối đa 2 lần</option>
                                <option value="3" ${isEdit && quiz.maxAttempts == 3 ? 'selected' : ''}>Tối đa 3 lần</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 0; padding-top: 14px; border-top: 1px solid var(--border-color);">
                        <label style="display: inline-flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 500; font-size: 0.9rem;">
                            <input type="checkbox" name="isPublic" ${!isEdit || quiz.isPublic ? 'checked' : ''} style="width: 17px; height: 17px;">
                            <span><i class="fas fa-globe" style="color: var(--primary);"></i> Công khai lên Kho đề chung cho mọi người cùng ôn luyện</span>
                        </label>
                    </div>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px;">
                    <button type="button" class="btn btn-outline" onclick="switchLabStep(1)">
                        <i class="fas fa-arrow-left"></i> Quay lại sửa câu hỏi
                    </button>
                    <button type="submit" class="btn btn-primary btn-lg" style="padding: 10px 28px;">
                        <i class="fas fa-check-circle"></i> ${isEdit ? 'Lưu thay đổi đề thi' : 'Xuất bản đề thi'}
                    </button>
                </div>
            </div>
        </div>

        <!-- Cột phải: Bảng thông số tóm tắt -->
        <div>
            <div class="card" style="padding: 22px; position: sticky; top: 85px; border-radius: 12px;">
                <h4 style="font-size: 1.05rem; font-weight: 700; margin-bottom: 16px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; color: var(--text-primary);">
                    <i class="fas fa-clipboard-check" style="color: var(--primary);"></i> Tóm tắt đề thi
                </h4>

                <div style="display: flex; flex-direction: column; gap: 12px; font-size: 0.9rem; margin-bottom: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="color: var(--text-secondary);"><i class="fas fa-list-ol" style="width: 18px;"></i> Số câu hỏi:</span>
                        <strong id="labStatQuestions" style="color: var(--text-primary);">0 câu</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="color: var(--text-secondary);"><i class="far fa-clock" style="width: 18px;"></i> Thời lượng:</span>
                        <strong id="labStatTime" style="color: var(--text-primary);">15 phút</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="color: var(--text-secondary);"><i class="fas fa-tasks" style="width: 18px;"></i> Tiến trình:</span>
                        <span id="labStatStep" class="badge badge-primary">Bước 1: Soạn câu hỏi</span>
                    </div>
                </div>

                <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 8px; padding: 12px; font-size: 0.82rem; color: var(--text-secondary); line-height: 1.5; margin-bottom: 18px;">
                    Hoàn tất nhập nội dung câu hỏi ở <strong>Bước 1</strong>, sau đó thiết lập thời gian và bảo mật ở <strong>Bước 2</strong> trước khi xuất bản.
                </div>

                <div id="sideActionBtn" style="display: flex; flex-direction: column; gap: 8px;">
                    <button type="submit" form="quizLabForm" class="btn btn-primary btn-block" style="padding: 11px;">
                        <i class="fas fa-check-circle"></i> ${isEdit ? 'Lưu thay đổi đề thi' : 'Xuất bản đề thi'}
                    </button>
                    <button type="button" class="btn btn-outline btn-block" style="padding: 9px;" onclick="switchLabStep(2)">
                        Cài đặt quy chế <i class="fas fa-sliders-h" style="margin-left: 6px;"></i>
                    </button>
                </div>
            </div>
        </div>

    </div>
</form>

<script>
    let currentLabStep = 1;

    function switchLabStep(step) {
        currentLabStep = step;
        const s1 = document.getElementById('step1Container');
        const s2 = document.getElementById('step2Container');
        const b1 = document.getElementById('tabBtn1');
        const b2 = document.getElementById('tabBtn2');
        const stepStat = document.getElementById('labStatStep');
        const sideAction = document.getElementById('sideActionBtn');

        if (step === 1) {
            s1.style.display = 'block';
            s2.style.display = 'none';
            b1.className = 'btn btn-primary';
            b2.className = 'btn btn-outline';
            if (stepStat) stepStat.innerText = 'Bước 1: Soạn câu hỏi';
            if (sideAction) {
                sideAction.innerHTML = `
                    <button type="submit" form="quizLabForm" class="btn btn-primary btn-block" style="padding: 11px;">
                        <i class="fas fa-check-circle"></i> ${isEdit ? 'Lưu thay đổi đề thi' : 'Xuất bản đề thi'}
                    </button>
                    <button type="button" class="btn btn-outline btn-block" style="padding: 9px;" onclick="switchLabStep(2)">
                        Cài đặt quy chế <i class="fas fa-sliders-h" style="margin-left: 6px;"></i>
                    </button>
                `;
            }
        } else {
            // Kiểm tra tiêu đề trước khi qua bước 2
            const titleInput = document.getElementById('quizTitleInput');
            if (titleInput && !titleInput.value.trim()) {
                alert('Vui lòng nhập Tiêu đề bài thi trước khi sang bước Cài đặt!');
                titleInput.focus();
                return;
            }

            s1.style.display = 'none';
            s2.style.display = 'block';
            b1.className = 'btn btn-outline';
            b2.className = 'btn btn-primary';
            if (stepStat) stepStat.innerText = 'Bước 2: Cài đặt đề thi';
            if (sideAction) {
                sideAction.innerHTML = `
                    <button type="submit" form="quizLabForm" class="btn btn-primary btn-block" style="padding: 11px;">
                        <i class="fas fa-check-circle"></i> ${isEdit ? 'Lưu thay đổi đề thi' : 'Xuất bản đề thi'}
                    </button>
                    <button type="button" class="btn btn-outline btn-block" style="padding: 9px;" onclick="switchLabStep(1)">
                        <i class="fas fa-arrow-left" style="margin-right: 6px;"></i> Quay lại sửa câu hỏi
                    </button>
                `;
            }
        }
        window.scrollTo({ top: 120, behavior: 'smooth' });
    }

    /**
     * Kiểm tra hợp lệ và tự động dọn sạch các thẻ câu hỏi rỗng trước khi submit
     */
    function validateAndCleanFormBeforeSubmit() {
        const titleInput = document.getElementById('quizTitleInput');
        if (!titleInput || !titleInput.value.trim()) {
            alert('Vui lòng nhập Tiêu đề bài thi!');
            switchLabStep(1);
            if (titleInput) titleInput.focus();
            return false;
        }

        const cards = document.querySelectorAll('.question-builder-card');
        let validCards = [];

        cards.forEach((card, idx) => {
            const text = (card.querySelector('textarea[name="questionText"]')?.value || '').trim();
            const a = (card.querySelector('input[name="optionA"]')?.value || '').trim();
            const b = (card.querySelector('input[name="optionB"]')?.value || '').trim();
            const c = (card.querySelector('input[name="optionC"]')?.value || '').trim();
            const d = (card.querySelector('input[name="optionD"]')?.value || '').trim();

            // Nếu câu này trống hoàn toàn (cả câu hỏi và các đáp án đều rỗng) -> tự động xóa thẻ rỗng
            if (!text && !a && !b && !c && !d) {
                card.remove();
            } else {
                validCards.push({ card, text, a, b, c, d, index: idx + 1 });
            }
        });

        if (validCards.length === 0) {
            alert('Vui lòng soạn ít nhất 1 câu hỏi trắc nghiệm có đầy đủ nội dung và đáp án!');
            switchLabStep(1);
            addQuestionCard();
            return false;
        }

        // Kiểm tra xem có câu nào điền dở dang (ví dụ có câu hỏi mà thiếu đáp án)
        for (let item of validCards) {
            if (!item.text) {
                alert('Câu hỏi #' + item.index + ' chưa có nội dung câu hỏi!');
                switchLabStep(1);
                item.card.querySelector('textarea[name="questionText"]')?.focus();
                return false;
            }
            if (!item.a || !item.b || !item.c || !item.d) {
                alert('Câu hỏi #' + item.index + ' chưa điền đủ 4 đáp án A, B, C, D!');
                switchLabStep(1);
                return false;
            }
        }

        // Xóa bản nháp nếu submit
        try {
            localStorage.removeItem('quizmaster_draft_quiz');
        } catch (e) {}

        return true;
    }

    function initQuizLabQuestions() {
        // Cập nhật nhãn thời gian ban đầu
        const timeInput = document.getElementById('timeLimitInput');
        if (timeInput) {
            onTimeLimitChange(timeInput.value);
        }

        // Tải danh sách câu hỏi: nếu có dữ liệu truyền về (Edit hoặc khi Submit lỗi quay lại)
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
            // Tự động khởi tạo 1 câu hỏi trống khi mở trang mới
            addQuestionCard();
        }

        // Theo dõi thay đổi số lượng câu hỏi để cập nhật chỉ số
        const observer = new MutationObserver(function() {
            const count = document.querySelectorAll('.question-builder-card').length;
            const statEl = document.getElementById('labStatQuestions');
            if (statEl) statEl.innerText = count + ' câu';
        });

        const container = document.getElementById('questionsContainer');
        if (container) {
            observer.observe(container, { childList: true });
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initQuizLabQuestions);
    } else {
        initQuizLabQuestions();
    }

    /**
     * Chèn nhanh 1 câu hỏi mẫu về Java Web / MySQL cho tiện kiểm thử
     */
    function insertSampleQuestion() {
        const samplePool = [
            {
                text: "Trong chu trình sống (Lifecycle) của Java Servlet, phương thức nào được gọi cho mỗi request từ Client gửi đến?",
                a: "init()",
                b: "service()",
                c: "destroy()",
                d: "doGet()",
                correct: "B",
                points: 1,
                explanation: "Container gọi phương thức service() cho mỗi request. Phương thức service() sẽ phân tích HTTP Method và ủy quyền xử lý tiếp sang doGet(), doPost()."
            },
            {
                text: "Để lưu thông tin giỏ hàng hoặc trạng thái đăng nhập qua nhiều trang JSP khác nhau, đối tượng ngầm định nào được sử dụng?",
                a: "request",
                b: "pageContext",
                c: "session",
                d: "application",
                correct: "C",
                points: 1,
                explanation: "HttpSession duy trì trạng thái của một phiên làm việc cụ thể giữa Client và Server."
            }
        ];

        const randomIndex = Math.floor(Math.random() * samplePool.length);
        addQuestionCard(samplePool[randomIndex]);
    }

    function setTimePreset(mins) {
        const input = document.getElementById('timeLimitInput');
        if (input) {
            input.value = mins;
            onTimeLimitChange(mins);
        }
    }

    function onTimeLimitChange(val) {
        const mins = parseInt(val) || 0;
        const badge = document.getElementById('timeLimitBadge');
        const statTime = document.getElementById('labStatTime');
        
        let label = (mins <= 0) ? 'Không giới hạn' : (mins + ' phút');
        if (badge) {
            badge.innerText = label;
            badge.className = (mins <= 0) ? 'badge badge-success' : 'badge badge-primary';
        }
        if (statTime) {
            statTime.innerText = label;
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
