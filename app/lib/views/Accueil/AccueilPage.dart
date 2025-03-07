import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:app/views/Détails_Livre/details_livre.dart';

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

  int selectedCategoryIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Image de profil par défaut
  static const String defaultProfileImage = 'assets/images/default_profile.png';

  // Liste des membres avec leurs prêts
  final List<Member> members = List.generate(
    10,
    (index) => Member(
      'Membre ${index + 1}',
      (10 - index) * 5,
    ), // Nombre de prêts décroissant
  )..sort(
    (a, b) => b.loans.compareTo(a.loans),
  ); // Tri par nombre de prêts décroissant

  // Liste des livres avec leurs détails
  final List<BookDetails> books = [
    BookDetails(
      title: "Le Petit Prince",
      author: "Antoine de Saint-Exupéry",
      coverImage: "assets/images/couverture1.png",
      rating: 5,
      description:
          "Un conte poétique qui aborde les thèmes de l'amour et l'amitié.",
      category: "Fiction",
      pages: 96,
      borrowCount: 24,
      isAvailable: true,
    ),
    BookDetails(
      title: "Harry Potter",
      author: "J.K. Rowling",
      coverImage: "assets/images/couverture2.png",
      rating: 4,
      description: "L'histoire d'un jeune sorcier découvrant son destin.",
      category: "Fantasy",
      pages: 320,
      borrowCount: 18,
      isAvailable: true,
    ),
    BookDetails(
      title: "Le Seigneur des Anneaux",
      author: "J.R.R. Tolkien",
      coverImage: "assets/images/couverture3.png",
      rating: 5,
      description: "Une épopée fantastique dans un monde imaginaire.",
      category: "Fantasy",
      pages: 576,
      borrowCount: 15,
      isAvailable: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
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
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color:
                              selectedCategoryIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                selectedCategoryIndex == index
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color:
                                  selectedCategoryIndex == index
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Membres actifs
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'active_members'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 120, // Augmenté pour accommoder le texte supplémentaire
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
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBookSection(String title) {
    if (title == 'new_arrivals'.tr) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: books.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final book = books[index];
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
                          child: Image.asset(
                            book.coverImage,
                            height: 120,
                            width: 80,
                            fit: BoxFit.cover,
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
                                    'borrowed_times'.trParams({'count': '${book.borrowCount}'}),
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
                                    onPressed: book.isAvailable ? () {} : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      minimumSize: const Size(120, 36),
                                    ),
                                    child: Text(
                                      book.isAvailable ? 'borrow'.tr : 'unavailable'.tr,
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
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 220, // Augmenté pour plus d'espace
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () => Get.to(() => DetailsLivre(book: book)),
                  child: Container(
                    width: 140, // Augmenté pour plus d'espace
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: Image.asset(
                            book.coverImage,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
    }
  }
}
