import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app/themeData.dart' as theme_data;
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/services/book_service.dart';
import 'dart:async';
import 'package:app/services/api_service.dart';
import 'package:app/models/book.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/user_model.dart';

class BookData {
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String publishedDate;
  final String isbn;
  final String category;
  final int pageCount;
  final String language;

  BookData({
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.publishedDate,
    required this.isbn,
    required this.category,
    required this.pageCount,
    required this.language,
  });

  factory BookData.empty() {
    return BookData(
      title: '',
      author: '',
      description: '',
      coverUrl: '',
      publishedDate: '',
      isbn: '',
      category: '',
      pageCount: 0,
      language: '',
    );
  }
}

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
    
    // Vérifier l'état de l'authentification au démarrage
    print('InitState - État de l\'authentification:');
    print('User: ${_authController.currentUser.value?.toJson()}');
    print('User ID: ${_authController.currentUser.value?.id}');
    
    titleController.addListener(_onFieldsChanged);
    authorController.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  void _onFieldsChanged() {
    if (bookData != null) {
      setState(() {
        bookData = null;
      });
    }
    
    if (titleController.text.isNotEmpty) {
      _debounceSearch();
    }
  }

  void _debounceSearch() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _searchBook(titleController.text, authorController.text);
    });
  }

  Future<void> _searchBook(String title, String author) async {
    if (title.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final bookInfo = await BookService.searchBook(title, author: author);
      if (bookInfo != null) {
        if (!mounted) return;
        setState(() {
          bookData = BookData(
            title: bookInfo['title'] ?? '',
            author: bookInfo['author'] ?? 'Auteur inconnu',
            description: bookInfo['description'] ?? 'Aucune description disponible',
            coverUrl: bookInfo['coverUrl'] ?? '',
            publishedDate: bookInfo['publishedDate'] ?? '',
            isbn: bookInfo['isbn'] ?? '',
            category: bookInfo['category'] ?? '',
            pageCount: bookInfo['pageCount'] ?? 0,
            language: bookInfo['language'] ?? '',
          );
          authorController.text = bookInfo['author'] ?? '';
        });
      } else {
        if (!mounted) return;
        Get.snackbar(
          'Information',
          'Aucun livre trouvé avec ces critères',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Theme.of(context).cardColor,
          colorText: Theme.of(context).textTheme.bodyLarge?.color,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la recherche',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => Theme(
        data: controller.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
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
              onPressed: () => Get.back(),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('book_title'.tr, controller),
                const SizedBox(height: 8),
                _buildTextField(titleController, 'enter_title'.tr, controller),
                const SizedBox(height: 16),
                _buildLabel('author'.tr, controller),
                const SizedBox(height: 8),
                _buildTextField(authorController, 'enter_author'.tr, controller),
                
                if (bookData != null) ...[
                  const SizedBox(height: 16),
                  _buildBookDetails(controller),
                ],

                const SizedBox(height: 24),
                _buildGeneratedContent(controller),
                const SizedBox(height: 24),
                _buildAvailabilitySection(controller),
                const SizedBox(height: 24),
                _buildAddButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeController controller) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildTextField(TextEditingController textController, String hint, ThemeController controller) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
            border: Theme.of(context).inputDecorationTheme.border,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            filled: true,
            contentPadding: EdgeInsets.only(
              left: 16,
              right: isLoading ? 48 : 16,
              top: 16,
              bottom: 16,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBookDetails(ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildEditableField(
                'ISBN',
                isbnController..text = bookData?.isbn ?? '',
                controller,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEditableField(
                'Publication_date'.tr,
                TextEditingController(text: bookData?.publishedDate ?? ''),
                controller,
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEditableField(
                'Number_of_pages'.tr,
                pageCountController..text = bookData?.pageCount.toString() ?? '',
                controller,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEditableField(
                'language'.tr,
                languageController..text = bookData?.language.toUpperCase() ?? '',
                controller,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEditableField(
          'Category'.tr,
          categoryController..text = bookData?.category ?? '',
          controller,
        ),
        const SizedBox(height: 16),
        Text(
          'Description'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController..text = bookData?.description ?? '',
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    ThemeController themeController, {
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildGeneratedContent(ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated_content'.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).cardColor,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCover(controller),
              const SizedBox(width: 16),
              _buildBookDescription(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability'.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDatePicker(controller),
        const SizedBox(height: 16),
        _buildDurationField(controller),
      ],
    );
  }

  Widget _buildAddButton(ThemeController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _addBook,
        icon: const Icon(Icons.add),
        label: Text(
          'add'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme_data.blueColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _addBook() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Vérifier l'état de l'authentification avant l'ajout
      final user = _authController.currentUser.value;
      print('AddBook - État de l\'authentification:');
      print('User: ${user?.toJson()}');
      print('User ID: ${user?.id}');
      
      if (user?.id == null) {
        print('Erreur: ID utilisateur manquant');
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour ajouter un livre',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validation des champs requis
      if (titleController.text.isEmpty || authorController.text.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Le titre et l\'auteur sont requis',
          snackPosition: SnackPosition.TOP,
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
        publishedDate: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '',
        isbn: isbnController.text.trim(),
        category: categoryController.text.trim(),
        pageCount: int.tryParse(pageCountController.text) ?? 0,
        language: languageController.text.trim(),
        ownerId: user?.id,  
        isAvailable: true,
        rating: 0,
        borrowCount: 0,
      );

      print('Tentative d\'ajout du livre:');
      print('Données du livre: ${book.toJson()}');
      
      if (user?.id != null) {  
        final success = await ApiService.addBook(book, user!.id);
        
        if (success) {
          // Effacer tous les champs du formulaire
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
            snackPosition: SnackPosition.TOP,
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
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e, stackTrace) {
      print('Erreur lors de l\'ajout du livre: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'ajout du livre',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildBookCover(ThemeController controller) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).cardColor),
        image: bookData != null && bookData!.coverUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(bookData!.coverUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: bookData == null || bookData!.coverUrl.isEmpty
          ? Icon(
              Icons.image,
              color: Theme.of(context).iconTheme.color,
              size: 32,
            )
          : null,
    );
  }

  Widget _buildBookDescription(ThemeController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bookData != null && bookData!.description.isNotEmpty
                ? bookData!.description
                : 'Le résumé sera généré automatiquement...',
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeController controller) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: theme_data.blueColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                  : 'Sélectionner une date',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationField(ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durée du prêt'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: durationController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).cardColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).cardColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme_data.blueColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            fillColor: Theme.of(context).cardColor,
            filled: true,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}