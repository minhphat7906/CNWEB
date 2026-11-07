/**
 * QuizMaster - Quiz Arena Runtime Engine (Countdown, Palette sync, Anti-cheat, Shortcuts & Modern Submit Modal)
 */

let timeRemainingSeconds = 0;
let totalTimeSeconds = 0;
let timeSpentSeconds = 0;
let timerInterval = null;
let isSubmitted = false;
let isUnlimited = false;
let tabSwitchesCount = 0;
let antiCheatEnabled = false;
let currentFocusedQuestionIndex = 1;

function initQuizArena(timeLimitMinutes, enableAntiCheat) {
    antiCheatEnabled = !!enableAntiCheat;
    isUnlimited = (timeLimitMinutes <= 0);

    if (isUnlimited) {
        timeSpentSeconds = 0;
        updateUnlimitedTimerDisplay();
        startUnlimitedTimer();
    } else {
        totalTimeSeconds = timeLimitMinutes * 60;
        timeRemainingSeconds = totalTimeSeconds;
        updateTimerDisplay();
        startTimer();
    }

    initOptionListeners();
    initBeforeUnloadWarning();
    initQuestionObserver();
    initKeyboardShortcuts();

    if (antiCheatEnabled) {
        initAntiCheatMonitoring();
    }
}

function startTimer() {
    timerInterval = setInterval(function () {
        timeRemainingSeconds--;
        updateTimerDisplay();

        if (timeRemainingSeconds <= 60) {
            const timerEl = document.getElementById('arenaTimer');
            if (timerEl) timerEl.classList.add('urgent');
        }

        if (timeRemainingSeconds <= 0) {
            clearInterval(timerInterval);
            timeRemainingSeconds = 0;
            updateTimerDisplay();
            alert('Đã hết thời gian làm bài! Hệ thống đang tự động nộp bài thi của bạn.');
            submitQuiz(true);
        }
    }, 1000);
}

function startUnlimitedTimer() {
    timerInterval = setInterval(function () {
        timeSpentSeconds++;
        updateUnlimitedTimerDisplay();
    }, 1000);
}

function updateUnlimitedTimerDisplay() {
    const timerDisplay = document.getElementById('timerText');
    if (!timerDisplay) return;

    const minutes = Math.floor(timeSpentSeconds / 60);
    const seconds = timeSpentSeconds % 60;
    const formatted = (minutes < 10 ? '0' : '') + minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
    timerDisplay.innerHTML = '<i class="fas fa-infinity" title="Không giới hạn thời gian"></i> ' + formatted;

    const timeSpentInput = document.getElementById('timeSpent');
    if (timeSpentInput) {
        timeSpentInput.value = timeSpentSeconds;
    }
}

function updateTimerDisplay() {
    const timerDisplay = document.getElementById('timerText');
    if (!timerDisplay) return;

    const minutes = Math.floor(timeRemainingSeconds / 60);
    const seconds = timeRemainingSeconds % 60;
    const formatted = (minutes < 10 ? '0' : '') + minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
    timerDisplay.innerText = formatted;

    const timeSpentInput = document.getElementById('timeSpent');
    if (timeSpentInput) {
        timeSpentInput.value = (totalTimeSeconds - timeRemainingSeconds);
    }
}

let isUserAway = false;
let lastLeaveTimestamp = 0;

/**
 * Giám sát chống gian lận:
 * Phát hiện học sinh chuyển tab trình duyệt hoặc thu nhỏ cửa sổ.
 */
function initAntiCheatMonitoring() {
    function handleLeave() {
        if (isSubmitted) return;
        const now = Date.now();
        if (!isUserAway && (now - lastLeaveTimestamp > 1000)) {
            isUserAway = true;
            lastLeaveTimestamp = now;
            recordTabSwitch();
        }
    }

    function handleReturn() {
        setTimeout(function () {
            isUserAway = false;
        }, 300);
    }

    document.addEventListener('visibilitychange', function () {
        if (document.hidden) {
            handleLeave();
        } else {
            handleReturn();
        }
    });

    window.addEventListener('blur', function () {
        handleLeave();
    });

    window.addEventListener('focus', function () {
        handleReturn();
    });
}

function recordTabSwitch() {
    tabSwitchesCount++;
    const tabInput = document.getElementById('tabSwitches');
    if (tabInput) tabInput.value = tabSwitchesCount;

    showAntiCheatWarning(tabSwitchesCount);
}

