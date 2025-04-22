import 'package:flutter/foundation.dart';
import 'imports.dart';

class AppInitializer {
  /// Initialisation critique (avant runApp)
  static Future<void> initializeCriticalServices() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Seul le strict nécessaire pour le démarrage
    await _initializeStorageInIsolate();
  }

  /// Initialisation non critique (après le premier frame)
  static Future<void> initializeNonCriticalServices() async {
    await _initNotificationService();
    await _initSocketAndUserDependentServices();
  }

  // --- Méthodes privées --- //

  static Future<void> _initializeStorageInIsolate() async {
    if (kIsWeb) {
      await StorageService().init(); // Pas d'isolate sur le web
    } else {
      await compute((_) async => await StorageService().init(), null);
    }
  }

  static Future<void> _initNotificationService() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await NotiService().iniNotification();
      }
    } catch (e) {
      debugPrint('⚠️ Notification init error: $e');
    }
  }

  static Future<void> _initSocketAndUserDependentServices() async {
    final storageService = StorageService();
    final userSession = storageService.getUserSession();

    if (userSession == null) return;

    final userId = _parseUserId(userSession);
    final userEmail = userSession['email']?.toString();

    if (userId != null) {
      final socketService = SocketService(isPhysicalDevice: false);
      Get.put(socketService, permanent: true);

      // Connexion différée pour réduire l'impact
      Future.delayed(const Duration(milliseconds: 500), () {
        socketService.connect();
        _setupSocketListeners(socketService, userId, userEmail);
      });
    }
  }

  static int? _parseUserId(Map<String, dynamic> userSession) {
    try {
      return int.tryParse(userSession['id'].toString());
    } catch (e) {
      debugPrint('❌ User ID parsing error: $e');
      return null;
    }
  }

  static void _setupSocketListeners(
    SocketService socketService,
    int userId,
    String? userEmail,
  ) {
    _setupBorrowListeners(socketService, userId);
    _setupDemandListeners(socketService, userEmail);
  }

  static void _setupBorrowListeners(SocketService socketService, int userId) {
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
  }

  static void _setupDemandListeners(
    SocketService socketService,
    String? userEmail,
  ) {
    socketService.listenForDemandUpdates().listen((demandId) async {
      try {
        final borrow = await BorrowService().getBorrowById(demandId);
        if (borrow.book?.id == null) return;

        final ownerData = await BookService.getBookOwner(borrow.book!.id!);
        if (ownerData?['email']?.toString() != userEmail) return;

        final borrower = await AuthService.getUserById(borrow.borrower!.id!);
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

  static String _formatUserName(Map<String, dynamic>? userData) {
    return (userData != null &&
            userData['firstname'] != null &&
            userData['lastname'] != null)
        ? '${userData['firstname']} ${userData['lastname']}'
        : 'un utilisateur';
  }
}
