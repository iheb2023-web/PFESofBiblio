import 'package:app/controllers/borrow_controller.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/borrow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MesEmpruntsPage extends StatelessWidget {
  final BorrowController _borrowController = Get.find<BorrowController>();
  final AuthController _authController = Get.find<AuthController>();

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
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        text = 'En attente';
        break;
      case 'APPROVED':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        text = 'Accepté';
        break;
      case 'REJECTED':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        text = 'Refusé';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[900]!;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBorrowCard(Borrow borrow) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book),
                          ),
                    ),
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
                      const SizedBox(height: 8),
                      Text(
                        borrow.book?.author ?? 'Auteur inconnu',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      _buildBorrowStatus(
                        borrow.borrowStatus?.toString().split('.').last ??
                            'UNKNOWN',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date d\'emprunt',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDate(borrow.borrowDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date de retour prévue',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDate(borrow.expectedReturnDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
    // Utiliser l'email de l'utilisateur connecté
    final userEmail = _authController.getCurrentUserEmail() ?? '';

    // Vérifier si l'utilisateur est connecté
    if (userEmail.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes emprunts'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Veuillez vous connecter pour voir vos emprunts',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    // Charger les emprunts de l'utilisateur au chargement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _borrowController.loadUserBorrows(userEmail);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mes emprunts'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () => _borrowController.loadUserBorrows(userEmail),
        child: Obx(() {
          if (_borrowController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Utiliser la liste borrows du contrôleur
          final borrows = _borrowController.borrows;

          if (borrows.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun emprunt trouvé',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: borrows.length,
            itemBuilder: (context, index) {
              final borrow = borrows[index];
              return _buildBorrowCard(borrow);
            },
          );
        }),
      ),
    );
  }
}
