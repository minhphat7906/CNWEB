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

@WebServlet(name = "QuizLabServlet", urlPatterns = {"/quiz-lab"})
public class QuizLabServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login&redirect=" +
                    java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "studio";

        switch (action) {
            case "my-quizzes":
                showMyQuizzes(request, response, currentUser);
                break;
            case "edit":
                showEditInLab(request, response, currentUser);
                break;
            case "studio":
            default:
                showLabStudio(request, response, currentUser);
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
        if ("update".equalsIgnoreCase(action)) {
            handleSaveLabQuiz(request, response, currentUser, true);
        } else {
            handleSaveLabQuiz(request, response, currentUser, false);
        }
    }

    private void showLabStudio(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Category> categories = categoryDAO.getAllCategories();
        List<Quiz> myQuizzes = user.isAdmin() ? quizDAO.getAllQuizzesForAdmin() : quizDAO.getQuizzesByCreator(user.getId());

        request.setAttribute("categories", categories);
        request.setAttribute("myQuizzesCount", myQuizzes.size());
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-lab.jsp").forward(request, response);
    }

    private void showMyQuizzes(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Quiz> myQuizzes = user.isAdmin() ? quizDAO.getAllQuizzesForAdmin() : quizDAO.getQuizzesByCreator(user.getId());
        request.setAttribute("quizzes", myQuizzes);
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-manage.jsp").forward(request, response);
    }

    private void showEditInLab(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int id = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
        Quiz quiz = quizDAO.getQuizById(id);

        if (quiz == null) {
            response.sendRedirect(request.getContextPath() + "/quiz-lab?error=notfound");
            return;
        }

        // Quyền chỉnh sửa: Quản trị viên, Giáo viên, hoặc Tác giả tạo bộ đề
        boolean canEdit = user.isAdmin() || user.isTeacher() || quiz.getCreatorId() == user.getId();
        if (!canEdit) {
            response.sendRedirect(request.getContextPath() + "/quiz-manage?error=forbidden");
            return;
        }

        List<Question> questions = questionDAO.getQuestionsByQuizId(id, false);
        quiz.setQuestions(questions);

        List<Category> categories = categoryDAO.getAllCategories();
        List<Quiz> myQuizzes = user.isAdmin() ? quizDAO.getAllQuizzesForAdmin() : quizDAO.getQuizzesByCreator(user.getId());
        request.setAttribute("quiz", quiz);
        request.setAttribute("categories", categories);
        request.setAttribute("myQuizzesCount", myQuizzes.size());
        request.setAttribute("isEdit", true);
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-lab.jsp").forward(request, response);
    }

    private void handleSaveLabQuiz(HttpServletRequest request, HttpServletResponse response, User user, boolean isEdit)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String description = request.getParameter("description");
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
        boolean showRanking = "on".equalsIgnoreCase(request.getParameter("showRanking")) || "true".equalsIgnoreCase(request.getParameter("showRanking"));

        // Lấy danh sách câu hỏi và ID câu hỏi (để cập nhật đúng vị trí)
        String[] qIds = request.getParameterValues("questionId");
        String[] qTexts = request.getParameterValues("questionText");
        String[] optAs = request.getParameterValues("optionA");
        String[] optBs = request.getParameterValues("optionB");
        String[] optCs = request.getParameterValues("optionC");
        String[] optDs = request.getParameterValues("optionD");
        String[] correctOpts = request.getParameterValues("correctOption");
        String[] explanations = request.getParameterValues("explanation");

        List<Question> questions = new ArrayList<>();
        if (qTexts != null) {
            for (int i = 0; i < qTexts.length; i++) {
                String qText = qTexts[i] != null ? qTexts[i].trim() : "";
                String a = optAs != null && optAs.length > i ? optAs[i].trim() : "";
                String b = optBs != null && optBs.length > i ? optBs[i].trim() : "";
                String c = optCs != null && optCs.length > i ? optCs[i].trim() : "";
                String d = optDs != null && optDs.length > i ? optDs[i].trim() : "";

                // Chỉ nhận câu hỏi nếu có nội dung hoặc ít nhất 1 đáp án được điền
                if (!qText.isEmpty() || !a.isEmpty() || !b.isEmpty() || !c.isEmpty() || !d.isEmpty()) {
                    Question q = new Question();
                    int qId = (qIds != null && qIds.length > i) ? ValidationUtils.parsePositiveInt(qIds[i], 0) : 0;
                    q.setId(qId);
                    q.setQuestionText(qText);
                    q.setOptionA(a);
                    q.setOptionB(b);
                    q.setOptionC(c);
                    q.setOptionD(d);
                    String correct = (correctOpts != null && correctOpts.length > i) ? correctOpts[i].trim().toUpperCase() : "A";
                    q.setCorrectOption(correct);
                    q.setPoints(1);
                    q.setExplanation(explanations != null && explanations.length > i ? explanations[i].trim() : "");
                    questions.add(q);
                }
            }
        }

        // Tạo đối tượng Quiz chứa toàn bộ dữ liệu vừa nhập
        Quiz quiz = new Quiz();
        quiz.setTitle(title != null ? title.trim() : "");
        quiz.setDescription(description != null ? description.trim() : "");
        quiz.setCategoryId(ValidationUtils.parsePositiveInt(request.getParameter("categoryId"), 1));
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
        quiz.setShowRanking(showRanking);

        if (isEdit) {
            int quizId = ValidationUtils.parsePositiveInt(request.getParameter("id"), 0);
            Quiz existing = quizDAO.getQuizById(quizId);
            boolean canEdit = (existing != null) && (user.isAdmin() || user.isTeacher() || existing.getCreatorId() == user.getId());
            if (!canEdit) {
                response.sendRedirect(request.getContextPath() + "/quiz-manage?error=forbidden");
                return;
            }
            quiz.setId(quizId);
            if (existing != null) {
                quiz.setCreatorId(existing.getCreatorId());
            }
        }

        // Kiểm tra hợp lệ: Tiêu đề
        if (!ValidationUtils.isNotEmpty(title)) {
            forwardBackWithData(request, response, user, quiz, questions, isEdit, "Vui lòng nhập tiêu đề cho bộ đề thi.");
            return;
        }

        // Kiểm tra hợp lệ: Câu hỏi
        if (questions.isEmpty()) {
            forwardBackWithData(request, response, user, quiz, questions, isEdit, "Vui lòng soạn thảo ít nhất 1 câu hỏi trắc nghiệm có đầy đủ nội dung.");
            return;
        }

        if (isEdit) {
            boolean updated = quizDAO.updateQuiz(quiz, questions);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/quiz-manage?success=updated");
            } else {
                forwardBackWithData(request, response, user, quiz, questions, isEdit, "Có lỗi xảy ra khi cập nhật đề thi vào CSDL. Vui lòng kiểm tra lại dịch vụ MySQL.");
            }
        } else {
            int newId = quizDAO.createQuiz(quiz, questions);
            if (newId > 0) {
                response.sendRedirect(request.getContextPath() + "/quiz-manage?success=created");
            } else {
                forwardBackWithData(request, response, user, quiz, questions, isEdit, "Có lỗi xảy ra khi lưu đề thi vào CSDL. Vui lòng kiểm tra lại dịch vụ MySQL.");
            }
        }
    }

    /**
     * Giữ nguyên 100% dữ liệu form và danh sách câu hỏi khi có lỗi
     */
    private void forwardBackWithData(HttpServletRequest request, HttpServletResponse response, User user,
                                     Quiz quiz, List<Question> questions, boolean isEdit, String errorMsg)
            throws ServletException, IOException {
        if (quiz != null) {
            quiz.setQuestions(questions);
            request.setAttribute("quiz", quiz);
        }
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("errorMessage", errorMsg);
        request.setAttribute("categories", categoryDAO.getAllCategories());
        List<Quiz> myQuizzes = user.isAdmin() ? quizDAO.getAllQuizzesForAdmin() : quizDAO.getQuizzesByCreator(user.getId());
        request.setAttribute("myQuizzesCount", myQuizzes.size());
        request.getRequestDispatcher("/WEB-INF/views/quiz/quiz-lab.jsp").forward(request, response);
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }
}
