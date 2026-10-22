package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.User;
import com.quizmaster.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HistoryServlet", urlPatterns = {"/history"})
public class HistoryServlet extends HttpServlet {

    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login&redirect=" +
                    java.net.URLEncoder.encode(request.getContextPath() + "/history", "UTF-8"));
            return;
        }

        int quizId = ValidationUtils.parsePositiveInt(request.getParameter("quizId"), 0);
        List<Attempt> attempts;
        Quiz selectedQuiz = null;

        if (quizId > 0) {
            attempts = attemptDAO.getAttemptsByUserAndQuiz(currentUser.getId(), quizId);
            selectedQuiz = quizDAO.getQuizById(quizId);
        } else {
            attempts = attemptDAO.getAttemptsByUser(currentUser.getId());
        }

        // Tính toán các chỉ số thống kê
        int total = attempts.size();
        double sumScore = 0.0;
        double maxScore = 0.0;
        int completedCount = 0;

        for (Attempt a : attempts) {
            if ("COMPLETED".equalsIgnoreCase(a.getStatus())) {
                completedCount++;
                sumScore += a.getScore();
                if (a.getScore() > maxScore) {
                    maxScore = a.getScore();
                }
            }
        }

        double avgScore = completedCount > 0 ? (Math.round((sumScore / completedCount) * 10.0) / 10.0) : 0.0;

        request.setAttribute("attempts", attempts);
        request.setAttribute("selectedQuizId", quizId);
        request.setAttribute("selectedQuiz", selectedQuiz);
        request.setAttribute("totalAttempts", total);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("avgScore", avgScore);
        request.setAttribute("highestScore", maxScore);

        request.getRequestDispatcher("/WEB-INF/views/history.jsp").forward(request, response);
    }
}
