class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation (minimum 6 characters)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Phone number validation (basic E.164 format)
  // Accepts: +919876543210 or 9876543210
  static bool isValidPhone(String phone) {
    // Remove spaces and dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');

    // Check for E.164 format (+country code + number)
    final e164Regex = RegExp(r'^\+?[1-9]\d{1,14}$');

    return e164Regex.hasMatch(cleanPhone) && cleanPhone.length >= 10;
  }

  // Check if passwords match
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}