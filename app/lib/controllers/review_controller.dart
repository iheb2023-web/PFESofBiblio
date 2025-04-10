import 'package:get/get.dart';
import 'package:app/models/review.dart';
import 'package:app/services/review_service.dart';
import 'package:app/controllers/auth_controller.dart';

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
    try {
      isLoading.value = true;
      error.value = '';

      final email = AuthController().currentUser.value?.email;
      if (email == null) {
        error.value = 'User not authenticated';
        return false;
      }

      final reviewJson = {
        'content': review.comment,
        'rating': review.rating,
        'book': {'id': review.bookId},
        'user': {'email': email},
      };

      final response = await GetConnect().post(
        'https://api.example.com/reviews',
        reviewJson,
        headers: {
          'Authorization': 'Bearer ${_authController.currentUser.value?.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final newReview = Review.fromJson(response.body);
        reviews.add(newReview);
        userReviews.add(newReview);
        return true;
      } else {
        error.value = response.body['message'] ?? 'Unknown error';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> deleteReview(int reviewId) async {
  //   try {
  //     isLoading.value = true;
  //     error.value = '';

  //     final success = await ReviewService.deleteReview(reviewId);
  //     if (success) {
  //       reviews.removeWhere((review) => review.id == reviewId);
  //       userReviews.removeWhere((review) => review.id == reviewId);
  //       return true;
  //     }
  //     error.value = 'Échec de la suppression du review';
  //     return false;
  //   } catch (e) {
  //     error.value = 'Erreur lors de la suppression du review: $e';
  //     print(error.value);
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<Review?> updateReview(
  //   int reviewId,
  //   Map<String, dynamic> reviewData,
  // ) async {
  //   try {
  //     isLoading.value = true;
  //     error.value = '';

  //     final updatedReview = await ReviewService.updateReview(
  //       reviewId,
  //       reviewData,
  //     );
  //     if (updatedReview != null) {
  //       _updateReviewInLists(updatedReview);
  //       return updatedReview;
  //     }
  //     error.value = 'Échec de la mise à jour du review';
  //     return null;
  //   } catch (e) {
  //     error.value = 'Erreur lors de la mise à jour du review: $e';
  //     print(error.value);
  //     return null;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void _updateReviewInLists(Review updatedReview) {
    final lists = [reviews, userReviews];
    for (var list in lists) {
      final index = list.indexWhere((review) => review.id == updatedReview.id);
      if (index != -1) {
        list[index] = updatedReview;
      }
    }
  }

  double getAverageStars() {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}
