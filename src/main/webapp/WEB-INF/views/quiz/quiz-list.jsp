<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Kho Đề Thi - QuizMaster" />
<c:set var="activePage" value="quiz" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="margin-bottom: 24px;">
    <h1 style="font-size: 1.85rem; font-weight: 800; margin-bottom: 6px; color: var(--text-primary); letter-spacing: -0.02em;">Kho Đề Thi Trắc Nghiệm</h1>
    <p style="color: var(--text-secondary); margin: 0; font-size: 0.95rem;">Khám phá các bộ đề kiểm tra, rèn luyện kiến thức và thử sức với ngân hàng câu hỏi đa dạng</p>
</div>

<!-- Thanh công cụ tìm kiếm và bộ lọc gọn gàng -->
<div class="card" style="padding: 16px 20px; margin-bottom: 24px; border-radius: 12px;">
    <form action="${pageContext.request.contextPath}/quiz" method="GET" style="display: grid; grid-template-columns: minmax(220px, 1fr) 180px 180px auto; gap: 12px; align-items: center;">
        <div style="position: relative;">
            <i class="fas fa-search" style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 0.9rem;"></i>
            <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="Tìm theo tên đề thi..." style="padding-left: 38px; height: 42px;">
        </div>

        <div>
            <select name="difficulty" class="form-control" onchange="this.form.submit()" style="height: 42px;">
                <option value="ALL">Mọi độ khó</option>
                <option value="EASY" ${selectedDifficulty eq 'EASY' ? 'selected' : ''}>Mức độ: Dễ</option>
                <option value="MEDIUM" ${selectedDifficulty eq 'MEDIUM' ? 'selected' : ''}>Mức độ: Trung bình</option>
                <option value="HARD" ${selectedDifficulty eq 'HARD' ? 'selected' : ''}>Mức độ: Nâng cao</option>
            </select>
        </div>

        <div>
            <select name="sort" class="form-control" onchange="this.form.submit()" style="height: 42px;">
                <option value="newest" ${selectedSort eq 'newest' ? 'selected' : ''}>Mới nhất</option>
                <option value="popular" ${selectedSort eq 'popular' ? 'selected' : ''}>Thi nhiều nhất</option>
                <option value="oldest" ${selectedSort eq 'oldest' ? 'selected' : ''}>Cũ nhất</option>
            </select>
        </div>

        <div>
            <button type="submit" class="btn btn-primary" style="height: 42px; padding: 0 20px; font-weight: 600;">
                <i class="fas fa-filter"></i> Lọc
            </button>
        </div>
    </form>
</div>

<!-- Thanh thông tin số lượng kết quả -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px;">
    <div style="font-size: 0.95rem; font-weight: 600; color: var(--text-secondary);">
        Hiển thị <span style="color: var(--text-primary); font-weight: 700;">${quizzes.size()}</span> đề thi (Trang ${currentPage} / ${totalPages} - Tổng ${totalCount} đề)
    </div>
</div>

