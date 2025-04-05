import 'package:app/controllers/borrow_controller.dart';
import 'package:app/models/borrow.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/controllers/auth_controller.dart';

class MesEmpruntsController extends GetxController {
  final BorrowController _borrowController = Get.find<BorrowController>();
  final AuthController _authController = Get.find<AuthController>();
  final _storageService = StorageService();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    print('MesEmpruntsController: onInit called');
    initializeAndLoadBorrows();

    // Écouter les changements d'état de l'utilisateur
    ever(_authController.currentUser, (_) {
      print('MesEmpruntsController: Changement détecté dans currentUser');
      loadBorrows();
    });

    // Rafraîchir automatiquement toutes les 30 secondes
    Future.delayed(const Duration(seconds: 30), () {
      loadBorrows();
    });
  }

  Future<void> initializeAndLoadBorrows() async {
    try {
      print('MesEmpruntsController: Initializing storage service');
      await _storageService.init();
      await loadBorrows();
    } catch (e) {
      print('MesEmpruntsController: Error initializing: $e');
    }
  }

  Future<void> loadBorrows() async {
    try {
      print('MesEmpruntsController: Starting loadBorrows');
      isLoading.value = true;

      final email = _authController.currentUser.value?.email;
      if (email == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('MesEmpruntsController: Loading borrows for user: $email');
      await _borrowController.loadAllBorrows();
    } catch (e) {
      print('MesEmpruntsController: Error loading borrows: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBorrows() async {
    print('MesEmpruntsController: Manual refresh of borrows');
    await loadBorrows();
  }
}

class MesEmpruntsPage extends StatelessWidget {
  final MesEmpruntsController _controller = Get.put(MesEmpruntsController());
  final BorrowController _borrowController = Get.find<BorrowController>();

  MesEmpruntsPage({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non spécifié';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildBorrowStatus(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'PENDING':
        backgroundColor = AppTheme.warningColor.withOpacity(0.1);
        textColor = AppTheme.warningColor;
        text = 'En attente';
        break;
      case 'APPROVED':
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        textColor = AppTheme.successColor;
        text = 'Accepté';
        break;
      case 'REJECTED':
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        textColor = AppTheme.errorColor;
        text = 'Refusé';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[900]!;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Mes Emprunts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refreshBorrows(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final borrows = _borrowController.userBorrows;
        
        if (borrows.isEmpty) {
          return const Center(
            child: Text('Vous n\'avez aucun emprunt en cours'),
          );
        }

        return ListView.builder(
          itemCount: borrows.length,
          itemBuilder: (context, index) {
            final borrow = borrows[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image de couverture
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: borrow.book?.coverUrl != null && borrow.book!.coverUrl.isNotEmpty
                          ? Image.network(
                              borrow.book!.coverUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(Icons.book, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(Icons.book, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Informations du livre
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            borrow.book?.title ?? 'Livre inconnu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (borrow.book?.author != null)
                            Text(
                              borrow.book!.author,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text('Date de demande: ${_formatDate(borrow.requestDate)}'),
                          Text('Date de retour prévue: ${_formatDate(borrow.expectedReturnDate)}'),
                          const SizedBox(height: 4),
                          _buildBorrowStatus(borrow.borrowStatus.toString().split('.').last),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
