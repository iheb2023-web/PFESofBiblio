class Review {
  final int? id;
  final String comment; // contenu du commentaire
  final int rating;
  final String publishedDate;
  final int bookId;
  final int? userId; // optionnel si on utilise l'email à l'envoi
  final String? username;
  String? userEmail; // pour l'envoi via email au lieu de userId

  Review({
    this.id,
    required this.comment,
    required this.rating,
    required this.publishedDate,
    required this.bookId,
    this.userId,
    this.username,
    this.userEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      comment: json['content'] ?? '',
      rating: json['rating'] ?? 0,
      publishedDate: json['publishedDate'] ?? '',
      bookId: json['book']?['id'] ?? 0,
      userId: json['user']?['id'],
      username: json['user']?['username'],
      userEmail: json['user']?['email'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'content': comment,
      'rating': rating,
      'book': {'id': bookId},
    };

    if (userEmail != null) {
      jsonMap['user'] = {'email': userEmail};
    }

    return jsonMap;
  }
}
