import 'package:app/imports.dart';
import 'package:app/models/book.dart';

class BookController extends GetxController {
  final RxList<Book> allBooks = <Book>[].obs;
  final RxList<Book> books = <Book>[].obs;
  final RxList<Book> userBooks = <Book>[].obs;
  final RxList<Book> popularBooks = <Book>[].obs;
  final RxList<Book> recommendedBooks = <Book>[].obs;
  final RxList<Book> newBooks = <Book>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadAllBooks();
    if (_authController.currentUser.value != null) {
      loadUserBooks();
    }

    ever(_authController.currentUser, (user) {
      if (user != null) {
        loadUserBooks();
      } else {
        userBooks.clear();
      }
    });
  }

  Future<void> loadAllBooks() async {
    final currentUserEmail = _authController.currentUser.value?.email;
    if (currentUserEmail == null) return;

    try {
      isLoading.value = true;
      error.value = '';
      final loadedBooks = await BookService.getAllBooksWithinEmailOwner(
        currentUserEmail,
      );

      // Utilisez des callbacks différés
      WidgetsBinding.instance.addPostFrameCallback((_) {
        allBooks.value = loadedBooks;
        books.value = loadedBooks;
        _updateSortedLists();
      });
    } catch (e) {
      error.value = 'Error loading books: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Nouvelle méthode pour mettre à jour les listes triées
  void _updateSortedLists() {
    // Livres populaires (les plus empruntés)
    popularBooks.value = List.from(allBooks)
      ..sort((a, b) => (b.borrowCount ?? 0).compareTo(a.borrowCount ?? 0));

    // Limite à 10 livres maximum
    if (popularBooks.length > 10) {
      popularBooks.value = popularBooks.sublist(0, 10);
    }

    // Livres recommandés (meilleures notes)
    recommendedBooks.value = List.from(allBooks)
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

    if (recommendedBooks.length > 10) {
      recommendedBooks.value = recommendedBooks.sublist(0, 10);
    }

    // Nouveautés (les plus récentes)
    newBooks.value = List.from(allBooks)..sort((a, b) {
      // Gestion des dates potentiellment null
      final dateA = a.publishedDate ?? '';
      final dateB = b.publishedDate ?? '';
      return dateB.compareTo(dateA);
    });

    if (newBooks.length > 10) {
      newBooks.value = newBooks.sublist(0, 10);
    }
  }

  Future<void> loadUserBooks() async {
    try {
      final user = _authController.currentUser.value;
      if (user?.id == null) return;

      isLoading.value = true;
      error.value = '';

      final loadedBooks = await BookService.getBooksByUser(user!.id!);
      userBooks.value = loadedBooks;
    } catch (e) {
      error.value = 'Error loading user books: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ... (le reste de vos méthodes existantes reste inchangé)

  Future<Book?> updateBook(int bookId, Map<String, dynamic> bookData) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedBook = await BookService.updateBook(bookId, bookData);

      if (updatedBook != null) {
        // Mise à jour des listes après modification
        _updateBookInLists(updatedBook);
        return updatedBook;
      }
      error.value = 'Échec de la mise à jour du livre';
      return null;
    } catch (e) {
      error.value = 'Erreur lors de la mise à jour du livre: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Nouvelle méthode pour mettre à jour un livre dans toutes les listes
  void _updateBookInLists(Book updatedBook) {
    final lists = [
      allBooks,
      books,
      userBooks,
      popularBooks,
      recommendedBooks,
      newBooks,
    ];

    for (var list in lists) {
      final index = list.indexWhere((book) => book.id == updatedBook.id);
      if (index != -1) {
        list[index] = updatedBook;
      }
    }

    // Re-trier les listes après mise à jour
    _updateSortedLists();
  }
}
