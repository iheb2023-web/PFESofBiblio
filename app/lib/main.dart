// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:app/theme/app_theme.dart';
// import 'package:app/views/Authentification/onBoardingScreen.dart';
// import 'package:app/controllers/auth_controller.dart';
// import 'package:app/translations/app_translations.dart';
// import 'package:app/services/storage_service.dart';
// import 'package:app/views/NavigationMenu.dart';
// import 'package:app/bindings/app_binding.dart';
// import 'package:app/views/Ma_Biblio/mes_demandes.dart';
// import 'package:app/services/socket_service.dart';
// import 'package:app/services/notification_service.dart'; // NEW

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // ✅ on initialise le binding
//   //init notif service
//   NotiService().iniNotification(); // ✅ on initialise le service de notification

//   final storageService = StorageService();
//   await storageService.init();
//   final socketService = SocketService(isPhysicalDevice: false);
//   Get.put(socketService);
//   socketService.connect();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.put(AuthController());
//     final socketService = Get.find<SocketService>();

//     WidgetsBinding.instance.addObserver(_AppLifecycleObserver(socketService));

//     return GetMaterialApp(
//       title: 'SoftBiblio',
//       debugShowCheckedModeBanner: false,
//       translations: AppTranslations(),
//       locale: const Locale('fr', 'FR'),
//       fallbackLocale: const Locale('fr', 'FR'),
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       initialBinding: AppBinding(),
//       defaultTransition: Transition.fade,
//       initialRoute: '/onboarding',
//       getPages: [
//         GetPage(name: '/home', page: () => const NavigationMenu()),
//         GetPage(name: '/onboarding', page: () => const Onboardingscreen()),
//         GetPage(
//           name: '/mes-demandes',
//           page: () => MesDemandesPage(),
//           transition: Transition.rightToLeft,
//         ),
//       ],
//       home: Obx(
//         () =>
//             authController.currentUser.value != null
//                 ? const NavigationMenu()
//                 : const Onboardingscreen(),
//       ),
//       builder: (context, child) {
//         // NEW: Utilise la notification locale au lieu de Snackbar
//         final socketService = Get.find<SocketService>();
//         socketService.listenForBorrowRequestUpdates().listen((data) {
//           NotiService().showNotification(
//             title: 'Demande acceptée',
//             body: 'demande d’emprunt numéro "$data" a été acceptée.',
//           );
//         });

//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//           child: child!,
//         );
//       },
//     );
//   }
// }

// class _AppLifecycleObserver extends WidgetsBindingObserver {
//   final SocketService socketService;

//   _AppLifecycleObserver(this.socketService);

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.detached) {
//       socketService
//           .disconnect(); // Déconnexion lorsque l'application est fermée
//     }
//   }
// }
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
import 'package:app/services/socket_service.dart';
import 'package:app/services/notification_service.dart'; // ✅ Notification

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialiser les services
  NotiService().iniNotification();

  final storageService = StorageService();
  await storageService.init();

  final socketService = SocketService(isPhysicalDevice: false);
  Get.put(socketService);
  socketService.connect();

  // ✅ Écoute unique des mises à jour ici (pas dans builder !)
  socketService.listenForBorrowRequestUpdates().listen((data) {
    NotiService().showNotification(
      title: 'Demande acceptée',
      body: 'demande d’emprunt numéro "$data" a été acceptée.',
    );
  });

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
      socketService.disconnect();
    }
  }
}
