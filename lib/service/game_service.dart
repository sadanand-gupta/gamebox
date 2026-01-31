import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/game_model_class.dart';

class GameService {
  // Parses the full JSON and returns every item.
  // Pagination (show 20 at a time) is handled by DashboardScreen,
  // so we must NOT limit the list here.
  Future<List<Game>> loadGames() async {
    try {
      final String jsonString =
      await rootBundle.loadString('assets/data/allgames_list.json');

      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((item) => Game.fromJson(item)).toList();
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  // Case-insensitive filter across name, category, and groupname.
  List<Game> filterGames(List<Game> games, String query) {
    if (query.trim().isEmpty) return games;

    final lower = query.trim().toLowerCase();

    return games.where((g) {
      return g.name.toLowerCase().contains(lower) ||
          g.category.toLowerCase().contains(lower) ||
          g.groupname.toLowerCase().contains(lower);
    }).toList();
  }
}