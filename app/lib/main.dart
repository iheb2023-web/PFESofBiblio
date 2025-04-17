import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/views/Authentification/onBoardingScreen.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/translations/app_translations.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/views/NavigationMenu.dart';
import 'package:app/bindings/app_binding.dart';
import 'package:app/views/Ma_Biblio/mes_demandes.dart';
import 'package:app/services/socket_service.dart'; // Importez le SocketService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();
  final socketService = SocketService(isPhysicalDevice: false);
  Get.put(socketService);
  socketService.connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final socketService = Get.find<SocketService>();

    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(socketService));

    return GetMaterialApp(
      title: 'SoftBiblio',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBinding(),
      defaultTransition: Transition.fade,
      initialRoute: '/onboarding',
      getPages: [
        GetPage(name: '/home', page: () => const NavigationMenu()),
        GetPage(name: '/onboarding', page: () => const Onboardingscreen()),
        GetPage(
          name: '/mes-demandes',
          page: () => MesDemandesPage(),
          transition: Transition.rightToLeft,
        ),
      ],
      home: Obx(
        () =>
            authController.currentUser.value != null
                ? const NavigationMenu()
                : const Onboardingscreen(),
      ),
      builder: (context, child) {
        // Ajouter un listener pour les notifications Socket
        final socketService = Get.find<SocketService>();
        socketService.listenForBorrowRequestUpdates().listen((data) {
          //Afficher une notification (SnackBar) lorsque des données sont reçues
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Votre demande d’emprunt numero : "$data" a été acceptée.',
              ),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.green,
            ),
          );
          //   Get.snackbar(
          //     'Demande acceptée ✅',
          //     'Votre demande d’emprunt numéro "$data" a été acceptée.',
          //     snackPosition: SnackPosition.TOP,
          //     backgroundColor: Colors.green,
          //     colorText: Colors.white,
          //     duration: const Duration(seconds: 4),
          //     margin: const EdgeInsets.all(12),
          //     borderRadius: 10,
          //     icon: const Icon(Icons.check_circle, color: Colors.white),
          //   );
        });

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final SocketService socketService;

  _AppLifecycleObserver(this.socketService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      socketService
          .disconnect(); // Déconnexion lorsque l'application est fermée
    }
  }
}
