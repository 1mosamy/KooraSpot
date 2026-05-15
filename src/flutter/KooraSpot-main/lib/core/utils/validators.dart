/// Reusable form field validators.
class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a city';
    }
    return null;
  }

  /// Validates an Egyptian mobile number (optional — empty is OK).
  static String? egyptianPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional field

    final phone = value.trim();
    final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid Egyptian number (010/011/012/015 + 8 digits)';
    }
    return null;
  }

  /// Required Egyptian phone number validator.
  static String? phoneRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phone = value.trim();
    final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid Egyptian number (010/011/012/015 + 8 digits)';
    }
    return null;
  }
}
