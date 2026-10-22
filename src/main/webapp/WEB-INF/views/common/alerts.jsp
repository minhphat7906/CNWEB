<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger" role="alert">
        <span><i class="fas fa-exclamation-circle"></i> ${errorMessage}</span>
        <button type="button" style="background: none; border: none; cursor: pointer; color: inherit; font-size: 1.1rem;" onclick="this.parentElement.remove();">&times;</button>
    </div>
</c:if>

<c:if test="${not empty successMessage or not empty param.success or not empty sessionScope.flashSuccess}">
    <div class="alert alert-success" role="alert">
        <span><i class="fas fa-check-circle"></i> 
            <c:choose>
                <c:when test="${not empty successMessage}">${successMessage}</c:when>
                <c:when test="${not empty sessionScope.flashSuccess}">
                    ${sessionScope.flashSuccess}
                    <c:remove var="flashSuccess" scope="session"/>
                </c:when>
                <c:when test="${param.success eq 'created'}">Tạo mới thành công!</c:when>
                <c:when test="${param.success eq 'updated'}">Cập nhật thành công!</c:when>
                <c:when test="${param.success eq 'deleted'}">Xóa thành công!</c:when>
                <c:when test="${param.success eq 'profile_updated'}">Đã cập nhật thông tin cá nhân!</c:when>
                <c:when test="${param.success eq 'password_changed'}">Đổi mật khẩu thành công!</c:when>
                <c:otherwise>Thao tác thành công!</c:otherwise>
            </c:choose>
        </span>
        <button type="button" style="background: none; border: none; cursor: pointer; color: inherit; font-size: 1.1rem;" onclick="this.parentElement.remove();">&times;</button>
    </div>
</c:if>

<c:if test="${not empty param.error}">
    <div class="alert alert-danger" role="alert">
        <span><i class="fas fa-exclamation-triangle"></i> 
            <c:choose>
                <c:when test="${param.error eq 'forbidden'}">Bạn không có quyền thực hiện hành động này.</c:when>
                <c:when test="${param.error eq 'notfound'}">Không tìm thấy tài nguyên yêu cầu.</c:when>
                <c:when test="${param.error eq 'empty'}">Bộ đề này hiện chưa có câu hỏi nào để bắt đầu.</c:when>
                <c:when test="${param.error eq 'wrong_passcode'}">Mật khẩu phòng thi không chính xác! Vui lòng thử lại.</c:when>
                <c:when test="${param.error eq 'require_passcode'}">Đề thi này yêu cầu mật khẩu bảo vệ trước khi làm bài.</c:when>
                <c:when test="${param.error eq 'max_attempts_reached'}">Bạn đã đạt số lượt làm bài tối đa cho phép đối với bộ đề thi này.</c:when>
                <c:when test="${param.error eq 'wrong_current_password'}">Mật khẩu hiện tại không chính xác.</c:when>
                <c:when test="${param.error eq 'invalid_new_password'}">Mật khẩu mới không hợp lệ hoặc xác nhận mật khẩu không khớp.</c:when>
                <c:otherwise>Đã xảy ra lỗi trong quá trình xử lý.</c:otherwise>
            </c:choose>
        </span>
        <button type="button" style="background: none; border: none; cursor: pointer; color: inherit; font-size: 1.1rem;" onclick="this.parentElement.remove();">&times;</button>
    </div>
</c:if>
