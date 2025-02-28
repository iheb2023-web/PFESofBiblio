import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  bool isShared = false;
  DateTime? selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController durationController = TextEditingController(text: '7 jours');

  BookData? bookData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    titleController.removeListener(_onTitleChanged);
    titleController.dispose();
    authorController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // Fonction pour chercher le livre après un délai
  Future<void> _onTitleChanged() async {
    if (titleController.text.length > 3) {
      // Attendre que l'utilisateur arrête de taper
      await Future.delayed(const Duration(milliseconds: 800));
      if (titleController.text.length > 3) {
        _searchBook(titleController.text);
      }
    }
  }

  Future<void> _searchBook(String title) async {
    if (title.isEmpty && authorController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {


      final response = await http.get(
          Uri.parse('https://openlibrary.org/search.json?title=${Uri.encodeComponent(title)}&limit=1')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['numFound'] > 0) {
          final item = data['docs'][0];

          String isbn = item['isbn'] != null && item['isbn'].isNotEmpty
              ? item['isbn'][0]
              : '';

          String coverUrl = item['cover_i'] != null
              ? 'https://covers.openlibrary.org/b/id/${item['cover_i']}-L.jpg'
              : '';

          final bookInfo = BookData(
            title: item['title'] ?? '',
            author: item['author_name']?.isNotEmpty == true ? item['author_name'][0] : 'Auteur inconnu',
            description: 'Aucune description disponible', // Open Library ne fournit pas toujours une description
            coverUrl: coverUrl,
            publishedDate: item['first_publish_year']?.toString() ?? '',
            isbn: isbn,
            category: item['subject']?.isNotEmpty == true ? item['subject'][0] : '',
            pageCount: item['number_of_pages_median'] ?? 0,
            language: item['language']?.isNotEmpty == true ? item['language'][0] : '',
          );

          setState(() {
            bookData = bookInfo;
            if (authorController.text.isEmpty) {
              authorController.text = bookInfo.author;
            }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ajouter un livre'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Titre du livre',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Saisir le titre',
                  suffixIcon: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Auteur',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authorController,
                decoration: InputDecoration(
                  hintText: "Nom de l'auteur",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),

              if (bookData != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ISBN',
                            style: TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(bookData!.isbn.isNotEmpty ? bookData!.isbn : 'Non disponible'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date de Publication',
                            style: TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(bookData!.publishedDate.isNotEmpty ? bookData!.publishedDate : 'Non disponible'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nombre de pages',
                            style: TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(bookData!.pageCount > 0 ? bookData!.pageCount.toString() : 'Non disponible'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Langue',
                            style: TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(bookData!.language.isNotEmpty
                              ? bookData!.language.toUpperCase()
                              : 'Non disponible'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (bookData!.category.isNotEmpty) ...[
                  const Text(
                    'Catégorie',
                    style: TextStyle(color: Colors.amber, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(bookData!.category),
                  const SizedBox(height: 16),
                ],
              ],

              const SizedBox(height: 24),

              const Text(
                'Contenu généré',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du livre
                    Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                        image: bookData != null && bookData!.coverUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(bookData!.coverUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: bookData == null || bookData!.coverUrl.isEmpty
                          ? Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Résumé',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bookData != null && bookData!.description.isNotEmpty
                                ? bookData!.description
                                : 'Le résumé sera généré automatiquement...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Disponibilité',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Date de disponibilité',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: selectedDate != null ? Colors.black : Colors.grey.shade500,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Durée maximale d'emprunt",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Partager',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isShared,
                    onChanged: (value) {
                      setState(() {
                        isShared = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logique pour ajouter le livre
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter le livre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}