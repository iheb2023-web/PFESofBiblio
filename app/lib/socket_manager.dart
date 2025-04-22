// // lib/services/socket_manager.dart
// import 'imports.dart';

// class SocketManager {
//   static void initializeSocketListeners() {
//     final socketService = Get.find<SocketService>();
//     final _authController = Get.find<AuthController>();
//     final currentUser = _authController.currentUser.value;

//     if (currentUser == null) {
//       print("⚠️ Aucun utilisateur connecté.");
//       return;
//     }

//     final String userConnectedEmail = currentUser.email;
//     print("voici email de currentuser : $userConnectedEmail");
//     final borrowService = BorrowService();

//     // Écoute des mises à jour des demandes d'emprunt
//     socketService.listenForBorrowRequestUpdates().listen((borrowId) async {
//       try {
//         final borrow = await borrowService.getBorrowById(borrowId);

//         if (borrow.borrower?.email != userConnectedEmail) {
//           print(
//             "🔕 L'utilisateur connecté n'est pas concerné par cette demande.",
//           );
//           return;
//         }

//         if (borrow.book?.id != null) {
//           final ownerData = await BookService.getBookOwner(borrow.book!.id!);
//           final ownerName =
//               ownerData != null &&
//                       ownerData['firstname'] != null &&
//                       ownerData['lastname'] != null
//                   ? '${ownerData['firstname']} ${ownerData['lastname']}'
//                   : 'le propriétaire';

//           final bookTitle = borrow.book?.title ?? 'le titre du livre';
//           final BorrowStatus borrowStatus = borrow.borrowStatus;

//           print("📌 borrowStatus reçu : $borrowStatus");

//           if (borrowStatus == BorrowStatus.APPROVED) {
//             NotiService().showNotification(
//               title: 'Demande acceptée :)',
//               body: '$ownerName a accepté votre demande pour "$bookTitle".',
//               type: 'borrowApproved',
//             );
//           } else if (borrowStatus == BorrowStatus.REJECTED) {
//             NotiService().showNotification(
//               title: 'Demande refusée :(',
//               body: '$ownerName a refusé votre demande pour "$bookTitle".',
//               type: 'borrowRejected',
//             );
//           }
//         }
//       } catch (e) {
//         print('❌ Erreur dans la notification : $e');
//       }
//     });

//     // Écoute des nouvelles demandes
//     socketService.listenForDemandUpdates().listen((demandId) async {
//       try {
//         final borrow = await borrowService.getBorrowById(demandId);

//         if (borrow.borrower?.id != null) {
//           final demanderData = await AuthService.getUserById(
//             borrow.borrower!.id!,
//           );
//           final demanderName =
//               demanderData != null &&
//                       demanderData['firstname'] != null &&
//                       demanderData['lastname'] != null
//                   ? '${demanderData['firstname']} ${demanderData['lastname']}'
//                   : 'un utilisateur';

//           final bookTitle = borrow.book?.title ?? 'le titre du livre';

//           NotiService().showNotification(
//             title: 'Nouvelle demande',
//             body:
//                 '$demanderName a fait une nouvelle demande pour "$bookTitle".',
//             type: 'demand',
//           );
//         }
//       } catch (e) {
//         print('❌ Erreur dans la notification de demande : $e');
//       }
//     });
//   }
// }
