<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đăng ký tài khoản - QuizMaster" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="max-width: 520px; margin: 40px auto;">
    <div class="card" style="padding: 36px;">
        <div style="text-align: center; margin-bottom: 24px;">
            <div class="brand-icon" style="margin: 0 auto 16px auto; width: 48px; height: 48px; font-size: 1.4rem;">
                <i class="fas fa-user-plus"></i>
            </div>
            <h2 style="font-size: 1.6rem; font-weight: 800;">Tạo tài khoản mới</h2>
            <p style="color: var(--text-secondary); font-size: 0.9rem;">Khởi đầu chuỗi ngày chuyên cần cùng QuizMaster</p>
        </div>

        <form action="${pageContext.request.contextPath}/auth" method="POST">
            <input type="hidden" name="action" value="register">

            <div class="form-group">
                <label class="form-label">Họ và tên <span style="color: red;">*</span></label>
                <input type="text" name="fullName" class="form-control" value="${fullName}" placeholder="Nguyễn Văn A" required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label">Tên đăng nhập <span style="color: red;">*</span></label>
                <input type="text" name="username" class="form-control" value="${username}" placeholder="user123 (từ 3-30 ký tự)" required>
            </div>

            <div class="form-group">
                <label class="form-label">Địa chỉ Email <span style="color: red;">*</span></label>
                <input type="email" name="email" class="form-control" value="${email}" placeholder="name@example.com" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label">Mật khẩu <span style="color: red;">*</span></label>
                    <input type="password" name="password" class="form-control" placeholder="Tối thiểu 6 ký tự" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Xác nhận mật khẩu <span style="color: red;">*</span></label>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Vai trò trên hệ thống</label>
                <div style="display: flex; gap: 20px;">
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                        <input type="radio" name="role" value="STUDENT" ${role == null or role eq 'STUDENT' ? 'checked' : ''}>
                        <span>Học viên (Làm bài & ôn tập)</span>
                    </label>
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                        <input type="radio" name="role" value="TEACHER" ${role eq 'TEACHER' ? 'checked' : ''}>
                        <span>Giáo viên (Soạn đề thi)</span>
                    </label>
                </div>
            </div>

            <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 16px;">
                <i class="fas fa-check"></i> Hoàn tất đăng ký
            </button>
        </form>

        <div style="text-align: center; margin-top: 24px; font-size: 0.9rem;">
            Đã có tài khoản? <a href="${pageContext.request.contextPath}/auth?action=login" style="font-weight: 700;">Đăng nhập</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
