package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.AttemptAnswer;
import com.quizmaster.model.Question;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AttemptDAO {
    private static final Logger LOGGER = Logger.getLogger(AttemptDAO.class.getName());
    private final UserDAO userDAO = new UserDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    /**
     * Thuật toán chấm điểm an toàn tại Server (Zero-Trust Evaluation)
     */
    public int evaluateAttempt(int userId, int quizId, int timeSpent, Map<Integer, String> userAnswers) {
        return evaluateAttempt(userId, quizId, timeSpent, 0, userAnswers);
    }

    public int evaluateAttempt(int userId, int quizId, int timeSpent, int tabSwitches, Map<Integer, String> userAnswers) {
        // Lấy danh sách câu hỏi gốc từ DB kèm đáp án đúng
        List<Question> questions = questionDAO.getQuestionsByQuizId(quizId, false);
        if (questions == null || questions.isEmpty()) {
            return 0;
        }

        int totalQuestions = questions.size();
        int correctCount = 0;

        List<AttemptAnswer> evaluatedAnswers = new ArrayList<>();

        for (Question q : questions) {
            String selectedOption = userAnswers != null ? userAnswers.get(q.getId()) : null;
            if (selectedOption != null) {
                selectedOption = selectedOption.trim().toUpperCase();
            }

            boolean isCorrect = false;
            if (selectedOption != null && selectedOption.equalsIgnoreCase(q.getCorrectOption())) {
                isCorrect = true;
                correctCount++;
            }

            AttemptAnswer ans = new AttemptAnswer();
            ans.setQuestionId(q.getId());
            ans.setSelectedOption(selectedOption);
            ans.setCorrect(isCorrect);
            evaluatedAnswers.add(ans);
        }

        // Điểm số thang 10, làm tròn 1 chữ số thập phân
        double rawScore = ((double) correctCount / totalQuestions) * 10.0;
        double finalScore = Math.round(rawScore * 10.0) / 10.0;

        String insertAttemptSql = "INSERT INTO attempts (user_id, quiz_id, start_time, end_time, status, score, correct_answers, total_questions, time_spent, tab_switches) " +
                                  "VALUES (?, ?, SUBDATE(NOW(), INTERVAL ? SECOND), NOW(), 'COMPLETED', ?, ?, ?, ?, ?)";
        String insertAnswerSql = "INSERT INTO attempt_answers (attempt_id, question_id, selected_option, is_correct) VALUES (?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psAttempt = null;
        PreparedStatement psAns = null;
        ResultSet rs = null;
        int attemptId = 0;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            psAttempt = conn.prepareStatement(insertAttemptSql, Statement.RETURN_GENERATED_KEYS);
            psAttempt.setInt(1, userId);
            psAttempt.setInt(2, quizId);
            psAttempt.setInt(3, timeSpent > 0 ? timeSpent : 1);
            psAttempt.setDouble(4, finalScore);
            psAttempt.setInt(5, correctCount);
            psAttempt.setInt(6, totalQuestions);
            psAttempt.setInt(7, timeSpent);
            psAttempt.setInt(8, Math.max(0, tabSwitches));
            psAttempt.executeUpdate();

            rs = psAttempt.getGeneratedKeys();
            if (rs.next()) {
                attemptId = rs.getInt(1);
            } else {
                throw new SQLException("Failed to obtain attempt id");
            }

            psAns = conn.prepareStatement(insertAnswerSql);
            for (AttemptAnswer ans : evaluatedAnswers) {
                psAns.setInt(1, attemptId);
                psAns.setInt(2, ans.getQuestionId());
                if (ans.getSelectedOption() != null && !ans.getSelectedOption().isEmpty()) {
                    psAns.setString(3, ans.getSelectedOption());
                } else {
                    psAns.setNull(3, Types.VARCHAR);
                }
                psAns.setBoolean(4, ans.isCorrect());
                psAns.addBatch();
            }
            psAns.executeBatch();

            conn.commit();

            // Tự động cập nhật chuỗi chuyên cần (Streak) cho học viên
            userDAO.updateStreak(userId);

            return attemptId;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction rollback in evaluateAttempt", e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return 0;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
            if (psAns != null) {
                try { psAns.close(); } catch (SQLException ignored) {}
            }
            DBContext.close(conn, psAttempt, rs);
        }
    }

    public Attempt getAttemptById(int attemptId) {
        String sql = "SELECT a.*, q.title AS quiz_title, q.time_limit, c.name AS category_name, " +
                     "       u.username, u.full_name, u.avatar_url " +
                     "FROM attempts a " +
                     "JOIN quizzes q ON a.quiz_id = q.id " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON a.user_id = u.id " +
                     "WHERE a.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Attempt a = mapResultSetToAttempt(rs);
                a.setAnswers(getAttemptAnswers(attemptId));
                return a;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAttemptById", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public List<AttemptAnswer> getAttemptAnswers(int attemptId) {
        List<AttemptAnswer> list = new ArrayList<>();
        String sql = "SELECT ans.*, q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, " +
                     "       q.correct_option, q.points, q.explanation " +
                     "FROM attempt_answers ans " +
                     "JOIN questions q ON ans.question_id = q.id " +
                     "WHERE ans.attempt_id = ? " +
                     "ORDER BY q.id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            while (rs.next()) {
                AttemptAnswer ans = new AttemptAnswer();
                ans.setId(rs.getInt("id"));
                ans.setAttemptId(rs.getInt("attempt_id"));
                ans.setQuestionId(rs.getInt("question_id"));
                ans.setSelectedOption(rs.getString("selected_option"));
                ans.setCorrect(rs.getBoolean("is_correct"));
                ans.setQuestionText(rs.getString("question_text"));
                ans.setOptionA(rs.getString("option_a"));
                ans.setOptionB(rs.getString("option_b"));
                ans.setOptionC(rs.getString("option_c"));
                ans.setOptionD(rs.getString("option_d"));
                ans.setCorrectOption(rs.getString("correct_option"));
                ans.setPoints(rs.getInt("points"));
                ans.setExplanation(rs.getString("explanation"));
                list.add(ans);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAttemptAnswers", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public List<Attempt> getAttemptsByUser(int userId) {
        List<Attempt> list = new ArrayList<>();
        String sql = "SELECT a.*, q.title AS quiz_title, q.time_limit, c.name AS category_name, " +
                     "       u.username, u.full_name, u.avatar_url " +
                     "FROM attempts a " +
                     "JOIN quizzes q ON a.quiz_id = q.id " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON a.user_id = u.id " +
                     "WHERE a.user_id = ? " +
                     "ORDER BY a.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAttempt(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAttemptsByUser", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public List<Attempt> getAttemptsByUserAndQuiz(int userId, int quizId) {
        List<Attempt> list = new ArrayList<>();
        String sql = "SELECT a.*, q.title AS quiz_title, q.time_limit, c.name AS category_name, " +
                     "       u.username, u.full_name, u.avatar_url " +
                     "FROM attempts a " +
                     "JOIN quizzes q ON a.quiz_id = q.id " +
                     "JOIN categories c ON q.category_id = c.id " +
                     "JOIN users u ON a.user_id = u.id " +
                     "WHERE a.user_id = ? AND a.quiz_id = ? " +
                     "ORDER BY a.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, quizId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAttempt(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAttemptsByUserAndQuiz", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public int countUserAttempts(int userId, int quizId) {
        String sql = "SELECT COUNT(*) FROM attempts WHERE user_id = ? AND quiz_id = ? AND status = 'COMPLETED'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, quizId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countUserAttempts", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Thuật toán Anti-Farming Leaderboard:
     * Lấy điểm cao nhất của mỗi học viên trong bộ đề, nếu bằng điểm thì ưu tiên thời gian làm ít hơn.
     */
    public List<Attempt> getLeaderboard(Integer quizId, int limit) {
        List<Attempt> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.id, a.user_id, a.quiz_id, a.score, a.correct_answers, a.total_questions, a.time_spent, a.created_at, " +
            "       u.username, u.full_name, u.avatar_url, q.title AS quiz_title, c.name AS category_name, q.time_limit " +
            "FROM attempts a " +
            "JOIN users u ON a.user_id = u.id " +
            "JOIN quizzes q ON a.quiz_id = q.id " +
            "JOIN categories c ON q.category_id = c.id " +
            "WHERE a.status = 'COMPLETED' "
        );

        if (quizId != null && quizId > 0) {
            sql.append(" AND a.quiz_id = ? ");
        }

        // Sắp xếp theo Điểm cao nhất -> Thời gian làm ít nhất -> Ngày nộp bài sớm hơn
        sql.append(" ORDER BY a.score DESC, a.time_spent ASC, a.id ASC LIMIT ?");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (quizId != null && quizId > 0) {
                ps.setInt(idx++, quizId);
            }
            ps.setInt(idx++, limit > 0 ? limit : 20);

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAttempt(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getLeaderboard", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public int countCompletedAttempts() {
        String sql = "SELECT COUNT(*) FROM attempts WHERE status = 'COMPLETED'";
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in countCompletedAttempts", e);
        } finally {
            DBContext.close(conn, st, rs);
        }
        return 0;
    }

    private Attempt mapResultSetToAttempt(ResultSet rs) throws SQLException {
        Attempt a = new Attempt();
        a.setId(rs.getInt("id"));
        a.setUserId(rs.getInt("user_id"));
        a.setQuizId(rs.getInt("quiz_id"));
        try { a.setStartTime(rs.getTimestamp("start_time")); } catch (SQLException ignored) {}
        try { a.setEndTime(rs.getTimestamp("end_time")); } catch (SQLException ignored) {}
        try { a.setStatus(rs.getString("status")); } catch (SQLException ignored) {}
        a.setScore(rs.getDouble("score"));
        a.setCorrectAnswers(rs.getInt("correct_answers"));
        a.setTotalQuestions(rs.getInt("total_questions"));
        a.setTimeSpent(rs.getInt("time_spent"));
        try { a.setTabSwitches(rs.getInt("tab_switches")); } catch (SQLException ignored) {}
        try { a.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignored) {}

        try { a.setUserName(rs.getString("username")); } catch (SQLException ignored) {}
        try { a.setUserFullName(rs.getString("full_name")); } catch (SQLException ignored) {}
        try { a.setUserAvatar(rs.getString("avatar_url")); } catch (SQLException ignored) {}
        try { a.setQuizTitle(rs.getString("quiz_title")); } catch (SQLException ignored) {}
        try { a.setCategoryName(rs.getString("category_name")); } catch (SQLException ignored) {}
        try { a.setTimeLimit(rs.getInt("time_limit")); } catch (SQLException ignored) {}
        return a;
    }
}
