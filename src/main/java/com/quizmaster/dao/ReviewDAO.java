package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.Review;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ReviewDAO {
    private static final Logger LOGGER = Logger.getLogger(ReviewDAO.class.getName());

    public List<Review> getReviewsByQuizId(int quizId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, u.full_name, u.avatar_url " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.id " +
                     "WHERE r.quiz_id = ? " +
                     "ORDER BY r.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, quizId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Review r = new Review();
                r.setId(rs.getInt("id"));
                r.setUserId(rs.getInt("user_id"));
                r.setQuizId(rs.getInt("quiz_id"));
                r.setRating(rs.getInt("rating"));
                r.setComment(rs.getString("comment"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setUserName(rs.getString("username"));
                r.setUserFullName(rs.getString("full_name"));
                r.setUserAvatar(rs.getString("avatar_url"));
                list.add(r);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getReviewsByQuizId", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public boolean addOrUpdateReview(Review review) {
        String sql = "INSERT INTO reviews (user_id, quiz_id, rating, comment) VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment), updated_at = NOW()";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, review.getUserId());
            ps.setInt(2, review.getQuizId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getComment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in addOrUpdateReview", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }
}
