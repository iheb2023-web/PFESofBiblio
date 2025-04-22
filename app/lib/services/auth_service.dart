import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/user_model.dart';
import 'package:app/services/storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static final StorageService _storageService = StorageService();
  // URL du serveur backend - à configurer selon l'environnement
  static const String baseUrl =
      'http://10.0.2.2:8080'; // Pour l'émulateur Android
  // static const String baseUrl = 'http://localhost:8080';  // Pour iOS
  // static const String baseUrl = 'http://192.168.1.xxx:8080';  // Pour appareil physique Android (remplacer xxx par votre IP)

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
      print('AuthService: Tentative de connexion avec email: $email');
      print('AuthService: URL du serveur: $baseUrl');

      final headers = await getHeaders();
      print('AuthService: Headers de la requête: $headers');

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: headers,
        body: json.encode({'email': email, 'password': password}),
      );

      print('AuthService: Réponse du serveur: ${response.statusCode}');
      print('AuthService: Corps de la réponse: ${response.body}');

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

          try {
            // Sauvegarder le token avant de récupérer les informations utilisateur
            await _storageService.saveAuthToken(token);
            print('AuthService - Token sauvegardé');

            // Récupérer les informations de l'utilisateur depuis le backend
            final userResponse = await http.get(
              Uri.parse('$baseUrl/users/usermininfo/$email'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            );

            print(
              'AuthService - Réponse utilisateur: ${userResponse.statusCode}',
            );
            print(
              'AuthService - Corps de la réponse utilisateur: ${userResponse.body}',
            );

            if (userResponse.statusCode != 200) {
              print(
                'AuthService - Erreur lors de la récupération des données utilisateur: ${userResponse.statusCode}',
              );
              throw Exception(
                'Erreur lors de la récupération des données utilisateur',
              );
            }

            final userInfo = json.decode(userResponse.body);
            print('AuthService - Informations utilisateur reçues: $userInfo');

            // Extraire toutes les informations de l'utilisateur depuis la réponse
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
            };

            print('AuthService - Données utilisateur préparées: $userData');

            try {
              // Créer l'utilisateur avec toutes les données
              final user = User.fromJson(userData);
              print('AuthService - Utilisateur créé avec ID: ${user.id}');

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
      await _storageService.clearSession();
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/users/logout'),
          headers: await getHeaders(),
        );

        if (response.statusCode != 200) {
          print(
            'AuthService: Erreur lors de la déconnexion côté serveur: ${response.statusCode}',
          );
        }
      } catch (e) {
        print(
          'AuthService: Erreur lors de la notification de déconnexion au serveur: $e',
        );
      }
    } catch (e) {
      print('AuthService: Erreur lors de la déconnexion: $e');
      // On propage l'erreur pour que le contrôleur puisse la gérer
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Future<void> logout() async {
  //   try {
  //     // 1. D'abord notifier le serveur
  //     final token =
  //         await _storageService
  //             .getAuthToken(); // Récupérer le token avant clear
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/users/logout'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token', // Utiliser le token directement
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       print('Erreur serveur lors de la déconnexion: ${response.statusCode}');
  //     }

  //     // 2. Puis nettoyer le stockage local
  //     await _storageService.clearSession();
  //   } catch (e) {
  //     print('Erreur lors de la déconnexion: $e');
  //     // Nettoyer quand même le stockage local en cas d'erreur
  //     await _storageService.clearSession();
  //     rethrow;
  //   }
  // }

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
      print('Erreur getuserbyid: $e');
      return null;
    }
  }
}
