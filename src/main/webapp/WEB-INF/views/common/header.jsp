<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'QuizMaster - Hệ thống Thi Trắc Nghiệm Trực Tuyến'}</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- App Styles -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/arena.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body>

<div class="app-layout" id="appLayout">
    <!-- Instant preload script to prevent sidebar flickering / jumping -->
    <script>
        (function() {
            try {
                if (window.innerWidth > 992 && localStorage.getItem('quizmaster_sidebar_collapsed') === 'true') {
                    document.getElementById('appLayout').classList.add('sidebar-collapsed');
                }
            } catch (e) {}
        })();
    </script>
    <!-- Backdrop for mobile drawer -->
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>

    <!-- SIDEBAR NAVIGATION -->
    <aside class="app-sidebar" id="appSidebar">
        <!-- Sidebar Brand -->
        <div class="sidebar-header">
            <a href="${pageContext.request.contextPath}/home" class="sidebar-brand">
                <div class="brand-icon">
                    <i class="fas fa-brain"></i>
                </div>
                <div class="brand-text">
                    <span class="brand-title">QuizMaster</span>
                    <span class="brand-sub">Khảo Thí Trực Tuyến</span>
                </div>
            </a>
            <button type="button" class="sidebar-close-btn" id="sidebarCloseBtn" title="Đóng thanh điều hướng">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <!-- User Profile Card in Sidebar (if logged in) -->
        <c:if test="${not empty sessionScope.currentUser}">
            <div class="sidebar-user-card">
                <div class="sidebar-user-avatar">
                    ${sessionScope.currentUser.fullName.substring(0, 1).toUpperCase()}
                </div>
                <div class="sidebar-user-info">
                    <div class="sidebar-user-name">${sessionScope.currentUser.fullName}</div>
                    <div class="sidebar-user-role">
                        <c:choose>
                            <c:when test="${sessionScope.currentUser.admin}">
                                <span class="badge badge-danger" style="font-size: 0.7rem; padding: 2px 6px;">Admin</span>
                            </c:when>
                            <c:when test="${sessionScope.currentUser.teacher}">
                                <span class="badge badge-info" style="font-size: 0.7rem; padding: 2px 6px;">Giảng viên</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-primary" style="font-size: 0.7rem; padding: 2px 6px;">Sinh viên</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="sidebar-streak" title="Chuỗi học tập liên tục">
                    <i class="fas fa-fire fire-icon"></i>
                    <span>${sessionScope.currentUser.currentStreak}d</span>
                </div>
            </div>
        </c:if>

        <!-- Navigation Menu Groups -->
        <div class="sidebar-nav-wrapper">
            <!-- Group 1: Khảo thí & Luyện tập -->
            <div class="sidebar-nav-group">
                <div class="sidebar-group-title">KHẢO THÍ & LUYỆN TẬP</div>
                <ul class="sidebar-menu">
                    <li>
                        <a href="${pageContext.request.contextPath}/home" class="sidebar-item ${activePage eq 'home' ? 'active' : ''}">
                            <i class="fas fa-home"></i>
                            <span class="sidebar-item-text">Bàn làm việc</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/quiz" class="sidebar-item ${activePage eq 'quiz' ? 'active' : ''}">
                            <i class="fas fa-book-open"></i>
                            <span class="sidebar-item-text">Kho đề thi</span>
                        </a>
                    </li>
                    <c:if test="${not empty sessionScope.currentUser}">
                        <li>
                            <a href="${pageContext.request.contextPath}/history" class="sidebar-item ${activePage eq 'history' ? 'active' : ''}">
                                <i class="fas fa-history"></i>
                                <span class="sidebar-item-text">Lịch sử làm bài</span>
                            </a>
                        </li>
                    </c:if>
                </ul>
            </div>

            <!-- Group 2: Biên soạn đề thi (Học viên & Giảng viên đều có thể tạo đề ôn tập) -->
            <c:if test="${not empty sessionScope.currentUser}">
                <div class="sidebar-nav-group">
                    <div class="sidebar-group-title">
                        <c:choose>
                            <c:when test="${sessionScope.currentUser.teacher or sessionScope.currentUser.admin}">QUẢN LÝ KHẢO THÍ</c:when>
                            <c:otherwise>BIÊN SOẠN & ÔN TẬP</c:otherwise>
                        </c:choose>
                    </div>
                    <ul class="sidebar-menu">
                        <li>
                            <a href="${pageContext.request.contextPath}/quiz-lab" class="sidebar-item ${activePage eq 'quiz-lab' ? 'active' : ''}">
                                <i class="fas fa-plus-circle"></i>
                                <span class="sidebar-item-text">Tạo đề thi mới</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/quiz-manage" class="sidebar-item ${activePage eq 'quiz-manage' ? 'active' : ''}">
                                <i class="fas fa-folder-open"></i>
                                <span class="sidebar-item-text">Đề thi đã tạo</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </c:if>

            <!-- Group 3: Quản trị viên (nếu là Admin) -->
            <c:if test="${not empty sessionScope.currentUser and sessionScope.currentUser.admin}">
                <div class="sidebar-nav-group">
                    <div class="sidebar-group-title">HỆ THỐNG</div>
                    <ul class="sidebar-menu">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin" class="sidebar-item ${activePage eq 'admin' ? 'active' : ''}">
                                <i class="fas fa-shield-alt"></i>
                                <span class="sidebar-item-text">Quản trị Admin</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </c:if>
        </div>

        <!-- Sidebar Footer -->
        <div class="sidebar-footer">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <a href="${pageContext.request.contextPath}/auth?action=logout" class="sidebar-footer-link logout">
                        <i class="fas fa-sign-out-alt"></i>
                        <span class="sidebar-item-text">Đăng xuất</span>
                    </a>
                </c:when>
                <c:otherwise>
                    <div class="sidebar-auth-btns">
                        <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-sm btn-block">
                            <i class="fas fa-sign-in-alt"></i> <span>Đăng nhập</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/auth?action=register" class="btn btn-primary btn-sm btn-block">
                            <i class="fas fa-user-plus"></i> <span>Đăng ký</span>
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </aside>

    <!-- APP MAIN CONTENT WRAPPER -->
    <div class="app-main">
        <!-- APP TOPBAR -->
        <header class="app-topbar">
            <div class="topbar-left">
                <button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" title="Thu gọn / Mở rộng Sidebar">
                    <i class="fas fa-bars"></i>
                </button>
                <div class="topbar-breadcrumb">
                    <span class="topbar-page-title">${pageTitle != null ? pageTitle : 'QuizMaster'}</span>
                </div>
            </div>

            <div class="topbar-right">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <!-- Streak Badge -->
                        <div class="streak-badge" title="Chuỗi học tập chuyên cần liên tục">
                            <i class="fas fa-fire fire-icon"></i>
                            <span>${sessionScope.currentUser.currentStreak} ngày</span>
                        </div>

                        <!-- Shortcut nút Tạo đề -->
                        <a href="${pageContext.request.contextPath}/quiz-lab" class="btn btn-primary btn-sm topbar-action-btn" style="font-weight: 600;">
                            <i class="fas fa-plus"></i> <span>Tạo đề thi</span>
                        </a>

                        <!-- User Profile Dropdown -->
                        <div class="user-menu">
                            <div class="user-trigger">
                                <div class="user-avatar">
                                    ${sessionScope.currentUser.fullName.substring(0, 1).toUpperCase()}
                                </div>
                                <span class="user-name">${sessionScope.currentUser.fullName}</span>
                                <i class="fas fa-chevron-down" style="font-size: 0.8rem; color: var(--text-muted);"></i>
                            </div>

                            <div class="user-dropdown">
                                <div style="padding: 10px 14px 6px;">
                                    <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-primary);">${sessionScope.currentUser.fullName}</div>
                                    <div style="font-size: 0.78rem; color: var(--text-muted);">@${sessionScope.currentUser.username} &bull; ${sessionScope.currentUser.role}</div>
                                </div>
                                <div class="dropdown-divider"></div>
                                <a href="${pageContext.request.contextPath}/profile" class="dropdown-item">
                                    <i class="fas fa-user-circle"></i> Hồ sơ tài khoản
                                </a>
                                <c:if test="${sessionScope.currentUser.admin}">
                                    <a href="${pageContext.request.contextPath}/admin" class="dropdown-item">
                                        <i class="fas fa-shield-alt"></i> Bảng điều khiển Admin
                                    </a>
                                </c:if>
                                <div class="dropdown-divider"></div>
                                <a href="${pageContext.request.contextPath}/auth?action=logout" class="dropdown-item" style="color: var(--danger);">
                                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                                </a>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-sm">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/auth?action=register" class="btn btn-primary btn-sm">Đăng ký</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </header>

        <!-- CONTENT AREA -->
        <main class="app-content">
            <div class="container">
                <jsp:include page="/WEB-INF/views/common/alerts.jsp" />
