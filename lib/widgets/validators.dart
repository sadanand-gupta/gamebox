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

  // ✅ STRICT E.164 phone validation
  // ✔ Must start with +
  // ✔ Must include country code
  // ✔ Total digits: 8–15
  // ❌ No spaces, dashes, brackets
  //
  // Valid:   +919876543210
  // Invalid: 9876543210, +91 9876543210
  static bool isValidE164Phone(String phone) {
    final regex = RegExp(r'^\+[1-9]\d{7,14}$');
    return regex.hasMatch(phone);
  }

  // (Optional) If you still want a loose validator elsewhere
  static bool isValidPhoneLoose(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    final regex = RegExp(r'^\+?[1-9]\d{9,14}$');
    return regex.hasMatch(cleanPhone);
  }

  // Check if passwords match
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
