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
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "LeaderboardServlet", urlPatterns = {"/leaderboard"})
public class LeaderboardServlet extends HttpServlet {

    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            String redirectUrl = request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : "");
            response.sendRedirect(request.getContextPath() + "/auth?action=login&redirect=" + URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Lấy danh sách các đề thi mà thí sinh ĐÃ LÀM (hoặc giáo viên/admin đã tạo)
        List<Quiz> eligibleQuizzes = quizDAO.getQuizzesEligibleForLeaderboard(user.getId(), user.isAdmin());

        int quizId = ValidationUtils.parsePositiveInt(request.getParameter("quizId"), 0);

        if (quizId <= 0) {
            if (!eligibleQuizzes.isEmpty()) {
                quizId = eligibleQuizzes.get(0).getId();
            }
        }

        Quiz selectedQuiz = null;
        boolean canView = false;
        String blockReason = null;

        if (quizId > 0) {
            selectedQuiz = quizDAO.getQuizById(quizId);
            if (selectedQuiz != null) {
                if (user.isAdmin() || selectedQuiz.getCreatorId() == user.getId()) {
                    canView = true;
                } else {
                    int attemptsCount = attemptDAO.countUserAttempts(user.getId(), quizId);
                    if (attemptsCount <= 0) {
                        canView = false;
                        blockReason = "NOT_ATTEMPTED";
                    } else if (!selectedQuiz.isShowRanking()) {
                        canView = false;
                        blockReason = "RANKING_DISABLED";
                    } else {
                        canView = true;
                    }
                }
            } else {
                blockReason = "NOT_FOUND";
            }
        }

        List<Attempt> topAttempts = null;
        if (canView && quizId > 0) {
            topAttempts = attemptDAO.getLeaderboard(quizId, 30);
        }

        request.setAttribute("quizzes", eligibleQuizzes);
        request.setAttribute("selectedQuiz", selectedQuiz);
        request.setAttribute("selectedQuizId", quizId);
        request.setAttribute("canView", canView);
        request.setAttribute("blockReason", blockReason);
        request.setAttribute("topAttempts", topAttempts);

        request.getRequestDispatcher("/WEB-INF/views/leaderboard.jsp").forward(request, response);
    }
}

