import 'package:app/models/temporary_prefernces.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/storage_service.dart'; // Ajouter StorageService
import 'package:get/get.dart';
import 'package:app/models/preference.dart';

class PreferenceController extends GetxController {
  final PreferenceService _preferenceService = PreferenceService();
  final StorageService _storageService =
      Get.find<StorageService>(); // Injecter StorageService
  var preferences = <Preference>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

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

      // Récupérer userId depuis StorageService
      final userSession = _storageService.getUserSession();
      final userId = int.tryParse(userSession?['id']?.toString() ?? '');
      if (userId == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Convertir les préférences en objet Preference
      final preference = tempPreference.value.toPreference(userId: userId);

      // Ajouter la préférence via PreferenceService
      final newPreference = await _preferenceService.addPreference(preference);
      preferences.add(newPreference);

      // Réinitialiser tempPreference
      tempPreference.value = TemporaryPreferenceData(userId: userId);

      Get.snackbar(
        'Succès',
        'Préférences enregistrées avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print(
        'Erreur lors de la soumission des préférences: $e',
      ); // Log pour débogage
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
    } catch (e) {
      errorMessage.value = e.toString();
      print(
        'Erreur lors du chargement des préférences: $e',
      ); // Log pour débogage
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
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print(
        'Erreur lors de l\'ajout de la préférence: $e',
      ); // Log pour débogage
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
