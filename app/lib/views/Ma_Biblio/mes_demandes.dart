import 'package:app/controllers/borrow_controller.dart';
import 'package:app/models/borrow.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MesDemandesPage extends StatelessWidget {
  final BorrowController _borrowController = Get.find<BorrowController>();

  MesDemandesPage({Key? key}) : super(key: key);

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
      case 'ACCEPTED':
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

  Widget _buildActionButtons(Borrow borrow) {
    if (borrow.borrowStatus.toString().split('.').last != 'PENDING') {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _borrowController.rejectRequest(borrow.id!),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.errorColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Refuser'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _borrowController.acceptRequest(borrow.id!),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Accepter'),
        ),
      ],
    );
  }

  Widget _buildBorrowCard(Borrow borrow) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vérifiez que les données sont bien affichées
            Text(
              'ID: ${borrow.id ?? 'Inconnu'}',
            ), // Ajout temporaire pour déboguer
            Text(
              'Titre: ${borrow.book?.title ?? 'Titre inconnu'}',
            ), // Ajout temporaire pour déboguer
            // En-tête avec l'avatar et les informations de l'emprunteur
            Row(
              children: [
                // Avatar de l'emprunteur
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    borrow.borrower?.firstname?.substring(0, 1).toUpperCase() ??
                        '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Informations de l'emprunteur et dates
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${borrow.borrower?.firstname ?? ''} ${borrow.borrower?.lastname ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Demande d\'emprunt',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Du ${_formatDate(borrow.borrowDate)} au ${_formatDate(borrow.expectedReturnDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Informations du livre
            Row(
              children: [
                // Image du livre
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      borrow.book?.coverUrl != null &&
                              borrow.book!.coverUrl.isNotEmpty
                          ? Image.network(
                            borrow.book!.coverUrl,
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 60,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.book,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Container(
                            width: 60,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, color: Colors.grey),
                          ),
                ),
                const SizedBox(width: 12),
                // Titre et auteur du livre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrow.book?.title ?? 'Titre inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        borrow.book?.author ?? 'Auteur inconnu',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _borrowController.acceptRequest(borrow.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        () => _borrowController.rejectRequest(borrow.id!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes d\'emprunt'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await _borrowController.loadOwnerRequests();
          } catch (e) {
            // Ensure Snackbar is shown only when context is valid
            if (context.mounted) {
              Get.snackbar(
                'Erreur',
                'Impossible de charger les demandes: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.8),
                colorText: Colors.white,
              );
            }
          }
        },
        child: Obx(() {
          if (_borrowController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_borrowController.ownerRequests.isEmpty) {
            print(
              'Aucune demande trouvée',
            ); // Log si aucune demande n'est trouvée
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune demande d\'emprunt',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          print(
            'Demandes trouvées: ${_borrowController.ownerRequests.length}',
          ); // Log des demandes trouvées
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _borrowController.ownerRequests.length,
            itemBuilder: (context, index) {
              final borrow = _borrowController.ownerRequests[index];
              print(
                'Affichage de la demande: ${borrow.id}, Status: ${borrow.borrowStatus}',
              ); // Log pour déboguer
              return _buildBorrowCard(borrow);
            },
          );
        }),
      ),
    );
  }
}
