// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamebox/main.dart';
import 'package:gamebox/screens/dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui' as ui;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _navAnimController;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Iconsax.home_15,
      activeIcon: Iconsax.home_14,
      label: 'Casino',
    ),
    _NavItem(
      icon: Iconsax.wallet_3,
      activeIcon: Iconsax.wallet_35,
      label: 'Wallet',
      enabled: false,
    ),
    _NavItem(
      icon: Iconsax.cup,
      activeIcon: Iconsax.cup5,
      label: 'Rewards',
      enabled: false,
    ),
    _NavItem(
      icon: Iconsax.profile_circle,
      activeIcon: Iconsax.profile_circle5,
      label: 'Profile',
      enabled: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (!_navItems[index].enabled) {
      _showComingSoonSnackbar();
      return;
    }

    setState(() => _selectedIndex = index);
    _navAnimController.forward(from: 0);
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.info_circle, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundGradientStart,
                  AppColors.backgroundGradientEnd,
                ],
              ),
            ),
          ),

          // Main content
          IndexedStack(
            index: _selectedIndex,
            children: const [
              DashboardScreen(),
              _PlaceholderScreen(title: 'Wallet'),
              _PlaceholderScreen(title: 'Rewards'),
              _PlaceholderScreen(title: 'Profile'),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildLuxuryBottomNav(),
    );
  }

  Widget _buildLuxuryBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80, // Increased from 75 to 80 for more breathing room
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardDark.withOpacity(0.95),
                  AppColors.cardLight.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navItems.length,
                  (index) => _buildNavItem(index),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    final isEnabled = item.enabled;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold.withOpacity(0.25),
                      AppColors.champagneGold.withOpacity(0.15),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon without the Stack to reduce height
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24, // Reduced from 26 to 24
                color: !isEnabled
                    ? AppColors.textMuted.withOpacity(0.4)
                    : isSelected
                    ? AppColors.gold
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4), // Reduced from 6 to 4
              // Label
              Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 10, // Reduced from 11 to 10
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: !isEnabled
                      ? AppColors.textMuted.withOpacity(0.4)
                      : isSelected
                      ? AppColors.gold
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool enabled;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.enabled = true,
  });
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.info_circle,
            size: 64,
            color: AppColors.gold.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Coming Soon',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
