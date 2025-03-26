import 'package:app/models/borrow.dart';
import 'package:app/services/borrow_service.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BorrowController extends GetxController {
  final BorrowService _borrowService = Get.find<BorrowService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Borrow> borrows = <Borrow>[].obs;
  final RxList<Borrow> ownerRequests = <Borrow>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllBorrows();
    loadOwnerRequests();
  }

  Future<void> loadOwnerRequests() async {
    try {
      isLoading.value = true;
      final email = Get.find<AuthController>().currentUser.value?.email;
      if (email == null) {
        throw Exception('Utilisateur non connecté');
      }
      final response = await _borrowService.getRequestsForOwner(email);
      ownerRequests.value = response;
    } catch (e) {
      error.value = e.toString();
      print('Erreur lors du chargement des demandes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptRequest(int borrowId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _borrowService.acceptBorrowRequest(borrowId);
      await loadOwnerRequests(); // Recharger la liste après acceptation
      Get.snackbar(
        'Succès',
        'Demande d\'emprunt acceptée',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor.withOpacity(0.1),
        colorText: AppTheme.successColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible d\'accepter la demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectRequest(int borrowId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _borrowService.rejectBorrowRequest(borrowId);
      await loadOwnerRequests(); // Recharger la liste après refus
      Get.snackbar(
        'Succès',
        'Demande d\'emprunt refusée',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor.withOpacity(0.1),
        colorText: AppTheme.successColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de refuser la demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllBorrows() async {
    try {
      isLoading.value = true;
      error.value = '';
      final email = _authController.currentUser.value?.email;
      if (email == null) {
        throw Exception('Utilisateur non connecté');
      }
      borrows.value = await _borrowService.getBorrowDemandsByEmail(email);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de charger vos demandes d\'emprunt',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Borrow> borrowBook(
    int bookId,
    DateTime borrowDate,
    DateTime returnDate,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = _authController.currentUser.value;
      if (user == null || user.email == null) {
        throw Exception('Veuillez vous connecter pour emprunter un livre');
      }

      final borrow = await _borrowService.borrowBook(
        bookId,
        user.email,
        borrowDate,
        returnDate,
      );

      // Recharger la liste des emprunts après succès
      await loadAllBorrows();
      return borrow;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
