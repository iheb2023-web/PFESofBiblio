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
    try {
      isLoading.value = true;
      error.value = '';

      final email = _authController.currentUser.value?.email;
      if (email == null) {
        error.value = 'User not authenticated';
        return false;
      }

      review.userEmail = email;

      final addedReview = await ReviewService.addReview(review);

      if (addedReview != null) {
        reviews.add(addedReview);
        userReviews.add(addedReview);
        return true;
      } else {
        error.value = 'Échec ajout review';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
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

  // double averageStars(int bookId) {
  //   final bookReviews =
  //       reviews.where((review) => review.bookId == bookId).toList();
  //   if (bookReviews.isEmpty) return 0.7;

  //   final totalRating = bookReviews.fold(
  //     0.0,
  //     (sum, review) => sum + review.rating,
  //   );
  //   return totalRating / bookReviews.length;
  // }
  // double averageStars() {
  //   if (reviews.isEmpty) return 0.0;

  //   final totalRating = reviews.fold<double>(
  //     0.0,
  //     (sum, review) => sum + review.rating,
  //   );

  //   return totalRating / reviews.length;
  // }
}
