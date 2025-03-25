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

      // Obtenir l'utilisateur courant depuis AuthController
      final currentUser = _authController.currentUser.value;
      print('MesLivresController: Current user: ${currentUser?.toString()}'); // Debug log

      if (currentUser?.id != null) {
        print('MesLivresController: Fetching books for user ID: ${currentUser!.id}'); // Debug log
        final fetchedBooks = await BookService.getBooksByUser(currentUser.id!);
        print('MesLivresController: Fetched ${fetchedBooks.length} books'); // Debug log
        books.value = fetchedBooks;
      } else {
        print('MesLivresController: No current user or user ID'); // Debug log
        // Essayer de récupérer depuis la session comme fallback
        final userSession = _storageService.getUserSession();
        print('MesLivresController: User Session: $userSession'); // Debug log
        
        if (userSession != null && userSession['id'] != null) {
          final sessionUserId = int.parse(userSession['id'].toString());
          print('MesLivresController: Found user ID in session: $sessionUserId'); // Debug log
          final fetchedBooks = await BookService.getBooksByUser(sessionUserId);
          print('MesLivresController: Fetched ${fetchedBooks.length} books from session ID'); // Debug log
          books.value = fetchedBooks;
        } else {
          print('MesLivresController: No user ID found in session'); // Debug log
        }
      }
    } catch (e) {
      print('MesLivresController: Error loading books: $e'); // Debug log
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
      builder: (themeController) => Scaffold(
        appBar: AppBar(
          title: const Text('Mes Livres'),
        ),
        body: Obx(() {
          if (bookController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookController.books.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez pas encore de livres dans votre bibliothèque'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookController.books.length,
            itemBuilder: (context, index) {
              final book = bookController.books[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBookCard(
                  context,
                  book: book,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context, {
    required Book book,
  }) {
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
      child: InkWell(
        onTap: () {
          // Navigate to book details
          Get.toNamed('/book-details', arguments: book);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
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
                        color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.darkSecondaryTextColor : AppTheme.lightSecondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          book.isAvailable ? Icons.check_circle : Icons.error,
                          color: book.isAvailable ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.isAvailable ? 'Disponible' : 'Emprunté',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: book.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}