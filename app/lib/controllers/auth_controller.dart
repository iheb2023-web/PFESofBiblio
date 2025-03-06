import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.login(email, password);
      currentUser.value = user;

      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // La navigation est maintenant gérée par la page de connexion
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow; // Propager l'erreur pour que la page de connexion puisse la gérer
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(User user) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newUser = await _authService.register(user);
      currentUser.value = newUser;

      Get.snackbar(
        'Succès',
        'Inscription réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigation vers la page d'accueil
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      // Supprimer les informations stockées si nécessaire
      // await storage.delete(key: 'user');

      Get.snackbar(
        'Succès',
        'Déconnexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigation vers la page de connexion
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.requestPasswordReset(email);

      Get.snackbar(
        'Succès',
        'Un email de réinitialisation a été envoyé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Retourner à la page de connexion
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool get isLoggedIn => currentUser.value != null;
  String get userFullName =>
      currentUser.value != null
          ? '${currentUser.value!.firstname} ${currentUser.value!.lastname}'
          : '';
}