<c:choose>
    <c:when test="${not empty quizzes}">
        <!-- LƯỚI ĐỀ THI HIỆN ĐẠI (GRID 3 CỘT) -->
        <div class="grid grid-3">
            <c:forEach items="${quizzes}" var="quiz">
                <div class="card quiz-card">
                    <div>
                        <div class="quiz-card-header">
                            <div style="display: flex; gap: 6px; align-items: center; flex-wrap: wrap;">
                                <span class="badge ${quiz.difficultyBadgeClass}">${quiz.difficultyLabel}</span>
                                <c:if test="${quiz.hasAccessCode()}">
                                    <span class="badge badge-warning" title="Yêu cầu mã PIN vào phòng" style="font-size: 0.72rem; padding: 2px 7px;"><i class="fas fa-lock"></i> Có mã PIN</span>
                                </c:if>
                                <c:if test="${quiz.antiCheat}">
                                    <span class="badge badge-danger" title="Giám sát chuyển tab" style="font-size: 0.72rem; padding: 2px 7px;"><i class="fas fa-shield-alt"></i> Giám sát</span>
                                </c:if>
                            </div>
                            <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600;">#${quiz.id}</span>
                        </div>
                        <h3 class="quiz-card-title">${quiz.title}</h3>
                        <p class="quiz-card-desc">${quiz.description}</p>
                    </div>

                    <div>
                        <div class="quiz-card-meta">
                            <span>
                                <i class="far fa-clock"></i> 
                                <c:choose>
                                    <c:when test="${quiz.timeLimit == 0}">Không giới hạn</c:when>
                                    <c:otherwise>${quiz.timeLimit} phút</c:otherwise>
                                </c:choose>
                            </span>
                            <span><i class="fas fa-question-circle"></i> ${quiz.questionCount} câu</span>
                            <span><i class="fas fa-users"></i> ${quiz.attemptCount} lượt</span>
                        </div>

                        <div class="quiz-card-footer" style="gap: 8px;">
                            <!-- Nút Xem trước -->
                            <button type="button" class="btn btn-outline btn-sm" 
                                    onclick="openQuizPreviewModal('${quiz.id}', '<c:out value="${quiz.title}"/>', '<c:out value="${quiz.description}"/>', '${quiz.timeLimit}', '${quiz.questionCount}', '${quiz.attemptCount}', ${quiz.hasAccessCode()}, ${quiz.antiCheat})"
                                    title="Xem tóm tắt thông số đề thi">
                                <i class="fas fa-eye"></i> Chi tiết
                            </button>
                            <!-- Nút Copy Link -->
                            <button type="button" class="btn btn-outline btn-sm" 
                                    onclick="copyQuizShareLink('${quiz.id}')" title="Sao chép link làm bài">
                                <i class="fas fa-link"></i>
                            </button>
                            <!-- Nút Vào thi -->
                            <a href="${pageContext.request.contextPath}/quiz?id=${quiz.id}" class="btn btn-primary btn-sm" style="margin-left: auto;">
                                Vào thi <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- BỘ ĐIỀU HƯỚNG PHÂN TRANG -->
        <c:if test="${totalPages > 1}">
            <div style="display: flex; justify-content: center; align-items: center; gap: 6px; margin-top: 36px; flex-wrap: wrap;">
                <c:if test="${currentPage > 1}">
                    <a href="?page=${currentPage - 1}&keyword=${keyword}&difficulty=${selectedDifficulty}&sort=${selectedSort}" class="btn btn-outline btn-sm">
                        <i class="fas fa-chevron-left"></i> Trước
                    </a>
                </c:if>

                <c:forEach begin="1" end="${totalPages}" var="p">
                    <a href="?page=${p}&keyword=${keyword}&difficulty=${selectedDifficulty}&sort=${selectedSort}" 
                       class="btn btn-sm ${currentPage == p ? 'btn-primary' : 'btn-outline'}" 
                       style="min-width: 36px; height: 36px; display: inline-flex; align-items: center; justify-content: center; font-weight: 600; border-radius: 8px;">
                        ${p}
                    </a>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                    <a href="?page=${currentPage + 1}&keyword=${keyword}&difficulty=${selectedDifficulty}&sort=${selectedSort}" class="btn btn-outline btn-sm">
                        Sau <i class="fas fa-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </c:if>
    </c:when>

    <c:otherwise>
        <div class="card" style="text-align: center; padding: 48px 24px; border-radius: 12px;">
            <div style="width: 64px; height: 64px; border-radius: 50%; background: #f1f5f9; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; color: var(--text-muted); font-size: 1.8rem;">
                <i class="fas fa-folder-open"></i>
            </div>
            <h3 style="margin-bottom: 8px; font-weight: 700;">Không tìm thấy đề thi phù hợp</h3>
            <p style="color: var(--text-secondary); margin-bottom: 20px; font-size: 0.95rem;">Thử thay đổi từ khóa tìm kiếm hoặc lọc theo mức độ khác.</p>
            <a href="${pageContext.request.contextPath}/quiz" class="btn btn-outline">Xem lại tất cả đề thi</a>
        </div>
    </c:otherwise>
</c:choose>

<!-- ======================================================== -->
<!-- MODAL XEM TRƯỚC BỘ ĐỀ (PREVIEW MODAL)                    -->
<!-- ======================================================== -->
<div id="quizPreviewModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 1000; align-items: center; justify-content: center; padding: 20px;">
    <div class="card" style="width: 100%; max-width: 520px; padding: 28px; border-radius: 16px; position: relative; box-shadow: var(--shadow-lg); animation: modalFadeIn 0.2s ease;">
        <!-- Nút Đóng -->
        <button type="button" onclick="closeQuizPreviewModal()" style="position: absolute; top: 16px; right: 18px; background: none; border: none; font-size: 1.4rem; color: var(--text-muted); cursor: pointer;">
            &times;
        </button>

        <div style="margin-bottom: 14px;">
            <span id="modalQuizIdBadge" class="badge badge-info" style="font-size: 0.75rem;"></span>
        </div>

        <h3 id="modalQuizTitle" style="font-size: 1.35rem; font-weight: 800; margin: 0 0 10px; color: var(--text-primary); line-height: 1.35;"></h3>
        <p id="modalQuizDesc" style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.5; margin: 0 0 20px;"></p>

        <!-- Bảng thông số tóm tắt -->
        <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 10px; padding: 14px 16px; display: flex; flex-direction: column; gap: 10px; margin-bottom: 22px; font-size: 0.88rem;">
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="far fa-clock" style="width: 18px;"></i> Thời gian làm bài</span>
                <strong id="modalQuizTime" style="color: var(--text-primary);"></strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="far fa-question-circle" style="width: 18px;"></i> Số câu hỏi</span>
                <strong id="modalQuizQuestions" style="color: var(--text-primary);"></strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="fas fa-users" style="width: 18px;"></i> Lượt thí sinh đã nộp</span>
                <strong id="modalQuizAttempts" style="color: var(--text-primary);"></strong>
            </div>
            <div id="modalQuizFlags" style="display: flex; gap: 6px; flex-wrap: wrap; margin-top: 4px; padding-top: 8px; border-top: 1px dashed var(--border-color);"></div>
        </div>

        <!-- Nút hành động chính: Bắt đầu thi (Indigo) -->
        <a id="modalStartBtn" href="#" class="btn btn-primary btn-block btn-lg" style="font-size: 1rem; font-weight: 700; padding: 12px; border-radius: 10px; text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 12px;">
            Bắt đầu làm bài <i class="fas fa-arrow-right"></i>
        </a>

        <!-- Hàng nút phụ -->
        <div style="display: flex; justify-content: center; gap: 10px;">
            <button type="button" id="modalShareBtn" class="btn btn-outline btn-sm" style="font-size: 0.85rem; padding: 7px 14px;">
                <i class="fas fa-link"></i> Sao chép liên kết
            </button>
            <a id="modalHistoryBtn" href="#" class="btn btn-outline btn-sm" style="font-size: 0.85rem; padding: 7px 14px;">
                <i class="fas fa-history"></i> Bảng xếp hạng / Lịch sử
            </a>
        </div>
    </div>