function showAntiCheatWarning(count) {
    let warningBox = document.getElementById('antiCheatWarningToast');
    if (!warningBox) {
        warningBox = document.createElement('div');
        warningBox.id = 'antiCheatWarningToast';
        warningBox.style.position = 'fixed';
        warningBox.style.top = '78px';
        warningBox.style.left = '50%';
        warningBox.style.transform = 'translateX(-50%)';
        warningBox.style.zIndex = '9999';
        warningBox.style.background = '#dc2626';
        warningBox.style.color = '#ffffff';
        warningBox.style.padding = '12px 22px';
        warningBox.style.borderRadius = '10px';
        warningBox.style.boxShadow = '0 10px 25px rgba(220, 38, 38, 0.35)';
        warningBox.style.fontWeight = '600';
        warningBox.style.fontSize = '0.92rem';
        warningBox.style.display = 'flex';
        warningBox.style.alignItems = 'center';
        warningBox.style.gap = '10px';
        document.body.appendChild(warningBox);
    }

    warningBox.innerHTML = '<i class="fas fa-exclamation-triangle" style="font-size: 1.2rem;"></i> ' +
        '<span>CẢNH BÁO: Bạn vừa rời khỏi màn hình làm bài lần thứ <strong>' + count + '</strong>. Lịch sử này đã được lưu lại!</span>';

    setTimeout(function () {
        if (warningBox && warningBox.parentNode) {
            warningBox.style.transition = 'opacity 0.4s ease';
            warningBox.style.opacity = '0';
            setTimeout(function () {
                if (warningBox.parentNode) warningBox.parentNode.removeChild(warningBox);
            }, 400);
        }
    }, 4000);
}

function initOptionListeners() {
    const radioInputs = document.querySelectorAll('input[type="radio"]');
    radioInputs.forEach(function (radio) {
        radio.addEventListener('change', function () {
            const qIndex = parseInt(this.getAttribute('data-question-index')) || 1;
            currentFocusedQuestionIndex = qIndex;

            // Cập nhật style cho nhãn được chọn trong cùng câu hỏi
            const parentContainer = this.closest('.options-list');
            if (parentContainer) {
                const labels = parentContainer.querySelectorAll('.option-label');
                labels.forEach(l => l.classList.remove('selected'));
                const chosenLabel = this.closest('.option-label');
                if (chosenLabel) chosenLabel.classList.add('selected');
            }

            // Đổi màu nút câu hỏi trên palette
            const paletteBtn = document.getElementById('palette-btn-' + qIndex);
            if (paletteBtn) {
                paletteBtn.classList.add('answered');
            }

            updateAnsweredProgress();
        });
    });
}

/**
 * Tự động theo dõi câu hỏi đang hiển thị trên màn hình
 */
function initQuestionObserver() {
    const questionItems = document.querySelectorAll('.question-item');
    if (!questionItems || questionItems.length === 0) return;

    if ('IntersectionObserver' in window) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const id = entry.target.id; // q-card-X
                    const index = parseInt(id.replace('q-card-', '')) || 1;
                    currentFocusedQuestionIndex = index;
                    highlightActivePaletteBtn(index);

                    // Thêm viền nhẹ cho câu hỏi đang focus
                    questionItems.forEach(item => item.classList.remove('is-focused'));
                    entry.target.classList.add('is-focused');
                }
            });
        }, {
            root: null,
            rootMargin: '-20% 0px -40% 0px',
            threshold: 0.1
        });

        questionItems.forEach(item => observer.observe(item));
    }
}

function highlightActivePaletteBtn(index) {
    document.querySelectorAll('.palette-btn').forEach(btn => btn.classList.remove('active'));
    const btn = document.getElementById('palette-btn-' + index);
    if (btn) btn.classList.add('active');
}

/**
 * Hỗ trợ phím tắt: 1, 2, 3, 4 hoặc A, B, C, D để chọn đáp án
 * Phím ArrowUp / ArrowDown để chuyển câu
 */
