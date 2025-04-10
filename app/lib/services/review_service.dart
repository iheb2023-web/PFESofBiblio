import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/review.dart';
import 'package:app/services/auth_service.dart';

class ReviewService {
  static const String baseUrl = 'http://10.0.2.2:8080/reviews';

  // Ajouter un avis
  static Future<Review?> addReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          ...await AuthService.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Review.fromJson(json.decode(response.body));
      } else {
        print("Erreur ajout review: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print('Exception lors de l\'ajout de review: $e');
    }
    return null;
  }

  //  Récupérer tous les avis
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      print("Erreur récupération reviews: $e");
    }
    return [];
  }

  // Récupérer les avis par ID de livre
  static Future<List<Review>> getReviewsByBookId(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$bookId'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      print("Erreur getReviewsByBookId: $e");
    }
    return [];
  }
}
