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

  List<Game> _allGames = [];
  List<Game> _filteredGames = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load games from JSON
  Future<void> _loadGames() async {
    setState(() => _isLoading = true);

    final games = await _gameService.loadGames();

    setState(() {
      _allGames = games;
      _filteredGames = games;
      _isLoading = false;
    });
  }

  // Search/Filter games
  void _filterGames(String query) {
    setState(() {
      _filteredGames = _gameService.filterGames(_allGames, query);
    });
  }

  // Logout
  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Search Bar
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

          // Games List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGames.isEmpty
                ? const Center(
              child: Text(
                'No games found',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: _filteredGames.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final game = _filteredGames[index];
                return _buildGameCard(game);
              },
            ),
          ),

          // Results Counter
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Text(
                'Showing ${_filteredGames.length} of ${_allGames.length} games (Limited to first 100 for demo)',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
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

            // Game Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Name
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

                  // Category
                  _buildInfoRow(Icons.category, 'Category', game.category),
                  const SizedBox(height: 4),

                  // Group
                  _buildInfoRow(Icons.group_work, 'Group', game.groupname),
                  const SizedBox(height: 4),

                  // Product/Provider
                  _buildInfoRow(Icons.business, 'Provider', game.product),
                  const SizedBox(height: 6),

                  // Min & Max Amount
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}