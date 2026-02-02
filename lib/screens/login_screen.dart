import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:gamebox/service/auth_service.dart';
import 'package:gamebox/widgets/validators.dart';
import 'registration_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _obscurePassword = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- Authentication logic remains the same ---
  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    if (!Validators.isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }
    setState(() => _isLoading = true);
    final success = await _authService.loginWithEmail(
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _navigateToDashboard();
    } else {
      _showError('Invalid email or password');
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (!Validators.isValidE164Phone(phone)) {
      _showError('Phone number must include country code (e.g. +919876543210)');
      return;
    }
    final storedPhone = await _authService.getStoredPhone();
    if (storedPhone == null || storedPhone != phone) {
      _showError('Phone number not registered. Please register first.');
      return;
    }
    setState(() => _otpSent = true);
    _showSuccess('Mock OTP sent: ${AuthService.mockOtp}');
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showError('Please enter OTP');
      return;
    }
    setState(() => _isLoading = true);
    final success = await _authService.verifyOtp(phone: phone, otp: otp);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _navigateToDashboard();
    } else {
      _showError('Invalid OTP. Use: ${AuthService.mockOtp}');
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: const Color(0xFF6366F1),
            spawnMinSpeed: 20.0,
            spawnMaxSpeed: 50.0,
            particleCount: 50,
            spawnMaxRadius: 1.5,
            spawnMinRadius: 1.0,
          ),
        ),
        vsync: this,
        child: _isLoading
            ? Center(child: _buildLoadingIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 450,
                    ), // Consistent max width
                    child: _buildUnifiedLayout(),
                  ),
                ),
              ),
      ),
    );
  }

  // ✨ UNIFIED LAYOUT for all screen sizes
  Widget _buildUnifiedLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Welcome Back, Champion!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your next adventure awaits. Sign in to continue.',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: _buildLoginFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    // A simpler loading indicator for the dark theme
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 20),
        Text(
          'Please wait...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // ✨ SIMPLIFIED: No longer needs 'isDesktop' flag
  Widget _buildLoginFormContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLoginTypeSelector(),
        const SizedBox(height: 24),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          child: _tabController.index == 0
              ? _buildEmailTab()
              : _buildWhatsAppTab(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationScreen(),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSelectorOption("Email", 0),
        const SizedBox(width: 10),
        _buildSelectorOption("WhatsApp", 1),
      ],
    );
  }

  Widget _buildSelectorOption(String text, int index) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'your@email.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Sign In',
          onPressed: _loginWithEmail,
          icon: Icons.arrow_forward_rounded,
        ),
      ],
    );
  }

  Widget _buildWhatsAppTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+919876543210',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(
          label: _otpSent ? 'OTP Sent ✓' : 'Send OTP',
          onPressed: _otpSent ? null : _sendOtp,
          icon: Icons.send_rounded,
          color: const Color(0xFF10B981),
        ),
        if (_otpSent) ...[
          const SizedBox(height: 24),
          _buildTextField(
            controller: _otpController,
            label: 'Enter OTP',
            hint: 'Enter OTP',
            icon: Icons.verified_user_rounded,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Verify & Sign In',
            onPressed: _verifyOtp,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFBBF24), width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Demo OTP: ${AuthService.mockOtp}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ✨ SIMPLIFIED: Colors are now hardcoded for the glass theme
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required IconData icon,
    Color color = const Color(0xFF6366F1),
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? LinearGradient(colors: [color, color.withOpacity(0.8)])
            : null,
        color: onPressed == null ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: onPressed != null
                        ? Colors.white
                        : Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: onPressed != null
                      ? Colors.white
                      : Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
