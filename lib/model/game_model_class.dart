class Game {
  final int gameId;
  final String name;
  final String urlThumb;
  final String groupname;
  final String category;
  final String product;
  final String gamecategory;
  final double minAmount;
  final double maxAmount;

  Game({
    required this.gameId,
    required this.name,
    required this.urlThumb,
    required this.groupname,
    required this.category,
    required this.product,
    required this.gamecategory,
    required this.minAmount,
    required this.maxAmount,
  });

  // Factory constructor to create Game from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameId: json['game_id'] ?? 0,
      name: json['name'] ?? '',
      urlThumb: json['url_thumb'] ?? '',
      groupname: json['groupname'] ?? '',
      category: json['category'] ?? '',
      product: json['product'] ?? '',
      gamecategory: json['gamecategory'] ?? '',
      minAmount: (json['MinAmount'] ?? 0).toDouble(),
      maxAmount: (json['MaxAmount'] ?? 0).toDouble(),
    );
  }

  // Convert Game to JSON
  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'name': name,
      'url_thumb': urlThumb,
      'groupname': groupname,
      'category': category,
      'product': product,
      'gamecategory': gamecategory,
      'MinAmount': minAmount,
      'MaxAmount': maxAmount,
    };
  }
}