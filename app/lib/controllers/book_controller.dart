import 'package:get/get.dart';
import 'package:app/models/book.dart';
import 'package:app/services/book_service.dart';
import 'package:app/controllers/auth_controller.dart';

class BookController extends GetxController {
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

    // Listen to auth changes to reload user books
    ever(_authController.currentUser, (user) {
      if (user != null) {
        loadUserBooks();
      } else {
        userBooks.clear();
      }
    });
  }

  Future<void> loadAllBooks() async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedBooks = await BookService.getAllBooks();
      books.value = loadedBooks;

      // Sort books by different criteria for each section
      popularBooks.value = List.from(loadedBooks)
        ..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
      if (popularBooks.length > 10)
        popularBooks.value = popularBooks.sublist(0, 10);

      recommendedBooks.value = List.from(loadedBooks)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      if (recommendedBooks.length > 10)
        recommendedBooks.value = recommendedBooks.sublist(0, 10);

      // Sort by newest first (assuming publishedDate is in ISO format)
      newBooks.value = List.from(loadedBooks)
        ..sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      if (newBooks.length > 10) newBooks.value = newBooks.sublist(0, 10);
    } catch (e) {
      error.value = 'Error loading books: $e';
      print(error.value);
    } finally {
      isLoading.value = false;
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
      print(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<Book?> addBook(Book book) async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = _authController.currentUser.value;
      if (user == null) {
        error.value = 'User not authenticated';
        return null;
      }

      final bookWithOwner = book.copyWith(ownerId: user.id);
      final addedBook = await BookService.addBook(bookWithOwner);

      if (addedBook != null) {
        books.add(addedBook);
        userBooks.add(addedBook);
        return addedBook;
      }
      return null;
    } catch (e) {
      error.value = 'Error adding book: $e';
      print(error.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  List<Book> getFilteredBooks(String? category) {
    if (category == null || category.toLowerCase() == 'all') {
      return books;
    }
    return books
        .where((book) => book.category?.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<Book> searchBooks(String query) {
    if (query.isEmpty) {
      return books;
    }

    final lowercaseQuery = query.toLowerCase();
    return books.where((book) {
      final title = book.title?.toLowerCase() ?? '';
      final author = book.author?.toLowerCase() ?? '';
      final category = book.category?.toLowerCase() ?? '';

      return title.contains(lowercaseQuery) ||
          author.contains(lowercaseQuery) ||
          category.contains(lowercaseQuery);
    }).toList();
  }

  Future<bool> deleteBook(int bookId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await BookService.deleteBook(bookId);

      if (success) {
        // Supprimer le livre des listes locales
        books.removeWhere((book) => book.id == bookId);
        userBooks.removeWhere((book) => book.id == bookId);
        popularBooks.removeWhere((book) => book.id == bookId);
        recommendedBooks.removeWhere((book) => book.id == bookId);
        newBooks.removeWhere((book) => book.id == bookId);
        return true;
      }
      error.value = 'Échec de la suppression du livre';
      return false;
    } catch (e) {
      error.value = 'Erreur lors de la suppression du livre: $e';
      print(error.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Book?> updateBook(int bookId, Map<String, dynamic> bookData) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedBook = await BookService.updateBook(bookId, bookData);

      if (updatedBook != null) {
        // Mettre à jour le livre dans les listes locales
        _updateBookInLists(updatedBook);
        return updatedBook;
      }
      error.value = 'Échec de la mise à jour du livre';
      return null;
    } catch (e) {
      error.value = 'Erreur lors de la mise à jour du livre: $e';
      print(error.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateBookInLists(Book updatedBook) {
    // Helper pour mettre à jour le livre dans toutes les listes
    final lists = [books, userBooks, popularBooks, recommendedBooks, newBooks];

    for (var list in lists) {
      final index = list.indexWhere((book) => book.id == updatedBook.id);
      if (index != -1) {
        list[index] = updatedBook;
      }
    }
  }
}
