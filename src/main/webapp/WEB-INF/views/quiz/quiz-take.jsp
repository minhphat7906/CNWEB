<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Phòng thi: ${quiz.title} - QuizMaster" />
<c:set var="activePage" value="quiz" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Thanh điều hướng và đồng hồ đếm ngược Sticky -->
<div class="arena-topbar" id="arenaTopbar" style="border-radius: 12px; margin-bottom: 24px;">
    <div>
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
            <span class="badge badge-primary" style="font-size: 0.75rem;">Phòng thi trực tuyến</span>
            <span style="font-size: 0.8rem; color: var(--text-muted);">Mã đề #${quiz.id}</span>
        </div>
        <h2 style="font-size: 1.15rem; font-weight: 700; margin: 0; color: var(--text-primary);"><c:out value="${quiz.title}"/></h2>
    </div>

    <div style="display: flex; align-items: center; gap: 14px;">
        <c:if test="${quiz.antiCheat}">
            <span class="badge badge-danger" title="Hệ thống tự động phát hiện khi thí sinh chuyển tab hoặc rời màn hình" style="font-size: 0.8rem; padding: 6px 12px;">
                <i class="fas fa-shield-alt"></i> Giám sát thi
            </span>
        </c:if>

        <div class="arena-timer" id="arenaTimer">
            <i class="fas fa-stopwatch"></i>
            <span id="timerText">--:--</span>
        </div>

        <button type="button" class="btn btn-primary" onclick="confirmSubmitQuiz()" style="padding: 10px 22px; font-weight: 600;">
            <i class="fas fa-paper-plane"></i> Nộp bài
        </button>
    </div>
</div>

<form id="quizForm" action="${pageContext.request.contextPath}/quiz-take" method="POST">
    <input type="hidden" name="action" value="submit">
    <input type="hidden" name="quizId" value="${quiz.id}">
    <input type="hidden" name="timeSpent" id="timeSpent" value="0">
    <input type="hidden" name="tabSwitches" id="tabSwitches" value="0">

    <div class="arena-layout">
        <!-- Cột danh sách câu hỏi -->
        <div class="questions-list">
            <c:forEach items="${questions}" var="q" varStatus="loop">
                <div class="question-item" id="q-card-${loop.index + 1}">
                    <div class="question-header">
                        <span class="question-num">Câu ${loop.index + 1} / ${totalQuestions}</span>
                        <span style="font-size: 0.82rem; color: var(--text-muted); font-weight: 500;">
                            Phím tắt: [1-4] hoặc [A-D]
                        </span>
                    </div>

                    <div class="question-text">
                        <c:out value="${q.questionText}"/>
                    </div>

                    <div class="options-list">
                        <!-- Option A -->
                        <label class="option-label" for="q_${q.id}_A">
                            <input type="radio" id="q_${q.id}_A" name="q_${q.id}" value="A" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">A</div>
                            <span class="option-text"><c:out value="${q.optionA}"/></span>
                        </label>

                        <!-- Option B -->
                        <label class="option-label" for="q_${q.id}_B">
                            <input type="radio" id="q_${q.id}_B" name="q_${q.id}" value="B" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">B</div>
                            <span class="option-text"><c:out value="${q.optionB}"/></span>
                        </label>

                        <!-- Option C -->
                        <label class="option-label" for="q_${q.id}_C">
                            <input type="radio" id="q_${q.id}_C" name="q_${q.id}" value="C" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">C</div>
                            <span class="option-text"><c:out value="${q.optionC}"/></span>
                        </label>

                        <!-- Option D -->
                        <label class="option-label" for="q_${q.id}_D">
                            <input type="radio" id="q_${q.id}_D" name="q_${q.id}" value="D" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">D</div>
                            <span class="option-text"><c:out value="${q.optionD}"/></span>
                        </label>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- Cột bảng điều khiển & Lưới điều hướng câu hỏi -->
        <div class="palette-container">
            <div class="palette-card" style="border-radius: 14px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                    <h4 style="font-size: 1rem; font-weight: 700; margin: 0; color: var(--text-primary);">Mục lục câu hỏi</h4>
                    <span id="answeredProgressText" style="font-size: 0.82rem; font-weight: 700; color: var(--primary);">
                        0 / ${totalQuestions} đã chọn
                    </span>
                </div>

                <div class="palette-grid">
                    <c:forEach begin="1" end="${totalQuestions}" var="num">
                        <button type="button" class="palette-btn" id="palette-btn-${num}" onclick="scrollToQuestion(${num})">
                            ${num}
                        </button>
                    </c:forEach>
                </div>

                <div style="font-size: 0.8rem; color: var(--text-muted); display: flex; flex-direction: column; gap: 8px; border-top: 1px solid var(--border-color); padding-top: 14px; margin-bottom: 20px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="width: 12px; height: 12px; border-radius: 3px; background: var(--primary); display: inline-block;"></span>
                        <span>Đã chọn đáp án</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="width: 12px; height: 12px; border-radius: 3px; background: var(--bg-surface); border: 1px solid var(--border-color); display: inline-block;"></span>
                        <span>Chưa chọn đáp án</span>
                    </div>
                </div>

                <button type="button" class="btn btn-primary btn-block btn-lg" onclick="confirmSubmitQuiz()" style="font-weight: 700; padding: 12px;">
                    <i class="fas fa-check-circle"></i> Nộp bài thi
                </button>
            </div>
        </div>
    </div>
