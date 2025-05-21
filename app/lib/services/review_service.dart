import 'dart:convert';
import 'package:app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/review.dart';
import 'package:app/services/auth_service.dart';

class ReviewService {
  static Future<Review?> addReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/reviews'),
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
        Uri.parse('${AppConfig.apiBaseUrl}/reviews'),
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
        Uri.parse('${AppConfig.apiBaseUrl}/reviews/$bookId'),
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

  // Récupérer un avis par ID
  static Future<Review?> getReviewById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/reviews/getReviewById/$id'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        return Review.fromJson(json.decode(response.body));
      } else {
        print(
          "Erreur récupération review par ID: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      print("Erreur dans getReviewById: $e");
    }
    return null;
  }

  // Mettre à jour un avis
  static Future<Review?> updateReview(int id, Review review) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/reviews/$id'),
        headers: {
          ...await AuthService.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 200) {
        return Review.fromJson(json.decode(response.body));
      } else {
        print(
          "Erreur lors de la mise à jour: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      print("Exception updateReview: $e");
    }
    return null;
  }

  // Supprimer un avis
  static Future<bool> deleteReview(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/reviews/$id'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print(
          "Erreur suppression review: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      print("Exception deleteReview: $e");
    }
    return false;
  }
}
