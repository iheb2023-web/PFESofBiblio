import 'imports.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de StorageService
  final storageService = StorageService();
  await storageService.init();

  // Initialisation de NotiService (pour Android uniquement)
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await NotiService().iniNotification();
    } catch (e) {
      debugPrint('⚠️ Notification init error: $e');
    }
  }

  // Initialisation de SocketService et connexion
  final socketService = SocketService(isPhysicalDevice: false);
  Get.put(socketService, permanent: true);
  socketService.connect();

  //Configuration des listeners pour les notifications locales
  final userSession = storageService.getUserSession();
  if (userSession != null) {
    final userId = int.tryParse(userSession['id']?.toString() ?? '');
    final userEmail = userSession['email']?.toString();

    if (userId != null) {
      // Listener pour les mises à jour des emprunts
      socketService.listenForBorrowRequestUpdates().listen((borrowId) async {
        try {
          final borrow = await BorrowService().getBorrowById(borrowId);
          if (borrow.borrower?.id != userId) return;

          final book = borrow.book;
          if (book?.id == null) return;

          final ownerData = await BookService.getBookOwner(book!.id!);
          final ownerName = _formatUserName(ownerData);
          final bookTitle = book.title ?? 'le titre du livre';

          switch (borrow.borrowStatus) {
            case BorrowStatus.APPROVED:
              await NotiService().showNotification(
                title: 'Demande acceptée :)',
                body: '$ownerName a accepté votre demande pour "$bookTitle".',
                type: 'borrowApproved',
              );
              break;
            case BorrowStatus.REJECTED:
              await NotiService().showNotification(
                title: 'Demande refusée :(',
                body: '$ownerName a refusé votre demande pour "$bookTitle".',
                type: 'borrowRejected',
              );
              break;
            default:
              break;
          }
        } catch (e) {
          debugPrint('❌ Borrow notification error: $e');
        }
      });

      // Listener pour les mises à jour des demandes
      if (userEmail != null) {
        socketService.listenForDemandUpdates().listen((demandId) async {
          try {
            final borrow = await BorrowService().getBorrowById(demandId);
            if (borrow.book?.id == null) return;

            final ownerData = await BookService.getBookOwner(borrow.book!.id!);
            if (ownerData?['email']?.toString() != userEmail) return;

            final borrower = await AuthService.getUserById(
              borrow.borrower!.id!,
            );
            final borrowerName = _formatUserName(borrower);
            final bookTitle = borrow.book?.title ?? 'le titre du livre';

            await NotiService().showNotification(
              title: 'Nouvelle demande',
              body: '$borrowerName a fait une demande pour "$bookTitle".',
              type: 'demand',
            );
          } catch (e) {
            debugPrint('❌ Demand notification error: $e');
          }
        });
      }
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final socketService = Get.find<SocketService>();

    // Ajouter l'observateur pour gérer la déconnexion du socket
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
      socketService
          .disconnect(); // Déconnexion lorsque l'application est fermée
    }
  }
}

// Utilitaire pour formater le nom de l'utilisateur
String _formatUserName(Map<String, dynamic>? userData) {
  return (userData != null &&
          userData['firstname'] != null &&
          userData['lastname'] != null)
      ? '${userData['firstname']} ${userData['lastname']}'
      : 'un utilisateur';
}
