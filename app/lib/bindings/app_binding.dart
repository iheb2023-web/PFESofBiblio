import 'package:app/controllers/preferences_controller.dart';
import 'package:app/controllers/review_controller.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/review_service.dart';
import 'package:app/services/socket_service.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/controllers/book_controller.dart';
import 'package:app/controllers/borrow_controller.dart';
import 'package:app/services/borrow_service.dart';
import 'package:app/services/storage_service.dart';

// class AppBinding extends Bindings {
//   @override
//   void dependencies() {
//     // Services
//     Get.put(StorageService(), permanent: true);
//     Get.put(BorrowService());
//     Get.put(ReviewService());
//     Get.put(SocketService());

//     // Controllers
//     Get.put(ThemeController());
//     Get.put(AuthController());
//     Get.put(BookController());
//     Get.put(BorrowController());
//     Get.put(ReviewController());
//   }
//}
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(StorageService(), permanent: true);
    Get.lazyPut(() => BorrowService(), fenix: true);
    Get.lazyPut(() => ReviewService(), fenix: true);
    Get.lazyPut(() => SocketService(), fenix: true);
    Get.lazyPut(() => PreferenceService(), fenix: true);

    // Controllers
    Get.lazyPut(() => ThemeController(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => BookController(), fenix: true); // ✅ Important ici
    Get.lazyPut(() => BorrowController(), fenix: true);
    Get.lazyPut(() => ReviewController(), fenix: true);
    Get.lazyPut(() => PreferenceController(), fenix: true);
  }
}
