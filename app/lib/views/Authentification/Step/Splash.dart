import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Attendre 3 secondes puis naviguer vers l'écran principal (ex: login)
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login'); // ou '/home'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // couleur de fond
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou image de ton app
            Image.asset(
              'assets/logo.png', // assure-toi d'ajouter cette image dans pubspec.yaml
              height: 120,
            ),
            const SizedBox(height: 20),
            // Animation circulaire de chargement
            const CircularProgressIndicator(
              color: Colors.green, // adapter à ta palette
            ),
          ],
        ),
      ),
    );
  }
}
