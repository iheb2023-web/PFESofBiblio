import 'package:app/models/temporary_prefernces.dart';
import 'package:app/services/preferences_service.dart';
import 'package:get/get.dart';
import 'package:app/models/preference.dart';

class PreferenceController extends GetxController {
  final PreferenceService _preferenceService = PreferenceService();
  var preferences = <Preference>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  final tempPreference = TemporaryPreferenceData().obs;

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

  Future<void> submitPreference(int userId) async {
    final preference = tempPreference.value.toPreference(userId: userId);
    await addPreference(preference);
    tempPreference.value =
        TemporaryPreferenceData(); // Réinitialiser après soumission
  }

  Future<void> loadPreferences() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _preferenceService.getPreferences();
      preferences.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
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
        'Success',
        'Preference added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
