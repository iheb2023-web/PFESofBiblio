import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/user_model.dart';
import 'package:app/services/storage_service.dart';

class AuthService {
  static final StorageService _storageService = StorageService();
  // Utiliser l'adresse IP de votre machine au lieu de localhost
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<Map<String, String>> getHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<User> login(String email, String password) async {
    try {
      print('Tentative de connexion avec email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: await getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data == null) {
            throw Exception('Réponse vide du serveur');
          }
          
          print('AuthService - données reçues: $data'); // Debug log
          
          // Créer l'utilisateur avant de sauvegarder la session
          final user = User.fromJson(data);
          print('AuthService - utilisateur créé avec ID: ${user.id}'); // Debug log
          
          // Sauvegarder les données de l'utilisateur
          await _storageService.saveUserSession(data);
          
          // Sauvegarder le token
          if (data['token'] != null) {
            await _storageService.saveAuthToken(data['token']);
          }
          
          return user;
        } catch (e) {
          print('Erreur lors du parsing de la réponse: $e');
          throw Exception('Format de réponse invalide');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      } else if (response.statusCode == 404) {
        throw Exception('Utilisateur non trouvé');
      } else {
        throw Exception(
          'Erreur serveur: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('Erreur de connexion: $e');
      throw Exception('Erreur de connexion au serveur: $e');
    } on FormatException catch (e) {
      print('Erreur de format: $e');
      throw Exception('Erreur de format de réponse: $e');
    } catch (e) {
      print('Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/logout'),
        headers: await getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la déconnexion');
      }
      
      // Nettoyer les données de session
      await _storageService.clearSession();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      print('Tentative de réinitialisation du mot de passe pour: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/request'),
        headers: await getHeaders(),
        body: json.encode({'email': email}),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('Email de réinitialisation envoyé avec succès');
      } else if (response.statusCode == 404) {
        throw Exception('Aucun compte associé à cet email');
      } else {
        throw Exception(
          'Erreur serveur: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('Erreur de connexion: $e');
      throw Exception('Erreur de connexion au serveur: $e');
    } on FormatException catch (e) {
      print('Erreur de format: $e');
      throw Exception('Erreur de format de réponse: $e');
    } catch (e) {
      print('Erreur inattendue: $e');
      throw Exception('Erreur lors de la réinitialisation du mot de passe: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors de la récupération du profil');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<User> updateProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }
}
