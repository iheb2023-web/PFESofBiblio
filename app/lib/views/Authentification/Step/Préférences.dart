import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/views/Authentification/Step/PageCountPreference.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // Liste étendue des intérêts avec leurs icônes
  final List<Map<String, dynamic>> interests = [
    {'name': 'Technologie', 'icon': Icons.computer, 'selected': false},
    {'name': 'Design', 'icon': Icons.brush, 'selected': false},
    {'name': 'Business', 'icon': Icons.business, 'selected': false},
    {'name': 'Fitness', 'icon': Icons.fitness_center, 'selected': false},
    {'name': 'Musique', 'icon': Icons.music_note, 'selected': false},
    {'name': 'Écriture', 'icon': Icons.edit, 'selected': false},
    {'name': 'Photo', 'icon': Icons.camera_alt, 'selected': false},
    {'name': 'Gaming', 'icon': Icons.sports_esports, 'selected': false},
    {'name': 'Cuisine', 'icon': Icons.restaurant, 'selected': false},
    {'name': 'Voyage', 'icon': Icons.flight, 'selected': false},
    {'name': 'Science', 'icon': Icons.science, 'selected': false},
    {'name': 'Art', 'icon': Icons.palette, 'selected': false},
    {'name': 'Sport', 'icon': Icons.sports_basketball, 'selected': false},
    {'name': 'Nature', 'icon': Icons.eco, 'selected': false},
    {'name': 'Cinéma', 'icon': Icons.movie, 'selected': false},
  ];

  int selectedCount = 0;

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
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Titre
              const Text(
                'Complétez votre profil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              const Text(
                "C'est quoi votre intérêt ?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Sous-titre
              const Text(
                'Vous pouvez choisir plusieurs options',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Grille d'intérêts
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
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
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                interest['selected']
                                    ? Colors.blue
                                    : Colors.transparent,
                            width: 2,
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
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              interest['name'],
                              style: TextStyle(
                                color:
                                    interest['selected']
                                        ? Colors.blue
                                        : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
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
                            Get.to(() => const PageCountPreference());
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
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
