package com.quizmaster.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Quiz implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String title;
    private String description;
    private int categoryId;
    private int creatorId;
    private int timeLimit; // in minutes
    private String difficulty; // 'EASY', 'MEDIUM', 'HARD'
    private boolean isPublic;
    private String coverImage;
    private boolean shuffleQuestions = false;
    private boolean shuffleOptions = false;
    private boolean showAnswers = true;
    private String accessCode;
    private int maxAttempts = 0; // 0 = unlimited
    private boolean antiCheat = false;
    private boolean showRanking = false;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper display fields
    private String categoryName;
    private String categoryIcon;
    private String creatorName;
    private int questionCount;
    private double averageRating;
    private int reviewCount;
    private int attemptCount;

    // Associated questions (optional, used when creating/editing/viewing)
    private List<Question> questions = new ArrayList<>();

    public Quiz() {
        this.timeLimit = 15;
        this.difficulty = "MEDIUM";
        this.isPublic = true;
        this.coverImage = "default-quiz-cover.jpg";
    }

    public Quiz(int id, String title, String description, int categoryId, int creatorId, int timeLimit, String difficulty, boolean isPublic) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.categoryId = categoryId;
        this.creatorId = creatorId;
        this.timeLimit = timeLimit;
        this.difficulty = difficulty;
        this.isPublic = isPublic;
        this.coverImage = "default-quiz-cover.jpg";
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(int creatorId) {
        this.creatorId = creatorId;
    }

    public int getTimeLimit() {
        return timeLimit;
    }

    public void setTimeLimit(int timeLimit) {
        this.timeLimit = timeLimit;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public boolean isPublic() {
        return isPublic;
    }

    public boolean getIsPublic() {
        return isPublic;
    }

    public void setPublic(boolean aPublic) {
        isPublic = aPublic;
    }

    public String getCoverImage() {
        return coverImage != null ? coverImage : "default-quiz-cover.jpg";
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getCategoryIcon() {
        return categoryIcon != null ? categoryIcon : "book";
    }

    public void setCategoryIcon(String categoryIcon) {
        this.categoryIcon = categoryIcon;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public int getAttemptCount() {
        return attemptCount;
    }

    public void setAttemptCount(int attemptCount) {
        this.attemptCount = attemptCount;
    }

    public List<Question> getQuestions() {
        return questions;
    }

    public void setQuestions(List<Question> questions) {
        this.questions = questions;
    }

    public String getDifficultyLabel() {
        if ("EASY".equalsIgnoreCase(difficulty)) return "Dễ";
        if ("HARD".equalsIgnoreCase(difficulty)) return "Khó";
        return "Trung bình";
    }

    public String getDifficultyBadgeClass() {
        if ("EASY".equalsIgnoreCase(difficulty)) return "badge-success";
        if ("HARD".equalsIgnoreCase(difficulty)) return "badge-danger";
        return "badge-warning";
    }

    public boolean isShuffleQuestions() {
        return shuffleQuestions;
    }

    public boolean getShuffleQuestions() {
        return shuffleQuestions;
    }

    public void setShuffleQuestions(boolean shuffleQuestions) {
        this.shuffleQuestions = shuffleQuestions;
    }

    public boolean isShuffleOptions() {
        return shuffleOptions;
    }

    public boolean getShuffleOptions() {
        return shuffleOptions;
    }

    public void setShuffleOptions(boolean shuffleOptions) {
        this.shuffleOptions = shuffleOptions;
    }

    public boolean isShowAnswers() {
        return showAnswers;
    }

    public boolean getShowAnswers() {
        return showAnswers;
    }

    public void setShowAnswers(boolean showAnswers) {
        this.showAnswers = showAnswers;
    }

    public String getAccessCode() {
        return accessCode;
    }

    public void setAccessCode(String accessCode) {
        this.accessCode = accessCode;
    }

    public boolean hasAccessCode() {
        return accessCode != null && !accessCode.trim().isEmpty();
    }

    public int getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(int maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public boolean isAntiCheat() {
        return antiCheat;
    }

    public boolean getAntiCheat() {
        return antiCheat;
    }

    public void setAntiCheat(boolean antiCheat) {
        this.antiCheat = antiCheat;
    }

    public boolean isShowRanking() {
        return showRanking;
    }

    public boolean getShowRanking() {
        return showRanking;
    }

    public void setShowRanking(boolean showRanking) {
        this.showRanking = showRanking;
    }

    public boolean isUnlimitedTime() {
        return timeLimit <= 0;
    }
}
