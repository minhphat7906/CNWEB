package com.quizmaster.util;

import java.util.regex.Pattern;

public class ValidationUtils {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{3,30}$");

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidUsername(String username) {
        if (username == null) return false;
        return USERNAME_PATTERN.matcher(username.trim()).matches();
    }

    public static boolean isNotEmpty(String text) {
        return text != null && !text.trim().isEmpty();
    }

    public static int parsePositiveInt(String str, int defaultValue) {
        if (str == null) return defaultValue;
        try {
            int val = Integer.parseInt(str.trim());
            return val > 0 ? val : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static String sanitize(String input) {
        if (input == null) return "";
        return input.trim()
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}
