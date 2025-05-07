class Review {
  final int? id;
  final String comment; // contenu du commentaire
  final int rating;
  final String publishedDate;
  final int? userId;
  final String? username;
  String? userEmail;
  final String? userImage;

  final int bookId; // Si tu veux l’associer manuellement (pas dans JSON ici)

  Review({
    this.id,
    required this.comment,
    required this.rating,
    required this.publishedDate,
    required this.bookId,
    this.userId,
    this.username,
    this.userEmail,
    this.userImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['userReviewsDto'];

    return Review(
      id: json['id'],
      comment: json['content'] ?? '',
      rating: json['rating'] ?? 0,
      publishedDate: json['createdAt'] ?? '',
      bookId:
          json['book']?['id'] ??
          0, // Par défaut à 0, car pas présent dans ce JSON (à remplir manuellement si besoin)
      userId: user?['id'],
      username:
          user != null
              ? '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'
              : null,
      userEmail: user?['email'],
      userImage: user?['image'],
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

  Review copyWith({
    int? rating,
    String? comment,
    // Ne pas inclure les autres champs que vous ne voulez pas modifier
  }) {
    return Review(
      id: this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      // Conservez tous les autres champs tels quels
      bookId: this.bookId,
      userId: this.userId,
      publishedDate: this.publishedDate,
      username: this.username,
    );
  }
}
