package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.TicketDAO;
import com.quizmaster.dao.UserDAO;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.SupportTicket;
import com.quizmaster.model.User;
import com.quizmaster.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final QuizDAO quizDAO = new QuizDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "dashboard";

        switch (tab) {
            case "users":
                showUsersTab(request, response);
                break;
            case "quizzes":
                showQuizzesTab(request, response);
                break;
            case "tickets":
                showTicketsTab(request, response);
                break;
            case "dashboard":
            default:
                showDashboardTab(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        switch (action) {
            case "updateRole": {
                int userId = ValidationUtils.parsePositiveInt(request.getParameter("userId"), 0);
                String newRole = request.getParameter("newRole");
                if (userId > 0 && newRole != null) {
                    userDAO.updateRole(userId, newRole);
                }
                response.sendRedirect(request.getContextPath() + "/admin?tab=users&success=role_updated");
                break;
            }
            case "deleteUser": {
                int userId = ValidationUtils.parsePositiveInt(request.getParameter("userId"), 0);
                if (userId > 0) {
                    userDAO.deleteUser(userId);
                }
                response.sendRedirect(request.getContextPath() + "/admin?tab=users&success=user_deleted");
                break;
            }
            case "toggleQuiz": {
                int quizId = ValidationUtils.parsePositiveInt(request.getParameter("quizId"), 0);
                if (quizId > 0) {
                    quizDAO.toggleVisibility(quizId);
                }
                response.sendRedirect(request.getContextPath() + "/admin?tab=quizzes&success=quiz_toggled");
                break;
            }
            case "deleteQuiz": {
                int quizId = ValidationUtils.parsePositiveInt(request.getParameter("quizId"), 0);
                if (quizId > 0) {
                    quizDAO.deleteQuiz(quizId);
                }
                response.sendRedirect(request.getContextPath() + "/admin?tab=quizzes&success=quiz_deleted");
                break;
            }
            case "updateTicket": {
                int ticketId = ValidationUtils.parsePositiveInt(request.getParameter("ticketId"), 0);
                String status = request.getParameter("status");
                if (ticketId > 0 && status != null) {
                    ticketDAO.updateTicketStatus(ticketId, status);
                }
                response.sendRedirect(request.getContextPath() + "/admin?tab=tickets&success=ticket_updated");
                break;
            }
            default:
                response.sendRedirect(request.getContextPath() + "/admin");
                break;
        }
    }

    private void showDashboardTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int totalUsers = userDAO.countUsers();
        int totalQuizzes = quizDAO.countQuizzes();
        int totalAttempts = attemptDAO.countCompletedAttempts();
        int pendingTickets = ticketDAO.countPendingTickets();

        List<User> recentUsers = userDAO.getAllUsers("ALL", null);
        if (recentUsers.size() > 5) recentUsers = recentUsers.subList(0, 5);

        List<Quiz> recentQuizzes = quizDAO.getAllQuizzesForAdmin();
        if (recentQuizzes.size() > 5) recentQuizzes = recentQuizzes.subList(0, 5);

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalQuizzes", totalQuizzes);
        request.setAttribute("totalAttempts", totalAttempts);
        request.setAttribute("pendingTickets", pendingTickets);
        request.setAttribute("recentUsers", recentUsers);
        request.setAttribute("recentQuizzes", recentQuizzes);

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }

    private void showUsersTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String role = request.getParameter("role");
        String keyword = request.getParameter("keyword");

        List<User> users = userDAO.getAllUsers(role, keyword);

        request.setAttribute("users", users);
        request.setAttribute("selectedRole", role);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/admin/manage-users.jsp").forward(request, response);
    }

    private void showQuizzesTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Quiz> quizzes = quizDAO.getAllQuizzesForAdmin();
        request.setAttribute("quizzes", quizzes);
        request.getRequestDispatcher("/WEB-INF/views/admin/manage-quizzes.jsp").forward(request, response);
    }

    private void showTicketsTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        List<SupportTicket> tickets = ticketDAO.getAllTickets(status);

        request.setAttribute("tickets", tickets);
        request.setAttribute("selectedStatus", status);

        request.getRequestDispatcher("/WEB-INF/views/admin/manage-tickets.jsp").forward(request, response);
    }
}
