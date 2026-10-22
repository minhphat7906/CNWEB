<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đăng nhập - QuizMaster" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="max-width: 480px; margin: 40px auto;">
    <div class="card" style="padding: 36px;">
        <div style="text-align: center; margin-bottom: 28px;">
            <div class="brand-icon" style="margin: 0 auto 16px auto; width: 48px; height: 48px; font-size: 1.4rem;">
                <i class="fas fa-lock"></i>
            </div>
            <h2 style="font-size: 1.6rem; font-weight: 800;">Đăng nhập hệ thống</h2>
            <p style="color: var(--text-secondary); font-size: 0.9rem;">Chào mừng bạn trở lại với QuizMaster</p>
        </div>

        <form action="${pageContext.request.contextPath}/auth" method="POST">
            <input type="hidden" name="action" value="login">
            <input type="hidden" name="redirect" value="${param.redirect}">

            <div class="form-group">
                <label class="form-label" for="identifier">Tên đăng nhập hoặc Email</label>
                <div style="position: relative;">
                    <input type="text" id="identifier" name="identifier" class="form-control" 
                           value="${identifier != null ? identifier : param.identifier}" 
                           placeholder="Nhập username hoặc email..." required autofocus>
                </div>
            </div>

            <div class="form-group">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                    <label class="form-label" for="password" style="margin-bottom: 0;">Mật khẩu</label>
                </div>
                <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 24px;">
                <i class="fas fa-sign-in-alt"></i> Đăng nhập
            </button>
        </form>

        <!-- Quick Demo Fill Section for Grading -->
        <div style="margin-top: 28px; padding-top: 20px; border-top: 1px solid var(--border-color);">
            <p style="font-size: 0.85rem; font-weight: 600; color: var(--text-secondary); margin-bottom: 10px; text-align: center;">
                ⚡ Điền nhanh tài khoản mẫu để chấm bài / kiểm thử:
            </p>
            <div style="display: flex; flex-direction: column; gap: 8px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="fillDemoAccount('teacher_ha', '123456')">
                    <i class="fas fa-chalkboard-teacher"></i> Giáo viên: <strong>teacher_ha</strong> (Thầy Mai Văn Hà)
                </button>
                <button type="button" class="btn btn-outline btn-sm" onclick="fillDemoAccount('admin', '123456')">
                    <i class="fas fa-user-shield"></i> Quản trị viên: <strong>admin</strong>
                </button>
                <button type="button" class="btn btn-outline btn-sm" onclick="fillDemoAccount('minhphat', '123456')">
                    <i class="fas fa-user-graduate"></i> Học viên: <strong>minhphat</strong> (Nguyễn Minh Phát)
                </button>
            </div>
        </div>

        <div style="text-align: center; margin-top: 24px; font-size: 0.9rem;">
            Chưa có tài khoản? <a href="${pageContext.request.contextPath}/auth?action=register" style="font-weight: 700;">Đăng ký ngay</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