</form>

<!-- ======================================================== -->
<!-- MODAL XÁC NHẬN NỘP BÀI THI HIỆN ĐẠI                      -->
<!-- ======================================================== -->
<div id="submitConfirmModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 1000; align-items: center; justify-content: center; padding: 20px;">
    <div class="card" style="width: 100%; max-width: 480px; padding: 28px; border-radius: 16px; position: relative; box-shadow: var(--shadow-lg); animation: modalFadeIn 0.2s ease;">
        <button type="button" onclick="closeSubmitModal()" style="position: absolute; top: 16px; right: 18px; background: none; border: none; font-size: 1.4rem; color: var(--text-muted); cursor: pointer;">
            &times;
        </button>

        <div style="text-align: center; margin-bottom: 20px;">
            <div style="width: 56px; height: 56px; border-radius: 50%; background: rgba(79, 70, 229, 0.1); color: var(--primary); display: flex; align-items: center; justify-content: center; margin: 0 auto 14px; font-size: 1.6rem;">
                <i class="fas fa-paper-plane"></i>
            </div>
            <h3 id="modalSubmitTitle" style="font-size: 1.3rem; font-weight: 800; color: var(--text-primary); margin: 0 0 6px;">Xác nhận nộp bài</h3>
            <p id="modalSubmitText" style="color: var(--text-secondary); font-size: 0.92rem; margin: 0;"></p>
        </div>

        <!-- Thanh tiến trình hoàn thành -->
        <div style="background: #e2e8f0; height: 8px; border-radius: 4px; overflow: hidden; margin-bottom: 16px;">
            <div id="modalSubmitProgressBar" style="background: var(--primary); height: 100%; width: 0%; transition: width 0.3s ease;"></div>
        </div>

        <!-- Cảnh báo trạng thái -->
        <div id="modalSubmitAlert" style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 12px 14px; font-size: 0.88rem; color: var(--text-secondary); line-height: 1.45; margin-bottom: 22px;"></div>

        <!-- Các nút bấm -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <button type="button" class="btn btn-outline" onclick="closeSubmitModal()" style="font-weight: 600; padding: 11px;">
                Tiếp tục làm
            </button>
            <button type="button" class="btn btn-primary" onclick="proceedFinalSubmit()" style="font-weight: 700; padding: 11px;">
                Đồng ý nộp bài
            </button>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Khởi động đồng hồ đếm ngược (hoặc đếm tiến nếu không giới hạn) & kích hoạt giám sát thi
        initQuizArena(${quiz.timeLimit}, ${quiz.antiCheat});
    });
</script>

<style>
@keyframes modalFadeIn {
    from { opacity: 0; transform: translateY(-8px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
