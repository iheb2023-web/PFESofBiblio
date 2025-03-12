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
      'question': 'when_prefer_read'.tr,
      'options': [
        {'text': 'morning'.tr, 'icon': Icons.wb_sunny},
        {'text': 'afternoon'.tr, 'icon': Icons.wb_cloudy},
        {'text': 'evening'.tr, 'icon': Icons.nights_stay},
        {'text': 'anytime'.tr, 'icon': Icons.access_time},
      ],
      'selected': null,
    },
    {
      'question': 'where_like_read'.tr,
      'options': [
        {'text': 'at_home'.tr, 'icon': Icons.home},
        {'text': 'in_transport'.tr, 'icon': Icons.directions_bus},
        {'text': 'in_cafe'.tr, 'icon': Icons.local_cafe},
        {'text': 'in_nature'.tr, 'icon': Icons.park},
      ],
      'selected': null,
    },
    {
      'question': 'how_choose_books'.tr,
      'options': [
        {'text': 'recommendations'.tr, 'icon': Icons.thumb_up},
        {'text': 'cover_summary'.tr, 'icon': Icons.menu_book},
        {'text': 'preferred_genre'.tr, 'icon': Icons.category},
        {'text': 'random'.tr, 'icon': Icons.shuffle},
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
                'last_step'.tr,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
}
