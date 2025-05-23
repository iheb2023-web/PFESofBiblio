import 'dart:convert';
import 'package:app/config/app_config.dart';
import 'package:app/imports.dart';
import 'package:app/models/top_borrower.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/user_model.dart';
import 'package:app/services/storage_service.dart';

class AuthService {
  static final StorageService _storageService = StorageService();

  static Future<Map<String, String>> getHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final Uri url = Uri.parse(
      '${AppConfig.apiBaseUrl}/users/password-reset/request?email=$email',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Un e-mail de réinitialisation a été envoyé',
        };
      } else {
        return {'success': false, 'message': 'Erreur: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  Future<int> verifyResetCode(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/users/password-reset/getTokenByEmail/$email',
        ),
      );

      if (response.statusCode == 200) {
        // Retourner directement l'entier reçu dans la réponse
        return int.parse(response.body);
      } else {
        throw Exception('Échec de la récupération du token');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> login(String email, String password) async {
    final headers = await getHeaders();

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/users/login'),
      headers: headers,
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data == null || data['access_token'] == null) {
        throw Exception('Réponse invalide du serveur');
      }

      final token = data['access_token'];
      await _storageService.saveAuthToken(token);

      final userResponse = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/usermininfo/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Erreur lors de la récupération de l’utilisateur');
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
        'hasPreference': userInfo['hasPreference'],
        'hasSetPassword': userInfo['hasSetPassword'],
        'token': token,
      };

      final user = User.fromJson(userData);
      await _storageService.saveUserSession(userData);

      return user;
    } else if (response.statusCode == 401) {
      throw Exception('Email ou mot de passe incorrect');
    } else if (response.statusCode == 404) {
      throw Exception('Utilisateur non trouvé');
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.clearSession();
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.apiBaseUrl}/users/logout'),
          headers: await getHeaders(),
        );

        if (response.statusCode != 200) {}
      } catch (e) {}
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  Future<User> updateProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/users/$userId'),
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
        Uri.parse('${AppConfig.apiBaseUrl}/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Échec de la récupération du user: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) async {
    final Uri url = Uri.parse(
      '${AppConfig.apiBaseUrl}/users/password-reset/changePassword?email=$email&password=$newPassword',
    );
    try {
      final response = await http.put(url, headers: await getHeaders());

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Mot de passe réinitialisé avec succès',
        };
      } else {
        return {
          'success': false,
          'message':
              'Erreur lors de la réinitialisation du mot de passe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  static Future<int?> numberOfBorrowsByUSer(String email) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/numberOfBorrows/$email'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Échec de la récupération du user: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<int?> numberOfBooksByUSer(String email) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/numberOfBooks/$email'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Échec de la récupération du user: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Récupère le top 10 des emprunteurs
  // Future<List<TopBorrower>> getTop10Borrowers() async {
  //   try {
  //     final headers = await getHeaders();
  //     final response = await http.get(
  //       Uri.parse('${AppConfig.apiBaseUrl}/users/top10emprunteur'),
  //       headers: headers,
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((item) => TopBorrower.fromJson(item)).toList();
  //     } else {
  //       throw Exception('Erreur serveur: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erreur réseau: $e');
  //   }
  // }
  // Dans AuthService
  Future<List<TopBorrower>> getTop10Borrowers() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/top10emprunteur'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TopBorrower.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
