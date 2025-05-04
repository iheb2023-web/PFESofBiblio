import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Gestion de la session
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    // Vérifier que l'ID est présent et valide
    if (userData['id'] == null) {
      throw Exception('ID utilisateur manquant dans les données');
    }

    // Convertir l'ID en entier si nécessaire
    final id =
        userData['id'] is int
            ? userData['id']
            : int.tryParse(userData['id'].toString());

    if (id == null) {
      throw Exception('ID utilisateur invalide');
    }

    // Sauvegarder les données complètes
    final jsonData = json.encode(userData);
    await _prefs.setString('user_session', jsonData);

    // Sauvegarder l'ID séparément pour un accès rapide
    await _prefs.setInt('user_id', id);
  }

  Map<String, dynamic>? getUserSession() {
    final String? data = _prefs.getString('user_session');

    if (data != null) {
      try {
        final Map<String, dynamic> sessionData = json.decode(data);

        // Vérifier que l'ID est présent
        if (sessionData['id'] == null) {
          return null;
        }

        // Vérifier que l'ID correspond à celui stocké séparément
        final savedId = _prefs.getInt('user_id');
        final sessionId =
            sessionData['id'] is int
                ? sessionData['id']
                : int.tryParse(sessionData['id'].toString());

        if (savedId != sessionId) {
          return null;
        }

        return sessionData;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int? getUserId() {
    return _prefs.getInt('user_id');
  }

  // Gestion de l'utilisateur complet
  Future<void> saveUser(String userData) async {
    await _prefs.setString('user_data', userData);
  }

  String? getUser() {
    return _prefs.getString('user_data');
  }

  // Nettoyage de la session
  Future<void> clearSession() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_session');
    await _prefs.remove('user_id');
    await _prefs.remove('user_data');
  }

  // Stockage des données utilisateur sous form de json
  Future<void> saveUserJson(Map<String, dynamic> userData) async {
    await _prefs.setString('user_data', json.encode(userData));
    try {
      final id =
          userData['id'] is int
              ? userData['id']
              : int.tryParse(userData['id'].toString());
      if (id != null) {
        await _prefs.setInt('user_id', id);
      }
    } catch (e) {}
  }

  Map<String, dynamic>? getUserJson() {
    final String? data = _prefs.getString('user_data');
    if (data != null) {
      try {
        return json.decode(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Stockage des livres favoris
  Future<void> saveFavoriteBooks(List<String> bookIds) async {
    await _prefs.setStringList('favorite_books', bookIds);
  }

  List<String> getFavoriteBooks() {
    return _prefs.getStringList('favorite_books') ?? [];
  }

  // Stockage des préférences de lecture
  Future<void> saveReadingPreferences(Map<String, dynamic> preferences) async {
    await _prefs.setString('reading_preferences', json.encode(preferences));
  }

  Map<String, dynamic>? getReadingPreferences() {
    final String? data = _prefs.getString('reading_preferences');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }
}
