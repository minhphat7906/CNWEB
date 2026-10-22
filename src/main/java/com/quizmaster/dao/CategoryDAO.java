package com.quizmaster.dao;

import com.quizmaster.config.DBContext;
import com.quizmaster.model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CategoryDAO {
    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.*, COUNT(q.id) AS quiz_count " +
                     "FROM categories c " +
                     "LEFT JOIN quizzes q ON c.id = q.category_id AND q.is_public = TRUE " +
                     "GROUP BY c.id ORDER BY c.id ASC";
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                c.setIcon(rs.getString("icon"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                c.setQuizCount(rs.getInt("quiz_count"));
                list.add(c);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAllCategories", e);
        } finally {
            DBContext.close(conn, st, rs);
        }
        return list;
    }

    public Category findById(int id) {
        String sql = "SELECT * FROM categories WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                c.setIcon(rs.getString("icon"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                return c;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findById", e);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public boolean addCategory(Category category) {
        String sql = "INSERT INTO categories (name, description, icon) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.setString(3, category.getIcon() != null ? category.getIcon() : "book");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding category", e);
        } finally {
            DBContext.close(conn, ps);
        }
        return false;
    }
}
