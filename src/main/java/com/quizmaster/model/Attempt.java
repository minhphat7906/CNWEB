package com.quizmaster.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Attempt implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private int quizId;
    private Timestamp startTime;
    private Timestamp endTime;
    private String status; // 'IN_PROGRESS', 'COMPLETED', 'ABANDONED'
    private double score;
    private int correctAnswers;
    private int totalQuestions;
    private int timeSpent; // in seconds
    private int tabSwitches = 0; // number of times user switched tab (anti-cheat)
    private Timestamp createdAt;

    // Helper display fields
    private String userName;
    private String userFullName;
    private String userAvatar;
    private String quizTitle;
    private String categoryName;
    private int timeLimit;

    private List<AttemptAnswer> answers = new ArrayList<>();

    public Attempt() {
        this.status = "IN_PROGRESS";
        this.score = 0.0;
        this.correctAnswers = 0;
        this.totalQuestions = 0;
        this.timeSpent = 0;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getQuizId() {
        return quizId;
    }

    public void setQuizId(int quizId) {
        this.quizId = quizId;
    }

    public Timestamp getStartTime() {
        return startTime;
    }

    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public int getCorrectAnswers() {
        return correctAnswers;
    }

    public void setCorrectAnswers(int correctAnswers) {
        this.correctAnswers = correctAnswers;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(int totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    public int getTimeSpent() {
        return timeSpent;
    }

    public void setTimeSpent(int timeSpent) {
        this.timeSpent = timeSpent;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserFullName() {
        return userFullName != null ? userFullName : userName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public String getUserAvatar() {
        return userAvatar != null ? userAvatar : "default-avatar.png";
    }

    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getTimeLimit() {
        return timeLimit;
    }

    public void setTimeLimit(int timeLimit) {
        this.timeLimit = timeLimit;
    }

    public List<AttemptAnswer> getAnswers() {
        return answers;
    }

    public void setAnswers(List<AttemptAnswer> answers) {
        this.answers = answers;
    }

    public String getFormattedTimeSpent() {
        int minutes = timeSpent / 60;
        int seconds = timeSpent % 60;
        return String.format("%02d:%02d", minutes, seconds);
    }

    public boolean isPassed() {
        return score >= 5.0;
    }

    public int getTabSwitches() {
        return tabSwitches;
    }

    public void setTabSwitches(int tabSwitches) {
        this.tabSwitches = tabSwitches;
    }
}
