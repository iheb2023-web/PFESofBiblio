import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/views/Authentification/Step/ReadingHabits.dart';
import 'package:app/controllers/preferences_controller.dart'; // Import du contrôleur

class PageCountPreference extends StatefulWidget {
  const PageCountPreference({super.key});

  @override
  State<PageCountPreference> createState() => _PageCountPreferenceState();
}

class _PageCountPreferenceState extends State<PageCountPreference> {
  final PreferenceController _controller =
      Get.find(); // Récupération du contrôleur

  int? selectedOption;

  final List<Map<String, dynamic>> pageRanges = [
    {
      'title': 'less_100_pages'.tr,
      'subtitle': 'quick_reads'.tr,
      'range': '< 100',
    },
    {
      'title': '150_250_pages'.tr,
      'subtitle': 'medium_reads'.tr,
      'range': '150-250',
    },
    {
      'title': '300_400_pages'.tr,
      'subtitle': 'longer_reads'.tr,
      'range': '300-400',
    },
    {
      'title': 'more_400_pages'.tr,
      'subtitle': 'extensive_reads'.tr,
      'range': '400+',
    },
  ];
  void _savePreferredLength() {
    if (selectedOption != null) {
      final selectedRange = pageRanges[selectedOption!]['range'] as String;
      _controller.updateTempPreference(preferredBookLength: selectedRange);
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
                      Get.to(() => const ReadingHabits());
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
                      flex: 66, // Deux tiers en bleu
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 34, // Un tiers en gris
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Question
              Text(
                'how_many_pages'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Sous-titre
              Text(
                'choose_reading_length'.tr,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Options de nombre de pages
              Expanded(
                child: ListView.builder(
                  itemCount: pageRanges.length,
                  itemBuilder: (context, index) {
                    final option = pageRanges[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedOption = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                selectedOption == index
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color:
                                  selectedOption == index
                                      ? Colors.blue
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.book,
                                color:
                                    selectedOption == index
                                        ? Colors.blue
                                        : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            selectedOption == index
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option['subtitle'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            selectedOption == index
                                                ? Colors.blue.withOpacity(0.7)
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                      selectedOption != null
                          ? () {
                            _savePreferredLength(); // Sauvegarde la préférence
                            Get.to(() => const ReadingHabits());
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
