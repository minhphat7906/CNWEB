<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Phòng thi: ${quiz.title} - QuizMaster" />
<c:set var="activePage" value="quiz" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Thanh điều hướng và đồng hồ đếm ngược Sticky -->
<div class="arena-topbar" id="arenaTopbar">
    <div>
        <span class="badge badge-primary" style="margin-bottom: 4px;">Phòng thi trực tuyến</span>
        <h2 style="font-size: 1.25rem; font-weight: 800; margin: 0;">${quiz.title}</h2>
    </div>

    <div style="display: flex; align-items: center; gap: 16px;">
        <c:if test="${quiz.antiCheat}">
            <span class="badge badge-warning" title="Hệ thống đang kích hoạt giám sát chống gian lận" style="font-size: 0.85rem; padding: 6px 12px;">
                <i class="fas fa-shield-alt"></i> Giám sát thi
            </span>
        </c:if>

        <div class="arena-timer" id="arenaTimer">
            <i class="fas fa-stopwatch"></i>
            <span id="timerText">--:--</span>
        </div>

        <button type="button" class="btn btn-success btn-lg" onclick="confirmSubmitQuiz()">
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
                        <span style="font-size: 0.85rem; color: var(--text-muted); font-weight: 600;">
                            1 điểm
                        </span>
                    </div>

                    <div class="question-text">
                        ${q.questionText}
                    </div>

                    <div class="options-list">
                        <!-- Option A -->
                        <label class="option-label" for="q_${q.id}_A">
                            <input type="radio" id="q_${q.id}_A" name="q_${q.id}" value="A" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">A</div>
                            <span class="option-text">${q.optionA}</span>
                        </label>

                        <!-- Option B -->
                        <label class="option-label" for="q_${q.id}_B">
                            <input type="radio" id="q_${q.id}_B" name="q_${q.id}" value="B" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">B</div>
                            <span class="option-text">${q.optionB}</span>
                        </label>

                        <!-- Option C -->
                        <label class="option-label" for="q_${q.id}_C">
                            <input type="radio" id="q_${q.id}_C" name="q_${q.id}" value="C" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">C</div>
                            <span class="option-text">${q.optionC}</span>
                        </label>

                        <!-- Option D -->
                        <label class="option-label" for="q_${q.id}_D">
                            <input type="radio" id="q_${q.id}_D" name="q_${q.id}" value="D" 
                                   data-question-id="${q.id}" data-question-index="${loop.index + 1}">
                            <div class="option-badge">D</div>
                            <span class="option-text">${q.optionD}</span>
                        </label>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- Cột bảng điều khiển & Lưới điều hướng câu hỏi -->
        <div class="palette-container">
            <div class="palette-card">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <h4 style="font-size: 1.05rem; font-weight: 800; margin: 0;">Mục lục câu hỏi</h4>
                    <span id="answeredProgressText" style="font-size: 0.85rem; font-weight: 700; color: var(--primary);">
                        0 / ${totalQuestions} câu đã chọn
                    </span>
                </div>

                <div class="palette-grid">
                    <c:forEach begin="1" end="${totalQuestions}" var="num">
                        <button type="button" class="palette-btn" id="palette-btn-${num}" onclick="scrollToQuestion(${num})">
                            ${num}
                        </button>
                    </c:forEach>
                </div>

                <div style="font-size: 0.82rem; color: var(--text-muted); display: flex; flex-direction: column; gap: 6px; border-top: 1px solid var(--border-color); padding-top: 14px; margin-bottom: 20px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="width: 14px; height: 14px; border-radius: 3px; background: var(--primary); display: inline-block;"></span>
                        <span>Đã chọn đáp án</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="width: 14px; height: 14px; border-radius: 3px; background: var(--bg-page); border: 1px solid var(--border-color); display: inline-block;"></span>
                        <span>Chưa chọn đáp án</span>
                    </div>
                </div>

                <button type="button" class="btn btn-success btn-block btn-lg" onclick="confirmSubmitQuiz()">
                    <i class="fas fa-check-double"></i> Nộp bài thi
                </button>
            </div>
        </div>
    </div>
</form>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Khởi động đồng hồ đếm ngược (hoặc đếm tiến nếu không giới hạn) & kích hoạt giám sát thi
        initQuizArena(${quiz.timeLimit}, ${quiz.antiCheat});
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
