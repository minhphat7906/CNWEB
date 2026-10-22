package com.quizmaster.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class SupportTicket implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Integer userId;
    private String name;
    private String email;
    private String subject;
    private String message;
    private String status; // 'PENDING', 'IN_PROGRESS', 'RESOLVED'
    private Timestamp createdAt;

    public SupportTicket() {
        this.status = "PENDING";
    }

    public SupportTicket(Integer userId, String name, String email, String subject, String message) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.status = "PENDING";
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatusBadgeClass() {
        if ("RESOLVED".equalsIgnoreCase(status)) return "badge-success";
        if ("IN_PROGRESS".equalsIgnoreCase(status)) return "badge-warning";
        return "badge-danger";
    }

    public String getStatusLabel() {
        if ("RESOLVED".equalsIgnoreCase(status)) return "Đã xử lý";
        if ("IN_PROGRESS".equalsIgnoreCase(status)) return "Đang xử lý";
        return "Chờ xử lý";
    }
}
