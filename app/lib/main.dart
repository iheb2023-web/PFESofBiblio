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

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize storage service
//   final storageService = StorageService();
//   await storageService.init();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.put(AuthController());

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
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//           child: child!,
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:app/theme/app_theme.dart';
// import 'package:app/views/Authentification/onBoardingScreen.dart';
// import 'package:app/controllers/auth_controller.dart';
// import 'package:app/translations/app_translations.dart';
// import 'package:app/services/storage_service.dart';
// import 'package:app/services/socket_service.dart';
// import 'package:app/views/NavigationMenu.dart';
// import 'package:app/bindings/app_binding.dart';
// import 'package:app/views/Ma_Biblio/mes_demandes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialiser les services
//   await Get.putAsync(() => StorageService().init());
//   await Get.putAsync(() => SocketService().init());

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.put(AuthController());

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
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//           child: child!,
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:app/theme/app_theme.dart';
// import 'package:app/services/socket_service.dart';
// import 'package:app/views/Authentification/onBoardingScreen.dart';
// import 'package:app/controllers/auth_controller.dart';
// import 'package:app/translations/app_translations.dart';
// import 'package:app/services/storage_service.dart';
// import 'package:app/views/NavigationMenu.dart';
// import 'package:app/bindings/app_binding.dart';
// import 'package:app/views/Ma_Biblio/mes_demandes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize storage service
//   final storageService = StorageService();
//   await storageService.init();

//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final SocketService socketService =
//       SocketService(); // Instance du service WebSocket
//   String message = ''; // Variable pour stocker le message de notification

//   @override
//   void initState() {
//     super.initState();
//     socketService.connect(); // Connexion WebSocket
//     socketService.listenForBorrowRequestUpdates().listen((data) {
//       setState(() {
//         message = 'L\'emprunt a été mis à jour : ${data['book']['title']}';
//       });
//     });
//   }

//   @override
//   void dispose() {
//     socketService.disconnect(); // Déconnexion WebSocket
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.put(AuthController());

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
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//           child: child!,
//         );
//       },
//     );
//   }

//   // Affichage des notifications directement dans le main
//   Widget buildNotification() {
//     return message.isEmpty
//         ? Center(child: Text('Aucune nouvelle notification.'))
//         : Center(child: Text(message, style: TextStyle(fontSize: 18)));
//   }
// }

import 'package:app/views/D%C3%A9tails_Livre/details_livre.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/services/socket_service.dart';
import 'package:app/views/Authentification/onBoardingScreen.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/translations/app_translations.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/views/NavigationMenu.dart';
import 'package:app/bindings/app_binding.dart';
import 'package:app/views/Ma_Biblio/mes_demandes.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('Main: Initialisation du StorageService');
  }
  final storageService = StorageService();
  await storageService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SocketService socketService = SocketService();
  String message = '';

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Main: Initialisation de _MyAppState');
    }

    socketService.connect();
    socketService.listenForBorrowRequestUpdates().listen(
      (data) {
        if (kDebugMode) {
          print('Main: Données reçues du WebSocket: $data');
          print('Main: Route actuelle: ${Get.currentRoute}');
        }
        message = 'La demande d\'emprunt #$data a été traitée';
        if (kDebugMode) {
          print('Main: Message de notification mis à jour: $message');
        }
        try {
          Get.snackbar(
            'Notification',
            message,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5), // Augmenter la durée
            margin: const EdgeInsets.all(20), // Plus de marge
            backgroundColor: Colors.blueAccent, // Couleur visible
            colorText: Colors.white,
            isDismissible: true,
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.easeInBack,
          );
          if (kDebugMode) {
            print('Main: Get.snackbar affiché avec succès');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Main: Erreur lors de l\'affichage de Get.snackbar: $e');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Main: Erreur dans le flux WebSocket: $error');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('Main: Flux WebSocket fermé');
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print('Main: Affichage d\'un Get.snackbar de test');
      }
      try {
        Get.snackbar(
          'Test',
          'Vérification du mécanisme de notification',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(20),
          backgroundColor: Colors.blueAccent,
          colorText: Colors.white,
        );
        if (kDebugMode) {
          print('Main: Get.snackbar de test affiché');
        }
      } catch (e) {
        if (kDebugMode) {
          print(
            'Main: Erreur lors de l\'affichage du Get.snackbar de test: $e',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('Main: Déconnexion et nettoyage');
    }
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Main: Construction du widget GetMaterialApp');
    }
    final authController = Get.put(AuthController());

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
      home: Builder(
        builder: (context) {
          if (kDebugMode) {
            print('Main: Construction du widget home');
          }
          return Obx(
            () =>
                authController.currentUser.value != null
                    ? const NavigationMenu()
                    : const Onboardingscreen(),
          );
        },
      ),
      builder: (context, child) {
        if (kDebugMode) {
          print('Main: Construction du MediaQuery');
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
