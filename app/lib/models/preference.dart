class Preference {
  final int? id;
  final String preferredBookLength;
  final List<String> favoriteGenres;
  final List<String> preferredLanguages;
  final List<String> favoriteAuthors;
  final String type;
  final int? userId;

  Preference({
    this.id,
    required this.preferredBookLength,
    required this.favoriteGenres,
    required this.preferredLanguages,
    required this.favoriteAuthors,
    required this.type,
    this.userId,
  });

  // Conversion d'un JSON en objet Preference
  factory Preference.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;

    return Preference(
      id: json['id'] as int?,
      preferredBookLength: json['preferredBookLength'] ?? '',
      favoriteGenres: List<String>.from(json['favoriteGenres'] ?? []),
      preferredLanguages: List<String>.from(json['preferredLanguages'] ?? []),
      favoriteAuthors: List<String>.from(json['favoriteAuthors'] ?? []),
      type: json['type'] ?? '',
      userId:
          userJson != null ? userJson['id'] as int? : json['userId'] as int?,
    );
  }

  // Conversion de l'objet Preference en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preferredBookLength': preferredBookLength,
      'favoriteGenres': favoriteGenres,
      'preferredLanguages': preferredLanguages,
      'favoriteAuthors': favoriteAuthors,
      'type': type,
      'userId': userId,
    };
  }

  // Méthode copyWith pour cloner l'objet avec des modifications
  Preference copyWith({
    int? id,
    String? preferredBookLength,
    List<String>? favoriteGenres,
    List<String>? preferredLanguages,
    List<String>? favoriteAuthors,
    String? type,
    int? userId,
  }) {
    return Preference(
      id: id ?? this.id,
      preferredBookLength: preferredBookLength ?? this.preferredBookLength,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      favoriteAuthors: favoriteAuthors ?? this.favoriteAuthors,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }
}
