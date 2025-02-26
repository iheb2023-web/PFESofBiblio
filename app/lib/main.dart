import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onboarding App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display', // Police similaire à celle de l'iOS
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Illustration avec livres et éléments décoratifs
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Éléments décoratifs (croix et cercles)
                    Positioned(
                      top: 20,
                      left: 80,
                      child: Icon(Icons.close, color: Colors.cyan.shade300, size: 24),
                    ),
                    Positioned(
                      top: 40,
                      right: 100,
                      child: Icon(Icons.close, color: Colors.cyan.shade300, size: 24),
                    ),
                    Positioned(
                      top: 10,
                      right: 60,
                      child: Icon(Icons.add, color: Colors.blue.shade300, size: 24),
                    ),
                    Positioned(
                      left: 40,
                      bottom: 120,
                      child: Icon(Icons.add, color: Colors.blue.shade300, size: 24),
                    ),
                    // Cercles décoratifs
                    ...List.generate(
                      8,
                          (index) => Positioned(
                        left: 30.0 * index,
                        top: 70.0 + (index % 3) * 40,
                        child: Container(
                          width: 10 + (index % 3) * 5.0,
                          height: 10 + (index % 3) * 5.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    // Livres
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Livre violet
                        Container(
                          width: 50,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 20,
                                height: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Livre vert foncé
                        Container(
                          width: 60,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A3A40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                width: 40,
                                height: 10,
                                color: Colors.blue.shade300,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 40,
                                height: 10,
                                color: Colors.blue.shade300,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Livre bleu clair
                        Container(
                          width: 70,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Container(
                                width: 50,
                                height: 5,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 50,
                                height: 5,
                                color: Colors.white,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Livre bleu
                        Transform.rotate(
                          angle: 0.2,
                          child: Container(
                            width: 50,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Indicateurs de page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 4,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 4,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 4,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Texte
              Text(
                'Chaque livre trouve un nouveau lecteur',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Boutons
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Next',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}