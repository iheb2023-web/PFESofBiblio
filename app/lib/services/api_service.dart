import 'dart:convert';
import 'package:app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/book.dart';

class ApiService {
  static Future<bool> addBook(Book book, int? userId) async {
    if (userId == null) {
      return false;
    }

    try {
      final bookData = {...book.toJson(), 'ownerId': userId};
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/books'),
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
