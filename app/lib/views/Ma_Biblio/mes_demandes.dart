import 'package:app/controllers/borrow_controller.dart';
import 'package:app/models/borrow.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/services/borrow_service.dart';

class MesDemandesController extends GetxController {
  final BorrowController _borrowController = Get.find<BorrowController>();
  final AuthController _authController = Get.find<AuthController>();
  final BorrowService _borrowService = Get.find<BorrowService>();
  final _storageService = StorageService();
  var isLoading = true.obs;
  var pendingBorrows = <Borrow>[].obs;
  String? bookId; // Ajout d'un champ pour stocker l'ID du livre

  // Méthode pour initialiser avec un ID de livre
  void initWithBookId(String id) {
    bookId = id;
    initializeAndLoadDemandes();
  }

  @override
  void onInit() {
    super.onInit();
    initializeAndLoadDemandes();

    // Écouter les changements d'état de l'utilisateur
    ever(_authController.currentUser, (_) {
      loadDemandes();
    });

    // Rafraîchir automatiquement toutes les 30 secondes
    Future.delayed(const Duration(seconds: 30), () {
      loadDemandes();
    });
  }

  Future<void> initializeAndLoadDemandes() async {
    try {
      await _storageService.init();
      await loadDemandes();
    } catch (e) {}
  }

  void updatePendingBorrows(List<Borrow> borrows) {
    pendingBorrows.value =
        borrows.where((borrow) {
          final status = borrow.borrowStatus.toString().split('.').last;
          print('STATUT DEBUG ===> ${borrow.borrowStatus}');

          return status == 'PENDING' ||
              status == 'APPROVED' ||
              status == 'IN_PROGRESS';
        }).toList();
  }

  Future<void> returnBook(int borrowId) async {
    try {
      isLoading.value = true;
      await _borrowController.returnBook(borrowId); // Retourner le livre
      await loadDemandes(); // Recharger les demandes après le retour
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDemandes() async {
    try {
      isLoading.value = true;

      final email = _authController.currentUser.value?.email;
      if (email == null) {
        throw Exception('Utilisateur non connecté');
      }

      final borrows = await _borrowService.getBorrowDemandsByEmail(email);
      final filteredBorrows =
          bookId != null
              ? borrows.where((b) => b.book?.id.toString() == bookId).toList()
              : borrows;

      updatePendingBorrows(filteredBorrows);
    } catch (e) {
      pendingBorrows.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDemandes() async {
    await loadDemandes();
  }

  Future<void> handleBorrowRequest(Borrow borrow, bool isApproved) async {
    try {
      isLoading.value = true;
      await _borrowService.processBorrowRequest(borrow, isApproved);
      await loadDemandes(); // Recharger la liste après le traitement
      Get.snackbar(
        'Succès',
        isApproved ? 'Demande acceptée' : 'Demande refusée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de traiter la demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class MesDemandesPage extends StatelessWidget {
  final String? bookId; // Paramètre optionnel pour l'ID du livre
  final MesDemandesController controller = Get.put(MesDemandesController());

  MesDemandesPage({Key? key, this.bookId}) : super(key: key) {
    // Initialiser le contrôleur avec l'ID du livre si fourni
    if (bookId != null) {
      controller.initWithBookId(bookId!);
    } else {
      controller.initializeAndLoadDemandes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Demandes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshDemandes,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.pendingBorrows.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune demande en attente',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.pendingBorrows.length,
            itemBuilder: (context, index) {
              final borrow = controller.pendingBorrows[index];
              return _buildBorrowCard(borrow);
            },
          );
        }),
      ),
    );
  }

  Widget _buildBorrowCard(Borrow borrow) {
    final status = borrow.borrowStatus.toString().split('.').last;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du livre
                if (borrow.book?.coverUrl != null &&
                    borrow.book!.coverUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      borrow.book!.coverUrl,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[200],
                          child: Icon(Icons.book, color: Colors.grey[400]),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.book, color: Colors.grey[400]),
                  ),
                const SizedBox(width: 16),
                // Informations du livre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrow.book?.title ?? 'Titre inconnu',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (borrow.book?.author != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          borrow.book!.author,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],

                      if (borrow.borrower?.firstname != null ||
                          borrow.borrower?.lastname != null)
                        Text(
                          'Demandeur : ${borrow.borrower?.firstname ?? ''} ${borrow.borrower?.lastname ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Colors
                                    .blueGrey, // Choisis une couleur claire et lisible
                            fontWeight:
                                FontWeight.bold, // Mettre le texte en gras
                            // Optionnel : pour garder le style italique
                          ),
                        ),

                      const SizedBox(height: 8),

                      Text(
                        'Date de demande: ${borrow.requestDate != null ? DateFormat('dd/MM/yyyy').format(borrow.requestDate!) : 'Non spécifiée'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Date d\'emprunt: ${borrow.borrowDate != null ? DateFormat('dd/MM/yyyy').format(borrow.borrowDate!) : 'Non spécifiée'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Date de retour: ${borrow.expectedReturnDate != null ? DateFormat('dd/MM/yyyy').format(borrow.expectedReturnDate!) : 'Non spécifiée'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
           // Gestion des boutons en fonction du statut
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status == 'IN_PROGRESS' || status == 'APPROVED') ...[
              Text(
                status == 'IN_PROGRESS' 
                    ? 'En cours d\'emprunt' 
                    : 'Réservation approuvée',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status == 'IN_PROGRESS' ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
            ],
            status == 'PENDING'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => controller.handleBorrowRequest(borrow, true),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.successColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Accepter',
                          style: TextStyle(color: AppTheme.successColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => controller.handleBorrowRequest(borrow, false),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Refuser',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  )
                : status == 'IN_PROGRESS'
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => controller.returnBook(borrow.id!),
                          style: TextButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Marquer comme retourné',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
            ],
           ),
          ],
        ),
      ),
    );
  }
  Color _getStatusColor(String status) {
  switch (status) {
    case 'PENDING':
      return Colors.orange;
    case 'IN_PROGRESS':
      return Colors.blue;
    case 'RETURNED':
      return Colors.green;
    case 'REJECTED':
      return Colors.red;
    default:
      return Colors.blue;
  }
}
}
