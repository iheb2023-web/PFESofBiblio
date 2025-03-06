import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/views/NavigationMenu.dart';

class ReadingHabits extends StatefulWidget {
  const ReadingHabits({super.key});

  @override
  State<ReadingHabits> createState() => _ReadingHabitsState();
}

class _ReadingHabitsState extends State<ReadingHabits> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Quand préférez-vous lire ?',
      'options': [
        {'text': 'Le matin', 'icon': Icons.wb_sunny},
        {'text': 'L\'après-midi', 'icon': Icons.wb_cloudy},
        {'text': 'Le soir', 'icon': Icons.nights_stay},
        {'text': 'À tout moment', 'icon': Icons.access_time},
      ],
      'selected': null,
    },
    {
      'question': 'Où aimez-vous lire ?',
      'options': [
        {'text': 'À la maison', 'icon': Icons.home},
        {'text': 'Dans les transports', 'icon': Icons.directions_bus},
        {'text': 'Dans un café', 'icon': Icons.local_cafe},
        {'text': 'Dans la nature', 'icon': Icons.park},
      ],
      'selected': null,
    },
    {
      'question': 'Comment choisissez-vous vos livres ?',
      'options': [
        {'text': 'Recommandations', 'icon': Icons.thumb_up},
        {'text': 'Couverture/Résumé', 'icon': Icons.menu_book},
        {'text': 'Genre préféré', 'icon': Icons.category},
        {'text': 'Au hasard', 'icon': Icons.shuffle},
      ],
      'selected': null,
    },
  ];

  bool get canContinue => questions.every((q) => q['selected'] != null);

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
                      Get.offAll(() => const NavigationMenu());
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
                'Dernière étape !',
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Questions et réponses
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 30),
                  itemBuilder: (context, questionIndex) {
                    final question = questions[questionIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['question'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: question['options'].length,
                          itemBuilder: (context, optionIndex) {
                            final option = question['options'][optionIndex];
                            final isSelected =
                                question['selected'] == optionIndex;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  question['selected'] = optionIndex;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.blue
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      option['icon'],
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        option['text'],
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.blue
                                                  : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bouton Terminer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      canContinue
                          ? () {
                            Get.offAll(() => const NavigationMenu());
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Terminer',
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
