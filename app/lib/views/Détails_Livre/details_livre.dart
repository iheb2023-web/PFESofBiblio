import 'package:app/models/book.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/views/Emprunter/emprunter_livre.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/review_controller.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/review.dart';

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
  String? proprietaire;
  late AnimationController _animationController;
  bool _isRotating = false;
  final ReviewController _reviewController = Get.find<ReviewController>();
  final AuthController _authController = Get.find<AuthController>();
  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays >= 1) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inHours >= 1) {
      return "Il y a ${difference.inHours} heures";
    } else {
      return "Il y a quelques minutes";
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _reviewController.loadReviewsForBook(widget.book.id!);
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    final propritaire = await AuthService.getUserById(widget.book.ownerId!);
    final propritaireName = _formatUserName(propritaire);
    setState(() {
      proprietaire = propritaireName;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAddReviewDialog() {
    _commentController.clear(); // Vide le contrôleur
    int localRating = 0; // Commence avec 0 étoiles au lieu de _rating

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            localRating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < localRating ? Icons.star : Icons.star_border,
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
                  onPressed: () async {
                    final user = _authController.currentUser.value;

                    if (user == null || widget.book.id == null) {
                      Get.snackbar(
                        "Erreur",
                        "Utilisateur ou livre introuvable",
                      );
                      return;
                    }

                    try {
                      await _reviewController.addReview(
                        Review(
                          rating: localRating,
                          comment: _commentController.text,
                          userId: user.id!,
                          bookId: widget.book.id!,
                          publishedDate: DateTime.now().toIso8601String(),
                        ),
                      );

                      setState(() {
                        _rating = localRating; // Mettre à jour l'état global
                      });

                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Get.snackbar(
                          'thank_you'.tr,
                          'review_added'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      });
                    } catch (e) {
                      Get.snackbar("Erreur", "Impossible d'ajouter l'avis");
                    }
                  },
                  child: Text('publish'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editReview(Review review) {
    final commentController = TextEditingController(text: review.comment);
    int currentRating = review.rating ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, setDialogState) {
            return AlertDialog(
              title: Text('edit_review'.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'your_rating'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            currentRating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < currentRating
                              ? Icons.star
                              : Icons.star_border,
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
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Modifiez votre avis...',
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
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: Text('cancel'.tr),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedReview = review.copyWith(
                      rating: currentRating,
                      comment: commentController.text,
                    );

                    try {
                      final success = await _reviewController.updateReview(
                        review.id!,
                        updatedReview,
                      );

                      Navigator.of(dialogContext, rootNavigator: true).pop();

                      if (success) {
                        Get.snackbar(
                          'Succès',
                          'Avis mis à jour',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Échec de la mise à jour de l\'avis',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } catch (e) {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                      Get.snackbar(
                        'Erreur',
                        'Une erreur est survenue: ${e.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text('save_changes'.tr),
                ),
              ],
            );
          },
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
                  onPressed: () => Navigator.of(context).pop(),
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

                          // Dans la section d'en-tête du livre
                          Row(
                            children: [
                              // Afficher les étoiles pleines selon la note moyenne
                              FutureBuilder<double>(
                                future: _getAverageStars(widget.book),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      width: 100,
                                      child: LinearProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    );
                                  } else {
                                    final averageRating = snapshot.data ?? 0;
                                    return Row(
                                      children: [
                                        // Étoiles pleines pour la partie entière
                                        ...List.generate(
                                          averageRating.floor(),
                                          (index) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        ),
                                        // Demi-étoile si nécessaire
                                        if (averageRating -
                                                averageRating.floor() >=
                                            0.5)
                                          const Icon(
                                            Icons.star_half,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        // Étoiles vides
                                        ...List.generate(
                                          5 - averageRating.ceil(),
                                          (index) => const Icon(
                                            Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              // Afficher le nombre d'avis (optionnel)
                              Obx(() {
                                final count = _reviewController.reviews.length;
                                return Text(
                                  '($count)',
                                  style: const TextStyle(color: Colors.grey),
                                );
                              }),
                            ],
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
                      "Emprunté 3 fois",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Propriétaire : $proprietaire',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      widget.book.description ??
                          '', // Gestion du cas où la description serait null
                      style: TextStyle(color: Colors.grey, height: 1.5),
                      maxLines: 3, // Limite à 3 lignes maximum
                      overflow:
                          TextOverflow
                              .ellipsis, // Ajoute "..." si le texte est tronqué
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

                    //liste dynamique des avis
                    Obx(() {
                      final reviews = _reviewController.reviews;
                      final currentUserId =
                          _authController.currentUser.value!.id;

                      if (reviews.isEmpty) {
                        return const Center(
                          child: Text(
                            "Aucun avis pour le moment.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        children:
                            reviews.map((review) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Ligne supérieure (avis + 3 points conditionnels)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildAvis(
                                              nom:
                                                  review.username ??
                                                  "Utilisateur",
                                              note: review.rating,
                                              commentaire: review.comment,
                                              date: _formatDate(
                                                review.publishedDate,
                                              ),
                                              photoUrl: null,
                                            ),
                                          ),
                                          // Afficher les 3 points SEULEMENT si l'utilisateur est l'auteur
                                          if (currentUserId == review.userId)
                                            PopupMenuButton<String>(
                                              icon: const Icon(
                                                Icons.more_vert,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              itemBuilder:
                                                  (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            color: Colors.blue,
                                                            size: 20,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text("Modifier"),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text("Supprimer"),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  _editReview(review);
                                                }
                                                if (value == 'delete') {
                                                  _reviewController
                                                      .deleteReview(review.id!);
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    }),
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

  String _formatUserName(Map<String, dynamic>? userData) {
    return (userData != null &&
            userData['firstname'] != null &&
            userData['lastname'] != null)
        ? '${userData['firstname']} ${userData['lastname']}'
        : 'un utilisateur';
  }
}

Future<double> _getAverageStars(Book book) async {
  final reviewController = Get.find<ReviewController>();
  return await reviewController.averageStars(book.id!);
}
