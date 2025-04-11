import 'package:app/controllers/review_controller.dart';
import 'package:app/services/review_service.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/controllers/book_controller.dart';
import 'package:app/controllers/borrow_controller.dart';
import 'package:app/services/borrow_service.dart';
import 'package:app/services/storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(StorageService(), permanent: true);
    Get.put(BorrowService());
    Get.put(ReviewService());

    // Controllers
    Get.put(ThemeController());
    Get.put(AuthController());
    Get.put(BookController());
    Get.put(BorrowController());
    Get.put(ReviewController());
  }
}
