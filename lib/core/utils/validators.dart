  class Validators {
    Validators._();

    static String? validateEmail(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Email is required';
      }
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Enter a valid email';
      }
      return null;
    }

    static String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    }

    static String? validateConfirmPassword(String? value, String password) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    }

    static String? validateName(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Name is required';
      }
      if (value.trim().length < 2) {
        return 'Name must be at least 2 characters';
      }
      return null;
    }

    static String? validatePhone(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Phone number is required';
      }
      final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Enter a valid phone number';
      }
      return null;
    }

    static String? validateCardNumber(String? value) {
      if (value == null || value.replaceAll(' ', '').isEmpty) {
        return 'Card number is required';
      }
      if (value.replaceAll(' ', '').length < 16) {
        return 'Enter a valid card number';
      }
      return null;
    }

    static String? validateExpiry(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Expiry date is required';
      }
      return null;
    }

    static String? validateCvv(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'CVV is required';
      }
      if (value.trim().length < 3) {
        return 'Enter a valid CVV';
      }
      return null;
    }

    static String? validateRequired(String? value, String fieldName) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    }
  }