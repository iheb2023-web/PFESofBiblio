import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/book.dart';
import 'package:app/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Pour l'émulateur Android
  // static const String baseUrl = 'http://localhost:8080'; // Pour iOS

  static Future<bool> addBook(Book book, int userId) async {
    try {
      // Create a new book with the owner ID
      final bookWithOwner = book.copyWith(ownerId: userId);
      
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(bookWithOwner.toJson()),
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

  // Get books for a specific user
  static Future<List<Book>> getBooksByUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/user/$userId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des livres de l\'utilisateur: $e');
      return [];
    }
  }
}