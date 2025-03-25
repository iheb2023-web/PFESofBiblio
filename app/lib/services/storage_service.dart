import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app/models/user_model.dart';

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
    print('StorageService: Sauvegarde des données utilisateur: $userData');
    await _prefs.setString('user_session', json.encode(userData));
    
    // Sauvegarder l'ID séparément pour un accès facile
    if (userData['id'] != null) {
      final id = userData['id'] is int ? userData['id'] : int.tryParse(userData['id'].toString());
      if (id != null) {
        print('StorageService: Sauvegarde de l\'ID utilisateur: $id');
        await _prefs.setInt('user_id', id);
      }
    }
  }

  Map<String, dynamic>? getUserSession() {
    final String? data = _prefs.getString('user_session');
    print('StorageService: Données de session brutes: $data');
    
    if (data != null) {
      try {
        final Map<String, dynamic> sessionData = json.decode(data);
        print('StorageService: Données de session décodées: $sessionData');
        
        // Récupérer l'ID séparé si nécessaire
        if (sessionData['id'] == null) {
          final userId = getUserId();
          if (userId != null) {
            sessionData['id'] = userId;
            print('StorageService: ID ajouté depuis le stockage séparé: $userId');
          }
        }
        
        return sessionData;
      } catch (e) {
        print('StorageService: Erreur lors de la lecture de la session: $e');
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
      final id = userData['id'] is int ? userData['id'] : int.tryParse(userData['id'].toString());
      if (id != null) {
        await _prefs.setInt('user_id', id);
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'ID utilisateur: $e');
    }
  }

  Map<String, dynamic>? getUserJson() {
    final String? data = _prefs.getString('user_data');
    if (data != null) {
      try {
        return json.decode(data);
      } catch (e) {
        print('Erreur lors de la lecture des données utilisateur: $e');
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