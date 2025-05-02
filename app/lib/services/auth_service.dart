import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/user_model.dart';
import 'package:app/services/storage_service.dart';

class AuthService {
  static final StorageService _storageService = StorageService();
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
      final headers = await getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: headers,
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data == null) {
            throw Exception('Réponse vide du serveur');
          }
          if (data['access_token'] == null) {
            throw Exception('Token d\'accès manquant dans la réponse');
          }

          final token = data['access_token'];

          try {
            await _storageService.saveAuthToken(token);

            final userResponse = await http.get(
              Uri.parse('$baseUrl/users/usermininfo/$email'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            if (userResponse.statusCode != 200) {
              throw Exception(
                'Erreur lors de la récupération des données utilisateur',
              );
            }

            final userInfo = json.decode(userResponse.body);

            final userData = {
              'id': userInfo['id'],
              'email': userInfo['email'] ?? email,
              'firstname': userInfo['firstname']?.toString() ?? '',
              'lastname': userInfo['lastname']?.toString() ?? '',
              'role': userInfo['role']?.toString() ?? 'USER',
              'image': userInfo['image']?.toString(),
              'job': userInfo['job']?.toString(),
              'birthday': userInfo['birthday']?.toString(),
              'phone': userInfo['phone']?.toString(),
              'address': userInfo['address']?.toString(),
              'hasPreference': userInfo['hasPreference'] ?? false,
              'hasSetPassword': userInfo['hasSetPassword'] ?? false,
            };

            try {
              final user = User.fromJson(userData);
              await _storageService.saveUserSession(userData);

              return user;
            } catch (e) {
              throw Exception(
                'Erreur lors de la création de l\'utilisateur: $e',
              );
            }
          } catch (e) {
            throw Exception('Token invalide ou malformé: $e');
          }
        } catch (e) {
          throw Exception('Format de réponse invalide: $e');
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
      throw Exception('Erreur de connexion au serveur: $e');
    } on FormatException catch (e) {
      throw Exception('Erreur de format de réponse: $e');
    } catch (e) {
      throw Exception('votre email et ou mot de passe est incorrect :(');
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.clearSession();
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/users/logout'),
          headers: await getHeaders(),
        );

        if (response.statusCode != 200) {}
      } catch (e) {}
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/request'),
        headers: await getHeaders(),
        body: json.encode({'email': email}),
      );
      if (response.statusCode == 200) {
      } else if (response.statusCode == 404) {
        throw Exception('Aucun compte associé à cet email');
      } else {
        throw Exception(
          'Erreur serveur: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    } on FormatException catch (e) {
      throw Exception('Erreur de format de réponse: $e');
    } catch (e) {
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

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Échec de la récupération du user');
      }
    } catch (e) {
      return null;
    }
  }
}