function initKeyboardShortcuts() {
    document.addEventListener('keydown', function (e) {
        // Bỏ qua nếu đang gõ trong input / textarea
        const activeTag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
        if (activeTag === 'input' || activeTag === 'textarea') return;

        // Nếu Modal nộp bài đang mở
        const modal = document.getElementById('submitConfirmModal');
        const isModalOpen = (modal && modal.style.display === 'flex');

        if (isModalOpen) {
            if (e.key === 'Escape') {
                closeSubmitModal();
            } else if (e.key === 'Enter') {
                proceedFinalSubmit();
            }
            return;
        }

        const key = e.key.toUpperCase();
        let targetOption = null;

        if (key === 'A' || key === '1') targetOption = 'A';
        else if (key === 'B' || key === '2') targetOption = 'B';
        else if (key === 'C' || key === '3') targetOption = 'C';
        else if (key === 'D' || key === '4') targetOption = 'D';

        if (targetOption) {
            // Tìm câu hỏi hiện tại và tick chọn
            const curCard = document.getElementById('q-card-' + currentFocusedQuestionIndex);
            if (curCard) {
                const radio = curCard.querySelector(`input[type="radio"][value="${targetOption}"]`);
                if (radio) {
                    radio.checked = true;
                    radio.dispatchEvent(new Event('change'));
                }
            }
        } else if (e.key === 'ArrowDown') {
            const total = document.querySelectorAll('.question-item').length;
            if (currentFocusedQuestionIndex < total) {
                scrollToQuestion(currentFocusedQuestionIndex + 1);
            }
        } else if (e.key === 'ArrowUp') {
            if (currentFocusedQuestionIndex > 1) {
                scrollToQuestion(currentFocusedQuestionIndex - 1);
            }
        }
    });
}

function scrollToQuestion(index) {
    currentFocusedQuestionIndex = index;
    const target = document.getElementById('q-card-' + index);
    if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'center' });
        highlightActivePaletteBtn(index);
    }
}

function updateAnsweredProgress() {
    const answeredCount = document.querySelectorAll('.palette-btn.answered').length;
    const totalCount = document.querySelectorAll('.palette-btn').length;

    const progressEl = document.getElementById('answeredProgressText');
    if (progressEl) {
        progressEl.innerText = answeredCount + ' / ' + totalCount + ' câu đã chọn';
    }
}

function initBeforeUnloadWarning() {
    window.addEventListener('beforeunload', function (e) {
        if (!isSubmitted) {
            e.preventDefault();
            e.returnValue = 'Bài thi chưa được nộp. Dữ liệu làm bài có thể bị mất nếu bạn rời khỏi trang!';
        }
    });
}

/**
 * Hiển thị Modal xác nhận nộp bài hiện đại thay vì confirm() thô sơ
 */
function confirmSubmitQuiz() {
    const answeredCount = document.querySelectorAll('.palette-btn.answered').length;
    const totalCount = document.querySelectorAll('.palette-btn').length;
    const unansweredCount = totalCount - answeredCount;

    const modal = document.getElementById('submitConfirmModal');
    if (modal) {
        const titleEl = document.getElementById('modalSubmitTitle');
        const textEl = document.getElementById('modalSubmitText');
        const alertEl = document.getElementById('modalSubmitAlert');
        const progressEl = document.getElementById('modalSubmitProgressBar');

        if (titleEl) titleEl.innerText = 'Xác nhận nộp bài thi';
        if (textEl) {
            textEl.innerHTML = `Bạn đã hoàn thành <strong>${answeredCount}</strong> / <strong>${totalCount}</strong> câu hỏi.`;
        }

        if (progressEl) {
            const percent = totalCount > 0 ? Math.round((answeredCount / totalCount) * 100) : 0;
            progressEl.style.width = percent + '%';
        }

        if (alertEl) {
            if (unansweredCount > 0) {
                alertEl.style.display = 'block';
                alertEl.innerHTML = `<i class="fas fa-exclamation-circle" style="color: #f59e0b;"></i> Còn <strong>${unansweredCount} câu chưa trả lời</strong>. Bạn có chắc chắn muốn nộp bài sớm không?`;
            } else {
                alertEl.style.display = 'block';
                alertEl.innerHTML = `<i class="fas fa-check-circle" style="color: #10b981;"></i> Tuyệt vời! Bạn đã hoàn thành toàn bộ <strong>${totalCount} câu hỏi</strong>. Sẵn sàng nộp bài để xem kết quả!`;
            }
        }

        modal.style.display = 'flex';
    } else {
        // Fallback nếu không tìm thấy modal
        let msg = 'Bạn chắc chắn muốn nộp bài thi?';
        if (answeredCount < totalCount) {
            msg = `Bạn mới trả lời ${answeredCount}/${totalCount} câu hỏi.\nBạn có chắc chắn muốn nộp bài ngay bây giờ?`;
        }
        if (confirm(msg)) {
            submitQuiz(false);
        }
    }
}

function closeSubmitModal() {
    const modal = document.getElementById('submitConfirmModal');
    if (modal) modal.style.display = 'none';
}

function proceedFinalSubmit() {
    closeSubmitModal();
    submitQuiz(false);
}

function submitQuiz(isAutoSubmit) {
    if (isSubmitted) return;
    isSubmitted = true;
    if (timerInterval) clearInterval(timerInterval);

    const form = document.getElementById('quizForm');
    if (form) {
        form.submit();
    }
}
