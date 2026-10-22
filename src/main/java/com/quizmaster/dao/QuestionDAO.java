package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.Question;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class QuestionDAO {
    private static final Logger LOGGER = Logger.getLogger(QuestionDAO.class.getName());

    public List<Question> getQuestionsByQuizId(int quizId, boolean hideAnswers) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE quiz_id = ? ORDER BY id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, quizId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Question q = new Question();
                q.setId(rs.getInt("id"));
                q.setQuizId(rs.getInt("quiz_id"));
                q.setQuestionText(rs.getString("question_text"));
                q.setOptionA(rs.getString("option_a"));
                q.setOptionB(rs.getString("option_b"));
                q.setOptionC(rs.getString("option_c"));
                q.setOptionD(rs.getString("option_d"));
                q.setPoints(rs.getInt("points"));
                q.setCreatedAt(rs.getTimestamp("created_at"));

                if (hideAnswers) {
                    // Chống gian lận: Ẩn đáp án đúng và lời giải khi học viên đang làm bài
                    q.setCorrectOption(null);
                    q.setExplanation(null);
                } else {
                    q.setCorrectOption(rs.getString("correct_option"));
                    q.setExplanation(rs.getString("explanation"));
                }
                list.add(q);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getQuestionsByQuizId", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public Question getQuestionById(int id) {
        String sql = "SELECT * FROM questions WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Question q = new Question();
                q.setId(rs.getInt("id"));
                q.setQuizId(rs.getInt("quiz_id"));
                q.setQuestionText(rs.getString("question_text"));
                q.setOptionA(rs.getString("option_a"));
                q.setOptionB(rs.getString("option_b"));
                q.setOptionC(rs.getString("option_c"));
                q.setOptionD(rs.getString("option_d"));
                q.setCorrectOption(rs.getString("correct_option"));
                q.setPoints(rs.getInt("points"));
                q.setExplanation(rs.getString("explanation"));
                q.setCreatedAt(rs.getTimestamp("created_at"));
                return q;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getQuestionById", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public static void insertQuestion(Connection conn, Question q) throws SQLException {
        String sql = "INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, points, explanation) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, q.getQuizId());
            ps.setString(2, q.getQuestionText());
            ps.setString(3, q.getOptionA());
            ps.setString(4, q.getOptionB());
            ps.setString(5, q.getOptionC());
            ps.setString(6, q.getOptionD());
            ps.setString(7, q.getCorrectOption());
            ps.setInt(8, q.getPoints() > 0 ? q.getPoints() : 1);
            ps.setString(9, q.getExplanation());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    q.setId(rs.getInt(1));
                }
            }
        }
    }
}
