package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.UserDAO;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.User;
import com.quizmaster.util.PasswordUtils;
import com.quizmaster.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        // Lấy thông tin mới nhất từ DB
        User freshUser = userDAO.findById(currentUser.getId());
        if (freshUser != null) {
            request.getSession().setAttribute("currentUser", freshUser);
            currentUser = freshUser;
        }

        List<Attempt> attempts = attemptDAO.getAttemptsByUser(currentUser.getId());

        // Tính toán thống kê cá nhân
        int totalAttempts = attempts.size();
        int passedCount = 0;
        double totalScore = 0;
        double maxScore = 0;

        for (Attempt a : attempts) {
            totalScore += a.getScore();
            if (a.isPassed()) passedCount++;
            if (a.getScore() > maxScore) maxScore = a.getScore();
        }

        double avgScore = totalAttempts > 0 ? (Math.round((totalScore / totalAttempts) * 10.0) / 10.0) : 0.0;

        request.setAttribute("user", currentUser);
        request.setAttribute("attempts", attempts);
        request.setAttribute("totalAttempts", totalAttempts);
        request.setAttribute("passedCount", passedCount);
        request.setAttribute("avgScore", avgScore);
        request.setAttribute("maxScore", maxScore);

        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
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
        if ("changePassword".equalsIgnoreCase(action)) {
            handleChangePassword(request, response, currentUser);
        } else {
            handleUpdateInfo(request, response, currentUser);
        }
    }

    private void handleUpdateInfo(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");

        if (ValidationUtils.isNotEmpty(fullName) && ValidationUtils.isValidEmail(email)) {
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            userDAO.updateProfile(user);
            request.getSession().setAttribute("currentUser", user);
            response.sendRedirect(request.getContextPath() + "/profile?success=profile_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/profile?error=invalid_info");
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        User fresh = userDAO.findById(user.getId());
        if (fresh == null || !PasswordUtils.checkPassword(currentPassword, fresh.getPasswordHash())) {
            response.sendRedirect(request.getContextPath() + "/profile?error=wrong_current_password");
            return;
        }

        if (newPassword == null || newPassword.length() < 6 || !newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/profile?error=invalid_new_password");
            return;
        }

        String newHash = PasswordUtils.hashPassword(newPassword);
        userDAO.changePassword(user.getId(), newHash);
        response.sendRedirect(request.getContextPath() + "/profile?success=password_changed");
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }
}
