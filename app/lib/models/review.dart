class Review {
  final int? id;
  final String comment;
  final int rating;
  final String publishedDate;
  final int bookId;
  final int userId;
  final String? username; // optionnel pour afficher dans les DTO

  Review({
    this.id,
    required this.comment,
    required this.rating,
    required this.publishedDate,
    required this.bookId,
    required this.userId,
    this.username,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      comment: json['comment'],
      rating: json['rating'],
      publishedDate: json['publishedDate'],
      bookId: json['book']['id'],
      userId: json['user']['id'],
      username: json['user']['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'rating': rating,
      'publishedDate': publishedDate,
      'book': {'id': bookId},
      'user': {'id': userId},
    };
  }
}
