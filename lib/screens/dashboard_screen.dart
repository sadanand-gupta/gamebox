import 'package:flutter/material.dart';
import 'package:gamebox/model/game_model_class.dart';
import 'package:gamebox/service/auth_service.dart';
import 'package:gamebox/service/game_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _gameService = GameService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Full list returned from JSON (all 48k items)
  List<Game> _allGames = [];

  // Currently visible subset (grows by _batchSize on each load)
  List<Game> _visibleGames = [];

  // The list that is actually shown — either _visibleGames or filtered results
  List<Game> _displayedGames = [];

  // How many items we show at once
  static const int _batchSize = 20;

  // Pointer: next index to grab from _allGames (or from _filteredSource)
  int _currentIndex = 0;

  // Are we in the middle of fetching the very first batch from JSON?
  bool _isInitialLoading = true;

  // Are we currently appending the next batch? (shows bottom spinner)
  bool _isFetchingMore = false;

  // Have we reached the end of the list?
  bool _hasMore = true;

  // Are we in search mode right now?
  bool _isSearching = false;

  // The filtered-down list when user types in search box
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

  // ─── SCROLL LISTENER ────────────────────────────────────────────────
  // Fires when the user is within 200px of the bottom edge.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextBatch();
    }
  }

  // ─── INITIAL LOAD ───────────────────────────────────────────────────
  // Parse the full JSON once, then show the first 20 items.
  Future<void> _loadInitialGames() async {
    setState(() => _isInitialLoading = true);

    // loadGames() parses the entire JSON and returns ALL items.
    // (Remove the .take(100) limit inside GameService if you still have it.)
    _allGames = await _gameService.loadGames();

    // Reset pagination state and show first batch
    _currentIndex = 0;
    _visibleGames = [];
    _isSearching = false;
    _hasMore = true;

    _appendNextBatch(_allGames);

    setState(() => _isInitialLoading = false);
  }

  // ─── APPEND NEXT 20 ─────────────────────────────────────────────────
  // Grabs the next _batchSize items from the given source list starting
  // at _currentIndex, appends them to _visibleGames, and updates display.
  void _appendNextBatch(List<Game> source) {
    if (_currentIndex >= source.length) {
      _hasMore = false;
      return;
    }

    final end = (_currentIndex + _batchSize).clamp(0, source.length);
    final newItems = source.sublist(_currentIndex, end);

    _visibleGames.addAll(newItems);
    _currentIndex = end;
    _hasMore = _currentIndex < source.length;

    // _displayedGames always mirrors _visibleGames (search resets this)
    _displayedGames = List.from(_visibleGames);
  }

  // ─── LAZY LOAD TRIGGER ──────────────────────────────────────────────
  // Called by the scroll listener. Guards against duplicate calls.
  Future<void> _loadNextBatch() async {
    if (_isFetchingMore || !_hasMore) return;

    setState(() => _isFetchingMore = true);

    // Small delay so the bottom spinner is actually visible to the user
    await Future.delayed(const Duration(milliseconds: 300));

    final source = _isSearching ? _filteredSource : _allGames;
    _appendNextBatch(source);

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  // ─── SEARCH ─────────────────────────────────────────────────────────
  // Filters the master list, then resets pagination on the filtered result.
  void _filterGames(String query) {
    if (query.trim().isEmpty) {
      // Search cleared → go back to paginating the full list
      _isSearching = false;
      _filteredSource = [];
      _visibleGames = [];
      _currentIndex = 0;
      _hasMore = true;
      _appendNextBatch(_allGames);
    } else {
      // Build the filtered list from ALL games (not just visible ones)
      _isSearching = true;
      _filteredSource = _gameService.filterGames(_allGames, query);

      // Reset pagination for this new filtered list
      _visibleGames = [];
      _currentIndex = 0;
      _hasMore = true;
      _appendNextBatch(_filteredSource);
    }

    setState(() {});
  }

  // ─── LOGOUT ─────────────────────────────────────────────────────────
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // ─── BUILD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Total count shown in footer: full list or filtered list
    final totalCount =
    _isSearching ? _filteredSource.length : _allGames.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterGames,
              decoration: InputDecoration(
                hintText: 'Search by name, category, or group...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterGames('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ── Main List ───────────────────────────────────────────────
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedGames.isEmpty
                ? const Center(
              child: Text(
                'No games found',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount:
              _displayedGames.length + (_hasMore ? 1 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                // Last item in the list → bottom loader
                if (index == _displayedGames.length) {
                  return const _BottomLoader();
                }
                return _buildGameCard(_displayedGames[index]);
              },
            ),
          ),

          // ── Footer: showing X of Y ──────────────────────────────────
          if (!_isInitialLoading)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Text(
                'Showing ${_displayedGames.length} of $totalCount games',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // ─── GAME CARD ──────────────────────────────────────────────────────
  Widget _buildGameCard(Game game) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                game.urlThumb,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.category, 'Category', game.category),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.group_work, 'Group', game.groupname),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.business, 'Provider', game.product),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Min: ₹${game.minAmount.toStringAsFixed(0)} | Max: ₹${game.maxAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── BOTTOM LOADER WIDGET ───────────────────────────────────────────────────
// Extracted as a const widget so Flutter skips rebuilding it every frame.
class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}