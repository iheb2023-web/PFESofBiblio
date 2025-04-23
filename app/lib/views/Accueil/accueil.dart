import 'package:app/models/book.dart';
import 'package:app/views/Emprunter/emprunter_livre.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsLivre extends StatefulWidget {
  final Book book;

  const DetailsLivre({super.key, required this.book});

  @override
  State<DetailsLivre> createState() => _DetailsLivreState();
}

class _DetailsLivreState extends State<DetailsLivre>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  late AnimationController _animationController;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('add_review'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'your_rating'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Étoiles interactives
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                      Navigator.of(context).pop();
                      _showAddReviewDialog(); // Rouvrir avec la nouvelle note
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre avis',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                // ... logique d'ajout d'avis
                Get.back();
                Get.snackbar(
                  'thank_you'.tr,
                  'review_added'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('publish'.tr),
            ),
          ],
        );
      },
    );
  }

  void _show3DDialog() {
    if (widget.book.modelUrl == null) {
      Get.snackbar(
        'Information',
        'La vue 3D n\'est pas disponible pour ce livre',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Barre supérieure avec titre et bouton fermer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vue 3D - ${widget.book.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Visualiseur 3D
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle:
                                _isRotating
                                    ? _animationController.value * 2 * 3.14159
                                    : 0,
                            child: Container(
                              width: 200,
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(widget.book.coverUrl),
                                  fit: BoxFit.cover,
                                  onError:
                                      (exception, stackTrace) =>
                                          const Icon(Icons.book),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child:
                                  widget.book.coverUrl.isEmpty
                                      ? const Center(
                                        child: Icon(Icons.book, size: 50),
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Contrôles
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isRotating = !_isRotating;
                              if (_isRotating) {
                                _animationController.repeat();
                              } else {
                                _animationController.stop();
                              }
                            });
                          },
                          icon: Icon(
                            _isRotating ? Icons.stop : Icons.play_arrow,
                          ),
                          label: Text(
                            _isRotating ? 'Arrêter' : 'Faire tourner',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec bouton retour
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    debugPrint(
                      'Go Back button clicked',
                    ); // Journal pour déboguer
                    if (Navigator.canPop(context)) {
                      Get.back(); // Retourner à la page précédente si possible
                    } else {
                      debugPrint(
                        'No previous page in the navigation stack',
                      ); // Journal si aucune page précédente
                    }
                  },
                ),
              ),

              // Section couverture et informations principales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Couverture du livre avec bouton 3D
                    Expanded(
                      flex: 4,
                      child: Stack(
                        children: [
                          Hero(
                            tag: 'book_cover_${widget.book.title}',
                            child: Container(
                              height: 240,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(widget.book.coverUrl),
                                  fit: BoxFit.cover,
                                  onError:
                                      (exception, stackTrace) =>
                                          const Icon(Icons.book),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child:
                                  widget.book.coverUrl.isEmpty
                                      ? const Center(
                                        child: Icon(Icons.book, size: 50),
                                      )
                                      : null,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.view_in_ar),
                              onPressed: _show3DDialog,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Informations du livre
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.book.author,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Notation
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color:
                                    index < widget.book.rating
                                        ? Colors.amber
                                        : Colors.grey[300],
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          // Boutons d'action
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(
                                      () => EmprunterLivre(book: widget.book),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Emprunter"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // État et nombre d'emprunts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Disponible",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Emprunté 24 fois",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // À propos du livre
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'about_book'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Le Petit Prince est une œuvre de langue française, la plus connue d'Antoine de Saint-Exupéry. Publié en 1943 à New York simultanément à sa traduction anglaise...",
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Informations supplémentaires
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildInfoCard(
                      icon: Icons.category,
                      title: "Catégorie",
                      value: widget.book.category,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoCard(
                      icon: Icons.book,
                      title: "Pages",
                      value: widget.book.pageCount.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section avis
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'reader_reviews'.tr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _showAddReviewDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Liste des avis
                    _buildAvis(
                      nom: "Marie Dupont",
                      note: 5,
                      commentaire:
                          "Un chef-d'œuvre intemporel qui touche le cœur.",
                      date: "Il y a 2 jours",
                      photoUrl: null,
                    ),
                    const SizedBox(height: 16),
                    _buildAvis(
                      nom: "Jean Martin",
                      note: 4,
                      commentaire: "Une belle histoire qui fait réfléchir.",
                      date: "Il y a 1 semaine",
                      photoUrl: null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvis({
    required String nom,
    required int note,
    required String commentaire,
    required String date,
    String? photoUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Photo de profil
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image:
                        photoUrl != null
                            ? NetworkImage(photoUrl) as ImageProvider
                            : const AssetImage(
                              'assets/images/default_profile.png',
                            ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nom et date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Notation en étoiles
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: index < note ? Colors.amber : Colors.grey[300],
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Commentaire
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(commentaire, style: const TextStyle(height: 1.4)),
          ),
        ],
      ),
    );
  }
}
