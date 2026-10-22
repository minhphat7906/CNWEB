<%@ page contentType="text/html;charset=UTF-8" language="java" %>
            </div><!-- /.container -->
        </main><!-- /.app-content -->

        <footer class="app-footer">
            <div class="container">
                <div class="app-footer-grid">
                    <div class="app-footer-brand">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px;">
                            <div class="brand-icon" style="width: 32px; height: 32px; font-size: 0.95rem;">
                                <i class="fas fa-brain"></i>
                            </div>
                            <h4 style="margin: 0;">QuizMaster</h4>
                        </div>
                        <p>
                            Hệ thống thi trắc nghiệm trực tuyến chất lượng cao, phục vụ giảng dạy và khảo thí. 
                            Xây dựng trên nền tảng Java Servlet/JSP theo chuẩn mô hình MVC.
                        </p>
                        <p style="font-size: 0.82rem; color: #64748b; margin-top: 10px;">
                            <i class="fas fa-graduation-cap"></i> Môn học: <strong>Công nghệ Web</strong> - Giảng viên: <strong>Thầy Mai Văn Hà</strong>
                        </p>
                    </div>

                    <div class="app-footer-col">
                        <h5>Liên kết nhanh</h5>
                        <ul class="app-footer-links">
                            <li><a href="${pageContext.request.contextPath}/home"><i class="fas fa-angle-right"></i> Trang chủ</a></li>
                            <li><a href="${pageContext.request.contextPath}/quiz"><i class="fas fa-angle-right"></i> Khám phá kho đề</a></li>
                            <li><a href="${pageContext.request.contextPath}/quiz-lab"><i class="fas fa-angle-right"></i> Phòng Lab Soạn Đề</a></li>
                            <li><a href="${pageContext.request.contextPath}/leaderboard"><i class="fas fa-angle-right"></i> Bảng vàng thành tích</a></li>
                        </ul>
                    </div>

                    <div class="app-footer-col">
                        <h5>Hỗ trợ kỹ thuật</h5>
                        <ul class="app-footer-links">
                            <li><i class="fas fa-envelope"></i> support@quizmaster.edu.vn</li>
                            <li><i class="fas fa-map-marker-alt"></i> ĐH Bách Khoa - ĐHĐN</li>
                            <li><i class="fas fa-code-branch"></i> Phiên bản: 1.0 (Servlet/JSP MVC)</li>
                        </ul>
                    </div>
                </div>

                <div class="app-footer-bottom">
                    <p>&copy; 2026 QuizMaster System. Bài tập nhóm Công nghệ Web - Nhóm sinh viên: Nguyễn Minh Phát, Lê Hoàng Nam, Trần Thụy Trang.</p>
                </div>
            </div>
        </footer>
    </div><!-- /.app-main -->
</div><!-- /#appLayout -->

    <!-- Scripts -->
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/arena.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/quiz-builder.js"></script>
</body>
</html>
