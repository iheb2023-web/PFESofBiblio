import 'dart:convert';
import 'package:app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/book.dart';
import 'package:app/services/auth_service.dart';

class BookService {
  static Future<List<Book>> getAllBooks() async {
    http.Response? response; // Déclarer response en dehors du try
    try {
      response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/books'),
        headers: {...await AuthService.getHeaders(), 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        // Premier essai avec UTF-8
        try {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          return data.map((json) => Book.fromJson(json)).toList();
        } on FormatException {
          // Fallback en latin1 si UTF-8 échoue
          final String decodedBody = latin1.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          return data.map((json) => Book.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load books (Status: ${response.statusCode})');
    } catch (e) {
      if (response != null) {
        print('Response headers: ${response.headers}');
      }
      return [];
    }
  }

  static Future<List<Book>> getAllBooksWithinEmailOwner(String email) async {
    http.Response? response;
    try {
      // Construire l'URL avec le paramètre email
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/books/allBookWithinEmailOwner/$email',
      );

      response = await http.get(
        uri,
        headers: {...await AuthService.getHeaders(), 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        try {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          return data.map((json) => Book.fromJson(json)).toList();
        } on FormatException {
          // Fallback en latin1 si UTF-8 échoue
          final String decodedBody = latin1.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          return data.map((json) => Book.fromJson(json)).toList();
        }
      } else if (response.statusCode == 404) {
        // Aucun livre trouvé pour cet email
        return [];
      } else {
        throw Exception(
          'Failed to load books (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (response != null) {
        print('Error response headers: ${response.headers}');
        print('Error response body: ${response.body}');
      }
      print('Error fetching books with owner email: $e');
      print("email de user connecte est : $email");
      return [];
    }
  }

  static Future<List<Book>> getBooksByUser(int userId) async {
    http.Response? response; // Déclarer en dehors du try pour accès dans catch

    try {
      final headers = {
        ...await AuthService.getHeaders(),
        'Accept-Charset': 'utf-8', // Ajout du charset
      };
      final url = '${AppConfig.apiBaseUrl}/books/user/$userId';
      response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        try {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final books = data.map((json) => Book.fromJson(json)).toList();
          return books;
        } on FormatException {
          final String decodedBody = latin1.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final books = data.map((json) => Book.fromJson(json)).toList();
          return books;
        }
      }
      throw Exception('Échec du chargement des livres: ${response.statusCode}');
    } catch (e) {
      if (response != null) {}
      return [];
    }
  }

  // Search Google Books API
  static Future<Map<String, dynamic>?> searchGoogleBooks(
    String title, {
    String? author,
  }) async {
    try {
      String queryString = 'intitle:${Uri.encodeComponent(title)}';
      if (author != null && author.isNotEmpty) {
        queryString += '+inauthor:${Uri.encodeComponent(author)}';
      }

      final response = await http.get(
        Uri.parse('${AppConfig.googleBooksUrl}?q=$queryString&maxResults=1'),
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
      return null;
    }
  }

  // Delete book
  static Future<bool> deleteBook(int bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/books/$bookId'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception(
        'Échec de la suppression du livre: ${response.statusCode}',
      );
    } catch (e) {
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
        Uri.parse('${AppConfig.apiBaseUrl}/books/$bookId'),
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

  static Future<Map<String, dynamic>?> getBookOwner(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/books/getBookOwner/$bookId'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // ou tu peux faire une classe BookOwnerDto si tu veux
      } else {
        throw Exception('Échec de la récupération du propriétaire');
      }
    } catch (e) {
      return null;
    }
  }
}
