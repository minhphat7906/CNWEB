<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="isEdit" value="${not empty quiz and not empty quiz.id}" />
<c:set var="pageTitle" value="${isEdit ? 'Chỉnh Sửa Bộ Đề - Quiz Lab Studio' : 'Phòng Lab Soạn Đề - QuizMaster Studio'}" />
<c:set var="activePage" value="quiz-lab" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Tiêu đề Phòng Lab -->
<div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
            <span class="badge ${isEdit ? 'badge-primary' : 'badge-warning'}" style="font-size: 0.85rem; padding: 6px 12px;">
                <i class="fas ${isEdit ? 'fa-edit' : 'fa-flask'}"></i> ${isEdit ? 'Lab Editor' : 'Quiz Lab Studio'}
            </span>
            <span style="font-size: 0.85rem; color: var(--text-muted);">${isEdit ? 'Hiệu chỉnh & tối ưu nội dung đề thi' : 'Không gian nghiên cứu & sáng tạo đề thi'}</span>
        </div>
        <h1 style="font-size: 2.1rem; font-weight: 800; color: var(--text-primary); margin: 0;">
            <c:choose>
                <c:when test="${isEdit}">Chỉnh Sửa Đề Thi: <c:out value="${quiz.title}"/></c:when>
                <c:otherwise>Phòng Lab Soạn Đề Trắc Nghiệm</c:otherwise>
            </c:choose>
        </h1>
        <p style="color: var(--text-secondary); margin-top: 4px;">
            Hệ thống hỗ trợ biên soạn đề thi tương tác hai bước: Soạn thảo câu hỏi & Cài đặt thông số phòng thi an toàn
        </p>
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

<!-- Thanh chuyển Tab/Bước theo quy trình -->
<div style="display: flex; gap: 12px; margin-bottom: 24px; border-bottom: 2px solid var(--border-color); padding-bottom: 2px;">
    <button type="button" id="tabBtn1" class="btn btn-primary" onclick="switchLabStep(1)" style="border-bottom-left-radius: 0; border-bottom-right-radius: 0; padding: 10px 22px; font-weight: 700;">
        <i class="fas fa-edit"></i> Bước 1: Soạn câu hỏi & Nội dung
    </button>
    <button type="button" id="tabBtn2" class="btn btn-outline" onclick="switchLabStep(2)" style="border-bottom-left-radius: 0; border-bottom-right-radius: 0; padding: 10px 22px; font-weight: 700;">
        <i class="fas fa-sliders-h"></i> Bước 2: Cài đặt cho đề thi
    </button>
</div>

