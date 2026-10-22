package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.Question;
import com.quizmaster.model.Quiz;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class QuizDAO {
    private static final Logger LOGGER = Logger.getLogger(QuizDAO.class.getName());

    public List<Quiz> getAllPublicQuizzes(String keyword, Integer categoryId, String difficulty, String sortBy) {
        List<Quiz> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
            "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
            "       (SELECT IFNULL(AVG(rating), 0) FROM reviews WHERE quiz_id = q.id) AS avg_rating, " +
            "       (SELECT COUNT(*) FROM reviews WHERE quiz_id = q.id) AS review_count, " +
            "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
            "FROM quizzes q " +
            "JOIN categories c ON q.category_id = c.id " +
            "JOIN users u ON q.creator_id = u.id " +
            "WHERE q.is_public = TRUE "
        );

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (q.title LIKE ? OR q.description LIKE ?) ");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND q.category_id = ? ");
        }
        if (difficulty != null && !difficulty.trim().isEmpty() && !"ALL".equalsIgnoreCase(difficulty)) {
            sql.append(" AND q.difficulty = ? ");
        }

        if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY avg_rating DESC, q.id DESC");
        } else if ("popular".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY attempt_count DESC, q.id DESC");
        } else if ("oldest".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY q.id ASC");
        } else {
            sql.append(" ORDER BY q.id DESC");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String search = "%" + keyword.trim() + "%";
                ps.setString(idx++, search);
                ps.setString(idx++, search);
            }
            if (categoryId != null && categoryId > 0) {
                ps.setInt(idx++, categoryId);
            }
            if (difficulty != null && !difficulty.trim().isEmpty() && !"ALL".equalsIgnoreCase(difficulty)) {
                ps.setString(idx++, difficulty.trim());
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToQuiz(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllPublicQuizzes", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public List<Quiz> getFeaturedQuizzes(int limit) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
                     "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
                     "       (SELECT IFNULL(AVG(rating), 0) FROM reviews WHERE quiz_id = q.id) AS avg_rating, " +
                     "       (SELECT COUNT(*) FROM reviews WHERE quiz_id = q.id) AS review_count, " +
                     "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
                     "FROM quizzes q " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON q.creator_id = u.id " +
                     "WHERE q.is_public = TRUE " +
                     "ORDER BY attempt_count DESC, avg_rating DESC, q.id DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit > 0 ? limit : 6);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToQuiz(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getFeaturedQuizzes", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public List<Quiz> getQuizzesByCreator(int creatorId) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
                     "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
                     "       (SELECT IFNULL(AVG(rating), 0) FROM reviews WHERE quiz_id = q.id) AS avg_rating, " +
                     "       (SELECT COUNT(*) FROM reviews WHERE quiz_id = q.id) AS review_count, " +
                     "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
                     "FROM quizzes q " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON q.creator_id = u.id " +
                     "WHERE q.creator_id = ? " +
                     "ORDER BY q.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, creatorId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToQuiz(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getQuizzesByCreator", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public Quiz getQuizById(int id) {
        String sql = "SELECT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
                     "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
                     "       (SELECT IFNULL(AVG(rating), 0) FROM reviews WHERE quiz_id = q.id) AS avg_rating, " +
                     "       (SELECT COUNT(*) FROM reviews WHERE quiz_id = q.id) AS review_count, " +
                     "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
                     "FROM quizzes q " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON q.creator_id = u.id " +
                     "WHERE q.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToQuiz(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getQuizById", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Kỹ thuật JDBC Transaction: Lưu bộ đề cùng danh sách câu hỏi nguyên khối
     */
    public int createQuiz(Quiz quiz, List<Question> questions) {
        String sqlQuiz = "INSERT INTO quizzes (title, description, category_id, creator_id, time_limit, difficulty, is_public, cover_image, shuffle_questions, shuffle_options, show_answers, access_code, max_attempts, anti_cheat, show_ranking) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int quizId = 0;
        try {
            conn = DBContext.getConnection();
            // Bắt đầu Transaction
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(sqlQuiz, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, quiz.getTitle());
            ps.setString(2, quiz.getDescription());
            ps.setInt(3, quiz.getCategoryId());
            ps.setInt(4, quiz.getCreatorId());
            ps.setInt(5, Math.max(0, quiz.getTimeLimit())); // 0 = Không giới hạn thời gian
            ps.setString(6, quiz.getDifficulty() != null ? quiz.getDifficulty() : "MEDIUM");
            ps.setBoolean(7, quiz.isPublic());
            ps.setString(8, quiz.getCoverImage() != null ? quiz.getCoverImage() : "default-quiz-cover.jpg");
            ps.setBoolean(9, quiz.isShuffleQuestions());
            ps.setBoolean(10, quiz.isShuffleOptions());
            ps.setBoolean(11, quiz.isShowAnswers());
            ps.setString(12, quiz.getAccessCode());
            ps.setInt(13, Math.max(0, quiz.getMaxAttempts()));
            ps.setBoolean(14, quiz.isAntiCheat());
            ps.setBoolean(15, quiz.isShowRanking());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                quizId = rs.getInt(1);
                quiz.setId(quizId);
            } else {
                throw new SQLException("Failed to retrieve generated quiz id");
            }

            // Chèn danh sách câu hỏi
            if (questions != null && !questions.isEmpty()) {
                for (Question q : questions) {
                    q.setQuizId(quizId);
                    QuestionDAO.insertQuestion(conn, q);
                }
            }

            // Commit thành công
            conn.commit();
            return quizId;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction rollback in createQuiz", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return 0;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {}
            }
            DBContext.close(conn, ps, rs);
        }
    }

    /**
     * Cập nhật đề thi và danh sách câu hỏi sử dụng JDBC Transaction
     */
    public boolean updateQuiz(Quiz quiz, List<Question> questions) {
        String sqlQuiz = "UPDATE quizzes SET title = ?, description = ?, category_id = ?, time_limit = ?, difficulty = ?, is_public = ?, " +
                         "shuffle_questions = ?, shuffle_options = ?, show_answers = ?, access_code = ?, max_attempts = ?, anti_cheat = ?, show_ranking = ? " +
                         "WHERE id = ?";
        String sqlDeleteOldQuestions = "DELETE FROM questions WHERE quiz_id = ?";
        Connection conn = null;
        PreparedStatement psQuiz = null;
        PreparedStatement psDel = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật thông tin đề thi
            psQuiz = conn.prepareStatement(sqlQuiz);
            psQuiz.setString(1, quiz.getTitle());
            psQuiz.setString(2, quiz.getDescription());
            psQuiz.setInt(3, quiz.getCategoryId());
            psQuiz.setInt(4, Math.max(0, quiz.getTimeLimit()));
            psQuiz.setString(5, quiz.getDifficulty());
            psQuiz.setBoolean(6, quiz.isPublic());
            psQuiz.setBoolean(7, quiz.isShuffleQuestions());
            psQuiz.setBoolean(8, quiz.isShuffleOptions());
            psQuiz.setBoolean(9, quiz.isShowAnswers());
            psQuiz.setString(10, quiz.getAccessCode());
            psQuiz.setInt(11, Math.max(0, quiz.getMaxAttempts()));
            psQuiz.setBoolean(12, quiz.isAntiCheat());
            psQuiz.setBoolean(13, quiz.isShowRanking());
            psQuiz.setInt(14, quiz.getId());
            psQuiz.executeUpdate();

            // 2. Xóa các câu hỏi cũ
            psDel = conn.prepareStatement(sqlDeleteOldQuestions);
            psDel.setInt(1, quiz.getId());
            psDel.executeUpdate();

            // 3. Thêm lại các câu hỏi mới
            if (questions != null && !questions.isEmpty()) {
                for (Question q : questions) {
                    q.setQuizId(quiz.getId());
                    QuestionDAO.insertQuestion(conn, q);
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction rollback in updateQuiz", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {}
            }
            if (psDel != null) {
                try { psDel.close(); } catch (SQLException ignored) {}
            }
            DBContext.close(conn, psQuiz);
        }
    }

    public boolean deleteQuiz(int id) {
        String sql = "DELETE FROM quizzes WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting quiz", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public boolean toggleVisibility(int id) {
        String sql = "UPDATE quizzes SET is_public = NOT is_public WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggling quiz visibility", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }

    public List<Quiz> getAllQuizzesForAdmin() {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
                     "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
                     "       (SELECT IFNULL(AVG(rating), 0) FROM reviews WHERE quiz_id = q.id) AS avg_rating, " +
                     "       (SELECT COUNT(*) FROM reviews WHERE quiz_id = q.id) AS review_count, " +
                     "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
                     "FROM quizzes q " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON q.creator_id = u.id " +
                     "ORDER BY q.id DESC";
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            while (rs.next()) {
                list.add(mapResultSetToQuiz(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllQuizzesForAdmin", e);
        } finally {
            DBContext.close(conn, st, rs);
        }
        return list;
    }

    public List<Quiz> getQuizzesEligibleForLeaderboard(int userId, boolean isAdmin) {
        List<Quiz> list = new ArrayList<>();
        String sql;
        if (isAdmin) {
            sql = "SELECT DISTINCT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
                  "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
                  "       0 AS avg_rating, 0 AS review_count, " +
                  "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
                  "FROM quizzes q " +
                  "JOIN categories c ON q.category_id = c.id " +
                  "JOIN users u ON q.creator_id = u.id " +
                  "ORDER BY q.id DESC";
        } else {
            sql = "SELECT DISTINCT q.*, c.name AS category_name, c.icon AS category_icon, u.full_name AS creator_name, " +
                  "       (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count, " +
                  "       0 AS avg_rating, 0 AS review_count, " +
                  "       (SELECT COUNT(*) FROM attempts WHERE quiz_id = q.id AND status = 'COMPLETED') AS attempt_count " +
                  "FROM quizzes q " +
                  "JOIN categories c ON q.category_id = c.id " +
                  "JOIN users u ON q.creator_id = u.id " +
                  "LEFT JOIN attempts a ON q.id = a.quiz_id AND a.user_id = ? AND a.status = 'COMPLETED' " +
                  "WHERE (a.id IS NOT NULL AND q.show_ranking = TRUE) " +
                  "   OR (q.creator_id = ?) " +
                  "ORDER BY q.id DESC";
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            if (!isAdmin) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToQuiz(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getQuizzesEligibleForLeaderboard", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public int countQuizzes() {
        String sql = "SELECT COUNT(*) FROM quizzes";
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countQuizzes", e);
        } finally {
            DBContext.close(conn, st, rs);
        }
        return 0;
    }

    private Quiz mapResultSetToQuiz(ResultSet rs) throws SQLException {
        Quiz q = new Quiz();
        q.setId(rs.getInt("id"));
        q.setTitle(rs.getString("title"));
        q.setDescription(rs.getString("description"));
        q.setCategoryId(rs.getInt("category_id"));
        q.setCreatorId(rs.getInt("creator_id"));
        q.setTimeLimit(rs.getInt("time_limit"));
        q.setDifficulty(rs.getString("difficulty"));
        q.setPublic(rs.getBoolean("is_public"));
        q.setCoverImage(rs.getString("cover_image"));
        q.setCreatedAt(rs.getTimestamp("created_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));
        q.setCategoryName(rs.getString("category_name"));
        q.setCategoryIcon(rs.getString("category_icon"));
        q.setCreatorName(rs.getString("creator_name"));
        q.setQuestionCount(rs.getInt("question_count"));
        q.setAverageRating(Math.round(rs.getDouble("avg_rating") * 10.0) / 10.0);
        q.setReviewCount(rs.getInt("review_count"));
        q.setAttemptCount(rs.getInt("attempt_count"));

        try { q.setShuffleQuestions(rs.getBoolean("shuffle_questions")); } catch (SQLException ignored) {}
        try { q.setShuffleOptions(rs.getBoolean("shuffle_options")); } catch (SQLException ignored) {}
        try { q.setShowAnswers(rs.getBoolean("show_answers")); } catch (SQLException ignored) {}
        try { q.setAccessCode(rs.getString("access_code")); } catch (SQLException ignored) {}
        try { q.setMaxAttempts(rs.getInt("max_attempts")); } catch (SQLException ignored) {}
        try { q.setAntiCheat(rs.getBoolean("anti_cheat")); } catch (SQLException ignored) {}
        try { q.setShowRanking(rs.getBoolean("show_ranking")); } catch (SQLException ignored) {}

        return q;
    }
}
