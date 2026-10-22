package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ReviewDAO;
import com.quizmaster.model.*;
import com.quizmaster.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "TakeQuizServlet", urlPatterns = {"/quiz-take"})
public class TakeQuizServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if ("result".equalsIgnoreCase(action)) {
            showResult(request, response, currentUser);
        } else {
            startQuizArena(request, response, currentUser);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if ("review".equalsIgnoreCase(action)) {
            handleReview(request, response, currentUser);
        } else {
            handleSubmitQuiz(request, response, currentUser);
        }
    }

    private void startQuizArena(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int quizId = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
        Quiz quiz = quizDAO.getQuizById(quizId);

        if (quiz == null) {
            response.sendRedirect(request.getContextPath() + "/quiz?error=notfound");
            return;
        }

        if (!quiz.isPublic() && !user.isAdmin() && quiz.getCreatorId() != user.getId()) {
            response.sendRedirect(request.getContextPath() + "/quiz?error=forbidden");
            return;
        }

        // 1. Kiểm tra Mật khẩu phòng thi (Access Code) kiểu Azota (miễn cho Tác giả & Admin)
        if (quiz.hasAccessCode() && !user.isAdmin() && quiz.getCreatorId() != user.getId()) {
            String enteredCode = request.getParameter("accessCode");
            HttpSession session = request.getSession();
            Boolean isUnlocked = (Boolean) session.getAttribute("unlocked_quiz_" + quizId);

            if (isUnlocked == null || !isUnlocked) {
                if (enteredCode != null && enteredCode.trim().equals(quiz.getAccessCode().trim())) {
                    session.setAttribute("unlocked_quiz_" + quizId, true);
                } else if (enteredCode != null && !enteredCode.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/quiz?id=" + quizId + "&error=wrong_passcode");
                    return;
                } else {
                    // Chưa nhập mật khẩu -> chuyển hướng về trang chi tiết yêu cầu nhập
                    response.sendRedirect(request.getContextPath() + "/quiz?id=" + quizId + "&require_passcode=true");
                    return;
                }
            }
        }

        // 2. Kiểm tra Số lần làm bài tối đa (Max Attempts) kiểu Azota (miễn cho Tác giả & Admin)
        if (quiz.getMaxAttempts() > 0 && !user.isAdmin() && quiz.getCreatorId() != user.getId()) {
            int completedCount = attemptDAO.countUserAttempts(user.getId(), quizId);
            if (completedCount >= quiz.getMaxAttempts()) {
                response.sendRedirect(request.getContextPath() + "/quiz?id=" + quizId + "&error=max_attempts_reached&limit=" + quiz.getMaxAttempts());
                return;
            }
        }

        // 3. Lấy danh sách câu hỏi và BẢO MẬT ZERO-TRUST: hideAnswers = true
        List<Question> questions = questionDAO.getQuestionsByQuizId(quizId, true);
        if (questions == null || questions.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/quiz?id=" + quizId + "&error=empty");
            return;
        }

        // 4. Kỹ thuật Đảo câu hỏi ngẫu nhiên (Shuffle Questions) kiểu Azota
        if (quiz.isShuffleQuestions()) {
            java.util.Collections.shuffle(questions);
        }

        request.setAttribute("quiz", quiz);
        request.setAttribute("questions", questions);
        request.setAttribute("totalQuestions", questions.size());

        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-take.jsp").forward(request, response);
    }

    private void handleSubmitQuiz(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int quizId = ValidationUtils.parsePositiveInt(request.getParameter("quizId"), 0);
        int timeSpent = ValidationUtils.parsePositiveInt(request.getParameter("timeSpent"), 0);
        int tabSwitches = ValidationUtils.parsePositiveInt(request.getParameter("tabSwitches"), 0);

        Map<Integer, String> userAnswers = new HashMap<>();

        // Quét tất cả tham số form dạng "q_<questionId>"
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            if (paramName.startsWith("q_")) {
                try {
                    int questionId = Integer.parseInt(paramName.substring(2));
                    String chosenOption = request.getParameter(paramName);
                    if (chosenOption != null && !chosenOption.trim().isEmpty()) {
                        userAnswers.put(questionId, chosenOption.trim().toUpperCase());
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        // Chấm điểm an toàn tại Server kèm ghi nhận số lần chuyển tab gian lận
        int attemptId = attemptDAO.evaluateAttempt(user.getId(), quizId, timeSpent, tabSwitches, userAnswers);

        // Chuyển hướng sang trang kết quả
        response.sendRedirect(request.getContextPath() + "/quiz-take?action=result&attemptId=" + attemptId);
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int attemptId = ValidationUtils.parsePositiveInt(request.getParameter("attemptId"), 0);
        Attempt attempt = attemptDAO.getAttemptById(attemptId);

        if (attempt == null) {
            response.sendRedirect(request.getContextPath() + "/home?error=attemptnotfound");
            return;
        }

        // Chỉ cho phép người thi hoặc admin xem chi tiết
        if (!user.isAdmin() && attempt.getUserId() != user.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem kết quả của người khác.");
            return;
        }

        Quiz quiz = quizDAO.getQuizById(attempt.getQuizId());

        request.setAttribute("attempt", attempt);
        request.setAttribute("quiz", quiz);

        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-result.jsp").forward(request, response);
    }

    private void handleReview(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int quizId = ValidationUtils.parsePositiveInt(request.getParameter("quizId"), 0);
        int attemptId = ValidationUtils.parsePositiveInt(request.getParameter("attemptId"), 0);
        int rating = ValidationUtils.parsePositiveInt(request.getParameter("rating"), 5);
        String comment = request.getParameter("comment");

        if (quizId > 0 && rating >= 1 && rating <= 5) {
            Review review = new Review(user.getId(), quizId, rating, comment);
            reviewDAO.addOrUpdateReview(review);
        }

        response.sendRedirect(request.getContextPath() + "/quiz-take?action=result&attemptId=" + attemptId + "&reviewed=true");
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }
}
