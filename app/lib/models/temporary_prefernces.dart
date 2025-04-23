import 'package:app/models/preference.dart';

class TemporaryPreferenceData {
  String? preferredBookLength;
  List<String> favoriteGenres = [];
  List<String> preferredLanguages = [];
  List<String> favoriteAuthors = [];
  String? type;
  int? userId; // Ajoutez ce champ

  Preference toPreference({int? userId}) {
    return Preference(
      preferredBookLength: preferredBookLength ?? '',
      favoriteGenres: favoriteGenres,
      preferredLanguages: preferredLanguages,
      favoriteAuthors: favoriteAuthors,
      type: type ?? '',
      userId: userId ?? this.userId, // Utilisez le paramètre ou le champ
    );
  }
}
