// lib/screens/dashboard_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamebox/main.dart';
import 'package:gamebox/model/game_model_class.dart';
import 'package:gamebox/service/game_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rive/rive.dart' hide Image, LinearGradient;
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

enum ChatSender { user, agent }

class ChatMessage {
  final String text;
  final ChatSender sender;

  ChatMessage({required this.text, required this.sender});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final _gameService = GameService();
  bool _isLoading = true;
  late AnimationController _headerAnimController;
  late AnimationController _floatingChipController;
  int _currentIndex = 0;
  int _selectedSideBarIndex = 0;
  int _selectedFilterIndex = 0;

  // --- FIX: ALL PAGINATION STATE VARIABLES ARE NOW PRESENT ---
  final _scrollController = ScrollController();
  List<Game> _allGames = [];
  List<Game> _displayedGames = [];
  bool _isPaginating = false;
  bool _hasMoreData = true;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatingChipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _loadInitialGames();

    // Listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isPaginating) {
        _loadMoreGames();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _floatingChipController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialGames() async {
    await Future.delayed(const Duration(seconds: 2));
    _allGames = await _gameService.loadGames();
    if (mounted) {
      setState(() {
        _displayedGames = _allGames.take(_pageSize).toList();
        _hasMoreData = _allGames.length > _pageSize;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreGames() async {
    if (_isPaginating || !_hasMoreData) return;
    setState(() => _isPaginating = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    final currentLength = _displayedGames.length;
    final nextPage = _allGames.skip(currentLength).take(_pageSize).toList();
    if (mounted) {
      setState(() {
        _displayedGames.addAll(nextPage);
        _hasMoreData = _displayedGames.length < _allGames.length;
        _isPaginating = false;
      });
    }
  }

  Future<void> _showGameLoadingPopup(BuildContext context, Game game) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 4), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            backgroundColor: Colors.transparent,
            child:
                Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.cardDark.withOpacity(0.95),
                            AppColors.cardLight.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Game icon/logo placeholder
                          Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.gold.withOpacity(0.3),
                                      AppColors.emerald.withOpacity(0.2),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Iconsax.game,
                                  size: 40,
                                  color: AppColors.gold,
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .rotate(duration: const Duration(seconds: 2)),

                          const SizedBox(height: 24),

                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.champagneGold, AppColors.gold],
                            ).createShader(bounds),
                            child: Text(
                              game.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Loading animation
                          const SizedBox(
                            height: 140,
                            child: RiveAnimation.asset(
                              'assets/images/gamebox_logo.png',
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.gold.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Launching Game...',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      curve: Curves.easeOut,
                    ),
          ),
        );
      },
    );
  }

  // inside _DashboardScreenState class

  @override
  Widget build(BuildContext context) {
    // Define breakpoints for layout changes
    const double webMobileBreakpoint = 768;
    const double webDesktopBreakpoint = 1024;

    final screenWidth = MediaQuery.of(context).size.width;

    // --- MODIFICATION: Main Responsive Logic ---
    // Check if we are on a wide desktop screen
    final bool isDesktopView = kIsWeb && screenWidth >= webDesktopBreakpoint;

    if (isDesktopView) {
      // Return the new Desktop UI
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        // --- MODIFICATION: ADD THESE TWO LINES ---
        floatingActionButton: _buildSupportFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // --- END MODIFICATION ---
        body: Row(
          children: [
            _buildSideNavigationBar(),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildLobbyHeader(),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  _isLoading
                      ? _buildGamesGridLoader()
                      : _buildNewGamesGrid(_displayedGames),
                  if (_isPaginating)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Return the existing Mobile/Tablet UI
      final bool isMobileView = !kIsWeb || screenWidth < webMobileBreakpoint;
      return Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildLuxuryAppBar(),
            _buildWelcomeBanner(),
            _buildPlayerStatus(),
            _buildQuickActions(),
            _buildSectionHeader('Live Casino Games'),
            _isLoading
                ? _buildGamesGridLoader()
                : _buildGamesGrid(_displayedGames), // Original gold-style grid
            SliverToBoxAdapter(
              child: SizedBox(height: _isPaginating ? 500 : 80),
            ),
          ],
        ),
        floatingActionButton: isMobileView ? _buildSupportFab() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: isMobileView ? _buildBottomNavBar() : null,
      );
    }
    // --- END MODIFICATION ---
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      backgroundColor: AppColors.cardDark,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textMuted,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(),
      items: const [
        BottomNavigationBarItem(icon: Icon(Iconsax.gameboy), label: 'Casino'),
        BottomNavigationBarItem(icon: Icon(Iconsax.wallet_3), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Iconsax.gift), label: 'Rewards'),
        BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
      ],
    );
  }

  Widget _buildSideNavigationBar() {
    final navItems = [
      {'icon': Iconsax.element_3, 'label': 'Dashboard'},
      {'icon': Iconsax.video_play, 'label': 'Live Casino'},
      {'icon': Iconsax.game, 'label': 'Slots'},
      {'icon': Iconsax.repeat_circle, 'label': 'Roulette'},
      {'icon': Iconsax.star, 'label': 'Game Shows'},
      {'icon': Iconsax.cup, 'label': 'Baccarat'},
      {'icon': Iconsax.cup, 'label': 'Sportsbook'},
    ];

    return Container(
      width: 260,
      color: AppColors.sideBarBackground,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 32.0),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.primaryPurple, size: 32),
                const SizedBox(width: 8),
                Text(
                  'UFA CASINO',
                  style: GoogleFonts.poppins(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // Explore Platform section
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 16.0),
            child: Text(
              'EXPLORE PLATFORM',
              style: GoogleFonts.poppins(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          // Navigation Items
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isSelected = _selectedSideBarIndex == index;
            return _buildNavigationItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedSideBarIndex = index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : AppColors.textGrey,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.textWhite : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFICATION: WIDGET FOR THE "WORLD LOBBY" HEADER ---
  Widget _buildLobbyHeader() {
    final filters = ['POPULAR', 'TREND', 'ALPHA'];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WORLD LOBBY',
                  style: GoogleFonts.poppins(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CURATING 24 LUXURY EXPERIENCES',
                  style: GoogleFonts.poppins(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Row(
              children: List.generate(filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      filters[index],
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFICATION: A NEW GAMES GRID FOR THE DESKTOP UI ---
  Widget _buildNewGamesGrid(List<Game> games) {
    return SliverPadding(
      padding: const EdgeInsets.all(32.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0, // Responsive grid item size
          childAspectRatio: 0.75,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final game = games[index];
          return _buildNewGameCard(game); // Use the new card style
        }, childCount: games.length),
      ),
    );
  }

  // --- MODIFICATION: THE RESTYLED GAME CARD ---
  Widget _buildNewGameCard(Game game) {
    return GestureDetector(
      onTap: () => _showGameLoadingPopup(context, game),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              game.urlThumb,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(
                color: AppColors.sideBarBackground,
                child: const Icon(
                  Iconsax.game,
                  color: AppColors.textGrey,
                  size: 40,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.5, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: AppColors.textYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'EVOLUTION GAMING', // Placeholder provider
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showGameLoadingPopup(context, game),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: AppColors.textWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Iconsax.play, size: 16),
                          label: Text(
                            'PLAY NOW',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.textYellow,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '\$100', // Placeholder value
                          style: GoogleFonts.poppins(
                            color: AppColors.textYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFICATION END ---
  Widget _buildSupportFab() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 233, 231, 224),
            Color.fromARGB(255, 251, 249, 249),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 104, 104, 103).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSupportChat(context),
          borderRadius: BorderRadius.circular(35),
          child: const Icon(
            Iconsax.message_question,
            color: Color.fromARGB(255, 82, 60, 28),
            size: 32,
          ),
        ),
      ),
    ).animate().scale(
      delay: 1.seconds,
      duration: 500.ms,
      curve: Curves.elasticOut,
    );
  }

  void _showSupportChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const LiveSupportChatSheet();
      },
    );
  }

  SliverAppBar _buildLuxuryAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 20.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with parallax
            Image.network(
              'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?q=80&w=2670&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    AppColors.background.withOpacity(0.7),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Floating chips decoration
            ...List.generate(5, (index) {
              return Positioned(
                left: (index * 80.0) % MediaQuery.of(context).size.width,
                top: 40 + (index * 20.0),
                child: AnimatedBuilder(
                  animation: _floatingChipController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(
                              _floatingChipController.value * 2 * math.pi +
                                  index,
                            ) *
                            10,
                      ),
                      child: Opacity(
                        opacity: 0.2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.champagneGold, AppColors.gold],
          ).createShader(bounds),
          child: Text(
            'ROYALE',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Iconsax.notification, color: AppColors.gold),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.ruby,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return SliverToBoxAdapter(
      child:
          Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold.withOpacity(0.15),
                      AppColors.emerald.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, AppColors.champagneGold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.crown_15,
                        color: AppColors.background,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, VIP',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your exclusive gaming awaits',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideX(begin: -0.2, curve: Curves.easeOut),
    );
  }

  Widget _buildPlayerStatus() {
    const String username = "CasinoKing777";
    const int level = 42;
    const double progress = 0.73;
    const String balance = "\$12,450";

    return SliverToBoxAdapter(
      child:
          Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.cardDark.withOpacity(0.8),
                            AppColors.cardLight.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Level badge
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.gold,
                                      AppColors.champagneGold,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    level.toString(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.background,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Username and progress
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: AppColors.background
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: progress,
                                            child: Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppColors.gold,
                                                    AppColors.champagneGold,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.gold
                                                        .withOpacity(0.5),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Balance
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Balance',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            AppColors.gold,
                                            AppColors.champagneGold,
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      balance,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 0.2, curve: Curves.easeOut),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Iconsax.add_circle,
        label: 'Deposit',
        gradient: const LinearGradient(
          colors: [AppColors.emerald, Color(0xFF3EA86F)],
        ),
      ),
      _QuickAction(
        icon: Iconsax.minus_cirlce,
        label: 'Withdraw',
        gradient: const LinearGradient(
          colors: [AppColors.ruby, Color(0xFFA01042)],
        ),
      ),
      _QuickAction(
        icon: Iconsax.gift,
        label: 'Bonuses',
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.champagneGold],
        ),
      ),
      _QuickAction(
        icon: Iconsax.chart_1,
        label: 'Status',
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Row(
          children: actions
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: entry.key == 0 ? 0 : 6,
                      right: entry.key == actions.length - 1 ? 0 : 6,
                    ),
                    child: _buildQuickActionButton(entry.value)
                        .animate(delay: (400 + entry.key * 100).ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(_QuickAction action) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        gradient: action.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: action.gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${action.label} - Coming Soon',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppColors.cardDark,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.gold, AppColors.champagneGold],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideX(begin: -0.2),
    );
  }

  Widget _buildGamesGrid(List<Game> games) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final game = games[index];
          return _buildGameCard(game)
              .animate(delay: (700 + index * 80).ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut)
              .shimmer(
                delay: (1200 + index * 80).ms,
                duration: 1500.ms,
                color: AppColors.gold.withOpacity(0.1),
              );
        }, childCount: games.length),
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () => _showGameLoadingPopup(context, game),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Game thumbnail
            Image.network(
              game.urlThumb,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(
                color: AppColors.cardDark,
                child: const Icon(
                  Iconsax.game,
                  color: AppColors.textMuted,
                  size: 40,
                ),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
              ),
            ),

            // Gold border on hover effect
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.0),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Game info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.9),
                            AppColors.champagneGold.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.play_circle5,
                            size: 14,
                            color: AppColors.background,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PLAY NOW',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesGridLoader() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.cardDark,
            highlightColor: AppColors.cardLight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }, childCount: 6),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Gradient gradient;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}

