import 'package:get/get.dart';
import 'package:app/models/review.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/services/review_service.dart';

class ReviewController extends GetxController {
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<Review> userReviews = <Review>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadReviewsForBook(int bookId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await ReviewService.getReviewsByBookId(bookId);
      reviews.value = result;
    } catch (e) {
      error.value = 'Erreur chargement reviews: $e';
      print(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addReview(Review review) async {
    if (_authController.currentUser.value?.email == null) {
      error.value = 'User not authenticated';
      return false;
    }

    try {
      isLoading.value = true;
      review.userEmail = _authController.currentUser.value!.email;

      final addedReview = await ReviewService.addReview(review);
      if (addedReview == null) return false;

      await loadReviewsForBook(review.bookId!); // Recharge tous les avis
      return true;
    } catch (e) {
      error.value = 'AddReview error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateReviewInLists(Review updatedReview) {
    final lists = [reviews, userReviews];
    for (var list in lists) {
      final index = list.indexWhere((review) => review.id == updatedReview.id);
      if (index != -1) {
        list[index] = updatedReview;
      }
    }
  }

  Future<double> averageStars(int bookId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load reviews for the book
      final bookReviews = await ReviewService.getReviewsByBookId(bookId);

      if (bookReviews.isEmpty) {
        return 0.0; // Return 0 if no reviews
      }

      // Calculate sum of ratings
      final totalRating = bookReviews.fold<double>(
        0.0,
        (sum, review) => sum + (review.rating ?? 0.0),
      );

      // Calculate average
      final average = totalRating / bookReviews.length;

      // Round to 1 decimal place
      return double.parse(average.toStringAsFixed(1));
    } catch (e) {
      error.value = 'Erreur calcul moyenne stars: $e';
      print(error.value);
      return 0.0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Review?> fetchReviewById(int reviewId) async {
    try {
      isLoading.value = true;
      final review = await ReviewService.getReviewById(reviewId);
      if (review != null) {
        print('Review récupéré: ${review.toJson()}');
        return review;
      } else {
        error.value = 'Review introuvable';
        return null;
      }
    } catch (e) {
      error.value = 'Erreur lors de la récupération: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateReview(int id, Review updatedReview) async {
    try {
      isLoading.value = true;
      error.value = '';

      final email = _authController.currentUser.value?.email;
      if (email == null) {
        error.value = 'User not authenticated';
        return false;
      }

      updatedReview.userEmail = email;

      final result = await ReviewService.updateReview(id, updatedReview);

      if (result != null) {
        _updateReviewInLists(result);
        // Recharger les avis pour le livre après la mise à jour
        final rev = await fetchReviewById(id);
        await loadReviewsForBook(rev!.bookId);
        print("voici id de livre    ${updatedReview}");
        return true;
      } else {
        error.value = 'Échec mise à jour review';
        return false;
      }
    } catch (e) {
      error.value = 'Erreur updateReview: $e';
      print(error.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un avis
  Future<bool> deleteReview(int id) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await ReviewService.deleteReview(id);
      if (success) {
        reviews.removeWhere((review) => review.id == id);
        userReviews.removeWhere((review) => review.id == id);
        return true;
      } else {
        error.value = 'Échec suppression review';
        return false;
      }
    } catch (e) {
      error.value = 'Erreur deleteReview: $e';
      print(error.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
