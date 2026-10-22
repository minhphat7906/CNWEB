package com.quizmaster.config;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    private static String driver = "com.mysql.cj.jdbc.Driver";
    private static String url = "jdbc:mysql://localhost:3306/quiz_system?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh&characterEncoding=UTF-8";
    private static String user = "root";
    private static String password = "";

    static {
        try {
            Properties prop = new Properties();
            InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties");
            if (input != null) {
                prop.load(input);
                if (prop.getProperty("db.driver") != null) driver = prop.getProperty("db.driver");
                if (prop.getProperty("db.url") != null) url = prop.getProperty("db.url");
                if (prop.getProperty("db.username") != null) user = prop.getProperty("db.username");
                if (prop.getProperty("db.password") != null) password = prop.getProperty("db.password");
            }
            Class.forName(driver);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load DB driver or configuration", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(url, user, password);
        } catch (SQLException e) {
            // Also try with empty password or root password in case student configured mysql with password root
            try {
                if ("".equals(password)) {
                    return DriverManager.getConnection(url, user, "root");
                }
            } catch (SQLException ignored) {}
            throw e;
        }
    }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Statement", e);
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Connection", e);
            }
        }
    }

    public static void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }
}
