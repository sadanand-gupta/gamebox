import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gamebox/model/game_model_class.dart';

class GameService {
  // Load games from assets JSON file
  // Returns only first 100 items for performance
  Future<List<Game>> loadGames() async {
    try {
      // Load JSON string from assets
      final String jsonString =
      await rootBundle.loadString('assets/data/allgames_list.json');

      // Parse JSON
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert to Game objects
      List<Game> allGames = jsonList.map((json) => Game.fromJson(json)).toList();

      // Return only first 100 items for demo performance
      // In production, you'd implement pagination or lazy loading
      return allGames.take(100).toList();
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  // Filter games by search query
  List<Game> filterGames(List<Game> games, String query) {
    if (query.isEmpty) return games;

    final lowerQuery = query.toLowerCase();

    return games.where((game) {
      return game.name.toLowerCase().contains(lowerQuery) ||
          game.category.toLowerCase().contains(lowerQuery) ||
          game.groupname.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}