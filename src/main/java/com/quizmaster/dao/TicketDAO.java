package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.SupportTicket;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TicketDAO {
    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());

    public boolean createTicket(SupportTicket ticket) {
        String sql = "INSERT INTO support_tickets (user_id, name, email, subject, message, status) VALUES (?, ?, ?, ?, ?, 'PENDING')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            if (ticket.getUserId() != null && ticket.getUserId() > 0) {
                ps.setInt(1, ticket.getUserId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, ticket.getName());
            ps.setString(3, ticket.getEmail());
            ps.setString(4, ticket.getSubject());
            ps.setString(5, ticket.getMessage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating support ticket", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public List<SupportTicket> getAllTickets(String status) {
        List<SupportTicket> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM support_tickets WHERE 1=1 ");
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND status = ? ");
        }
        sql.append(" ORDER BY id DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
                ps.setString(1, status.trim());
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                SupportTicket t = new SupportTicket();
                t.setId(rs.getInt("id"));
                int uId = rs.getInt("user_id");
                t.setUserId(rs.wasNull() ? null : uId);
                t.setName(rs.getString("name"));
                t.setEmail(rs.getString("email"));
                t.setSubject(rs.getString("subject"));
                t.setMessage(rs.getString("message"));
                t.setStatus(rs.getString("status"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(t);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllTickets", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public boolean updateTicketStatus(int id, String status) {
        String sql = "UPDATE support_tickets SET status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating ticket status", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public int countPendingTickets() {
        String sql = "SELECT COUNT(*) FROM support_tickets WHERE status = 'PENDING'";
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countPendingTickets", e);
        } finally {
            DBContext.close(conn, st, rs);
        }
        return 0;
    }
}
