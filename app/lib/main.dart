import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/views/Authentification/onBoardingScreen.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/translations/app_translations.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/views/NavigationMenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le service de stockage
  final storageService = StorageService();
  await storageService.init();

  // Initialiser le contrôleur de thème
  Get.put(ThemeController());

  // Initialiser le contrôleur d'authentification et attendre qu'il soit prêt
  final authController = Get.put(AuthController());
  await authController.checkAuthStatus(); // Attendre la vérification de la session

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) => GetMaterialApp(
        title: 'SoftBiblio',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: const Locale('fr', 'FR'),
        fallbackLocale: const Locale('fr', 'FR'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: authController.currentUser.value != null 
            ? const NavigationMenu() // Utiliser le NavigationMenu existant
            : const Onboardingscreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}
