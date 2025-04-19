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

      // Ajout de l'email avant envoi
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

  double getAverageStars() {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}
