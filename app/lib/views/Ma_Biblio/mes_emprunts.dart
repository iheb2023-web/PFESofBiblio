import 'package:app/controllers/borrow_controller.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/borrow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MesEmpruntsPage extends StatefulWidget {
  const MesEmpruntsPage({super.key});

  @override
  State<MesEmpruntsPage> createState() => _MesEmpruntsPageState();
}

class _MesEmpruntsPageState extends State<MesEmpruntsPage> {
  final BorrowController _borrowController = Get.find<BorrowController>();
  final AuthController _authController = Get.find<AuthController>();

  String selectedStatus = 'TOUS';

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

      case 'RETURNED':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        text = 'Terminé';
        break;

      case 'IN_PROGRESS':
        backgroundColor = const Color.fromARGB(255, 208, 208, 224)!;
        textColor = const Color.fromARGB(255, 70, 179, 194)!;
        text = 'En cours';
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
    final status = borrow.borrowStatus?.toString().split('.').last ?? 'UNKNOWN';
    final showCancelButton =
        status == 'PENDING' || status == 'APPROVED' || status == 'IN_PROGRESS';
    final isInProgress = status == 'IN_PROGRESS';

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
                      _buildBorrowStatus(status),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
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
            if (showCancelButton) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed:
                      () =>
                          isInProgress
                              ? _showCancelInProgressConfirmation(borrow)
                              : _showCancelConfirmation(borrow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isInProgress ? Colors.orange[50] : Colors.red[50],
                    foregroundColor:
                        isInProgress ? Colors.orange[800] : Colors.red[800],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                            isInProgress
                                ? Colors.orange[300]!
                                : Colors.red[300]!,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    isInProgress ? 'Annuler l\'emprunt' : 'Annuler la demande',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final userEmail = _authController.getCurrentUserEmail() ?? '';
    if (userEmail.isNotEmpty) {
      _borrowController.loadUserBorrows(userEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authController.getCurrentUserEmail() ?? '';

    if (userEmail.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes emprunts')),
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

    final filters = [
      {'label': 'Tous', 'value': 'TOUS'},
      {'label': 'En cours de lecture', 'value': 'IN_PROGRESS'},
      {'label': 'En attente', 'value': 'PENDING'},
      {'label': 'Accepté', 'value': 'APPROVED'},
      {'label': 'Terminé', 'value': 'RETURNED'},
      {'label': 'Refusé', 'value': 'REJECTED'},
    ];

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    filters.map((filter) {
                      final isSelected = selectedStatus == filter['value'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(
                            filter['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedStatus = filter['value']!;
                            });
                          },
                          selectedColor: Colors.blueAccent,
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? Colors.blueAccent
                                      : Colors.grey[400]!,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _borrowController.loadUserBorrows(userEmail),
        child: Obx(() {
          if (_borrowController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final borrows =
              selectedStatus == 'TOUS'
                  ? _borrowController.borrows
                  : _borrowController.borrows
                      .where(
                        (b) =>
                            b.borrowStatus?.toString().split('.').last ==
                            selectedStatus,
                      )
                      .toList();

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
              return _buildBorrowCard(borrows[index]);
            },
          );
        }),
      ),
    );
  }

  void _showCancelConfirmation(Borrow borrow) {
    final borrowController = Get.find<BorrowController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler l\'emprunt de "${borrow.book?.title ?? 'ce livre'}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Fermer le dialog
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Fermer le dialog
              await Future.delayed(
                const Duration(milliseconds: 150),
              ); // Laisse le temps à la fermeture

              try {
                await borrowController.cancelBorrow(borrow.id!);
              } catch (e) {}
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible:
          false, // L'utilisateur ne peut pas fermer en cliquant dehors
    );
  }

  void _showCancelInProgressConfirmation(Borrow borrow) {
    final borrowController = Get.find<BorrowController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler l\'emprunt en cours de "${borrow.book?.title ?? 'ce livre'}" ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back(); // Fermer la boîte
              await Future.delayed(
                const Duration(milliseconds: 150),
              ); // Petite pause pour assurer la fermeture

              try {
                await borrowController.cancelWhileInProgress(borrow.id!);
              } catch (e) {}
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false, // Pour éviter de fermer en cliquant dehors
    );
  }
}
