package com.quizmaster.controller;

import com.quizmaster.dao.CategoryDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ReviewDAO;
import com.quizmaster.model.Category;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.Review;
import com.quizmaster.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "QuizServlet", urlPatterns = {"/quiz"})
public class QuizServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            handleQuizDetail(request, response, idParam.trim());
        } else {
            handleQuizList(request, response);
        }
    }

    private void handleQuizDetail(HttpServletRequest request, HttpServletResponse response, String idStr)
            throws ServletException, IOException {
        int quizId;
        try {
            quizId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/quiz");
            return;
        }

        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy bộ đề thi này.");
            return;
        }

        javax.servlet.http.HttpSession session = request.getSession(false);
        com.quizmaster.model.User currentUser = (session != null) ? (com.quizmaster.model.User) session.getAttribute("currentUser") : null;
        if (!quiz.isPublic()) {
            if (currentUser == null || (!currentUser.isAdmin() && quiz.getCreatorId() != currentUser.getId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bộ đề này đang ở chế độ riêng tư.");
                return;
            }
        }

        boolean userHasAttempted = false;
        if (currentUser != null) {
            com.quizmaster.dao.AttemptDAO attemptDAO = new com.quizmaster.dao.AttemptDAO();
            userHasAttempted = currentUser.isAdmin() || quiz.getCreatorId() == currentUser.getId() || attemptDAO.countUserAttempts(currentUser.getId(), quizId) > 0;
        }

        request.setAttribute("quiz", quiz);
        request.setAttribute("userHasAttempted", userHasAttempted);
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-detail.jsp").forward(request, response);
    }

    private void handleQuizList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String difficulty = request.getParameter("difficulty");
        String sort = request.getParameter("sort");
        int page = ValidationUtils.parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 6; // 6 đề mỗi trang để hiển thị lưới 3 cột cân đối

        List<Quiz> allQuizzes = quizDAO.getAllPublicQuizzes(keyword, null, difficulty, sort);
        int totalCount = allQuizzes != null ? allQuizzes.size() : 0;
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalCount);
        List<Quiz> pagedQuizzes = (allQuizzes != null && fromIndex < totalCount)
                ? allQuizzes.subList(fromIndex, toIndex)
                : new java.util.ArrayList<>();

        request.setAttribute("quizzes", pagedQuizzes);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("selectedDifficulty", difficulty);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-list.jsp").forward(request, response);
    }
}
