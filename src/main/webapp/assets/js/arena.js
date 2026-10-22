/**
 * QuizMaster - Quiz Arena Runtime Engine (Countdown, Palette sync, Anti-cheat & Auto-submit)
 */

let timeRemainingSeconds = 0;
let totalTimeSeconds = 0;
let timeSpentSeconds = 0;
let timerInterval = null;
let isSubmitted = false;
let isUnlimited = false;
let tabSwitchesCount = 0;
let antiCheatEnabled = false;

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
            alert('Hết giờ làm bài! Hệ thống đang tự động nộp bài của bạn.');
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

    // Cập nhật trường ẩn timeSpent trong Form
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
 * Đảm bảo mỗi chu kỳ tab ra ngoài rồi quay vào chỉ tính ĐÚNG 1 lần.
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
        warningBox.style.top = '80px';
        warningBox.style.left = '50%';
        warningBox.style.transform = 'translateX(-50%)';
        warningBox.style.zIndex = '9999';
        warningBox.style.background = '#ef4444';
        warningBox.style.color = 'white';
        warningBox.style.padding = '14px 24px';
        warningBox.style.borderRadius = '12px';
        warningBox.style.boxShadow = '0 10px 25px rgba(239, 68, 68, 0.4)';
        warningBox.style.fontWeight = '700';
        warningBox.style.fontSize = '0.95rem';
        warningBox.style.display = 'flex';
        warningBox.style.alignItems = 'center';
        warningBox.style.gap = '12px';
        warningBox.style.animation = 'dropdownFadeIn 0.3s ease';
        document.body.appendChild(warningBox);
    }

    warningBox.innerHTML = '<i class="fas fa-exclamation-triangle" style="font-size: 1.3rem;"></i> ' +
        '<span>CẢNH BÁO: Phát hiện bạn rời khỏi màn hình làm bài lần thứ <strong>' + count + '</strong>! Hành vi này đã được ghi lại.</span>';

    setTimeout(function () {
        if (warningBox && warningBox.parentNode) {
            warningBox.style.transition = 'opacity 0.5s ease';
            warningBox.style.opacity = '0';
            setTimeout(function () {
                if (warningBox.parentNode) warningBox.parentNode.removeChild(warningBox);
            }, 500);
        }
    }, 4500);
}

function initOptionListeners() {
    const radioInputs = document.querySelectorAll('input[type="radio"]');
    radioInputs.forEach(function (radio) {
        radio.addEventListener('change', function () {
            const questionId = this.getAttribute('data-question-id');
            const qIndex = this.getAttribute('data-question-index');

            // Cập nhật style cho nhãn được chọn trong cùng câu hỏi
            const parentContainer = this.closest('.options-list');
            if (parentContainer) {
                const labels = parentContainer.querySelectorAll('.option-label');
                labels.forEach(l => l.classList.remove('selected'));
                const chosenLabel = this.closest('.option-label');
                if (chosenLabel) chosenLabel.classList.add('selected');
            }

            // Đổi màu nút câu hỏi trên palette lưới câu hỏi
            const paletteBtn = document.getElementById('palette-btn-' + qIndex);
            if (paletteBtn) {
                paletteBtn.classList.add('answered');
            }

            updateAnsweredProgress();
        });
    });
}

function scrollToQuestion(index) {
    const target = document.getElementById('q-card-' + index);
    if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'center' });
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

function confirmSubmitQuiz() {
    const answeredCount = document.querySelectorAll('.palette-btn.answered').length;
    const totalCount = document.querySelectorAll('.palette-btn').length;

    let msg = 'Bạn chắc chắn muốn nộp bài thi?';
    if (answeredCount < totalCount) {
        msg = 'Bạn mới hoàn thành ' + answeredCount + '/' + totalCount + ' câu hỏi.\nBạn có chắc chắn muốn nộp bài ngay bây giờ?';
    }

    if (confirm(msg)) {
        submitQuiz(false);
    }
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
