import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/models/book.dart';
import 'package:app/views/Détails_Livre/details_livre.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = []; // Liste complète des livres
  List<Book> _filteredBooks = []; // Livres filtrés
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    // Simuler un chargement asynchrone
    await Future.delayed(const Duration(seconds: 1));

    // Exemple de données (remplacer par votre vraie source de données)
    final books = [
      Book(
        title: 'Le Petit Prince',
        author: 'Antoine de Saint-Exupéry',
        coverUrl: 'https://example.com/petit-prince.jpg',
        category: 'Littérature',
        rating: 8,
        pageCount: 96,
        isbn: '9782070408504',
        description: '',
        publishedDate: '',
        language: '',
      ),
      Book(
        title: '1984',
        author: 'George Orwell',
        coverUrl: 'https://example.com/1984.jpg',
        category: 'Science-Fiction',
        rating: 7,
        pageCount: 328,
        isbn: '9782070368228',
        description: '',
        publishedDate: '',
        language: '',
      ),
      // Ajouter d'autres livres...
    ];

    setState(() {
      _allBooks = books;
      _filteredBooks = books;
      _isLoading = false;
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks =
          _allBooks.where((book) {
            return book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query) ||
                book.category.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            appBar: AppBar(
              title: Text('Explorer'.tr),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor:
                  themeController.isDarkMode ? Colors.white : Colors.black,
            ),
            body: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un livre, auteur...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          themeController.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),

                // Filtres
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('Tous', themeController),
                      _buildFilterChip('Roman', themeController),
                      _buildFilterChip('Science-Fiction', themeController),
                      _buildFilterChip('Histoire', themeController),
                      _buildFilterChip('Biographie', themeController),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Résultats
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredBooks.isEmpty
                          ? Center(
                            child: Text(
                              'Aucun résultat trouvé',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = _filteredBooks[index];
                              return _buildBookCard(book, themeController);
                            },
                          ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterChip(String label, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: false,
        onSelected: (_) {
          // Implémenter la logique de filtrage
        },
        backgroundColor:
            themeController.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: themeController.isDarkMode ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildBookCard(Book book, ThemeController themeController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: themeController.isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => DetailsLivre(book: book));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Couverture du livre
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.coverUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[200],
                        child: Icon(Icons.book, color: Colors.grey[500]),
                      ),
                ),
              ),
              const SizedBox(width: 12),

              // Détails du livre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          book.rating.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                themeController.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.menu_book,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.pageCount} pages',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        book.category,
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
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
