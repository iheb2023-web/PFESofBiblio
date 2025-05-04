import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/models/book.dart';
import 'package:app/services/book_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/views/Ma_Biblio/mes_demandes.dart';

class MesLivresController extends GetxController {
  var books = <Book>[].obs;
  var isLoading = true.obs;
  final _storageService = StorageService();
  final _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    initializeAndLoadBooks();

    // Écouter les changements d'état de l'utilisateur
    ever(_authController.currentUser, (_) {
      loadUserBooks();
    });

    // Rafraîchir automatiquement toutes les 30 secondes
    Future.delayed(const Duration(seconds: 30), () {
      loadUserBooks();
    });
  }

  // Méthode pour forcer le rafraîchissement
  Future<void> refreshBooks() async {
    await loadUserBooks();
  }

  Future<void> initializeAndLoadBooks() async {
    try {
      await _storageService.init();
      await loadUserBooks();
    } catch (e) {}
  }

  Future<void> loadUserBooks() async {
    try {
      isLoading.value = true;

      // Vérifier d'abord la session stockée
      final userSession = _storageService.getUserSession();

      int? userId;

      // Essayer d'obtenir l'ID de l'utilisateur de la session d'abord
      if (userSession != null && userSession['id'] != null) {
        userId = int.parse(userSession['id'].toString());
      }

      // Si pas d'ID dans la session, essayer depuis AuthController
      if (userId == null) {
        final currentUser = _authController.currentUser.value;
        if (currentUser?.id != null) {
          userId = currentUser!.id;
        }
      }

      if (userId != null) {
        final fetchedBooks = await BookService.getBooksByUser(userId);
        books.value = fetchedBooks;
      } else {
        books.value = [];
      }
    } catch (e) {
      books.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteBook(int bookId) async {
    try {
      isLoading.value = true;
      final success = await BookService.deleteBook(bookId);

      if (success) {
        books.removeWhere((book) => book.id == bookId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Book?> updateBook(int bookId, Map<String, dynamic> bookData) async {
    try {
      isLoading.value = true;
      final updatedBook = await BookService.updateBook(bookId, bookData);

      if (updatedBook != null) {
        // Mettre à jour le livre dans la liste locale
        final index = books.indexWhere((book) => book.id == bookId);
        if (index != -1) {
          books[index] = updatedBook;
        }

        return updatedBook;
      } else {
        return null;
      }
    } catch (e) {
      return null;
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
            appBar: AppBar(elevation: 0, toolbarHeight: 10),
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
                  onPressed: () => _showEditDialog(context, book),
                  child: Text(
                    'Modifier',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () => _showDeleteConfirmation(context, book),
                  child: Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed:
                      () => Get.to(
                        () => MesDemandesPage(bookId: book.id.toString()),
                      ),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  label: Text(
                    'Consulter les demandes',
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

  void _showDeleteConfirmation(BuildContext context, Book book) {
    final bookController = Get.find<MesLivresController>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${book.title}" de votre bibliothèque ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (book.id != null) {
                  final success = await bookController.deleteBook(book.id!);

                  final snackBarText =
                      success
                          ? 'Livre supprimé avec succès'
                          : 'Échec de la suppression du livre';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(snackBarText),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Book book) {
    final bookController = Get.find<MesLivresController>();
    final _formKey = GlobalKey<FormState>();

    // Contrôleurs pour les champs de formulaire
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final descriptionController = TextEditingController(text: book.description);
    final coverUrlController = TextEditingController(text: book.coverUrl);
    final publishedDateController = TextEditingController(
      text: book.publishedDate,
    );
    final isbnController = TextEditingController(text: book.isbn);
    final categoryController = TextEditingController(text: book.category);
    final pageCountController = TextEditingController(
      text: book.pageCount.toString(),
    );
    final languageController = TextEditingController(text: book.language);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier le livre'),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextFormField(
                    controller: titleController,
                    label: 'Titre*',
                    icon: Icons.title,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Le titre est requis'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: authorController,
                    label: 'Auteur*',
                    icon: Icons.person,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'L\'auteur est requis'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: coverUrlController,
                    label: 'URL de la couverture',
                    icon: Icons.link,
                  ),
                  if (coverUrlController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        coverUrlController.text,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: publishedDateController,
                    label: 'Date de publication',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: isbnController,
                    label: 'ISBN',
                    icon: Icons.numbers,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: categoryController,
                    label: 'Catégorie',
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: pageCountController,
                    label: 'Nombre de pages',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: languageController,
                    label: 'Langue',
                    icon: Icons.language,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (book.id != null) {
                    // Préparer les données à mettre à jour
                    final bookData = {
                      'title': titleController.text,
                      'author': authorController.text,
                      'description': descriptionController.text,
                      'coverUrl': coverUrlController.text,
                      'publishedDate': publishedDateController.text,
                      'isbn': isbnController.text,
                      'category': categoryController.text,
                      'pageCount': int.tryParse(pageCountController.text) ?? 0,
                      'language': languageController.text,
                    };

                    Navigator.of(context).pop();

                    // Effectuer la mise à jour avec gestion des erreurs
                    try {
                      final updatedBook = await bookController.updateBook(
                        book.id!,
                        bookData,
                      );
                      Get.snackbar(
                        updatedBook != null ? 'Succès' : 'Erreur',
                        updatedBook != null
                            ? 'Livre mis à jour avec succès'
                            : 'Échec de la mise à jour du livre',
                        backgroundColor:
                            updatedBook != null
                                ? Colors.green.withOpacity(0.9)
                                : Colors.red.withOpacity(0.9),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Erreur',
                        'Une erreur s\'est produite : $e',
                        backgroundColor: Colors.red.withOpacity(0.9),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  }
                }
              },
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
