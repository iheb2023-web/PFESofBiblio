import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/views/profile/MultiSelectChip.dart';
import 'package:app/models/preference.dart';

class EditPreferencePage extends StatefulWidget {
  final Preference? preference;

  const EditPreferencePage({super.key, this.preference});

  @override
  State<EditPreferencePage> createState() => _EditPreferencePageState();
}

class _EditPreferencePageState extends State<EditPreferencePage> {
  late TextEditingController preferredBookLengthController;
  late TextEditingController authorsController;
  late TextEditingController typeController;
  List<String> selectedGenres = [];
  List<String> selectedLanguages = [];

  final PreferenceService _preferenceService = PreferenceService();
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final List<String> bookLengthOptions = [
    '< 100',
    '150-250',
    '300-400',
    '400+',
  ];
  final List<String> genreOptions = [
    'Fiction',
    'Science',
    'Fantaisie',
    'Histoire',
    'Biographie',
    'Romance',
    'Mystère',
    'Horreur',
    'Science Fiction',
    'Poésie',
    'Voyage',
    'Santé',
    'Cuisine',
    'Bandes',
    'Art',
  ];
  final List<String> languageOptions = ['Français', 'Anglais', 'العربية'];

  @override
  void initState() {
    super.initState();
    preferredBookLengthController = TextEditingController();
    authorsController = TextEditingController();
    typeController = TextEditingController();

    if (widget.preference != null) {
      _initializeFields(widget.preference!);
    } else {
      _loadPreferences();
    }
  }

  void _initializeFields(Preference pref) {
    preferredBookLengthController.text = pref.preferredBookLength ?? '';
    selectedGenres = pref.favoriteGenres ?? [];
    selectedLanguages = pref.preferredLanguages ?? [];
    authorsController.text = (pref.favoriteAuthors ?? []).join(', ');
    typeController.text = pref.type ?? '';
  }

  Future<void> _loadPreferences() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    try {
      await _preferenceService.loadUserPreference();
      final preference = _preferenceService.preferences.firstOrNull;
      if (preference != null) {
        _initializeFields(preference);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les préférences: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    preferredBookLengthController.dispose();
    authorsController.dispose();
    typeController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = _authController.currentUser.value;
      if (user == null) throw Exception('Utilisateur non connecté');

      final favoriteAuthors =
          authorsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final preference = Preference(
        id: widget.preference?.id,
        preferredBookLength: preferredBookLengthController.text,
        favoriteGenres: selectedGenres,
        preferredLanguages: selectedLanguages,
        favoriteAuthors: favoriteAuthors,
        type: typeController.text,
        userId: user.id,
      );

      if (widget.preference == null) {
        await _preferenceService.addPreference(preference);
      } else {
        await _preferenceService.updatePreference(preference);
      }

      Get.back(result: preference);
      Get.snackbar(
        'Succès',
        'Préférences enregistrées avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer les préférences: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.preference == null
              ? 'Ajouter des préférences'
              : 'Modifier les préférences',
        ),
      ),
      body:
          isLoading && widget.preference == null
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Longueur de livre préférée'),
                      // Dans votre build method, modifiez le DropdownButtonFormField comme suit :
                      DropdownButtonFormField<String>(
                        value:
                            preferredBookLengthController.text.isEmpty
                                ? null
                                : bookLengthOptions.contains(
                                  preferredBookLengthController.text,
                                )
                                ? preferredBookLengthController.text
                                : null,
                        items:
                            bookLengthOptions.map((length) {
                              return DropdownMenuItem<String>(
                                value: length,
                                child: Text(length),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              preferredBookLengthController.text = value;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Sélectionnez une longueur',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null ? 'Ce champ est requis' : null,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Genres favoris'),
                      MultiSelectChip(
                        allItems: genreOptions,
                        selectedItems: selectedGenres,
                        onSelectionChanged:
                            (selected) =>
                                setState(() => selectedGenres = selected),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Langues préférées'),
                      MultiSelectChip(
                        allItems: languageOptions,
                        selectedItems: selectedLanguages,
                        onSelectionChanged:
                            (selected) =>
                                setState(() => selectedLanguages = selected),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Auteurs favoris'),
                      TextFormField(
                        controller: authorsController,
                        decoration: InputDecoration(
                          hintText:
                              'Saisissez les auteurs séparés par des virgules',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Type de lecture préféré'),
                      TextFormField(
                        controller: typeController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Papier, Numérique, Audio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _savePreferences,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Enregistrer les préférences'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
