import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/config/app_config.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;
  var hasSetPassword = false.obs;

  String get baseUrl => AppConfig.apiBaseUrl;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;

      final token = await _storageService.getAuthToken();

      if (token == null) {
        currentUser.value = null;
        isLoggedIn.value = false;
        update();
        return;
      }

      final userData = await _storageService.getUserSession();

      if (userData != null && userData['id'] != null) {
        try {
          final user = User.fromJson(userData);

          if (user.id == null) {
            currentUser.value = null;
            isLoggedIn.value = false;
            await _storageService.clearSession();
            update();
            return;
          }

          currentUser.value = user;
          isLoggedIn.value = true;
          update();
        } catch (e) {
          currentUser.value = null;
          isLoggedIn.value = false;
          await _storageService.clearSession();
          update();
        }
      } else {
        currentUser.value = null;
        isLoggedIn.value = false;
        await _storageService.clearSession();
        update();
      }
    } catch (e) {
      currentUser.value = null;
      isLoggedIn.value = false;
      update();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Veuillez remplir tous les champs');
      }

      await _storageService.clearSession();

      final user = await _authService.login(email, password);

      final userJson = user.toJson();

      await _storageService.saveUserSession(userJson);

      currentUser.value = user;
      isLoggedIn.value = true;
      update();

      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();

      try {
        await _storageService.clearSession();
      } catch (_) {}

      currentUser.value = null;
      isLoggedIn.value = false;
      update();

      Get.snackbar(
        'Erreur',
        'Merci de vérifier que vos identifiants sont corrects. :(',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.init();
      await _storageService.clearSession();
      currentUser.value = null;
      isLoggedIn.value = false;
      update();

      Get.snackbar(
        'Succès',
        'Déconnexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const LoginPage());
    } catch (e) {
      try {
        await _storageService.clearSession();
      } catch (_) {}

      currentUser.value = null;
      isLoggedIn.value = false;
      update();

      Get.snackbar(
        'Erreur',
        'Erreur lors de la déconnexion',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      Get.offAll(() => const LoginPage());
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

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final updatedUser = await _authService.updateProfile(
        currentUser.value!.id!,
        userData,
      );
      currentUser.value = updatedUser;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Échec de la mise à jour du profil',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get userFullName =>
      currentUser.value != null
          ? '${currentUser.value!.firstname} ${currentUser.value!.lastname}'
          : '';

  String? getCurrentUserEmail() {
    return currentUser.value?.email;
  }

  Future<String?> uploadProfileImage(File image) async {}

  Future<User?> getUserById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userData = await AuthService.getUserById(id);

      if (userData == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final user = User.fromJson(userData);
      return user;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la récupération de l\'utilisateur: $e';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (newPassword.isEmpty) {
        throw Exception('Le nouveau mot de passe ne peut pas être vide');
      }

      final user = currentUser.value;
      if (user == null || user.email.isEmpty) {
        throw Exception(
          "Impossible de récupérer l'email de l'utilisateur connecté",
        );
      }

      hasSetPassword.value = true;
      if (user != null) {
        final updatedUser = user.copyWith(hasSetPassword: true);
        final userData = {
          'id': updatedUser.id,
          'email': updatedUser.email,
          'hasSetPassword': updatedUser.hasSetPassword,
        };

        await updateUserProfile(userData);
      }

      final email = user.email;

      final response = await _authService.resetPassword(email, newPassword);

      if (response['success'] == true) {
        Get.snackbar(
          'Succès',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => const LoginPage());
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int?> numberOfBorrowsByUser(String email) async {
    try {
      final nb = await AuthService.numberOfBorrowsByUSer(email);

      if (nb == null) {
        throw Exception('Utilisateur non trouvé');
      }
      return nb;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<int?> numberOfBooksByUser(String email) async {
    try {
      final nb = await AuthService.numberOfBooksByUSer(email);

      if (nb == null) {
        throw Exception('Utilisateur non trouvé');
      }
      return nb;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
