import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/config/app_config.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get baseUrl => AppConfig.apiBaseUrl;

  @override
  void onInit() {
    super.onInit();
    print('AuthController: onInit');
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final userData = await _storageService.getUserSession();
      print('AuthController: Vérification du statut d\'authentification');
      
      if (userData != null) {
        final user = User.fromJson(userData);
        print('AuthController: Utilisateur chargé: ${user.toString()}');
        currentUser.value = user;
        update(); // Notifier GetX du changement
      } else {
        print('AuthController: Aucune session utilisateur trouvée');
      }
    } catch (e) {
      print('AuthController: Erreur lors de la vérification du statut: $e');
      errorMessage.value = 'Erreur lors de la vérification de la session';
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('AuthController: Tentative de connexion pour $email');

      final user = await _authService.login(email, password);
      print('AuthController: Connexion réussie pour ${user.toString()}');
      
      currentUser.value = user;
      update(); // Notifier GetX du changement

      // Sauvegarder la session
      await _storageService.saveUserSession(user.toJson());
      print('AuthController: Session sauvegardée');
      
      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('AuthController: Erreur de connexion: $e');
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

  Future<void> logout() async {
    try {
      print('AuthController: Déconnexion en cours');
      await _authService.logout();
      await _storageService.clearSession();
      currentUser.value = null;
      update(); // Notifier GetX du changement
      print('AuthController: Déconnexion réussie');
      // Supprimer les informations stockées si nécessaire
      // await storage.delete(key: 'user');
      // message de succès est affiché
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
      print('AuthController: Erreur de déconnexion: $e');
      errorMessage.value = 'Erreur lors de la déconnexion';
      Get.snackbar(
        'Erreur',
        'Erreur lors de la déconnexion',
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
      print('AuthController: Demande de réinitialisation du mot de passe pour $email');

      await _authService.requestPasswordReset(email);
      print('AuthController: Email de réinitialisation envoyé');

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
      print('AuthController: Erreur de réinitialisation du mot de passe: $e');
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

      final updatedUser = await _authService.updateProfile(currentUser.value!.id!, userData);
      currentUser.value = updatedUser;
      
      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> refreshUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      print('Error refreshing user profile: $e');
    }
  }

  //vérifie si un utilisateur est connecté en fonction de currentUser
  bool get isLoggedIn => currentUser.value != null;
  //renvoie le nom complet de l'utilisateur si l'utilisateur est connecté.
  String get userFullName =>
      currentUser.value != null
          ? '${currentUser.value!.firstname} ${currentUser.value!.lastname}'
          : '';
}
