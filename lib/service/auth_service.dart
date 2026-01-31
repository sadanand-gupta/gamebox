import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyPhone = 'user_phone';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLoginType = 'login_type'; // 'email' or 'whatsapp'

  // Mock OTP - fixed for demo
  static const String mockOtp = '123456';

  // Register with Email
  Future<bool> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyPassword, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Register with WhatsApp (Phone)
  Future<bool> registerWithWhatsApp({
    required String phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPhone, phone);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Login with Email
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString(_keyEmail);
      final storedPassword = prefs.getString(_keyPassword);

      if (storedEmail == email && storedPassword == password) {
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyLoginType, 'email');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Verify OTP (Mock - always returns 123456)
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPhone = prefs.getString(_keyPhone);

      // Check if phone is registered and OTP matches mock OTP
      if (storedPhone == phone && otp == mockOtp) {
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyLoginType, 'whatsapp');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyLoginType);
  }

  // Get stored email (for checking if registered)
  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Get stored phone (for checking if registered)
  Future<String?> getStoredPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }
}