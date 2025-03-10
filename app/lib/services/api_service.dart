import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/book.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Pour l'émulateur Android
  // static const String baseUrl = 'http://localhost:8080'; // Pour iOS

  static Future<bool> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(book.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erreur lors de l\'ajout du livre: $e');
      return false;
    }
  }

  // Ajout d'autres méthodes utiles
  static Future<List<Book>> getAllBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des livres: $e');
      return [];
    }
  }
} 