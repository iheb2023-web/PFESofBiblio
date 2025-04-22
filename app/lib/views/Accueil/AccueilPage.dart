import 'package:app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:app/views/Détails_Livre/details_livre.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/controllers/book_controller.dart';

// Déplacer la classe Member au niveau supérieur, avant AccueilPage
class Member {
  final String name;
  final int loans;

  Member(this.name, this.loans);
}

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage>
    with SingleTickerProviderStateMixin {
  final List<String> categories = [
    'all'.tr,
    'fiction'.tr,
    'business'.tr,
    'science'.tr,
    'history'.tr,
  ];

  String? selectedCategory;
  late BookController _bookController; // Retirer l'initialisation directe

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Image de profil par défaut
  static const String defaultProfileImage = 'assets/images/default_profile.png';

  // Liste des membres avec leurs prêts
  final List<Member> members = List.generate(
    10,
    (index) => Member('Membre ${index + 1}', (10 - index) * 5),
  )..sort((a, b) => b.loans.compareTo(a.loans));

  @override
  void initState() {
    super.initState();
    // Initialiser BookController dans initState
    _bookController = Get.find<BookController>();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load books when the page is initialized
    _bookController.loadAllBooks();
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre supérieure avec logo et profil
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png', height: 40),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // Navigation vers la page des messages
                          },
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigation vers le profil
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(defaultProfileImage),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search_book'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),

              // Catégories
              const SizedBox(height: 20),
              _buildCategoryChips(),

              // Membres actifs
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'active_members'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(defaultProfileImage),
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.book_outlined,
                                size: 12,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${member.loans}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Livres populaires
              _buildBookSection('popular_books'.tr),

              // Livres pour vous
              _buildBookSection('recommended'.tr),

              // Livres disponibles
              _buildBookSection('new_arrivals'.tr),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: FloatingActionButton(
              onPressed: () {
                // Action pour ouvrir le chat
              },
              elevation: 4,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(5),
                height: 150,
                width: 150,
                child: Lottie.asset(
                  'assets/lottie/chatbot.json',
                  fit: BoxFit.cover,
                  frameRate: FrameRate(60),
                  repeat: true,
                  options: LottieOptions(enableMergePaths: true),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryChips() {
    return GetBuilder<ThemeController>(
      builder:
          (controller) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                for (String category in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCategory =
                                selectedCategory == category ? null : category;
                          });
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedCategory == category
                                    ? AppTheme.primaryColor
                                    : (controller.isDarkMode
                                        ? AppTheme.darkSurfaceColor
                                        : AppTheme.lightSurfaceColor),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color:
                                  selectedCategory == category
                                      ? AppTheme.primaryColor
                                      : controller.isDarkMode
                                      ? Colors.white24
                                      : Colors.grey[300]!,
                              width: 1,
                            ),
                            boxShadow: [
                              if (selectedCategory == category)
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color:
                                  selectedCategory == category
                                      ? Colors.white
                                      : (controller.isDarkMode
                                          ? Colors.white70
                                          : AppTheme.lightTextColor),
                              fontWeight:
                                  selectedCategory == category
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildBookSection(String title) {
    List<Book> sectionBooks = [];

    // Select the appropriate book list based on the section title
    if (title == 'popular_books'.tr) {
      sectionBooks = _bookController.popularBooks;
    } else if (title == 'recommended'.tr) {
      sectionBooks = _bookController.recommendedBooks;
    } else if (title == 'new_arrivals'.tr) {
      sectionBooks = _bookController.newBooks;
    }

    return Obx(() {
      if (_bookController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_bookController.error.value.isNotEmpty) {
        return Center(
          child: Text(
            _bookController.error.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle view all action
                  },
                  child: Text('view_all'.tr),
                ),
              ],
            ),
          ),
          if (title == 'new_arrivals'.tr)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sectionBooks.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final book = sectionBooks[index];
                return GestureDetector(
                  onTap: () => Get.to(() => DetailsLivre(book: book)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Image de couverture
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.coverUrl,
                              height: 120,
                              width: 80,
                              fit: BoxFit.cover,
                              cacheWidth:
                                  160, // 2x la largeur d'affichage pour une bonne qualité
                              cacheHeight:
                                  240, // 2x la hauteur d'affichage pour une bonne qualité
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 120,
                                  width: 80,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 120,
                                    width: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.book),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Informations du livre
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
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'borrowed_times'.trParams({
                                        'count': '${book.borrowCount}',
                                      }),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed:
                                          book.isAvailable ? () {} : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        minimumSize: const Size(120, 36),
                                      ),
                                      child: Text(
                                        book.isAvailable
                                            ? 'borrow'.tr
                                            : 'unavailable'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
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
              },
            )
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sectionBooks.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final book = sectionBooks[index];
                  return GestureDetector(
                    onTap: () => Get.to(() => DetailsLivre(book: book)),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.coverUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              cacheWidth: 600, // Limiter la taille en cache
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.book,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[700],
                              ),
                              Text(' ${book.rating}/5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}
