import 'package:app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/models/preference.dart';
import 'package:app/services/storage_service.dart';

class PreferenceService {
  final StorageService _storageService = StorageService();
  final String baseUrl = 'http://10.0.2.2:8080'; // Remplacez par votre URL

  Future<List<Preference>> getPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/preferences'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Preference.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load preferences: $e');
    }
  }

  Future<Preference> addPreference(Preference preference) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/preferences'),
        headers: await AuthService.getHeaders(),
        body: json.encode(preference.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Preference.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add preference: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add preference: $e');
    }
  }
}
