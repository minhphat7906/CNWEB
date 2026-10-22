/**
 * QuizMaster - Main Client Scripts
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Tự động đóng các thông báo Flash Alert sau 4 giây
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity 0.5s ease';
            alert.style.opacity = '0';
            setTimeout(function () {
                if (alert.parentNode) {
                    alert.parentNode.removeChild(alert);
                }
            }, 500);
        }, 4000);
    });

    // 2. Xử lý Sidebar Navigation (Thu gọn trên Desktop, Mở trượt trên Mobile)
    const appLayout = document.getElementById('appLayout');
    const sidebarToggleBtn = document.getElementById('sidebarToggleBtn');
    const sidebarCloseBtn = document.getElementById('sidebarCloseBtn');
    const sidebarBackdrop = document.getElementById('sidebarBackdrop');

    if (sidebarToggleBtn && appLayout) {
        sidebarToggleBtn.addEventListener('click', function () {
            if (window.innerWidth <= 992) {
                appLayout.classList.toggle('sidebar-mobile-open');
            } else {
                appLayout.classList.toggle('sidebar-collapsed');
                localStorage.setItem('quizmaster_sidebar_collapsed', 
                    appLayout.classList.contains('sidebar-collapsed') ? 'true' : 'false');
            }
        });
    }

    if (sidebarCloseBtn && appLayout) {
        sidebarCloseBtn.addEventListener('click', function () {
            appLayout.classList.remove('sidebar-mobile-open');
        });
    }

    if (sidebarBackdrop && appLayout) {
        sidebarBackdrop.addEventListener('click', function () {
            appLayout.classList.remove('sidebar-mobile-open');
        });
    }

    // Khôi phục trạng thái thu gọn Sidebar đã lưu trên Desktop
    if (window.innerWidth > 992 && appLayout) {
        if (localStorage.getItem('quizmaster_sidebar_collapsed') === 'true') {
            appLayout.classList.add('sidebar-collapsed');
        }
    }

    // 3. Xử lý Click mở Menu Profile người dùng (Không dùng hover để tránh trôi chuột)
    const userTrigger = document.querySelector('.user-trigger');
    const userDropdown = document.querySelector('.user-dropdown');

    if (userTrigger && userDropdown) {
        userTrigger.addEventListener('click', function (e) {
            e.stopPropagation();
            userDropdown.classList.toggle('show');
        });

        // Bấm ra ngoài màn hình thì tự động đóng menu lại
        document.addEventListener('click', function (e) {
            if (!userDropdown.contains(e.target) && !userTrigger.contains(e.target)) {
                userDropdown.classList.remove('show');
            }
        });
    }
});

/**
 * Nạp thông tin tài khoản mẫu nhanh vào trang đăng nhập
 */
function fillDemoAccount(username, password) {
    const userInput = document.getElementById('identifier');
    const passInput = document.getElementById('password');
    if (userInput && passInput) {
        userInput.value = username;
        passInput.value = password;
        userInput.focus();
    }
}