<form id="quizLabForm" action="${pageContext.request.contextPath}/quiz-lab" method="POST">
    <c:if test="${isEdit}">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" value="${quiz.id}">
    </c:if>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 28px; align-items: flex-start;">
        
        <!-- Cột trái: Khu vực soạn thảo chính theo từng bước -->
        <div>
            <!-- ======================================================== -->
            <!-- BƯỚC 1: SOẠN THẢO THÔNG TIN BỘ ĐỀ & NGÂN HÀNG CÂU HỎI      -->
            <!-- ======================================================== -->
            <div id="step1Container">
                <!-- Khối 1: Thông tin cơ bản bộ đề -->
                <div class="card" style="padding: 24px; margin-bottom: 24px; border-left: 4px solid var(--primary);">
                    <h3 style="font-size: 1.15rem; font-weight: 800; margin-bottom: 16px; color: var(--primary);">
                        <i class="fas fa-info-circle"></i> 1. Thông tin cơ bản đề thi
                    </h3>

                    <div class="form-group">
                        <label class="form-label">Tiêu đề bài thi <span style="color: red;">*</span></label>
                        <input type="text" id="quizTitleInput" name="title" class="form-control" value="<c:out value='${isEdit ? quiz.title : ""}'/>" placeholder="Nhập tên đề thi trắc nghiệm..." required autofocus>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mục tiêu & Hướng dẫn làm bài</label>
                        <textarea name="description" class="form-control" rows="2" placeholder="Bộ đề kiểm tra đánh giá kiến thức về..."><c:out value="${isEdit ? quiz.description : ''}"/></textarea>
                    </div>

                    <input type="hidden" name="categoryId" value="${isEdit ? quiz.categoryId : 1}">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label class="form-label">Mức độ thử thách <span style="color: red;">*</span></label>
                        <select name="difficulty" class="form-control" style="max-width: 240px;">
                            <option value="EASY" ${isEdit && quiz.difficulty == 'EASY' ? 'selected' : ''}>Dễ</option>
                            <option value="MEDIUM" ${(!isEdit && true) || quiz.difficulty == 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                            <option value="HARD" ${isEdit && quiz.difficulty == 'HARD' ? 'selected' : ''}>Nâng cao</option>
                        </select>
                    </div>
                </div>

                <!-- Khối 2: Ngân hàng câu hỏi trong Lab -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="font-size: 1.25rem; font-weight: 800; color: var(--primary);">
                        <i class="fas fa-microscope"></i> 2. Ngân hàng câu hỏi (<span id="totalQuestionsCount">0</span> câu)
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

                <!-- Dữ liệu câu hỏi ban đầu khi Edit -->
                <div id="initialQuestionsData" style="display: none;">
                    <c:if test="${isEdit and not empty quiz.questions}">
                        <c:forEach items="${quiz.questions}" var="q">
                            <div class="initial-q-item"
                                 data-text="<c:out value='${q.questionText}'/>"
                                 data-a="<c:out value='${q.optionA}'/>"
                                 data-b="<c:out value='${q.optionB}'/>"
                                 data-c="<c:out value='${q.optionC}'/>"
                                 data-d="<c:out value='${q.optionD}'/>"
                                 data-correct="<c:out value='${q.correctOption}'/>"
                                 data-explanation="<c:out value='${q.explanation}'/>">
                            </div>
                        </c:forEach>
                    </c:if>
                </div>

                <!-- Container chứa các câu hỏi động -->
                <div id="questionsContainer"></div>

                <div style="margin-top: 20px; display: flex; gap: 12px; align-items: center;">
                    <button type="button" class="btn btn-outline" onclick="addQuestionCard()">
                        <i class="fas fa-plus-circle"></i> Thêm câu hỏi tiếp theo
                    </button>
                    <button type="button" class="btn btn-primary btn-lg" style="margin-left: auto;" onclick="switchLabStep(2)">
                        Tiếp tục: Cài đặt cho đề thi <i class="fas fa-arrow-right" style="margin-left: 6px;"></i>
                    </button>
                </div>
            </div>

            <!-- ======================================================== -->
            <!-- BƯỚC 2: CÀI ĐẶT CHO ĐỀ THI (THỜI GIAN, BẢO MẬT, XẾP HẠNG) -->
            <!-- ======================================================== -->
            <div id="step2Container" style="display: none;">
                <div class="card" style="padding: 28px; margin-bottom: 24px; border-left: 4px solid #f59e0b;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px;">
                        <div>
                            <h3 style="font-size: 1.25rem; font-weight: 800; color: #b45309; margin: 0 0 4px;">
                                <i class="fas fa-sliders-h"></i> Cài đặt cho đề thi
                            </h3>
                            <p style="color: var(--text-secondary); margin: 0; font-size: 0.9rem;">
                                Thiết lập thời gian làm bài, quy chế bảo mật, đảo đề và quyền xem kết quả
                            </p>
                        </div>
                        <span class="badge badge-warning" style="font-size: 0.78rem;"><i class="fas fa-cog"></i> Exam Settings</span>
                    </div>

                    <!-- 1. Cài đặt thời gian thi: Hỗ trợ 0 = Không giới hạn -->
                    <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 18px; margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <label class="form-label" style="margin: 0; font-weight: 700;">
                                <i class="far fa-clock" style="color: var(--primary);"></i> Thời gian làm bài (Phút):
                            </label>
                            <span id="timeLimitBadge" class="badge badge-primary" style="font-size: 0.85rem;">15 phút</span>
                        </div>

                        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
                            <input type="number" id="timeLimitInput" name="timeLimit" class="form-control" value="${isEdit ? quiz.timeLimit : 15}" min="0" max="300" style="max-width: 140px; font-weight: 700; font-size: 1.1rem;" oninput="onTimeLimitChange(this.value)">
                            <span style="font-size: 0.88rem; color: var(--text-muted);">(Nhập <strong>0</strong> để làm bài <strong>KHÔNG GIỚI HẠN THỜI GIAN</strong>)</span>
                        </div>

                        <!-- Nút chọn nhanh thời gian -->
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(0)"><i class="fas fa-infinity"></i> 0: Không giới hạn</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(15)">15 phút</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(45)">45 phút</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(60)">60 phút</button>
                            <button type="button" class="btn btn-outline btn-sm" onclick="setTimePreset(90)">90 phút</button>
                        </div>
                    </div>

                    <!-- 2. Lưới các Toggle Switch cấu hình đề thi -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                        <!-- Đảo câu hỏi -->
                        <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="shuffleQuestions" id="shuffleQuestions" ${!isEdit || quiz.shuffleQuestions ? 'checked' : ''} style="width: 20px; height: 20px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.95rem; color: var(--text-primary);"><i class="fas fa-random" style="color: #4f46e5;"></i> Đảo câu hỏi</strong>
                                    <span style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.4;">Xáo trộn ngẫu nhiên thứ tự câu hỏi mỗi lần thí sinh vào thi.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Đảo đáp án -->
                        <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="shuffleOptions" id="shuffleOptions" ${isEdit && quiz.shuffleOptions ? 'checked' : ''} style="width: 20px; height: 20px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.95rem; color: var(--text-primary);"><i class="fas fa-sort-alpha-down" style="color: #06b6d4;"></i> Đảo đáp án</strong>
                                    <span style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.4;">Xáo trộn các lựa chọn A, B, C, D của từng câu hỏi.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Cho xem đáp án sau khi thi -->
                        <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="showAnswers" id="showAnswers" ${!isEdit || quiz.showAnswers ? 'checked' : ''} style="width: 20px; height: 20px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.95rem; color: var(--text-primary);"><i class="fas fa-eye" style="color: #10b981;"></i> Cho xem đáp án</strong>
                                    <span style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.4;">Hiển thị đáp án đúng và lời giải chi tiết ngay sau khi nộp bài.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Cho phép xem bảng xếp hạng -->
                        <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="showRanking" id="showRanking" ${isEdit && quiz.showRanking ? 'checked' : ''} style="width: 20px; height: 20px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.95rem; color: var(--text-primary);"><i class="fas fa-trophy" style="color: #f59e0b;"></i> Cho xem bảng xếp hạng</strong>
                                    <span style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.4;">Nếu tắt, thí sinh sẽ không thể xem bảng xếp hạng hoặc điểm của người khác.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Giám sát chống gian lận -->
                        <div style="background: var(--bg-page); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px; grid-column: span 2;">
                            <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="antiCheat" id="antiCheat" ${!isEdit || quiz.antiCheat ? 'checked' : ''} style="width: 20px; height: 20px; margin-top: 2px;">
                                <div>
                                    <strong style="display: block; font-size: 0.95rem; color: var(--text-primary);"><i class="fas fa-shield-alt" style="color: #ef4444;"></i> Giám sát thi (Phát hiện chuyển tab)</strong>
                                    <span style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.4;">Cảnh báo & đếm số lần thí sinh chuyển tab hoặc rời màn hình làm bài thi.</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- 3. Mật khẩu phòng thi & Số lần thi tối đa -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 18px;">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label"><i class="fas fa-key" style="color: #f59e0b;"></i> Mật khẩu phòng thi (Mã bảo vệ)</label>
                            <input type="text" name="accessCode" class="form-control" value="<c:out value='${isEdit ? quiz.accessCode : ""}'/>" placeholder="Để trống nếu cho phép vào thi tự do...">
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label"><i class="fas fa-redo-alt" style="color: #8b5cf6;"></i> Số lần làm bài tối đa</label>
                            <select name="maxAttempts" class="form-control">
                                <option value="0" ${!isEdit || quiz.maxAttempts == 0 ? 'selected' : ''}>0: Không giới hạn số lần thi</option>
                                <option value="1" ${isEdit && quiz.maxAttempts == 1 ? 'selected' : ''}>1: Chỉ được thi 1 lần duy nhất</option>
                                <option value="2" ${isEdit && quiz.maxAttempts == 2 ? 'selected' : ''}>2: Tối đa 2 lần làm bài</option>
                                <option value="3" ${isEdit && quiz.maxAttempts == 3 ? 'selected' : ''}>3: Tối đa 3 lần làm bài</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 0; padding-top: 14px; border-top: 1px solid var(--border-color);">
                        <label style="display: inline-flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600;">
                            <input type="checkbox" name="isPublic" ${!isEdit || quiz.isPublic ? 'checked' : ''} style="width: 18px; height: 18px;">
                            <span><i class="fas fa-globe"></i> Công khai đề thi này lên Kho đề chung cho sinh viên luyện tập</span>
                        </label>
                    </div>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px;">
                    <button type="button" class="btn btn-outline btn-lg" onclick="switchLabStep(1)">
                        <i class="fas fa-arrow-left"></i> Quay lại sửa câu hỏi
                    </button>
                    <button type="submit" class="btn btn-success btn-lg">
                        <i class="fas fa-check-circle"></i> ${isEdit ? 'Lưu thay đổi đề thi' : 'Xuất bản bộ đề vào CSDL'}
                    </button>
                </div>
            </div>
        </div>

        <!-- Cột phải: Bảng thông số & Live Sandbox Tools -->
        <div>
            <div class="card" style="padding: 24px; position: sticky; top: 90px;">
                <h4 style="font-size: 1.1rem; font-weight: 800; margin-bottom: 16px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                    <i class="fas fa-chart-line"></i> Chỉ số Phòng Lab
                </h4>

                <div style="display: flex; flex-direction: column; gap: 14px; font-size: 0.95rem; margin-bottom: 24px;">
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--text-secondary);"><i class="fas fa-list-ol"></i> Tổng số câu:</span>
                        <strong id="labStatQuestions">0 câu</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--text-secondary);"><i class="far fa-clock"></i> Thời lượng:</span>
                        <strong id="labStatTime">15 phút</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--text-secondary);"><i class="fas fa-tasks"></i> Bước hiện tại:</span>
                        <span id="labStatStep" class="badge badge-primary">Bước 1: Soạn câu hỏi</span>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--text-secondary);"><i class="fas fa-database"></i> Giao dịch lưu:</span>
                        <span class="badge badge-info">JDBC Transaction</span>
                    </div>
                </div>

                <div style="background: var(--bg-page); border: 1px dashed var(--border-focus); border-radius: var(--radius-md); padding: 14px; font-size: 0.85rem; color: var(--text-secondary); line-height: 1.6; margin-bottom: 20px;">
                    <strong>💡 Quy trình tạo đề chuẩn:</strong>
                    <br>
                    • <strong>Bước 1:</strong> Điền tên bộ đề và soạn các câu hỏi trắc nghiệm A, B, C, D.
                    <br>
                    • <strong>Bước 2:</strong> Chuyển sang bước Cài đặt đề thi để cấu hình thời gian, đảo đề, bảng xếp hạng và bảo mật trước khi xuất bản!
                </div>

                <div id="sideActionBtn">
                    <button type="button" class="btn btn-primary btn-block btn-lg" onclick="switchLabStep(2)">
                        Tiếp tục: Cài đặt đề <i class="fas fa-arrow-right"></i>
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
                    <button type="button" class="btn btn-primary btn-block btn-lg" onclick="switchLabStep(2)">
                        Tiếp tục: Cài đặt đề <i class="fas fa-arrow-right"></i>
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
                    <button type="submit" form="quizLabForm" class="btn btn-success btn-block btn-lg">
                        <i class="fas fa-save"></i> ${isEdit ? 'Lưu cập nhật đề thi' : 'Xuất bản bộ đề'}
                    </button>
                `;
            }
        }
        window.scrollTo({ top: 140, behavior: 'smooth' });
    }

    document.addEventListener('DOMContentLoaded', function() {
        // Cập nhật nhãn thời gian ban đầu
        const timeInput = document.getElementById('timeLimitInput');
        if (timeInput) {
            onTimeLimitChange(timeInput.value);
        }

        // Tải danh sách câu hỏi: nếu là Edit thì nạp câu hỏi cũ, nếu là Create thì tạo 2 thẻ trống
        const initialCards = document.querySelectorAll('#initialQuestionsData .initial-q-item');
        if (initialCards && initialCards.length > 0) {
            initialCards.forEach(item => {
                addQuestionCard({
                    text: item.getAttribute('data-text') || '',
                    a: item.getAttribute('data-a') || '',
                    b: item.getAttribute('data-b') || '',
                    c: item.getAttribute('data-c') || '',
                    d: item.getAttribute('data-d') || '',
                    correct: item.getAttribute('data-correct') || 'A',
                    points: 1,
                    explanation: item.getAttribute('data-explanation') || ''
                });
            });
        } else {
            // Tự động khởi tạo 2 câu hỏi trống khi mở Lab mới
            addQuestionCard();
            addQuestionCard();
        }

        // Theo dõi thay đổi số lượng câu hỏi để cập nhật chỉ số Lab
        const observer = new MutationObserver(function() {
            const count = document.querySelectorAll('.question-builder-card').length;
            const statEl = document.getElementById('labStatQuestions');
            if (statEl) statEl.innerText = count + ' câu';
        });

        const container = document.getElementById('questionsContainer');
        if (container) {
            observer.observe(container, { childList: true });
        }
    });

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
