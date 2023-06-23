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
    return Quote(
      anime: json['anime'],
      character: json['character'],
      quote: json['quote'],
    );
  }
}