</div>

<!-- Toast thông báo đã sao chép link -->
<div id="globalToast" style="display: none; position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); background: #0f172a; color: white; padding: 10px 20px; border-radius: 30px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); z-index: 99999; font-weight: 600; font-size: 0.88rem; align-items: center; gap: 8px; animation: modalFadeIn 0.2s ease;">
    <i class="fas fa-check-circle" style="color: #22c55e;"></i> <span id="globalToastText">Đã sao chép liên kết đề thi!</span>
</div>

<script>
    function openQuizPreviewModal(id, title, desc, time, count, attempts, hasPass, antiCheat) {
        document.getElementById('modalQuizTitle').innerText = title;
        document.getElementById('modalQuizIdBadge').innerText = 'Mã đề #' + id;
        document.getElementById('modalQuizDesc').innerText = desc || 'Bộ đề kiểm tra đánh giá năng lực trắc nghiệm trực tuyến.';
        document.getElementById('modalQuizTime').innerText = (parseInt(time) <= 0) ? 'Không giới hạn thời gian' : (time + ' phút');
        document.getElementById('modalQuizQuestions').innerText = count + ' câu hỏi trắc nghiệm';
        document.getElementById('modalQuizAttempts').innerText = attempts + ' lượt';

        const flagsContainer = document.getElementById('modalQuizFlags');
        flagsContainer.innerHTML = '';
        if (hasPass) {
            flagsContainer.innerHTML += '<span class="badge badge-warning" style="font-size: 0.72rem;"><i class="fas fa-lock"></i> Có mã PIN</span> ';
        }
        if (antiCheat) {
            flagsContainer.innerHTML += '<span class="badge badge-danger" style="font-size: 0.72rem;"><i class="fas fa-shield-alt"></i> Giám sát chống gian lận</span> ';
        }
        if (!hasPass && !antiCheat) {
            flagsContainer.innerHTML = '<span style="color: var(--text-muted); font-size: 0.78rem;">Phòng thi tự do, không hạn chế thiết bị</span>';
        }

        const contextPath = '${pageContext.request.contextPath}';
        document.getElementById('modalStartBtn').href = contextPath + '/quiz?id=' + id;
        document.getElementById('modalHistoryBtn').href = contextPath + '/history?quizId=' + id;
        document.getElementById('modalShareBtn').onclick = function() {
            copyQuizShareLink(id);
        };

        const modal = document.getElementById('quizPreviewModal');
        modal.style.display = 'flex';
    }

    function closeQuizPreviewModal() {
        const modal = document.getElementById('quizPreviewModal');
        if (modal) modal.style.display = 'none';
    }

    window.addEventListener('click', function(e) {
        const modal = document.getElementById('quizPreviewModal');
        if (e.target === modal) {
            closeQuizPreviewModal();
        }
    });

    function copyQuizShareLink(id) {
        const url = window.location.origin + '${pageContext.request.contextPath}/quiz?id=' + id;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(url).then(function() {
                showToastNotification('Đã sao chép liên kết đề thi #' + id + '! Có thể gửi cho thí sinh.');
            }).catch(function() {
                prompt('Sao chép liên kết đề thi:', url);
            });
        } else {
            prompt('Sao chép liên kết đề thi:', url);
        }
    }

    function showToastNotification(msg) {
        const toast = document.getElementById('globalToast');
        const text = document.getElementById('globalToastText');
        if (toast && text) {
            text.innerText = msg;
            toast.style.display = 'flex';
            setTimeout(() => {
                toast.style.display = 'none';
            }, 3000);
        }
    }
</script>

<style>
@keyframes modalFadeIn {
    from { opacity: 0; transform: translateY(-8px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
