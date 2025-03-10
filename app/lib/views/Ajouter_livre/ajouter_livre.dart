import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app/themeData.dart';
import 'package:app/theme/theme_controller.dart';

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
  final TextEditingController durationController = TextEditingController(text: '7 jours');

  BookData? bookData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authorController.addListener(_onAuthorChanged);
  }

  @override
  void dispose() {
    authorController.removeListener(_onAuthorChanged);
    titleController.dispose();
    authorController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // Fonction pour chercher le livre après un délai quand l'auteur est modifié
  Future<void> _onAuthorChanged() async {
    if (authorController.text.length > 3 && titleController.text.isNotEmpty) {
      // Attendre que l'utilisateur arrête de taper
      await Future.delayed(const Duration(milliseconds: 800));
      if (authorController.text.length > 3) {
        _searchBook(titleController.text, authorController.text);
      }
    }
  }

  Future<void> _searchBook(String title, String author) async {
    if (title.isEmpty || author.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Détecter si le titre est en anglais ou en français
      bool isEnglish = RegExp(r'^[a-zA-Z\s.,!?-]+$').hasMatch(title);
      String language = isEnglish ? 'en' : 'fr';
      
      // Construire la requête avec le titre et l'auteur
      String query = 'intitle:${Uri.encodeComponent(title)} inauthor:${Uri.encodeComponent(author)}';
      
      // Construire l'URL avec les paramètres appropriés
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query&langRestrict=$language&maxResults=1')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0]['volumeInfo'];

          String isbn = '';
          if (item['industryIdentifiers'] != null) {
            for (var identifier in item['industryIdentifiers']) {
              if (identifier['type'] == 'ISBN_13') {
                isbn = identifier['identifier'];
                break;
              } else if (identifier['type'] == 'ISBN_10' && isbn.isEmpty) {
                isbn = identifier['identifier'];
                break;
              }
            }
          }

          String coverUrl = '';
          if (item['imageLinks'] != null) {
            coverUrl = item['imageLinks']['thumbnail'] ?? '';
            // Convertir l'URL http en https et augmenter la taille de l'image
            coverUrl = coverUrl.replaceAll('http://', 'https://').replaceAll('zoom=1', 'zoom=2');
          }

          // Génération d'une description plus complète dans la langue appropriée
          String description = '';
          if (isEnglish) {
            if (item['publishedDate'] != null) {
              description += 'Published in ${item['publishedDate']}. ';
            }
            if (item['authors']?.isNotEmpty == true) {
              description += 'Written by ${item['authors'][0]}. ';
            }
            if (item['pageCount'] != null) {
              description += '${item['pageCount']} pages. ';
            }
            if (item['categories']?.isNotEmpty == true) {
              description += 'Category: ${item['categories'][0]}. ';
            }
            if (item['language'] != null) {
              description += 'Language: ${item['language'].toUpperCase()}. ';
            }
            if (item['description'] != null) {
              description += '\n\n${item['description']}';
            }
          } else {
            if (item['publishedDate'] != null) {
              description += 'Publié en ${item['publishedDate']}. ';
            }
            if (item['authors']?.isNotEmpty == true) {
              description += 'Écrit par ${item['authors'][0]}. ';
            }
            if (item['pageCount'] != null) {
              description += '${item['pageCount']} pages. ';
            }
            if (item['categories']?.isNotEmpty == true) {
              description += 'Catégorie : ${item['categories'][0]}. ';
            }
            if (item['language'] != null) {
              description += 'Langue : ${item['language'].toUpperCase()}. ';
            }
            if (item['description'] != null) {
              description += '\n\n${item['description']}';
            }
          }
          
          if (description.isEmpty) {
            description = isEnglish ? 'No description available' : 'Aucune description disponible';
          }

          final bookInfo = BookData(
            title: item['title'] ?? '',
            author: item['authors']?.isNotEmpty == true ? item['authors'][0] : (isEnglish ? 'Unknown author' : 'Auteur inconnu'),
            description: description,
            coverUrl: coverUrl,
            publishedDate: item['publishedDate'] ?? '',
            isbn: isbn,
            category: item['categories']?.isNotEmpty == true ? item['categories'][0] : '',
            pageCount: item['pageCount'] ?? 0,
            language: item['language'] ?? '',
          );

          setState(() {
            bookData = bookInfo;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche du livre: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => Scaffold(
        backgroundColor: controller.isDarkMode ? darkBackgroundColor : whiteSmokeColor,
        appBar: AppBar(
          title: Text(
            'add_book'.tr,
            style: TextStyle(
              color: controller.isDarkMode ? whiteColor : blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, 
              color: controller.isDarkMode ? whiteColor : blackColor),
            onPressed: () => Get.back(),
          ),
          backgroundColor: controller.isDarkMode ? darkBackgroundColor : whiteColor,
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
    );
  }

  Widget _buildLabel(String text, ThemeController controller) {
    return Text(
      text,
      style: TextStyle(
        color: controller.isDarkMode ? Colors.grey[300] : const Color.fromARGB(255, 63, 62, 62),
      ),
    );
  }

  Widget _buildTextField(TextEditingController textController, String hint, ThemeController controller) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: controller.isDarkMode ? Colors.grey[500] : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: blueColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: controller.isDarkMode ? Colors.grey[900] : whiteColor,
        filled: true,
      ),
      style: TextStyle(
        color: controller.isDarkMode ? whiteColor : blackColor,
      ),
    );
  }

  Widget _buildBookDetails(ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildBookInfo('ISBN', bookData!.isbn, controller),
            _buildBookInfo('Date de Publication', bookData!.publishedDate, controller),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildBookInfo('Nombre de pages', 
              bookData!.pageCount > 0 ? bookData!.pageCount.toString() : 'Non disponible', 
              controller),
            _buildBookInfo('Langue', 
              bookData!.language.isNotEmpty ? bookData!.language.toUpperCase() : 'Non disponible', 
              controller),
          ],
        ),
        if (bookData!.category.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildBookInfo('Catégorie', bookData!.category, controller),
        ],
      ],
    );
  }

  Widget _buildBookInfo(String label, String value, ThemeController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: controller.isDarkMode ? Colors.grey[300] : const Color.fromARGB(255, 63, 62, 62),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: controller.isDarkMode ? whiteColor : blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedContent(ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contenu généré',
          style: TextStyle(
            color: controller.isDarkMode ? whiteColor : blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: controller.isDarkMode ? Colors.grey[900] : whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey,
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
          'Disponibilité',
          style: TextStyle(
            color: controller.isDarkMode ? whiteColor : blackColor,
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
        onPressed: () => Get.back(),
        icon: const Icon(Icons.add),
        label: Text(
          'add'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: blueColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(ThemeController controller) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: controller.isDarkMode ? Colors.grey[900] : whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey),
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
              color: controller.isDarkMode ? Colors.grey[500] : Colors.grey,
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
            'Résumé',
            style: TextStyle(
              color: controller.isDarkMode ? whiteColor : const Color.fromARGB(255, 17, 17, 17),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bookData != null && bookData!.description.isNotEmpty
                ? bookData!.description
                : 'Le résumé sera généré automatiquement...',
            style: TextStyle(
              color: controller.isDarkMode ? Colors.grey[300] : const Color.fromARGB(255, 63, 62, 62),
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.keyboard_arrow_down,
            color: controller.isDarkMode ? Colors.grey[500] : Colors.grey,
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
                  primary: blueColor,
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
          color: controller.isDarkMode ? Colors.grey[900] : whiteColor,
          border: Border.all(color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                  : 'Sélectionner une date',
              style: TextStyle(
                color: selectedDate != null 
                    ? controller.isDarkMode ? whiteColor : blackColor
                    : controller.isDarkMode ? Colors.grey[500] : Colors.grey,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: controller.isDarkMode ? Colors.grey[500] : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationField(ThemeController controller) {
    return TextField(
      controller: durationController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: controller.isDarkMode ? Colors.grey[700]! : Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: blueColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: controller.isDarkMode ? Colors.grey[900] : whiteColor,
        filled: true,
      ),
      style: TextStyle(
        color: controller.isDarkMode ? whiteColor : blackColor,
      ),
    );
  }
}