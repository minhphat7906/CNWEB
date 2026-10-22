package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.CategoryDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.UserDAO;
import com.quizmaster.model.Category;
import com.quizmaster.model.Quiz;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final QuizDAO quizDAO = new QuizDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Category> categories = categoryDAO.getAllCategories();
        List<Quiz> featuredQuizzes = quizDAO.getFeaturedQuizzes(6);

        // Thống kê nền tảng
        int totalUsers = userDAO.countUsers();
        int totalQuizzes = quizDAO.countQuizzes();
        int totalAttempts = attemptDAO.countCompletedAttempts();

        request.setAttribute("categories", categories);
        request.setAttribute("featuredQuizzes", featuredQuizzes);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalQuizzes", totalQuizzes);
        request.setAttribute("totalAttempts", totalAttempts);

        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}
