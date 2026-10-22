<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Kho Đề Thi - QuizMaster" />
<c:set var="activePage" value="quiz" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="margin-bottom: 24px;">
    <h1 style="font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Khám Phá Kho Đề Thi</h1>
    <p style="color: var(--text-secondary); margin: 0;">Khảo sát ngân hàng đề thi trắc nghiệm, xem trước thông tin và thử sức ngay</p>
</div>

<!-- Thanh công cụ tìm kiếm và lọc đề thi -->
<div class="card" style="padding: 20px; margin-bottom: 24px;">
    <form action="${pageContext.request.contextPath}/quiz" method="GET" style="display: grid; grid-template-columns: 2.5fr 1fr 1fr auto; gap: 14px; align-items: flex-end;">
        <div>
            <label class="form-label">Tìm kiếm đề thi</label>
            <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="Nhập tên đề thi hoặc từ khóa...">
        </div>

        <div>
            <label class="form-label">Mức độ thử thách</label>
            <select name="difficulty" class="form-control" onchange="this.form.submit()">
                <option value="ALL">Mọi độ khó</option>
                <option value="EASY" ${selectedDifficulty eq 'EASY' ? 'selected' : ''}>Dễ</option>
                <option value="MEDIUM" ${selectedDifficulty eq 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                <option value="HARD" ${selectedDifficulty eq 'HARD' ? 'selected' : ''}>Nâng cao</option>
            </select>
        </div>

        <div>
            <label class="form-label">Sắp xếp theo</label>
            <select name="sort" class="form-control" onchange="this.form.submit()">
                <option value="newest" ${selectedSort eq 'newest' ? 'selected' : ''}>Mới nhất</option>
                <option value="popular" ${selectedSort eq 'popular' ? 'selected' : ''}>Lượt thi nhiều nhất</option>
                <option value="oldest" ${selectedSort eq 'oldest' ? 'selected' : ''}>Cũ nhất</option>
            </select>
        </div>

        <div>
            <button type="submit" class="btn btn-primary" style="height: 44px; width: 100%;">
                <i class="fas fa-filter"></i> Lọc đề
            </button>
        </div>
    </form>
</div>

<!-- Thanh tiêu đề kết quả & Chuyển đổi Dạng Lưới / Dạng Bảng -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
    <div style="font-size: 1.05rem; font-weight: 700; color: var(--text-primary);">
        Danh sách đề thi <span style="font-size: 0.9rem; color: var(--text-secondary); font-weight: 500;">(Hiển thị trang ${currentPage} / ${totalPages} - Tổng ${totalCount} đề)</span>
    </div>

    <!-- Nút chuyển đổi View Mode -->
    <div style="display: inline-flex; background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 8px; padding: 2px;">
        <button type="button" id="gridToggleBtn" class="btn btn-sm btn-primary" onclick="setListViewMode('grid')" style="border-radius: 6px; padding: 4px 12px;">
            <i class="fas fa-th-large"></i> Dạng lưới
        </button>
        <button type="button" id="listToggleBtn" class="btn btn-sm btn-outline" onclick="setListViewMode('list')" style="border-radius: 6px; padding: 4px 12px; border: none;">
            <i class="fas fa-bars"></i> Dạng bảng
        </button>
    </div>
</div>

<c:choose>
    <c:when test="${not empty quizzes}">
        <!-- 1. GIAO DIỆN DẠNG LƯỚI (GRID VIEW) -->
        <div id="quizGridView" class="grid grid-3">
            <c:forEach items="${quizzes}" var="quiz">
                <div class="card quiz-card">
                    <div>
                        <div class="quiz-card-header">
                            <div style="display: flex; gap: 6px; align-items: center;">
                                <span class="badge ${quiz.difficultyBadgeClass}">${quiz.difficultyLabel}</span>
                                <c:if test="${quiz.hasAccessCode()}">
                                    <span class="badge badge-warning" title="Yêu cầu mật khẩu phòng thi" style="font-size: 0.72rem; padding: 2px 6px;"><i class="fas fa-key"></i> Có mã</span>
                                </c:if>
                                <c:if test="${quiz.antiCheat}">
                                    <span class="badge badge-danger" title="Giám sát thi chống chuyển tab" style="font-size: 0.72rem; padding: 2px 6px;"><i class="fas fa-shield-alt"></i> Giám sát</span>
                                </c:if>
                            </div>
                            <span style="font-size: 0.82rem; color: var(--text-muted); font-weight: 700;">#${quiz.id}</span>
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
                                    onclick="openQuizPreviewModal('${quiz.id}', '<c:out value="${quiz.title}"/>', '<c:out value="${quiz.description}"/>', '${quiz.timeLimit}', '${quiz.questionCount}', '${quiz.attemptCount}', ${quiz.hasAccessCode()}, ${quiz.antiCheat})">
                                <i class="fas fa-eye"></i> Xem trước
                            </button>
                            <!-- Nút Copy Link -->
                            <button type="button" class="btn btn-outline btn-sm" 
                                    onclick="copyQuizShareLink('${quiz.id}')" title="Sao chép link gửi cho bạn bè">
                                <i class="fas fa-share-alt"></i>
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

        <!-- 2. GIAO DIỆN DẠNG BẢNG DANH SÁCH (LIST VIEW) -->
        <div id="quizListView" style="display: none;">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Mã đề</th>
                            <th>Tiêu đề bộ đề thi</th>
                            <th>Số câu</th>
                            <th>Thời lượng</th>
                            <th>Độ khó</th>
                            <th>Lượt thi</th>
                            <th style="text-align: right;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${quizzes}" var="quiz">
                            <tr>
                                <td><strong style="color: var(--primary);">#${quiz.id}</strong></td>
                                <td>
                                    <strong><a href="${pageContext.request.contextPath}/quiz?id=${quiz.id}">${quiz.title}</a></strong>
                                    <div style="font-size: 0.8rem; color: var(--text-muted);">${quiz.description}</div>
                                </td>
                                <td><strong>${quiz.questionCount}</strong> câu</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${quiz.timeLimit == 0}">
                                            <span class="badge badge-success"><i class="fas fa-infinity"></i> Không giới hạn</span>
                                        </c:when>
                                        <c:otherwise>${quiz.timeLimit} phút</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="badge ${quiz.difficultyBadgeClass}">${quiz.difficultyLabel}</span></td>
                                <td>${quiz.attemptCount} lượt</td>
                                <td style="text-align: right;">
                                    <div class="table-actions" style="justify-content: flex-end;">
                                        <button type="button" class="btn btn-outline btn-sm" 
                                                onclick="openQuizPreviewModal('${quiz.id}', '<c:out value="${quiz.title}"/>', '<c:out value="${quiz.description}"/>', '${quiz.timeLimit}', '${quiz.questionCount}', '${quiz.attemptCount}', ${quiz.hasAccessCode()}, ${quiz.antiCheat})">
                                            <i class="fas fa-eye"></i> Xem trước
                                        </button>
                                        <button type="button" class="btn btn-outline btn-sm" 
                                                onclick="copyQuizShareLink('${quiz.id}')" title="Sao chép link chia sẻ">
                                            <i class="fas fa-share-alt"></i>
                                        </button>
                                        <a href="${pageContext.request.contextPath}/quiz?id=${quiz.id}" class="btn btn-primary btn-sm">
                                            Vào thi <i class="fas fa-play"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 3. BỘ ĐIỀU HƯỚNG PHÂN TRANG (PAGINATION) -->
        <c:if test="${totalPages > 1}">
            <div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 36px; flex-wrap: wrap;">
                <c:if test="${currentPage > 1}">
                    <a href="?page=${currentPage - 1}&keyword=${keyword}&difficulty=${selectedDifficulty}&sort=${selectedSort}" class="btn btn-outline btn-sm">
                        <i class="fas fa-chevron-left"></i> Trang trước
                    </a>
                </c:if>

                <c:forEach begin="1" end="${totalPages}" var="p">
                    <a href="?page=${p}&keyword=${keyword}&difficulty=${selectedDifficulty}&sort=${selectedSort}" 
                       class="btn btn-sm ${currentPage == p ? 'btn-primary' : 'btn-outline'}" 
                       style="min-width: 38px; text-align: center; font-weight: 700;">
                        ${p}
                    </a>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                    <a href="?page=${currentPage + 1}&keyword=${keyword}&difficulty=${selectedDifficulty}&sort=${selectedSort}" class="btn btn-outline btn-sm">
                        Trang sau <i class="fas fa-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </c:if>
    </c:when>

    <c:otherwise>
        <div class="card" style="text-align: center; padding: 48px;">
            <div style="font-size: 3rem; color: var(--text-muted); margin-bottom: 16px;">
                <i class="fas fa-folder-open"></i>
            </div>
            <h3 style="margin-bottom: 8px;">Không tìm thấy bộ đề phù hợp</h3>
            <p style="color: var(--text-secondary); margin-bottom: 20px;">Vui lòng thử lại với từ khóa tìm kiếm hoặc bấm nút bên dưới để xem lại tất cả đề thi.</p>
            <a href="${pageContext.request.contextPath}/quiz" class="btn btn-outline">Xem lại tất cả đề</a>
        </div>
    </c:otherwise>
</c:choose>

<!-- ======================================================== -->
<!-- MODAL XEM TRƯỚC BỘ ĐỀ (QUICK PREVIEW MODAL)              -->
<!-- ======================================================== -->
<div id="quizPreviewModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.65); backdrop-filter: blur(4px); z-index: 1000; align-items: center; justify-content: center; padding: 20px;">
    <div class="card" style="width: 100%; max-width: 580px; padding: 32px; border-radius: 14px; position: relative; box-shadow: var(--shadow-lg); animation: modalFadeIn 0.25s ease;">
        <!-- Nút Đóng -->
        <button type="button" onclick="closeQuizPreviewModal()" style="position: absolute; top: 16px; right: 18px; background: none; border: none; font-size: 1.5rem; color: var(--text-muted); cursor: pointer;">
            &times;
        </button>

        <h3 id="modalQuizTitle" style="font-size: 1.6rem; font-weight: 800; text-align: center; margin: 0 0 8px; color: var(--text-primary); line-height: 1.3;"></h3>

        <div style="display: flex; justify-content: center; align-items: center; gap: 8px; color: var(--text-secondary); font-size: 0.92rem; margin-bottom: 20px;">
            <span>Mã đề thi: <strong id="modalQuizId" style="color: var(--primary);"></strong></span>
            <i class="fas fa-qrcode" style="color: var(--text-muted);"></i>
        </div>

        <p id="modalQuizDesc" style="text-align: center; color: var(--text-secondary); font-size: 0.9rem; line-height: 1.5; margin: 0 0 20px;"></p>

        <!-- Bảng thông số nhanh -->
        <div style="border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); padding: 16px 8px; display: flex; flex-direction: column; gap: 12px; margin-bottom: 24px; font-size: 0.92rem;">
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="far fa-clock"></i> Thời gian làm bài</span>
                <strong id="modalQuizTime"></strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="far fa-calendar-alt"></i> Thời gian vào thi</span>
                <strong>Không thời hạn (Tự do)</strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="far fa-question-circle"></i> Số lượng câu hỏi</span>
                <strong id="modalQuizQuestions"></strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="far fa-file-alt"></i> Loại đề</span>
                <strong>Trắc nghiệm khách quan</strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: var(--text-secondary);"><i class="fas fa-users"></i> Tổng lượt đã làm</span>
                <strong id="modalQuizAttempts"></strong>
            </div>
            <div id="modalQuizFlags" style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 4px;"></div>
        </div>

        <!-- Nút hành động chính (Màu cam nổi bật) -->
        <a id="modalStartBtn" href="#" class="btn btn-block btn-lg" style="background: #ea580c; border-color: #ea580c; color: #ffffff; font-size: 1.1rem; font-weight: 700; padding: 12px; border-radius: 8px; text-align: center; text-decoration: none; display: block; margin-bottom: 12px; box-shadow: 0 4px 12px rgba(234, 88, 12, 0.3);">
            Bắt đầu thi <i class="fas fa-chevron-right" style="font-size: 0.9rem; margin-left: 4px;"></i>
        </a>

        <!-- Hàng nút phụ: Lấy link chia sẻ & Xem lịch sử -->
        <div style="display: flex; justify-content: center; gap: 10px;">
            <button type="button" id="modalShareBtn" class="btn btn-outline btn-sm" style="font-size: 0.88rem; padding: 6px 14px;">
                <i class="fas fa-share-alt"></i> Sao chép liên kết đề
            </button>
            <a id="modalHistoryBtn" href="#" class="btn btn-outline btn-sm" style="font-size: 0.88rem; padding: 6px 14px;">
                <i class="fas fa-history"></i> Lịch sử làm bài
            </a>
        </div>
    </div>
</div>

<!-- Toast thông báo đã sao chép link -->
<div id="globalToast" style="display: none; position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); background: #15803d; color: white; padding: 12px 24px; border-radius: 30px; box-shadow: 0 8px 24px rgba(0,0,0,0.25); z-index: 99999; font-weight: 700; font-size: 0.92rem; align-items: center; gap: 10px;">
    <i class="fas fa-check-circle"></i> <span id="globalToastText">Đã sao chép link đề thi vào bộ nhớ tạm!</span>
</div>

<script>
    let currentPreviewId = 0;

    function setListViewMode(mode) {
        const gridView = document.getElementById('quizGridView');
        const listView = document.getElementById('quizListView');
        const gridBtn = document.getElementById('gridToggleBtn');
        const listBtn = document.getElementById('listToggleBtn');

        if (mode === 'grid') {
            if (gridView) gridView.style.display = 'grid';
            if (listView) listView.style.display = 'none';
            gridBtn.className = 'btn btn-sm btn-primary';
            listBtn.className = 'btn btn-sm btn-outline';
            localStorage.setItem('quizmaster_view_mode', 'grid');
        } else {
            if (gridView) gridView.style.display = 'none';
            if (listView) listView.style.display = 'block';
            gridBtn.className = 'btn btn-sm btn-outline';
            listBtn.className = 'btn btn-sm btn-primary';
            localStorage.setItem('quizmaster_view_mode', 'list');
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const savedMode = localStorage.getItem('quizmaster_view_mode');
        if (savedMode === 'list') {
            setListViewMode('list');
        }
    });

    function openQuizPreviewModal(id, title, desc, time, count, attempts, hasPass, antiCheat) {
        currentPreviewId = id;
        document.getElementById('modalQuizTitle').innerText = title;
        document.getElementById('modalQuizId').innerText = '#' + id;
        document.getElementById('modalQuizDesc').innerText = desc || 'Bộ đề kiểm tra đánh giá năng lực trắc nghiệm trực tuyến.';
        document.getElementById('modalQuizTime').innerText = (parseInt(time) <= 0) ? 'Không giới hạn' : (time + ' phút');
        document.getElementById('modalQuizQuestions').innerText = count + ' câu';
        document.getElementById('modalQuizAttempts').innerText = attempts + ' lượt';

        const flagsContainer = document.getElementById('modalQuizFlags');
        flagsContainer.innerHTML = '';
        if (hasPass) {
            flagsContainer.innerHTML += '<span class="badge badge-warning"><i class="fas fa-lock"></i> Yêu cầu mật khẩu</span> ';
        }
        if (antiCheat) {
            flagsContainer.innerHTML += '<span class="badge badge-danger"><i class="fas fa-shield-alt"></i> Giám sát chống chuyển tab</span> ';
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
                showToastNotification('Đã sao chép link đề thi #' + id + '! Bạn có thể gửi link này cho thí sinh.');
            }).catch(function() {
                prompt('Sao chép liên kết đề thi bên dưới:', url);
            });
        } else {
            prompt('Sao chép liên kết đề thi bên dưới:', url);
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
            }, 3500);
        }
    }
</script>

<style>
@keyframes modalFadeIn {
    from { opacity: 0; transform: translateY(-12px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
