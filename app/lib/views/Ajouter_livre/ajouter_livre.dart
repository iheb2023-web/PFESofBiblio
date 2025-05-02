import 'package:app/models/book_model_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/services/book_service.dart';
import 'package:app/services/api_service.dart';
import 'package:app/models/book.dart';
import 'package:intl/intl.dart';
import 'add_book_form.dart';
import 'dart:async';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  DateTime? selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController pageCountController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  Timer? _debounceTimer;
  BookData? bookData;
  late AuthController _authController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    durationController.text = '7 jours';
    titleController.addListener(_onTitleChanged);
    authorController.addListener(_onAuthorChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    titleController.removeListener(_onTitleChanged);
    authorController.removeListener(_onAuthorChanged);
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    isbnController.dispose();
    categoryController.dispose();
    pageCountController.dispose();
    languageController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _onTitleChanged() => _onFieldsChanged();
  void _onAuthorChanged() => _onFieldsChanged();

  void _onFieldsChanged() {
    if (bookData != null) {
      setState(() {
        bookData = null;
      });
    }
    if (titleController.text.trim().length > 3) {
      _debounceSearch();
    }
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _searchBook(titleController.text.trim(), authorController.text.trim());
    });
  }

  Future<void> _searchBook(String title, String author) async {
    if (title.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final bookInfo = await BookService.searchBook(title, author: author);
      if (!mounted) return;

      if (bookInfo != null) {
        setState(() {
          bookData = BookData(
            title: bookInfo['title'] ?? '',
            author: bookInfo['author'] ?? 'Auteur inconnu',
            description:
                bookInfo['description'] ?? 'Aucune description disponible',
            coverUrl: bookInfo['coverUrl'] ?? '',
            publishedDate: bookInfo['publishedDate'] ?? '',
            isbn: bookInfo['isbn'] ?? '',
            category: bookInfo['category'] ?? '',
            pageCount: bookInfo['pageCount'] ?? 0,
            language: bookInfo['language'] ?? '',
          );
          if (bookInfo['author'] != null && bookInfo['author'].isNotEmpty) {
            authorController.text = bookInfo['author'];
          }
          descriptionController.text = bookInfo['description'] ?? '';
          isbnController.text = bookInfo['isbn'] ?? '';
          categoryController.text = bookInfo['category'] ?? '';
          pageCountController.text = (bookInfo['pageCount'] ?? 0).toString();
          languageController.text = (bookInfo['language'] ?? '').toUpperCase();
        });
      } else {
        Get.snackbar(
          'Information',
          'Aucun livre trouvé avec ces critères',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).cardColor,
          colorText: Theme.of(context).textTheme.bodyLarge?.color,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la recherche',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _addBook() async {
    setState(() => isLoading = true);

    try {
      final user = _authController.currentUser.value;

      if (user?.id == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour ajouter un livre',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (titleController.text.isEmpty || authorController.text.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Le titre et l\'auteur sont requis',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final book = Book(
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        description: descriptionController.text.trim(),
        coverUrl: bookData?.coverUrl ?? '',
        publishedDate:
            selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                : '',
        isbn: isbnController.text.trim(),
        category: categoryController.text.trim(),
        pageCount: int.tryParse(pageCountController.text) ?? 0,
        language: languageController.text.trim(),
        ownerId: user?.id,
        isAvailable: true,
        rating: 0,
        borrowCount: 0,
      );

      if (user?.id != null) {
        final success = await ApiService.addBook(book, user!.id);
        if (success) {
          titleController.clear();
          authorController.clear();
          descriptionController.clear();
          isbnController.clear();
          categoryController.clear();
          pageCountController.clear();
          languageController.clear();
          durationController.text = '7 jours';
          setState(() {
            selectedDate = null;
            bookData = null;
          });
          Get.snackbar(
            'Succès',
            'Le livre a été ajouté avec succès',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Get.back();
        } else {
          Get.snackbar(
            'Erreur',
            'Une erreur est survenue lors de l\'ajout du livre',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e, stackTrace) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'ajout du livre',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (controller) => Theme(
            data:
                controller.isDarkMode
                    ? AppTheme.darkTheme
                    : AppTheme.lightTheme,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                title: Text(
                  'add_book'.tr,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).appBarTheme.iconTheme?.color,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                elevation: 0,
              ),
              body: AddBookForm(
                titleController: titleController,
                authorController: authorController,
                descriptionController: descriptionController,
                isbnController: isbnController,
                categoryController: categoryController,
                pageCountController: pageCountController,
                languageController: languageController,
                durationController: durationController,
                bookData: bookData,
                isLoading: isLoading,
                selectedDate: selectedDate,
                onAddBook: _addBook,
                onDateSelected: (date) => setState(() => selectedDate = date),
              ),
            ),
          ),
    );
  }
}
