import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/views/Authentification/Step/PageCountPreference.dart';
import 'package:app/controllers/preferences_controller.dart'; // Importez le contrôleur

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final PreferenceController _controller = Get.find();
  final List<Map<String, dynamic>> interests = [
    {'name': 'Fiction', 'icon': Icons.menu_book, 'selected': false},
    {'name': 'Science', 'icon': Icons.science, 'selected': false},
    {'name': 'Histoire', 'icon': Icons.history_edu, 'selected': false},
    {'name': 'Biographie', 'icon': Icons.person, 'selected': false},
    {'name': 'Fantaisie', 'icon': Icons.auto_stories, 'selected': false},
    {'name': 'Romance', 'icon': Icons.favorite, 'selected': false},
    {'name': 'Mystère', 'icon': Icons.visibility, 'selected': false},
    {'name': 'Horreur', 'icon': Icons.nightlight_round, 'selected': false},
    {'name': 'Science Fiction', 'icon': Icons.rocket_launch, 'selected': false},
    {'name': 'Poésie', 'icon': Icons.format_quote, 'selected': false},
    {'name': 'Voyage', 'icon': Icons.flight, 'selected': false},
    {'name': 'Santé', 'icon': Icons.local_hospital, 'selected': false},
    {'name': 'Cuisine', 'icon': Icons.restaurant, 'selected': false},
    {'name': 'Bandes', 'icon': Icons.theater_comedy, 'selected': false},
    {'name': 'Art', 'icon': Icons.palette, 'selected': false},
  ];

  int selectedCount = 0;
  void _saveSelectedGenres() {
    final selectedGenres =
        interests
            .where((interest) => interest['selected'] == true)
            .map((interest) => interest['name'] as String)
            .toList();

    _controller.updateTempPreference(favoriteGenres: selectedGenres);
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
              // Barre supérieure avec retour et skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const PageCountPreference());
                    },
                    child: Text(
                      'skip'.tr,
                      style: const TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Titre
              Text(
                'complete_profile'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Barre de progression
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 33, // Premier tiers en bleu
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 67, // Reste en gris
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Question
              Text(
                'what_interests'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Sous-titre
              Text(
                'select_multiple'.tr,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Grille d'intérêts
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    final interest = interests[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          interest['selected'] = !interest['selected'];
                          selectedCount += interest['selected'] ? 1 : -1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              interest['selected']
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                interest['selected']
                                    ? Colors.blue
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              interest['icon'],
                              color:
                                  interest['selected']
                                      ? Colors.blue
                                      : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              interest['name'],
                              style: TextStyle(
                                color:
                                    interest['selected']
                                        ? Colors.blue
                                        : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bouton Continuer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      selectedCount > 0
                          ? () {
                            _saveSelectedGenres();
                            Get.to(() => const PageCountPreference());
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'continue'.tr,
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
}
