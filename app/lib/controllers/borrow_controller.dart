import 'package:app/models/borrow.dart';
import 'package:app/services/borrow_service.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BorrowController extends GetxController {
  final BorrowService _borrowService = BorrowService();
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

  Future<void> returnBook(int borrowId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _borrowService.markAsReturned(borrowId);
      await loadAllBorrows();
      Get.snackbar(
        'Succès',
        'Livre retourné avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de retourner le livre',
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

  Future<void> loadOwnerRequests() async {
    isLoading.value = true;
    try {
      final email = _authController.currentUser.value?.email;
      if (email == null) {
        throw Exception('Utilisateur non connecté');
      }
      final requests = await _borrowService.getRequestsForOwner(email);

      ownerRequests.assignAll(
        requests.map((request) {
          return Borrow(
            id: request.id,
            borrowDate: request.borrowDate,
            expectedReturnDate: request.expectedReturnDate,
            borrowStatus: request.borrowStatus,
            borrower: request.borrower,
            book: request.book,
          );
        }).toList(),
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les demandes.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptRequest(int borrowId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _borrowService.acceptBorrowRequest(borrowId);
      await loadOwnerRequests();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectRequest(int borrowId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _borrowService.rejectBorrowRequest(borrowId);
      await loadOwnerRequests();
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

      await loadAllBorrows();
      return borrow;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserBorrows(String email) async {
    try {
      isLoading.value = true;
      final borrows = await _borrowService.getUserBorrows(email);
      this.borrows.assignAll(borrows);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<DateTime>> getOccupiedDatesByBookId(int bookId) async {
    try {
      isLoading.value = true;
      return await _borrowService.getOccupiedDatesByBookId(bookId);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les dates occupées',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBorrow(int borrowId) async {
    try {
      isLoading.value = true;
      await _borrowService.cancelPendingOrApproved(borrowId);
      // await loadUserBorrows(currentUserEmail.value);
      Get.snackbar(
        'Succès',
        'Emprunt supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'annulation: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelWhileInProgress(int borrowId) async {
    try {
      isLoading.value = true;
      await _borrowService.cancelWhileInProgress(borrowId);

      Get.snackbar(
        'Succès',
        'Emprunt en cours annulé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'annulation: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<DateTime>> getBookOccupiedDatesUpdatedBorrow(
    int bookId,
    int borrowId,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      final dates = await _borrowService.getBookOccupiedDatesUpdatedBorrow(
        bookId,
        borrowId,
      );
      return dates;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les dates occupées mises à jour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
