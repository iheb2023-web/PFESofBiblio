import 'package:app/imports.dart';
import 'package:app/models/temporary_prefernces.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/models/preference.dart';

class PreferenceController extends GetxController {
  final PreferenceService _preferenceService = PreferenceService();
  final StorageService _storageService = Get.find<StorageService>();
  final AuthController _authController = Get.find<AuthController>();
  var preferences = <Preference>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasPreference = false.obs;

  final tempPreference = TemporaryPreferenceData().obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  void updateTempPreference({
    String? preferredBookLength,
    List<String>? favoriteGenres,
    List<String>? preferredLanguages,
    List<String>? favoriteAuthors,
    String? type,
  }) {
    tempPreference.update((val) {
      val?.preferredBookLength = preferredBookLength ?? val.preferredBookLength;
      val?.favoriteGenres = favoriteGenres ?? val.favoriteGenres;
      val?.preferredLanguages = preferredLanguages ?? val.preferredLanguages;
      val?.favoriteAuthors = favoriteAuthors ?? val.favoriteAuthors;
      val?.type = type ?? val.type;
    });
  }

  Future<void> submitPreference() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userSession = _storageService.getUserSession();
      final userId = int.tryParse(userSession?['id']?.toString() ?? '');
      if (userId == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      final preference = tempPreference.value.toPreference(userId: userId);
      final newPreference = await _preferenceService.addPreference(preference);
      preferences.add(newPreference);

      tempPreference.value = TemporaryPreferenceData(userId: userId);
      hasPreference.value = true;
      final currentUser = _authController.currentUser.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(hasPreference: true);
        final userData = {
          'id': updatedUser.id,
          'email': updatedUser.email,
          'hasPreference': updatedUser.hasPreference,
        };

        await _authController.updateUserProfile(userData);
      }

      Get.snackbar(
        'Succès',
        'Préférences enregistrées avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print('Erreur lors de la soumission des préférences: $e');
      Get.snackbar(
        'Erreur',
        'Échec de l\'enregistrement des préférences: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPreferences() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _preferenceService.getPreferences();
      preferences.assignAll(result);
      hasPreference.value = preferences.isNotEmpty;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Erreur lors du chargement des préférences: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPreference(Preference preference) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final newPreference = await _preferenceService.addPreference(preference);
      preferences.add(newPreference);

      Get.snackbar(
        'Succès',
        'Préférence ajoutée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print('Erreur lors de l\'ajout de la préférence: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
