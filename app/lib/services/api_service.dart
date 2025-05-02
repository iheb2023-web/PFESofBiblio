import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/book.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<bool> addBook(Book book, int? userId) async {
    if (userId == null) {
      return false;
    }

    try {
      final bookData = {...book.toJson(), 'ownerId': userId};
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookData),
      );
      if (response.statusCode != 201) {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      return false;
    }
  }
}
