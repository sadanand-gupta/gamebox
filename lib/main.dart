// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamebox/screens/login_screen.dart';
import 'package:gamebox/screens/main_screen.dart';
import 'package:gamebox/service/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

// 🎰 LUXURY CASINO THEME - Inspired by Monte Carlo & Las Vegas
class AppColors {
  // Primary Palette - Rich & Luxurious
  static const Color background = Color(0xFF0A0118); // Deep midnight purple
  static const Color backgroundGradientStart = Color(0xFF0A0118);
  static const Color backgroundGradientEnd = Color(0xFF1a0a2e);

  // Accent Colors - Premium metals
  static const Color gold = Color(0xFFD4AF37); // Classic casino gold
  static const Color champagneGold = Color(0xFFF7E7CE);
  static const Color roseGold = Color(0xFFE8B4B8);
  static const Color emerald = Color(0xFF50C878); // Luxury emerald
  static const Color ruby = Color(0xFFE0115F); // Rich ruby red

  // Surface colors
  static const Color cardDark = Color(0xFF1C0F2A);
  static const Color cardLight = Color(0xFF2D1B3D);
  static const Color glass = Color(0x33FFFFFF);

  // Text
  static const Color text = Color(0xFFFFFDF6); // Warm white
  static const Color textSecondary = Color(0xFFB8A98E); // Muted gold
  static const Color textMuted = Color(0xFF6D5D7B);

  // Status colors
  static const Color success = Color(0xFF50C878);
  static const Color warning = Color(0xFFFFB800);
  static const Color danger = Color(0xFFDC143C);
  // ... keep all existing colors (gold, emerald, etc.)

  static const Color darkBackground = Color(0xFF1A1B2F);
  static const Color sideBarBackground = Color(0xFF222440);
  static const Color primaryPurple = Color(0xFF6B4EFF);
  static const Color textYellow = Color(0xFFF9D86B);
  static const Color textGrey = Color(0xFF9A9DBA);
  static const Color textWhite = Color(0xFFFFFFFF);
  // --- END MODIFICATION ---
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxCasino Royale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: GoogleFonts.cormorantGaramondTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.dark,
          background: AppColors.background,
          primary: AppColors.gold,
          secondary: AppColors.emerald,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _navigateNext();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 4));
    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const MainScreen() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2D1B3D),
              Color(0xFF1a0a2e),
              AppColors.background,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            ...List.generate(20, (index) {
              return Positioned(
                left: (index * 53.7) % MediaQuery.of(context).size.width,
                top: (index * 71.3) % MediaQuery.of(context).size.height,
                child:
                    Container(
                          width: 2,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(
                          duration: Duration(
                            milliseconds: 1000 + (index * 100),
                          ),
                        )
                        .fadeOut(
                          delay: Duration(milliseconds: 2000 + (index * 100)),
                          duration: const Duration(milliseconds: 1000),
                        ),
              );
            }),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Luxury logo container with glow effect
                  Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.gold.withOpacity(0.3),
                              AppColors.gold.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.5),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: AppColors.emerald.withOpacity(0.3),
                              blurRadius: 100,
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.gold.withOpacity(0.9),
                                  AppColors.champagneGold.withOpacity(0.7),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.champagneGold,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Iconsax.crown_15,
                              size: 64,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 1000.ms, curve: Curves.easeOut)
                      .scale(
                        delay: 300.ms,
                        duration: 800.ms,
                        begin: const Offset(0.5, 0.5),
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shimmer(
                        delay: 1500.ms,
                        duration: 2000.ms,
                        color: AppColors.champagneGold.withOpacity(0.6),
                      ),

                  const SizedBox(height: 48),

                  // Casino name with luxury typography
                  ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            AppColors.champagneGold,
                            AppColors.gold,
                            AppColors.roseGold,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'ROYALE',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 8,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                blurRadius: 30,
                                color: AppColors.gold.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 1000.ms)
                      .slideY(
                        begin: 0.3,
                        duration: 1000.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 12),

                  Text(
                        'UFA CASINO ONLINE',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 4,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 800.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOut),

                  const SizedBox(height: 60),

                  // Loading indicator
                  SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.gold.withOpacity(0.7),
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(delay: 1500.ms)
                      .rotate(
                        duration: const Duration(seconds: 2),
                        curve: Curves.linear,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
