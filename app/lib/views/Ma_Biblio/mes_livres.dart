import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/models/book.dart';
import 'package:app/services/book_service.dart';
import 'package:app/services/storage_service.dart';

class MesLivresController extends GetxController {
  var books = <Book>[].obs;
  var isLoading = true.obs;
  final _storageService = StorageService();
  final _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    print('MesLivresController: onInit called'); // Debug log
    initializeAndLoadBooks();

    // Écouter les changements d'état de l'utilisateur
    ever(_authController.currentUser, (_) {
      print('MesLivresController: Changement détecté dans currentUser');
      loadUserBooks();
    });

    // Rafraîchir automatiquement toutes les 30 secondes
    Future.delayed(const Duration(seconds: 30), () {
      loadUserBooks();
    });
  }

  // Méthode pour forcer le rafraîchissement
  Future<void> refreshBooks() async {
    print('MesLivresController: Rafraîchissement manuel des livres');
    await loadUserBooks();
  }

  Future<void> initializeAndLoadBooks() async {
    try {
      print('MesLivresController: Initializing storage service'); // Debug log
      await _storageService.init();
      await loadUserBooks();
    } catch (e) {
      print('MesLivresController: Error initializing: $e'); // Debug log
    }
  }

  Future<void> loadUserBooks() async {
    try {
      print('MesLivresController: Starting loadUserBooks'); // Debug log
      isLoading.value = true;

      // Vérifier d'abord la session stockée
      final userSession = _storageService.getUserSession();
      print(
        'MesLivresController: Session utilisateur: $userSession',
      ); // Debug log

      int? userId;

      // Essayer d'obtenir l'ID de l'utilisateur de la session d'abord
      if (userSession != null && userSession['id'] != null) {
        userId = int.parse(userSession['id'].toString());
        print(
          'MesLivresController: ID utilisateur trouvé dans la session: $userId',
        );
      }

      // Si pas d'ID dans la session, essayer depuis AuthController
      if (userId == null) {
        final currentUser = _authController.currentUser.value;
        if (currentUser?.id != null) {
          userId = currentUser!.id;
          print(
            'MesLivresController: ID utilisateur trouvé dans AuthController: $userId',
          );
        }
      }

      if (userId != null) {
        print(
          'MesLivresController: Chargement des livres pour l\'utilisateur $userId',
        );
        final fetchedBooks = await BookService.getBooksByUser(userId);
        print('MesLivresController: ${fetchedBooks.length} livres récupérés');
        books.value = fetchedBooks;
      } else {
        print('MesLivresController: Aucun ID utilisateur trouvé');
        books.value = [];
      }
    } catch (e) {
      print('MesLivresController: Erreur lors du chargement des livres: $e');
      books.value = [];
    } finally {
      isLoading.value = false;
    }
  }
}

class MesLivresPage extends GetView<ThemeController> {
  MesLivresPage({super.key}) {
    Get.put(MesLivresController());
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<MesLivresController>();

    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            body: RefreshIndicator(
              onRefresh: () => bookController.refreshBooks(),
              child: Obx(() {
                if (bookController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookController.books.isEmpty) {
                  return const Center(
                    child: Text(
                      'Vous n\'avez pas encore de livres dans votre bibliothèque',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookController.books.length,
                  itemBuilder: (context, index) {
                    final book = bookController.books[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBookCard(context, book: book),
                    );
                  },
                );
              }),
            ),
          ),
    );
  }

  Widget _buildBookCard(BuildContext context, {required Book book}) {
    final theme = Theme.of(context);
    final isDark = controller.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Book cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.coverUrl,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 30),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color:
                              isDark
                                  ? AppTheme.darkTextColor
                                  : AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              isDark
                                  ? AppTheme.darkSecondaryTextColor
                                  : AppTheme.lightSecondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              book.isAvailable
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.isAvailable ? 'Disponible' : 'Emprunté',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                book.isAvailable ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action buttons row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {}, // Static for now
                  child: Text(
                    'Modifier',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () {}, // Static for now
                  child: Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {}, // Static for now
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  label: Text(
                    'Voir les emprunts',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
