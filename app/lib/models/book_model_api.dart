class BookData {
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String publishedDate;
  final String isbn;
  final String category;
  final int pageCount;
  final String language;

  BookData({
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

  factory BookData.empty() {
    return BookData(
      title: '',
      author: '',
      description: '',
      coverUrl: '',
      publishedDate: '',
      isbn: '',
      category: '',
      pageCount: 0,
      language: '',
    );
  }
}
