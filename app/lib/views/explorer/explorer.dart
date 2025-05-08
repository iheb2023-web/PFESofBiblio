import 'package:app/controllers/review_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/controllers/book_controller.dart';
import 'package:app/models/book.dart';
import 'package:app/views/Détails_Livre/details_livre.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final BookController _bookController = Get.find<BookController>();
  List<Book> _filteredBooks = [];
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
    await _bookController.loadAllBooks();
    setState(() {
      _filteredBooks = _bookController.allBooks;
      _isLoading = false;
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks =
          _bookController.allBooks.where((book) {
            return book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query);
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

                // Résultats en grille
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
                          : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 colonnes
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio:
                                      0.7, // Ratio largeur/hauteur
                                ),
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

  Widget _buildBookCard(Book book, ThemeController themeController) {
    final bool isDarkMode = themeController.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Get.to(() => DetailsLivre(book: book));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Couverture du livre (centrée)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverUrl,
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 100,
                          height: 140,
                          color:
                              isDarkMode ? Colors.grey[700] : Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 100,
                            height: 140,
                            color:
                                isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                            child: Icon(
                              Icons.book,
                              color:
                                  isDarkMode
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Titre du livre (avec hauteur fixe pour 2 lignes)
                SizedBox(
                  height: 40, // Hauteur fixe pour 2 lignes
                  child: Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 14, // Taille réduite
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Auteur (une seule ligne)
                Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 12, // Taille réduite
                    color: secondaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Note et nombre de pages (ligne compacte)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Note moyenne avec FutureBuilder
                    Flexible(
                      child: FutureBuilder<String>(
                        future: _getAverageStars(book),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }
                          if (snapshot.hasError) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                snapshot.data ?? '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Nombre de pages
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 16,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.pageCount}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _getAverageStars(Book book) async {
    final reviewController = Get.find<ReviewController>();
    final average = await reviewController.averageStars(book.id!);
    return average.toStringAsFixed(1);
  }
}
