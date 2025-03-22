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
    await _prefs.setString('user_session', json.encode(userData));
  }

  Map<String, dynamic>? getUserSession() {
    final String? data = _prefs.getString('user_session');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  Future<void> clearSession() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_session');
  }

  // Stockage des données utilisateur sous form de json
  Future<void> saveUser(String userJson) async {
    await _prefs.setString('user_data', userJson);
  }

  String? getUser() {
    return _prefs.getString('user_data');
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