// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:animated_background/animated_background.dart';
// import 'package:gamebox/service/auth_service.dart';
// import 'package:gamebox/widgets/validators.dart';
// import 'login_screen.dart';

// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen>
//     with TickerProviderStateMixin {
//   // ✨ UPDATED: Changed to TickerProviderStateMixin
//   final _formKey = GlobalKey<FormState>();
//   final _authService = AuthService();

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _registerWithEmail() async {
//     if (!_formKey.currentState!.validate()) return;

//     final email = _emailController.text.trim();
//     final password = _passwordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (!Validators.isValidEmail(email)) {
//       _showError('Please enter a valid email address');
//       return;
//     }
//     if (!Validators.isValidPassword(password)) {
//       _showError('Password must be at least 6 characters');
//       return;
//     }
//     if (!Validators.passwordsMatch(password, confirmPassword)) {
//       _showError('Passwords do not match');
//       return;
//     }

//     setState(() => _isLoading = true);
//     final success = await _authService.registerWithEmail(
//       email: email,
//       password: password,
//     );
//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     if (success) {
//       _showSuccess('Registration successful! Please login.');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     } else {
//       _showError('Registration failed. Please try again.');
//     }
//   }

//   Future<void> _registerWithWhatsApp() async {
//     final phone = _phoneController.text.trim();
//     if (!Validators.isValidE164Phone(phone)) {
//       _showError('Enter phone number in E.164 format (e.g. +919876543210)');
//       return;
//     }

//     setState(() => _isLoading = true);
//     final success = await _authService.registerWithWhatsApp(phone: phone);
//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     if (success) {
//       _showSuccess('Registration successful! Please login with WhatsApp.');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     } else {
//       _showError('Registration failed. Please try again.');
//     }
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline_rounded, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFEF4444),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF10B981),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktop = screenWidth > 900;

//     return Scaffold(
//       backgroundColor: const Color(0xFF111827),
//       body: AnimatedBackground(
//         behaviour: RandomParticleBehaviour(
//           options: ParticleOptions(
//             baseColor: const Color(0xFF6366F1),
//             spawnMinSpeed: 20.0,
//             spawnMaxSpeed: 50.0,
//             particleCount: 50,
//             spawnMaxRadius: 1.5,
//             spawnMinRadius: 1.0,
//           ),
//         ),
//         vsync: this,
//         child: _isLoading
//             ? Center(child: _buildLoadingIndicator())
//             : Center(
//                 child: SingleChildScrollView(
//                   child: Container(
//                     constraints: BoxConstraints(
//                       maxWidth: isDesktop ? 1100 : 450,
//                     ),
//                     margin: EdgeInsets.all(isDesktop ? 32 : 16),
//                     child: isDesktop
//                         ? _buildDesktopLayout()
//                         : _buildMobileLayout(),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: const Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(
//             strokeWidth: 3,
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Creating your account...',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF6B7280),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDesktopLayout() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(32),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 40,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(child: _buildDesktopBranding()),
//           Expanded(child: _buildRegistrationFormContent(isDesktop: true)),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileLayout() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           'Join the PlayBox',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             letterSpacing: -0.5,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'Sign up to unlock a universe of games.',
//           style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 32),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(24),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(color: Colors.white.withOpacity(0.2)),
//               ),
//               child: _buildRegistrationFormContent(isDesktop: false),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRegistrationFormContent({required bool isDesktop}) {
//     final Color labelColor = isDesktop
//         ? const Color(0xFF374151)
//         : Colors.white.withOpacity(0.9);
//     final Color hintColor = isDesktop
//         ? Colors.grey.shade400
//         : Colors.white.withOpacity(0.5);
//     final Color fieldTextColor = isDesktop ? Colors.black87 : Colors.white;
//     final Color fieldBgColor = isDesktop
//         ? Colors.grey.shade50
//         : Colors.black.withOpacity(0.2);
//     final Color fieldBorderColor = isDesktop
//         ? Colors.grey.shade200
//         : Colors.white.withOpacity(0.3);

//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (isDesktop) ...[
//             const Text(
//               'Create Account',
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1F2937),
//                 letterSpacing: -0.5,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Choose your preferred registration method',
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 40),
//           ],

//           isDesktop
//               ? _buildDesktopTabSelector()
//               : _buildMobileLoginTypeSelector(),
//           const SizedBox(height: 24),

//           _tabController.index == 0
//               ? _buildEmailTab(
//                   labelColor,
//                   hintColor,
//                   fieldTextColor,
//                   fieldBgColor,
//                   fieldBorderColor,
//                   isDesktop,
//                 )
//               : _buildWhatsAppTab(
//                   labelColor,
//                   hintColor,
//                   fieldTextColor,
//                   fieldBgColor,
//                   fieldBorderColor,
//                   isDesktop,
//                 ),

