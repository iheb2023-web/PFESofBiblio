class Book {
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String publishedDate;
  final String isbn;
  final String category;
  final int pageCount;
  final String language;

  Book({
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.publishedDate,
    required this.isbn,
    required this.category,
    required this.pageCount,
    required this.language,
  });

  // Conversion d'un JSON en objet Book
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      isbn: json['isbn'] ?? '',
      category: json['category'] ?? '',
      pageCount: json['pageCount'] ?? 0,
      language: json['language'] ?? '',
    );
  }

  // Conversion de l'objet Book en JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'publishedDate': publishedDate,
      'isbn': isbn,
      'category': category,
      'pageCount': pageCount,
      'language': language,
    };
  }

  // Copie d'un objet Book avec modification possible de certains champs
  Book copyWith({
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? publishedDate,
    String? isbn,
    String? category,
    int? pageCount,
    String? language,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
    );
  }
} 