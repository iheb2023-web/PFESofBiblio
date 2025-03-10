import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  static const String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static Future<Map<String, dynamic>?> searchBook(String title, {String? author}) async {
    try {
      String query = title;
      if (author != null && author.isNotEmpty) {
        query += '+inauthor:$author';
      }

      final response = await http.get(
        Uri.parse('$baseUrl?q=$query&maxResults=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final volumeInfo = data['items'][0]['volumeInfo'];
          return {
            'title': volumeInfo['title'],
            'author': volumeInfo['authors']?.first,
            'description': volumeInfo['description'],
            'coverUrl': volumeInfo['imageLinks']?['thumbnail'],
            'publishedDate': volumeInfo['publishedDate'],
            'isbn': volumeInfo['industryIdentifiers']
                ?.firstWhere(
                  (id) => id['type'] == 'ISBN_13',
                  orElse: () => volumeInfo['industryIdentifiers']?.first,
                )?['identifier'],
            'category': volumeInfo['categories']?.first,
            'pageCount': volumeInfo['pageCount'],
            'language': volumeInfo['language'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la recherche du livre: $e');
      return null;
    }
  }
} 