import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/views/NavigationMenu.dart';
import 'package:app/controllers/preferences_controller.dart'; // Importez le contrôleur

class ReadingHabits extends StatefulWidget {
  const ReadingHabits({super.key});

  @override
  State<ReadingHabits> createState() => _ReadingHabitsState();
}

class _ReadingHabitsState extends State<ReadingHabits> {
  final PreferenceController _controller = Get.find();

  // Selected language
  String? selectedLanguage;
  String? readingType;
  final TextEditingController otherAuthorController = TextEditingController();
  // Famous authors list with selection status
  final List<Map<String, dynamic>> famousAuthors = [
    {'name': 'Victor Hugo', 'selected': false},
    {'name': 'William Shakespeare', 'selected': false},
    {'name': 'Naguib Mahfouz', 'selected': false},
    {'name': 'Albert Camus', 'selected': false},
    {'name': 'Agatha Christie', 'selected': false},
  ];

  bool get canContinue =>
      selectedLanguage != null &&
      (famousAuthors.any((author) => author['selected']) ||
          otherAuthorController.text.isNotEmpty) &&
      readingType != null;

  @override
  void dispose() {
    otherAuthorController.dispose();
    super.dispose();
  }

  Future<void> _saveAllPreferences() async {
    try {
      // 1. Langues préférées
      if (selectedLanguage != null) {
        _controller.updateTempPreference(
          preferredLanguages: [selectedLanguage!],
        );
        print('Langues enregistrées: $selectedLanguage');
      }

      // 2. Auteurs préférés
      final selectedAuthors =
          famousAuthors
              .where((author) => author['selected'] == true)
              .map((author) => author['name'] as String)
              .toList();

      if (otherAuthorController.text.isNotEmpty) {
        selectedAuthors.add(otherAuthorController.text);
      }

      _controller.updateTempPreference(favoriteAuthors: selectedAuthors);
      print('Auteurs enregistrés: $selectedAuthors');

      // 3. Type de lecture
      if (readingType != null) {
        _controller.updateTempPreference(type: readingType!);
        print('Type enregistré: $readingType');
      }

      // Soumission finale
      await _controller.submitPreference(); // Pas besoin de passer userId

      print('Préférences soumises avec succès');
      Get.offAll(() => const NavigationMenu());
    } catch (e) {
      print('Erreur lors de l\'enregistrement des préférences: $e');
      Get.snackbar('Erreur', 'Échec de l\'enregistrement des préférences: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back and skip buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.offAll(() => const NavigationMenu());
                    },
                    child: Text(
                      'skip'.tr,
                      style: const TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Préférences de lecture'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Progress bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Preferred reading language
                      Text(
                        'Langue préférée'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildLanguageOption('Français', Icons.language),
                          const SizedBox(width: 10),
                          _buildLanguageOption('English', Icons.language),
                          const SizedBox(width: 10),
                          _buildLanguageOption('العربية', Icons.language),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 2. Preferred authors
                      Text(
                        'Auteurs préférés'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Famous authors list
                      ...famousAuthors.map(
                        (author) => _buildAuthorCheckbox(author),
                      ),

                      // Other author text field
                      const SizedBox(height: 10),
                      TextField(
                        controller: otherAuthorController,
                        decoration: InputDecoration(
                          hintText: 'Autre auteur'.tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 30),

                      // 3. Reading type preference
                      Text(
                        'Type de lecture'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildReadingTypeOption(
                            'moderne'.tr,
                            Icons.trending_up,
                          ),
                          const SizedBox(width: 10),
                          _buildReadingTypeOption(
                            'classique'.tr,
                            Icons.history,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Finish button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      canContinue
                          ? () async {
                            await _saveAllPreferences();
                            Get.offAll(() => const NavigationMenu());
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'finish'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build language selection option
  Widget _buildLanguageOption(String language, IconData icon) {
    final isSelected = selectedLanguage == language;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedLanguage = language;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  language,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build author checkbox
  Widget _buildAuthorCheckbox(Map<String, dynamic> author) {
    return CheckboxListTile(
      title: Text(author['name']),
      value: author['selected'],
      onChanged: (value) {
        setState(() {
          author['selected'] = value;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Helper method to build reading type option
  Widget _buildReadingTypeOption(String type, IconData icon) {
    final isSelected = readingType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            readingType = type;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
