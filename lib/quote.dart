class Quote {
  Quote({
    required this.anime,
    required this.character,
    required this.quote,
  });

  String anime;
  String character;
  String quote;

  factory Quote.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload =
        (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : json;

    String animeName = '';
    if (payload['anime'] is Map) {
      animeName = payload['anime']['name'] ?? '';
    } else if (payload['anime.name'] != null) {
      animeName = payload['anime.name'];
    }

    String characterName = '';
    if (payload['character'] is Map) {
      characterName = payload['character']['name'] ?? '';
    } else if (payload['character.name'] != null) {
      characterName = payload['character.name'];
    }

    final String quoteText = payload['content'] ?? payload['quote'] ?? '';

    return Quote(
      anime: animeName,
      character: characterName,
      quote: quoteText,
    );
  }
}
