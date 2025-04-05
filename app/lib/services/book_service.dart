import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/book.dart';
import 'package:app/services/auth_service.dart';

class BookService {
  static const String baseUrl = 'http://10.0.2.2:8080/books';
  static const String googleBooksUrl =
      'https://www.googleapis.com/books/v1/volumes';

  // Get all books
  static Future<List<Book>> getAllBooks() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      }
      throw Exception('Failed to load books');
    } catch (e) {
      print('Error getting all books: $e');
      return [];
    }
  }

  // Get books by user
  static Future<List<Book>> getBooksByUser(int userId) async {
    try {
      print('BookService: Récupération des livres pour l\'utilisateur $userId');
      final headers = await AuthService.getHeaders();
      print('BookService: Headers de la requête: $headers');

      final url = '$baseUrl/user/$userId';
      print('BookService: URL de la requête: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('BookService: Status code de la réponse: ${response.statusCode}');
      print('BookService: Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final books = data.map((json) => Book.fromJson(json)).toList();
        print('BookService: ${books.length} livres récupérés');
        return books;
      }
      throw Exception('Échec du chargement des livres: ${response.statusCode}');
    } catch (e) {
      print('BookService: Erreur lors de la récupération des livres: $e');
      return [];
    }
  }

  // Add new book
  static Future<Book?> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await AuthService.getHeaders(),
        body: json.encode(book.toJson()),
      );

      if (response.statusCode == 201) {
        return Book.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to add book');
    } catch (e) {
      print('Error adding book: $e');
      return null;
    }
  }

  // Search Google Books API
  static Future<Map<String, dynamic>?> searchGoogleBooks(
    String title, {
    String? author,
  }) async {
    try {
      // Construction de la requête à la manière de la version web
      String queryString = 'intitle:${Uri.encodeComponent(title)}';
      if (author != null && author.isNotEmpty) {
        queryString += '+inauthor:${Uri.encodeComponent(author)}';
      }

      final response = await http.get(
        Uri.parse('$googleBooksUrl?q=$queryString&maxResults=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final volumeInfo = data['items'][0]['volumeInfo'];

          // Récupération de l'ISBN avec préférence pour ISBN_13 comme dans la version web
          String isbn = '';
          if (volumeInfo['industryIdentifiers'] != null &&
              volumeInfo['industryIdentifiers'].isNotEmpty) {
            final isbn13 = volumeInfo['industryIdentifiers'].firstWhere(
              (id) => id['type'] == 'ISBN_13',
              orElse: () => volumeInfo['industryIdentifiers'][0],
            );
            isbn = isbn13['identifier'] ?? '';
          }

          // Conversion des URL HTTP en HTTPS comme dans la version web
          String coverUrl = volumeInfo['imageLinks']?['thumbnail'] ?? '';
          if (coverUrl.isNotEmpty && coverUrl.startsWith('http:')) {
            coverUrl = coverUrl.replaceFirst('http:', 'https:');
          }

          return {
            'title': volumeInfo['title'] ?? '',
            'author': volumeInfo['authors']?.first ?? '',
            'description': volumeInfo['description'] ?? '',
            'coverUrl': coverUrl,
            'publishedDate': volumeInfo['publishedDate'] ?? '',
            'isbn': isbn,
            'category': volumeInfo['categories']?.first ?? '',
            'pageCount': volumeInfo['pageCount'] ?? 0,
            'language': volumeInfo['language'] ?? '',
          };
        }
      }
      return null;
    } catch (e) {
      print('Error searching Google Books: $e');
      return null;
    }
  }

  // Search book by title and author
  static Future<Map<String, dynamic>?> searchBook(
    String title, {
    String? author,
  }) async {
    try {
      return await searchGoogleBooks(title, author: author);
    } catch (e) {
      print('Error searching book: $e');
      return null;
    }
  }

  // Delete book
  static Future<bool> deleteBook(int bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$bookId'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception(
        'Échec de la suppression du livre: ${response.statusCode}',
      );
    } catch (e) {
      print('Erreur lors de la suppression du livre: $e');
      return false;
    }
  }

  // Update book
  static Future<Book?> updateBook(
    int bookId,
    Map<String, dynamic> bookData,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$bookId'),
        headers: {
          ...await AuthService.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(bookData),
      );

      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      }
      throw Exception(
        'Échec de la mise à jour du livre: ${response.statusCode}',
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du livre: $e');
      return null;
    }
  }
}
