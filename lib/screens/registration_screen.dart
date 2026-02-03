// lib/screens/registration_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamebox/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _activeTab = 'email';
  bool _otpSent = false;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _validatePhoneNumber(String phone) {
    final e164Regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return e164Regex.hasMatch(phone);
  }

  Future<void> _registerWithEmail() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackbar('Please fill in all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _sendWhatsAppOTP() async {
    if (_usernameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showSnackbar('Please enter username and phone', isError: true);
      return;
    }

    if (!_validatePhoneNumber(_phoneController.text)) {
      _showSnackbar('Use E.164 format: +919876543210', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _otpSent = true;
    });

    _showSnackbar('OTP sent to WhatsApp');
  }

  Future<void> _verifyAndRegister() async {
    if (_otpController.text.isEmpty) {
      _showSnackbar('Please enter OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: isError
            ? const Color(0xFFFF4757)
            : const Color(0xFF2ED573),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A1628),
              const Color(0xFF1A2742),
              const Color(0xFF0F1F3A),
            ],
          ),
        ),
        child: Stack(
          children: [
            ...List.generate(isWideScreen ? 20 : 12, (index) {
              return AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  final offset = _shimmerController.value * 100;
                  return Positioned(
                    left: (index * 100.0) % size.width,
                    top: (index * 50.0) % size.height + offset,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),
            SafeArea(
              child: isWideScreen
                  ? _buildWideScreenLayout()
                  : isTablet
                  ? _buildTabletLayout()
                  : _buildMobileLayout(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (!isWideScreen) ? _buildCasinoBottomBar() : null,
    );
  }

  Widget _buildWideScreenLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          children: [
            Expanded(flex: 4, child: _buildRegistrationForm()),
            const SizedBox(width: 80),
            Expanded(flex: 5, child: _buildAnimatedHeroImage(750)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildRegistrationForm()),
            const SizedBox(width: 30),
            Expanded(flex: 5, child: _buildAnimatedHeroImage(380)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildAnimatedHeroImage(170),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildRegistrationForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeroImage(double height) {
    return Container(
      alignment: Alignment.center,
      child:
          Image.asset(
                'assets/images/ufafuture_9.png',
                fit: BoxFit.contain,
                height: height,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -10,
                end: 10,
                duration: 2500.ms,
                curve: Curves.easeInOutSine,
              )
              .then(delay: 500.ms)
              .shimmer(
                duration: 1500.ms,
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
    );
  }

  Widget _buildRegistrationForm() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.15),
            blurRadius: 50,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            child: DefaultTextStyle(
              style: GoogleFonts.rajdhani(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700),
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: const Color(0xFFFFD700).withOpacity(0.7),
                  ),
                ],
              ),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    'JOIN UFA FUTURE',
                    speed: const Duration(milliseconds: 100),
                  ),
                  TypewriterAnimatedText(
                    'CREATE YOUR LEGACY',
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white24, width: 2),
                right: BorderSide(color: Colors.white24, width: 2),
              ),
            ),
            child: Text(
              'ELITE GAMING // INSTANT ACCESS',
              style: GoogleFonts.orbitron(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildTabSwitcher().animate().fadeIn(delay: 500.ms),
          SizedBox(height: isMobile ? 16 : 20),
          if (_activeTab == 'email') ...[
            _buildEmailForm(),
          ] else ...[
            _buildWhatsAppForm(),
          ],
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'ALREADY A MEMBER?',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 8 : 10,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildSecondaryButton(
            label: 'SIGN IN',
            onPressed: () => Navigator.pop(context),
          ).animate().fadeIn(delay: 900.ms),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return Container(
      height: isMobile ? 42 : 46,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('EMAIL', 'email')),
          Expanded(child: _buildTab('WHATSAPP', 'whatsapp')),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;
    final isActive = _activeTab == value;

    return GestureDetector(
      onTap: () => setState(() {
        _activeTab = value;
        _otpSent = false;
      }),
      child: Container(
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF5B4DFF), Color(0xFF7B68FF)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return Column(
      children: [
        _buildInputField(
          controller: _usernameController,
          hint: 'CHOOSE USERNAME',
          icon: Icons.person_outline,
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: isMobile ? 12 : 14),
        _buildInputField(
          controller: _emailController,
          hint: 'EMAIL ADDRESS',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ).animate().fadeIn(delay: 700.ms),
        SizedBox(height: isMobile ? 12 : 14),
        _buildInputField(
          controller: _passwordController,
          hint: 'CREATE PASSWORD',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.4),
              size: isMobile ? 18 : 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ).animate().fadeIn(delay: 800.ms),
        SizedBox(height: isMobile ? 18 : 24),
        _buildPrimaryButton(
          label: 'CREATE ACCOUNT',
          onPressed: _isLoading ? null : _registerWithEmail,
        ).animate().fadeIn(delay: 900.ms),
      ],
    );
  }

  Widget _buildWhatsAppForm() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return Column(
      children: [
        _buildInputField(
          controller: _usernameController,
          hint: 'CHOOSE USERNAME',
          icon: Icons.person_outline,
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: isMobile ? 12 : 14),
        if (!_otpSent) ...[
          _buildInputField(
            controller: _phoneController,
            hint: 'WHATSAPP NUMBER (+91...)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ).animate().fadeIn(delay: 700.ms),
          SizedBox(height: isMobile ? 8 : 10),
          Text(
            'Use E.164 Format: +[CountryCode][Number]',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 9 : 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 18),
          _buildPrimaryButton(
            label: 'SEND OTP',
            onPressed: _isLoading ? null : _sendWhatsAppOTP,
          ).animate().fadeIn(delay: 800.ms),
        ] else ...[
          _buildInputField(
            controller: _otpController,
            hint: 'ENTER OTP',
            icon: Icons.lock_clock_outlined,
            keyboardType: TextInputType.number,
          ).animate().fadeIn(delay: 700.ms),
          SizedBox(height: isMobile ? 10 : 12),
          TextButton(
            onPressed: () => setState(() => _otpSent = false),
            child: Text(
              'CHANGE PHONE NUMBER',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 10 : 11,
                color: const Color(0xFF5B4DFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 14 : 16),
          _buildPrimaryButton(
            label: 'VERIFY & CREATE ACCOUNT',
            onPressed: _isLoading ? null : _verifyAndRegister,
          ).animate().fadeIn(delay: 800.ms),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: isMobile ? 13 : 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.3),
          fontSize: isMobile ? 12 : 13,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.4),
          size: isMobile ? 20 : 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: isMobile ? 48 : 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: onPressed != null
                ? const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFC700)],
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade700, Colors.grey.shade600],
                  ),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFFFFD700,
                      ).withOpacity(0.3 + _pulseController.value * 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFF0A1628),
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0A1628),
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return SizedBox(
      width: double.infinity,
      height: isMobile ? 48 : 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFD700),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCasinoBottomBar() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2742).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.casino, 'CASINO', true),
          _buildBottomNavItem(Icons.sports_esports, 'GAMES', false),
          _buildBottomNavItem(Icons.emoji_events, 'TOURNAMENTS', false),
          _buildBottomNavItem(Icons.card_giftcard, 'REWARDS', false),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive
              ? const Color(0xFFFFD700)
              : Colors.white.withOpacity(0.5),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isActive
                ? const Color(0xFFFFD700)
                : Colors.white.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
