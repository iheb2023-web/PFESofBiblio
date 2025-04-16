class Book {
  final int? id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String publishedDate;
  final String isbn;
  final String category;
  final int pageCount;
  final String language;
  final bool isAvailable;
  final int rating;
  final int borrowCount;
  final String? modelUrl;
  final int? ownerId;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.publishedDate,
    required this.isbn,
    required this.category,
    required this.pageCount,
    required this.language,
    this.isAvailable = true,
    this.rating = 0,
    this.borrowCount = 0,
    this.modelUrl,
    this.ownerId,
  });

  // Conversion d'un JSON en objet Book
  factory Book.fromJson(Map<String, dynamic> json) {
    final ownerJson = json['owner'] as Map<String, dynamic>?;
    final ownerId =
        ownerJson != null ? ownerJson['id'] as int? : json['ownerId'] as int?;

    return Book(
      id: json['id'] as int?,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      isbn: json['isbn'] ?? '',
      category: json['category'] ?? '',
      pageCount: json['pageCount'] ?? 0,
      language: json['language'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      rating: json['rating'] ?? 0,
      borrowCount: json['borrowCount'] ?? 0,
      modelUrl: json['modelUrl'] ?? '',
      ownerId: ownerId,
    );
  }

  // Conversion de l'objet Book en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'publishedDate': publishedDate,
      'isbn': isbn,
      'category': category,
      'pageCount': pageCount,
      'language': language,
      'isAvailable': isAvailable,
      'rating': rating,
      'borrowCount': borrowCount,
      'modelUrl': modelUrl,
      'ownerId': ownerId,
    };
  }

  // Copie d'un objet Book avec modification possible de certains champs
  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? publishedDate,
    String? isbn,
    String? category,
    int? pageCount,
    String? language,
    bool? isAvailable,
    int? rating,
    int? borrowCount,
    String? modelUrl,
    int? ownerId,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      borrowCount: borrowCount ?? this.borrowCount,
      modelUrl: modelUrl ?? this.modelUrl,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
