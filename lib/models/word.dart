class Word {
  final String correctSpelling;
  final List<String> misspellings;
  final int difficulty; // 1-5 scale
  final String? definition;

  Word({
    required this.correctSpelling,
    required this.misspellings,
    required this.difficulty,
    this.definition,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      correctSpelling: json['correctSpelling'] ?? '',
      misspellings: List<String>.from(json['misspellings'] ?? []),
      difficulty: json['difficulty'] ?? 1,
      definition: json['definition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correctSpelling': correctSpelling,
      'misspellings': misspellings,
      'difficulty': difficulty,
      'definition': definition,
    };
  }

  String getRandomMisspelling() {
    if (misspellings.isEmpty) return correctSpelling;
    return misspellings[DateTime.now().millisecondsSinceEpoch %
        misspellings.length];
  }

  bool isCorrectSpelling(String spelling) {
    return spelling.toLowerCase() == correctSpelling.toLowerCase();
  }
}
