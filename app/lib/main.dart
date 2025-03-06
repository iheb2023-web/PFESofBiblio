import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/theme/theme_controller.dart';
import 'package:app/views/Authentification/onBoardingScreen.dart';
import 'package:app/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le contrôleur de thème
  await Get.putAsync(() async => ThemeController());

  // Initialiser le contrôleur d'authentification
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SoftBiblio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Mode système par défaut
      home: const Onboardingscreen(),
    );
  }
}
