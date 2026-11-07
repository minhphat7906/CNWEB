package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.User;

import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public User findByUsernameOrEmail(String identifier) {
        String sql = "SELECT * FROM users WHERE username = ? OR email = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByUsernameOrEmail", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findById", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public boolean register(User user) {
        String sql = "INSERT INTO users (username, email, password_hash, full_name, role, avatar_url, current_streak) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 0)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getRole() != null ? user.getRole() : "STUDENT");
            ps.setString(6, user.getAvatarUrl() != null ? user.getAvatarUrl() : "default-avatar.png");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    user.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in register", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return false;
    }

    public boolean updateProfile(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, avatar_url = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getAvatarUrl());
            ps.setInt(4, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in updateProfile", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public boolean changePassword(int userId, String newHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in changePassword", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    /**
     * Thuật toán cập nhật chuỗi học tập (Streak):
     * - Nếu hôm nay đã làm đề (diffDays == 0): Giữ nguyên chuỗi.
     * - Nếu hôm qua có làm đề (diffDays == 1): Tăng chuỗi thêm 1 ngày liên tiếp.
     * - Nếu đứt chuỗi (diffDays >= 2 hoặc chưa từng làm): Bắt đầu lại từ 1.
     */
    public void updateStreak(int userId) {
        User user = findById(userId);
        if (user == null) return;

        LocalDate today = LocalDate.now();
        Date lastActive = user.getLastActiveDate();
        int currentStreak = user.getCurrentStreak();
        int newStreak;

        if (lastActive == null) {
            newStreak = 1;
        } else {
            LocalDate lastDate = lastActive.toLocalDate();
            long diffDays = ChronoUnit.DAYS.between(lastDate, today);
            if (diffDays == 0) {
                // Đã hoạt động trong hôm nay, giữ nguyên chuỗi
                return;
            } else if (diffDays == 1) {
                // Hoạt động ngày tiếp theo -> Tăng chuỗi liên tiếp
                newStreak = (currentStreak > 0 ? currentStreak : 0) + 1;
            } else {
                // Đứt chuỗi (bỏ lỡ >= 2 ngày) -> Bắt đầu chuỗi mới từ 1
                newStreak = 1;
            }
        }

        String sql = "UPDATE users SET current_streak = ?, last_active_date = CURDATE() WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, newStreak);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating streak for user " + userId, e);
        } finally {
            DBContext.close(conn, ps);
        }
    }

    /**
     * Tự động reset chuỗi về 0 trong CSDL khi học viên không làm đề liên tục
     */
    public void resetStreakInDB(int userId) {
        String sql = "UPDATE users SET current_streak = 0 WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error resetting streak in DB for user " + userId, e);
        } finally {
            DBContext.close(conn, ps);
        }
    }

    public List<User> getAllUsers(String role, String keyword) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1 ");
        if (role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role)) {
            sql.append(" AND role = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (username LIKE ? OR email LIKE ? OR full_name LIKE ?) ");
        }
        sql.append(" ORDER BY id DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role)) {
                ps.setString(paramIndex++, role.trim());
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String search = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, search);
                ps.setString(paramIndex++, search);
                ps.setString(paramIndex++, search);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllUsers", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public boolean updateRole(int userId, String newRole) {
        String sql = "UPDATE users SET role = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newRole);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating role", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting user", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public int countUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countUsers", e);
        } finally {
            DBContext.close(conn, st, rs);
        }
        return 0;
    }

    public List<User> getStreakLeaderboard(int limit) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, username, full_name, avatar_url, role, current_streak, last_active_date " +
                     "FROM users WHERE current_streak > 0 ORDER BY current_streak DESC, last_active_date DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit > 0 ? limit : 10);
            rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setAvatarUrl(rs.getString("avatar_url"));
                u.setRole(rs.getString("role"));
                u.setCurrentStreak(rs.getInt("current_streak"));
                u.setLastActiveDate(rs.getDate("last_active_date"));
                list.add(u);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getStreakLeaderboard", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setAvatarUrl(rs.getString("avatar_url"));
        u.setRole(rs.getString("role"));

        Date lastActive = rs.getDate("last_active_date");
        int streak = rs.getInt("current_streak");

        // TỰ ĐỘNG RESET STREAK: Nếu hôm qua không làm đề (diffDays >= 2), chuỗi streak tự động = 0!
        if (streak > 0) {
            if (lastActive == null) {
                streak = 0;
                resetStreakInDB(u.getId());
            } else {
                long days = ChronoUnit.DAYS.between(lastActive.toLocalDate(), LocalDate.now());
                if (days >= 2) {
                    streak = 0;
                    resetStreakInDB(u.getId());
                }
            }
        }

        u.setCurrentStreak(streak);
        u.setLastActiveDate(lastActive);
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    }
}
