import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:gamebox/model/game_model_class.dart';
import 'package:gamebox/service/auth_service.dart';
import 'package:gamebox/service/game_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  final _gameService = GameService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Game> _allGames = [];
  List<Game> _displayedGames = [];

  static const int _batchSize = 10;
  int _currentIndex = 0;

  bool _isInitialLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  bool _isSearching = false;

  List<Game> _filteredSource = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialGames();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadNextBatch();
    }
  }

  Future<void> _loadInitialGames() async {
    setState(() => _isInitialLoading = true);
    _allGames = await _gameService.loadGames();
    _resetPagination(_allGames);
    setState(() => _isInitialLoading = false);
  }

  void _appendNextBatch(List<Game> source) {
    if (_currentIndex >= source.length) {
      setState(() => _hasMore = false);
      return;
    }
    final end = (_currentIndex + _batchSize).clamp(0, source.length);
    final newItems = source.sublist(_currentIndex, end);
    _displayedGames.addAll(newItems);
    _currentIndex = end;
    _hasMore = _currentIndex < source.length;
  }

  Future<void> _loadNextBatch() async {
    if (_isFetchingMore || !_hasMore) return;
    setState(() => _isFetchingMore = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final source = _isSearching ? _filteredSource : _allGames;
    _appendNextBatch(source);
    if (mounted) setState(() => _isFetchingMore = false);
  }

  void _resetPagination(List<Game> sourceList) {
    _displayedGames = [];
    _currentIndex = 0;
    _hasMore = true;
    _appendNextBatch(sourceList);
    setState(() {});
  }

  void _filterGames(String query) {
    if (query.trim().isEmpty) {
      _isSearching = false;
      _filteredSource = [];
      _resetPagination(_allGames);
    } else {
      _isSearching = true;
      _filteredSource = _gameService.filterGames(_allGames, query);
      _resetPagination(_filteredSource);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _showGamePlayPopup(BuildContext context, Game game) async {
    bool isLoading = false;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // ✨ UPDATED: Frosted Glass Dialog
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                backgroundColor: Colors.white.withOpacity(0.1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: 'game-${game.gameId}',
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                game.urlThumb,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey.shade800,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

// 🎯 Min / Max Amount Row
Container(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.15)),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _amountItem(
        label: 'Min Amount',
        value: game.minAmount,
      ),
      Container(
        width: 1,
        height: 32,
        color: Colors.white.withOpacity(0.2),
      ),
      _amountItem(
        label: 'Max Amount',
        value: game.maxAmount,
      ),
    ],
  ),
),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                            setState(() => isLoading = true);
                            await Future.delayed(const Duration(seconds: 2));
                            if (mounted) Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            isLoading ? 'LOADING...' : 'PLAY NOW',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final gridPadding = isDesktop ? 48.0 : 16.0;
    int crossAxisCount = isDesktop ? 4 : (screenWidth > 800 ? 3 : 2);

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // ✨ UPDATED: Dark background
      body: AnimatedBackground(
        // ✨ NEW: Animated background
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(isDesktop), // ✨ UPDATED: New header
            _isInitialLoading
                ? SliverFillRemaining(child: _buildInitialLoader())
                : _displayedGames.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : _buildGamesGrid(gridPadding, crossAxisCount),
            if (_isFetchingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: _BottomLoader(),
                ),
              ),
            if (!_isInitialLoading && _displayedGames.isNotEmpty)
              _buildFooterInfo(),
          ],
        ),
      ),
    );
  }

  // ✨ NEW: Header and search bar combined into a SliverAppBar
  SliverAppBar _buildSliverAppBar(bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.amber.shade900,
      elevation: 0,
      title: const Text(
        'GameBox',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                ),
              ),
            ),
            // Positioned search bar at the bottom of the expanded app bar
            Positioned(
              bottom: 16,
              left: isDesktop ? 48 : 16,
              right: isDesktop ? 48 : 16,
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _amountItem({required String label, required double value}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹ ${value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ✨ NEW: Frosted Glass Search Bar
  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterGames,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search for your next adventure...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withOpacity(0.8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _filterGames('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✨ UPDATED: Grid generation logic
  Widget _buildGamesGrid(double padding, int crossAxisCount) {
    return SliverPadding(
      padding: EdgeInsets.all(padding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.8,
          crossAxisSpacing: padding,
          mainAxisSpacing: padding,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGameCard(_displayedGames[index]),
          childCount: _displayedGames.length,
        ),
      ),
    );
  }

  // ✨ UPDATED: Complete redesign of the Game Card
  Widget _buildGameCard(Game game) {
    return 
    Hero(
      tag: 'game-${game.gameId}',
      child: GestureDetector(
        onTap: () => _showGamePlayPopup(context, game),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                game.urlThumb,
                fit: BoxFit.cover,
                errorBuilder: (context, e, s) =>
                    Container(color: Colors.grey.shade900),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(color: Colors.grey.shade900),
              ),
              // Dark Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Content on top of the gradient
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ NEW: Frosted glass footer info bar
  Widget _buildFooterInfo() {
    final totalCount = _isSearching ? _filteredSource.length : _allGames.length;
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  'Showing ${_displayedGames.length} of $totalCount games',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✨ UPDATED: Simplified Loaders
  Widget _buildInitialLoader() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Games Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