//           const SizedBox(height: 24),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Already have an account? ",
//                 style: TextStyle(
//                   color: isDesktop
//                       ? Colors.grey.shade600
//                       : Colors.white.withOpacity(0.7),
//                   fontSize: 14,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LoginScreen()),
//                 ),
//                 style: TextButton.styleFrom(
//                   padding: EdgeInsets.zero,
//                   minimumSize: const Size(0, 0),
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Text(
//                   'Login',
//                   style: TextStyle(
//                     color: isDesktop ? const Color(0xFF6366F1) : Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileLoginTypeSelector() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildSelectorOption("Email", 0),
//         const SizedBox(width: 10),
//         _buildSelectorOption("WhatsApp", 1),
//       ],
//     );
//   }

//   Widget _buildSelectorOption(String text, int index) {
//     bool isSelected = _tabController.index == index;
//     return GestureDetector(
//       onTap: () => _tabController.animateTo(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Colors.white.withOpacity(0.25)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDesktopTabSelector() {
//     return TabBar(
//       controller: _tabController,
//       indicatorSize: TabBarIndicatorSize.label,
//       indicatorWeight: 3,
//       indicatorColor: const Color(0xFF6366F1),
//       labelColor: const Color(0xFF6366F1),
//       unselectedLabelColor: Colors.grey.shade500,
//       labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//       unselectedLabelStyle: const TextStyle(
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//       ),
//       dividerColor: Colors.transparent,
//       tabs: const [
//         Tab(text: 'Email'),
//         Tab(text: 'WhatsApp'),
//       ],
//     );
//   }

//   Widget _buildEmailTab(
//     Color label,
//     Color hint,
//     Color text,
//     Color bg,
//     Color border,
//     bool isDesktop,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildTextField(
//           controller: _emailController,
//           label: 'Email Address',
//           hint: 'your@email.com',
//           icon: Icons.email_rounded,
//           keyboardType: TextInputType.emailAddress,
//           labelColor: label,
//           hintColor: hint,
//           textColor: text,
//           bgColor: bg,
//           borderColor: border,
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           controller: _passwordController,
//           label: 'Password',
//           hint: '••••••••',
//           icon: Icons.lock_rounded,
//           obscureText: _obscurePassword,
//           labelColor: label,
//           hintColor: hint,
//           textColor: text,
//           bgColor: bg,
//           borderColor: border,
//           suffixIcon: IconButton(
//             icon: Icon(
//               _obscurePassword
//                   ? Icons.visibility_rounded
//                   : Icons.visibility_off_rounded,
//               color: hint,
//               size: 20,
//             ),
//             onPressed: () =>
//                 setState(() => _obscurePassword = !_obscurePassword),
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           controller: _confirmPasswordController,
//           label: 'Confirm Password',
//           hint: '••••••••',
//           icon: Icons.lock_outline_rounded,
//           obscureText: _obscureConfirmPassword,
//           labelColor: label,
//           hintColor: hint,
//           textColor: text,
//           bgColor: bg,
//           borderColor: border,
//           suffixIcon: IconButton(
//             icon: Icon(
//               _obscureConfirmPassword
//                   ? Icons.visibility_rounded
//                   : Icons.visibility_off_rounded,
//               color: hint,
//               size: 20,
//             ),
//             onPressed: () => setState(
//               () => _obscureConfirmPassword = !_obscureConfirmPassword,
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Password must be at least 6 characters',
//           style: TextStyle(
//             fontSize: 12,
//             color: hint,
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//         const SizedBox(height: 24),
//         _buildPrimaryButton(
//           label: 'Create Account',
//           onPressed: _registerWithEmail,
//           icon: Icons.arrow_forward_rounded,
//         ),
//       ],
//     );
//   }

//   Widget _buildWhatsAppTab(
//     Color label,
//     Color hint,
//     Color text,
//     Color bg,
//     Color border,
//     bool isDesktop,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildTextField(
//           controller: _phoneController,
//           label: 'Phone Number',
//           hint: '+919876543210',
//           icon: Icons.phone_rounded,
//           keyboardType: TextInputType.phone,
//           labelColor: label,
//           hintColor: hint,
//           textColor: text,
//           bgColor: bg,
//           borderColor: border,
//         ),
//         const SizedBox(height: 8),
//         _buildInfoBox(isDesktop),
//         const SizedBox(height: 24),
//         _buildPrimaryButton(
//           label: 'Register with WhatsApp',
//           onPressed: _registerWithWhatsApp,
//           icon: Icons.arrow_forward_rounded,
//           color: const Color(0xFF10B981),
//         ),
//       ],
//     );
//   }

//   // ✨ NEW: Helper for info box to adapt to UI
//   Widget _buildInfoBox(bool isDesktop) {
//     if (isDesktop) {
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.blue.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.blue.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.info_rounded, size: 18, color: Colors.blue.shade700),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Use E.164 format: +[country code][number]',
//                 style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.info_rounded,
//               size: 18,
//               color: Colors.white.withOpacity(0.8),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Use format: +[country code][number]',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.white.withOpacity(0.8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType? keyboardType,
//     bool obscureText = false,
//     Widget? suffixIcon,
//     required Color labelColor,
//     required Color hintColor,
//     required Color textColor,
//     required Color bgColor,
//     required Color borderColor,
//   }) {
//     final bool isGlass = bgColor.opacity < 1.0;
//     final Color iconContainerColor = isGlass
//         ? Colors.white.withOpacity(0.1)
//         : const Color(0xFF6366F1).withOpacity(0.1);
//     final Color iconColor = isGlass ? Colors.white : const Color(0xFF6366F1);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: labelColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: borderColor),
//           ),
//           child: TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             obscureText: obscureText,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: textColor,
//             ),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 color: hintColor,
//                 fontWeight: FontWeight.w400,
//               ),
//               prefixIcon: Container(
//                 margin: const EdgeInsets.all(12),
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: iconContainerColor,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: iconColor, size: 20),
//               ),
//               suffixIcon: suffixIcon,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPrimaryButton({
//     required String label,
//     required VoidCallback? onPressed,
//     required IconData icon,
//     Color color = const Color(0xFF6366F1),
//   }) {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         gradient: onPressed != null
//             ? LinearGradient(colors: [color, color.withOpacity(0.8)])
//             : null,
//         color: onPressed == null ? Colors.grey.shade300 : null,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: onPressed != null
//             ? [
//                 BoxShadow(
//                   color: color.withOpacity(0.3),
//                   blurRadius: 16,
//                   offset: const Offset(0, 8),
//                 ),
//               ]
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(14),
//           child: Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     color: onPressed != null
//                         ? Colors.white
//                         : Colors.grey.shade500,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   icon,
//                   color: onPressed != null
//                       ? Colors.white
//                       : Colors.grey.shade500,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDesktopBranding() {
//     return Container(
//       padding: const EdgeInsets.all(64),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(32),
//           bottomLeft: Radius.circular(32),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Join GameBox\nToday',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               height: 1.2,
//               letterSpacing: -1,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Create your account and get instant access to thousands of exciting games.',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white.withOpacity(0.9),
//               height: 1.6,
//             ),
//           ),
//           const SizedBox(height: 48),
//           _buildFeatureItem(
//             Icons.rocket_launch_rounded,
//             'Quick & easy registration',
//           ),
//           const SizedBox(height: 16),
//           _buildFeatureItem(Icons.lock_rounded, 'Your data is safe with us'),
//           const SizedBox(height: 16),
//           _buildFeatureItem(
//             Icons.favorite_rounded,
//             'Join thousands of players',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem(IconData icon, String text) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:gamebox/service/auth_service.dart';
import 'package:gamebox/widgets/validators.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- Authentication logic remains the same ---
  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (!Validators.isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }
    if (!Validators.isValidPassword(password)) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (!Validators.passwordsMatch(password, confirmPassword)) {
      _showError('Passwords do not match');
      return;
    }
    setState(() => _isLoading = true);
    final success = await _authService.registerWithEmail(
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _showSuccess('Registration successful! Please login.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      _showError('Registration failed. Please try again.');
    }
  }

  Future<void> _registerWithWhatsApp() async {
    final phone = _phoneController.text.trim();
    if (!Validators.isValidE164Phone(phone)) {
      _showError('Enter phone number in E.164 format (e.g. +919876543210)');
      return;
    }
    setState(() => _isLoading = true);
    final success = await _authService.registerWithWhatsApp(phone: phone);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _showSuccess('Registration successful! Please login with WhatsApp.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      _showError('Registration failed. Please try again.');
    }
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
          'Join the PlayBox',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign up to unlock a universe of games.',
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
              child: _buildRegistrationFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 20),
        Text(
          'Creating your account...',
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
  Widget _buildRegistrationFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLoginTypeSelector(),
          const SizedBox(height: 24),
          _tabController.index == 0 ? _buildEmailTab() : _buildWhatsAppTab(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Login',
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
      ),
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
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Password must be at least 6 characters',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Create Account',
          onPressed: _registerWithEmail,
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
        const SizedBox(height: 8),
        _buildInfoBox(),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Register with WhatsApp',
          onPressed: _registerWithWhatsApp,
          icon: Icons.arrow_forward_rounded,
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            size: 18,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Use format: +[country code][number]',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
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
