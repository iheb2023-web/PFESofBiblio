import 'package:app/services/auth_service.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/models/preference.dart';
import 'package:app/services/storage_service.dart';
import 'package:get/get.dart';

class PreferenceService {
  final StorageService _storageService = StorageService();
  final String baseUrl = 'http://10.0.2.2:8080'; // Remplacez par votre URL

  // Pour gérer l'état (si vous voulez le garder dans le service)
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final hasPreference = false.obs;
  final preferences = <Preference>[].obs;

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

  Future<Preference?> getPreferenceByUserId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/preferences/$id'), // Correction du endpoint
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        return Preference.fromJson(json.decode(response.body));
      } else {}
    } catch (e) {
      print("Erreur dans getPreferenceByUserId: $e");
    }
    return null;
  }

  Future<void> loadUserPreference() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userSession = _storageService.getUserSession();
      final userId = int.tryParse(userSession?['id']?.toString() ?? '');
      if (userId == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      final userPreference = await getPreferenceByUserId(userId);

      if (userPreference != null) {
        preferences.assignAll([userPreference]);
        hasPreference.value = true;
      } else {
        hasPreference.value = false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  updatePreference(Preference preference) {}
}
