import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/user_model.dart';
import 'package:app/services/storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
          print('AuthService - Structure complète de la réponse: $data');

          if (data == null) {
            throw Exception('Réponse vide du serveur');
          }

          // Vérifier que le token est présent et valide
          if (data['access_token'] == null) {
            print('AuthService - Pas de token dans la réponse');
            throw Exception('Token d\'accès manquant dans la réponse');
          }

          final token = data['access_token'];
          print('AuthService - Token reçu: $token');

          // Ajouter un log pour la structure du token
          print('AuthService - Structure du token brut: ${token.split('.')}');

          // Vérifier que le token est un JWT valide en essayant de le décoder
          try {
            final decodedToken = JwtDecoder.decode(token);
            print('AuthService - Token décodé: $decodedToken');
            print(
              'AuthService - Clés disponibles dans le token: ${decodedToken.keys.join(', ')}',
            );

            // Récupérer les informations de l'utilisateur depuis le backend
            final userEmail = decodedToken['sub'];
            final userResponse = await http.get(
              Uri.parse('$baseUrl/users/usermininfo/$userEmail'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            if (userResponse.statusCode != 200) {
              print('AuthService - Erreur lors de la récupération des données utilisateur: ${userResponse.statusCode}');
              throw Exception('Erreur lors de la récupération des données utilisateur');
            }

            final userInfo = json.decode(userResponse.body);
            print('AuthService - Informations utilisateur reçues: $userInfo');

            // Extraire toutes les informations de l'utilisateur depuis la réponse
            final userData = {
              'id': userInfo['id'],
              'email': userInfo['email'] ?? decodedToken['sub'],
              'firstname': userInfo['firstname']?.toString() ?? '',
              'lastname': userInfo['lastname']?.toString() ?? '',
              'role': userInfo['role']?.toString() ?? 'USER',
              'image': userInfo['image']?.toString(),
              'job': userInfo['job']?.toString(),
              'birthday': userInfo['birthday']?.toString(),
              'phone': userInfo['phone']?.toString(),
              'address': userInfo['address']?.toString(),
            };

            print('AuthService - Données utilisateur préparées: $userData');

            try {
              // Créer l'utilisateur avec toutes les données du token
              final user = User.fromJson(userData);
              print('AuthService - Utilisateur créé avec ID: ${user.id}');

              // Sauvegarder le token
              await _storageService.saveAuthToken(token);
              print('AuthService - Token sauvegardé');

              // Sauvegarder les données de l'utilisateur
              await _storageService.saveUserSession(userData);
              print('AuthService - Session utilisateur sauvegardée');

              return user;
            } catch (e) {
              print('Erreur lors de la création de l\'utilisateur: $e');
              print('AuthService - Données qui ont causé l\'erreur: $userData');
              throw Exception(
                'Erreur lors de la création de l\'utilisateur: $e',
              );
            }
          } catch (e) {
            print('Erreur lors de la validation du token: $e');
            print('AuthService - Token qui a causé l\'erreur: $token');
            throw Exception('Token invalide ou malformé: $e');
          }
        } catch (e) {
          print('Erreur lors du parsing de la réponse: $e');
          throw Exception('Format de réponse invalide: $e');
        }
      } else if (response.statusCode == 401) {
        print('AuthService - Erreur 401: Email ou mot de passe incorrect');
        throw Exception('Email ou mot de passe incorrect');
      } else if (response.statusCode == 404) {
        print('AuthService - Erreur 404: Utilisateur non trouvé');
        throw Exception('Utilisateur non trouvé');
      } else {
        print('AuthService - Erreur serveur: ${response.statusCode}');
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
