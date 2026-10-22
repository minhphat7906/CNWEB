package com.quizmaster.controller;

import com.quizmaster.dao.CategoryDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.model.Category;
import com.quizmaster.model.Question;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "QuizManageServlet", urlPatterns = {"/quiz-manage"})
public class QuizManageServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "create":
                response.sendRedirect(request.getContextPath() + "/quiz-lab");
                break;
            case "edit":
                int editId = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
                response.sendRedirect(request.getContextPath() + "/quiz-lab?action=edit&id=" + editId);
                break;
            case "delete":
                handleDelete(request, response, currentUser);
                break;
            case "list":
            default:
                showQuizList(request, response, currentUser);
                break;
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
        if ("edit".equalsIgnoreCase(action)) {
            handleSaveQuiz(request, response, currentUser, true);
        } else {
            handleSaveQuiz(request, response, currentUser, false);
        }
    }

    private void showQuizList(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Quiz> myQuizzes;
        if (user.isAdmin()) {
            myQuizzes = quizDAO.getAllQuizzesForAdmin();
        } else {
            myQuizzes = quizDAO.getQuizzesByCreator(user.getId());
        }
        request.setAttribute("quizzes", myQuizzes);
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-manage.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int id = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
        Quiz quiz = quizDAO.getQuizById(id);

        if (quiz == null) {
            response.sendRedirect(request.getContextPath() + "/quiz-manage?error=notfound");
            return;
        }

        // Kiểm tra quyền sở hữu
        if (!user.isAdmin() && quiz.getCreatorId() != user.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa bộ đề này.");
            return;
        }

        List<Question> questions = questionDAO.getQuestionsByQuizId(id, false);
        quiz.setQuestions(questions);

        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("quiz", quiz);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-edit.jsp").forward(request, response);
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int id = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
        Quiz quiz = quizDAO.getQuizById(id);

        if (quiz != null && (user.isAdmin() || quiz.getCreatorId() == user.getId())) {
            quizDAO.deleteQuiz(id);
            response.sendRedirect(request.getContextPath() + "/quiz-manage?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/quiz-manage?error=forbidden");
        }
    }

    private void handleSaveQuiz(HttpServletRequest request, HttpServletResponse response, User user, boolean isEdit)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        int categoryId = ValidationUtils.parsePositiveInt(request.getParameter("categoryId"), 1);
        int timeLimit = 0;
        try {
            timeLimit = Integer.parseInt(request.getParameter("timeLimit"));
            if (timeLimit < 0) timeLimit = 0;
        } catch (Exception e) {
            timeLimit = 15;
        }
        String difficulty = request.getParameter("difficulty");
        boolean isPublic = "on".equalsIgnoreCase(request.getParameter("isPublic")) || "true".equalsIgnoreCase(request.getParameter("isPublic"));

        boolean shuffleQuestions = "on".equalsIgnoreCase(request.getParameter("shuffleQuestions")) || "true".equalsIgnoreCase(request.getParameter("shuffleQuestions"));
        boolean shuffleOptions = "on".equalsIgnoreCase(request.getParameter("shuffleOptions")) || "true".equalsIgnoreCase(request.getParameter("shuffleOptions"));
        boolean showAnswers = "on".equalsIgnoreCase(request.getParameter("showAnswers")) || "true".equalsIgnoreCase(request.getParameter("showAnswers"));
        String accessCode = request.getParameter("accessCode");
        int maxAttempts = ValidationUtils.parsePositiveInt(request.getParameter("maxAttempts"), 0);
        boolean antiCheat = "on".equalsIgnoreCase(request.getParameter("antiCheat")) || "true".equalsIgnoreCase(request.getParameter("antiCheat"));

        if (!ValidationUtils.isNotEmpty(title)) {
            request.setAttribute("errorMessage", "Tiêu đề đề thi không được để trống.");
            showCreateForm(request, response);
            return;
        }

        // Lấy danh sách câu hỏi qua mảng tham số
        String[] qTexts = request.getParameterValues("questionText");
        String[] optAs = request.getParameterValues("optionA");
        String[] optBs = request.getParameterValues("optionB");
        String[] optCs = request.getParameterValues("optionC");
        String[] optDs = request.getParameterValues("optionD");
        String[] correctOpts = request.getParameterValues("correctOption");
        String[] explanations = request.getParameterValues("explanation");

        if (qTexts == null || qTexts.length == 0) {
            request.setAttribute("errorMessage", "Đề thi phải có ít nhất 1 câu hỏi.");
            showCreateForm(request, response);
            return;
        }

        List<Question> questions = new ArrayList<>();
        for (int i = 0; i < qTexts.length; i++) {
            if (ValidationUtils.isNotEmpty(qTexts[i])) {
                Question q = new Question();
                q.setQuestionText(qTexts[i].trim());
                q.setOptionA(optAs != null && optAs.length > i ? optAs[i].trim() : "");
                q.setOptionB(optBs != null && optBs.length > i ? optBs[i].trim() : "");
                q.setOptionC(optCs != null && optCs.length > i ? optCs[i].trim() : "");
                q.setOptionD(optDs != null && optDs.length > i ? optDs[i].trim() : "");
                String correct = (correctOpts != null && correctOpts.length > i) ? correctOpts[i].trim().toUpperCase() : "A";
                q.setCorrectOption(correct);
                q.setPoints(1);
                q.setExplanation(explanations != null && explanations.length > i ? explanations[i].trim() : "");
                questions.add(q);
            }
        }

        Quiz quiz = new Quiz();
        quiz.setTitle(title.trim());
        quiz.setDescription(request.getParameter("description") != null ? request.getParameter("description").trim() : "");
        quiz.setCategoryId(categoryId);
        quiz.setCreatorId(user.getId());
        quiz.setTimeLimit(timeLimit);
        quiz.setDifficulty(difficulty != null ? difficulty : "MEDIUM");
        quiz.setPublic(isPublic);
        quiz.setShuffleQuestions(shuffleQuestions);
        quiz.setShuffleOptions(shuffleOptions);
        quiz.setShowAnswers(showAnswers);
        quiz.setAccessCode(accessCode != null && !accessCode.trim().isEmpty() ? accessCode.trim() : null);
        quiz.setMaxAttempts(maxAttempts);
        quiz.setAntiCheat(antiCheat);

        if (isEdit) {
            int quizId = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
            Quiz existing = quizDAO.getQuizById(quizId);
            if (existing == null || (!user.isAdmin() && existing.getCreatorId() != user.getId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            quiz.setId(quizId);
            boolean updated = quizDAO.updateQuiz(quiz, questions);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/quiz-manage?success=updated");
            } else {
                request.setAttribute("errorMessage", "Lỗi khi cập nhật đề thi.");
                showEditForm(request, response, user);
            }
        } else {
            int newId = quizDAO.createQuiz(quiz, questions);
            if (newId > 0) {
                response.sendRedirect(request.getContextPath() + "/quiz-manage?success=created");
            } else {
                request.setAttribute("errorMessage", "Lỗi khi tạo đề thi mới.");
                showCreateForm(request, response);
            }
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }
}
