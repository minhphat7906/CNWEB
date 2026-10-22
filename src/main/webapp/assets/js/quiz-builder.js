/**
 * QuizMaster - Dynamic Question Builder Engine
 */

let questionCounter = 0;

function addQuestionCard(existingData) {
    questionCounter++;
    const container = document.getElementById('questionsContainer');
    if (!container) return;

    const data = existingData || {
        text: '',
        a: '',
        b: '',
        c: '',
        d: '',
        correct: 'A',
        points: 1,
        explanation: ''
    };

    const card = document.createElement('div');
    card.className = 'card question-builder-card';
    card.id = 'qCard_' + questionCounter;
    card.style.marginBottom = '20px';
    card.style.position = 'relative';

    card.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 class="q-title" style="color: var(--primary); font-weight: 700;">Câu hỏi #<span class="q-number">${questionCounter}</span></h4>
            <button type="button" class="btn btn-danger btn-sm" onclick="removeQuestionCard('qCard_${questionCounter}')">
                <i class="fas fa-trash"></i> Xóa câu này
            </button>
        </div>

        <div class="form-group">
            <label class="form-label">Nội dung câu hỏi <span style="color: red;">*</span></label>
            <textarea name="questionText" class="form-control" rows="2" placeholder="Nhập nội dung câu hỏi trắc nghiệm..." required>${escapeHtml(data.text)}</textarea>
        </div>

        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 16px;">
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">Đáp án A <span style="color: red;">*</span></label>
                <input type="text" name="optionA" class="form-control" value="${escapeHtml(data.a)}" placeholder="Nội dung đáp án A" required>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">Đáp án B <span style="color: red;">*</span></label>
                <input type="text" name="optionB" class="form-control" value="${escapeHtml(data.b)}" placeholder="Nội dung đáp án B" required>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">Đáp án C <span style="color: red;">*</span></label>
                <input type="text" name="optionC" class="form-control" value="${escapeHtml(data.c)}" placeholder="Nội dung đáp án C" required>
            </div>
            <div class="form-group" style="margin-bottom: 0;">
                <label class="form-label">Đáp án D <span style="color: red;">*</span></label>
                <input type="text" name="optionD" class="form-control" value="${escapeHtml(data.d)}" placeholder="Nội dung đáp án D" required>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 16px;">
            <div class="form-group">
                <label class="form-label">Đáp án ĐÚNG <span style="color: red;">*</span></label>
                <select name="correctOption" class="form-control" style="font-weight: 700; color: var(--primary);">
                    <option value="A" ${data.correct === 'A' ? 'selected' : ''}>A</option>
                    <option value="B" ${data.correct === 'B' ? 'selected' : ''}>B</option>
                    <option value="C" ${data.correct === 'C' ? 'selected' : ''}>C</option>
                    <option value="D" ${data.correct === 'D' ? 'selected' : ''}>D</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Lời giải thích chi tiết (hiển thị sau khi thi)</label>
                <input type="text" name="explanation" class="form-control" value="${escapeHtml(data.explanation)}" placeholder="Giải thích lý do chọn đáp án này...">
            </div>
        </div>
    `;

    container.appendChild(card);
    updateQuestionNumbers();
}

function removeQuestionCard(cardId) {
    const card = document.getElementById(cardId);
    if (card) {
        card.remove();
        updateQuestionNumbers();
    }
}

function updateQuestionNumbers() {
    const cards = document.querySelectorAll('.question-builder-card');
    cards.forEach((c, index) => {
        const numSpan = c.querySelector('.q-number');
        if (numSpan) numSpan.innerText = (index + 1);
    });

    const totalEl = document.getElementById('totalQuestionsCount');
    if (totalEl) totalEl.innerText = cards.length;
}

function escapeHtml(text) {
    if (!text) return '';
    return text.toString()
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}
