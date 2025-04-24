import 'package:app/models/preference.dart';
import 'package:app/services/storage_service.dart';
import 'package:get/get.dart'; // Pour accéder à StorageService

class TemporaryPreferenceData {
  String? preferredBookLength;
  List<String> favoriteGenres = [];
  List<String> preferredLanguages = [];
  List<String> favoriteAuthors = [];
  String? type;
  int? userId; // Champ pour stocker userId

  // Constructeur avec initialisation optionnelle de userId
  TemporaryPreferenceData({int? userId})
    : userId = userId ?? _getUserIdFromStorage();

  // Méthode pour récupérer userId depuis StorageService
  static int? _getUserIdFromStorage() {
    final storageService = Get.find<StorageService>();
    final userSession = storageService.getUserSession();
    return int.tryParse(userSession?['id']?.toString() ?? '');
  }

  Preference toPreference({int? userId}) {
    return Preference(
      preferredBookLength: preferredBookLength ?? '',
      favoriteGenres: favoriteGenres,
      preferredLanguages: preferredLanguages,
      favoriteAuthors: favoriteAuthors,
      type: type ?? '',
      userId: userId ?? this.userId, // Priorité au paramètre, sinon champ
    );
  }
}
