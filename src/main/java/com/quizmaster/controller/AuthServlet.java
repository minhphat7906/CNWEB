package com.quizmaster.controller;

import com.quizmaster.dao.UserDAO;
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

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "login";

        switch (action) {
            case "logout":
                handleLogout(request, response);
                break;
            case "register":
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                break;
            case "login":
            default:
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("register".equalsIgnoreCase(action)) {
            handleRegister(request, response);
        } else {
            handleLogin(request, response);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        if (!ValidationUtils.isNotEmpty(identifier) || !ValidationUtils.isNotEmpty(password)) {
            request.setAttribute("errorMessage", "Vui lòng nhập tên đăng nhập/email và mật khẩu.");
            request.setAttribute("identifier", identifier);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByUsernameOrEmail(identifier.trim());
        if (user == null || !PasswordUtils.checkPassword(password, user.getPasswordHash())) {
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác.");
            request.setAttribute("identifier", identifier);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập thành công -> Lưu session
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);

        if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("auth")) {
            response.sendRedirect(redirect);
        } else {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        if (role == null || (!"STUDENT".equalsIgnoreCase(role) && !"TEACHER".equalsIgnoreCase(role))) {
            role = "STUDENT";
        }

        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("fullName", fullName);
        request.setAttribute("role", role);

        if (!ValidationUtils.isValidUsername(username)) {
            request.setAttribute("errorMessage", "Tên đăng nhập từ 3 đến 30 ký tự (chỉ gồm chữ cái, số, dấu gạch dưới).");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtils.isValidEmail(email)) {
            request.setAttribute("errorMessage", "Định dạng email không hợp lệ.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtils.isNotEmpty(fullName)) {
            request.setAttribute("errorMessage", "Họ và tên không được để trống.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (password == null || password.length() < 6) {
            request.setAttribute("errorMessage", "Mật khẩu phải chứa ít nhất 6 ký tự.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Xác nhận mật khẩu không trùng khớp.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.findByUsernameOrEmail(username.trim()) != null) {
            request.setAttribute("errorMessage", "Tên đăng nhập đã được sử dụng. Vui lòng chọn tên khác.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.findByUsernameOrEmail(email.trim()) != null) {
            request.setAttribute("errorMessage", "Email này đã được đăng ký trên hệ thống.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        String passwordHash = PasswordUtils.hashPassword(password);
        User newUser = new User(0, username.trim(), email.trim(), passwordHash, fullName.trim(), role);

        boolean success = userDAO.register(newUser);
        if (success) {
            // Tự động đăng nhập
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", newUser);
            session.setAttribute("flashSuccess", "Đăng ký tài khoản thành công! Chào mừng bạn gia nhập QuizMaster.");
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình đăng ký. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