// ADD THIS ENTIRE WIDGET AT THE BOTTOM OF THE FILE

class LiveSupportChatSheet extends StatefulWidget {
  const LiveSupportChatSheet({super.key});

  @override
  State<LiveSupportChatSheet> createState() => _LiveSupportChatSheetState();
}

class _LiveSupportChatSheetState extends State<LiveSupportChatSheet> {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _languageSelected = false;
  bool _isAgentTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        sender: ChatSender.agent,
        text: "Welcome to UFA Future Support! Please select your language.",
      ),
    );
  }

  void _handleLanguageSelect(String language) {
    if (_languageSelected) return;

    setState(() {
      _languageSelected = true;
      _messages.add(ChatMessage(sender: ChatSender.user, text: language));
    });
    _simulateAgentResponse();
  }

  void _handleSendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: ChatSender.user, text: text));
      _textController.clear();
    });
    _simulateAgentResponse(userMessage: text);
  }

  void _simulateAgentResponse({String? userMessage}) {
    setState(() => _isAgentTyping = true);

    // Scroll to bottom after a slight delay to allow UI to build
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      String agentReply;
      if (userMessage == null) {
        agentReply =
            "Thank you for choosing English. My name is Alex. How can I assist you today?";
      } else {
        final lowerCaseMessage = userMessage.toLowerCase();
        if (lowerCaseMessage.contains('deposit')) {
          agentReply =
              "To make a deposit, please visit the 'Deposit' section from the main dashboard. We support various crypto and fiat methods.";
        } else if (lowerCaseMessage.contains('bonus')) {
          agentReply =
              "You can find all your available bonuses and promotions under the 'Bonuses' tab. New offers are added weekly!";
        } else if (lowerCaseMessage.contains('withdraw')) {
          agentReply =
              "Withdrawals are processed within 24 hours. You can initiate a withdrawal from the 'Withdraw' section on the dashboard.";
        } else {
          agentReply =
              "I understand. Please give me a moment to connect you with a specialist for that query. Thank you for your patience.";
        }
      }

      setState(() {
        _isAgentTyping = false;
        _messages.add(ChatMessage(sender: ChatSender.agent, text: agentReply));
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardDark, AppColors.cardLight.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      // ClipRRect ensures the Scaffold inside respects the rounded corners.
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Scaffold(
          backgroundColor:
              Colors.transparent, // Let the container's gradient show through.
          // Use an AppBar for a clean header structure.
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, // We don't need a back button.
            title: Text(
              'Live Support',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            // This adds the divider below the header.
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(
                color: AppColors.textMuted,
                height: 1,
                thickness: 1,
              ),
            ),
          ),
          // The body contains the message list and other conditional UI.
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),

              // These widgets will now appear correctly inside the body, above the input field.
              if (!_languageSelected) _buildLanguageButtons(),

              if (_isAgentTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Agent is typing',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('...')
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(delay: 200.ms)
                          .then()
                          .fadeOut(delay: 200.ms),
                    ],
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _languageSelected
              ? _buildChatInputField()
              : null,
        ),
      ),
    );
  }

  Widget _buildLanguageButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['English', 'Español', '中文']
            .map(
              (lang) => OutlinedButton(
                onPressed: () => _handleLanguageSelect(lang),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  foregroundColor: AppColors.gold,
                ),
                child: Text(lang),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.5)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.send_1, color: AppColors.gold),
            onPressed: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == ChatSender.user;
    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.gold
                  : AppColors.background.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.poppins(
                color: isUser ? AppColors.background : AppColors.text,
                fontSize: 14,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: isUser ? 0.2 : -0.2, curve: Curves.easeOut);
  }
}
