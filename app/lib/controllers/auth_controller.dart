import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/config/app_config.dart';
import 'dart:convert';

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
      isLoading.value = true;
      print('AuthController: Vérification du statut d\'authentification');

      // Vérifier d'abord le token
      final token = await _storageService.getAuthToken();
      print('AuthController: Token trouvé: ${token != null}');

      if (token == null) {
        print('AuthController: Aucun token trouvé, déconnexion');
        currentUser.value = null;
        update();
        return;
      }

      // Récupérer les données de session
      final userData = await _storageService.getUserSession();
      print('AuthController: Données de session: $userData');

      if (userData != null && userData['id'] != null) {
        try {
          final user = User.fromJson(userData);
          print('AuthController: Utilisateur créé avec ID: ${user.id}');

          // Vérifier que l'utilisateur a un ID valide
          if (user.id == null) {
            print('AuthController: ID utilisateur invalide, déconnexion');
            currentUser.value = null;
            await _storageService.clearSession();
            update();
            return;
          }

          // Mettre à jour l'état de l'utilisateur
          currentUser.value = user;
          print(
            'AuthController: État utilisateur mis à jour: ${user.toJson()}',
          );
          update();
        } catch (e) {
          print(
            'AuthController: Erreur lors de la création de l\'utilisateur: $e',
          );
          currentUser.value = null;
          await _storageService.clearSession();
          update();
        }
      } else {
        print(
          'AuthController: Données de session invalides ou manquantes, déconnexion',
        );
        currentUser.value = null;
        await _storageService.clearSession();
        update();
      }
    } catch (e) {
      print('AuthController: Erreur lors de la vérification du statut: $e');
      currentUser.value = null;
      update();
    } finally {
      isLoading.value = false;
      print(
        'AuthController: État final - isLoading: ${isLoading.value}, currentUser: ${currentUser.value?.id}',
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('AuthController: Tentative de connexion pour $email');

      // Vérifier que l'email et le mot de passe ne sont pas vides
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Veuillez remplir tous les champs');
      }

      // Nettoyer la session existante avant la nouvelle connexion
      await _storageService.clearSession();
      print('AuthController: Session précédente nettoyée');

      final user = await _authService.login(email, password);
      print('AuthController: Connexion réussie pour ${user.toString()}');
      print('AuthController: ID utilisateur: ${user.id}');

      // Vérifier que l'utilisateur a un ID valide
      if (user.id == null) {
        throw Exception('Erreur: ID utilisateur invalide');
      }

      // Convertir l'utilisateur en JSON
      final userJson = user.toJson();
      print('AuthController: Données à sauvegarder: $userJson');

      // Sauvegarder la session
      await _storageService.saveUserSession(userJson);
      print('AuthController: Session sauvegardée');

      // Vérifier que la session a été correctement sauvegardée
      final savedSession = await _storageService.getUserSession();
      print('AuthController: Session vérifiée: $savedSession');

      if (savedSession == null || savedSession['id'] != user.id) {
        throw Exception('Erreur: Session non sauvegardée correctement');
      }

      // Mettre à jour l'état de l'utilisateur
      currentUser.value = user;
      print('AuthController: État utilisateur mis à jour: ${user.toJson()}');
      update();

      print('AuthController: Connexion terminée avec succès');

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

      // Nettoyer la session en cas d'erreur
      try {
        await _storageService.clearSession();
        print('AuthController: Session nettoyée après erreur');
      } catch (storageError) {
        print(
          'AuthController: Erreur lors du nettoyage de la session: $storageError',
        );
      }

      // S'assurer que l'utilisateur est déconnecté
      currentUser.value = null;
      update();

      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow; // Propager l'erreur pour que la page de login puisse la gérer
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      print('AuthController: Déconnexion en cours');
      // S'assurer que le service de stockage est initialisé
      await _storageService.init();
      // D'abord effacer les données locales
      await _storageService.clearSession();
      // Ensuite appeler le service de déconnexion
      await _authService.logout();
      currentUser.value = null;
      update(); // Notifier GetX du changement
      print('AuthController: Déconnexion réussie');

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
      // Même en cas d'erreur, on essaie de nettoyer les données locales
      try {
        await _storageService.clearSession();
      } catch (storageError) {
        print(
          'AuthController: Erreur supplémentaire lors du nettoyage: $storageError',
        );
      }

      Get.snackbar(
        'Erreur',
        'Erreur lors de la déconnexion',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Rediriger vers login même en cas d'erreur
      Get.offAllNamed('/login');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print(
        'AuthController: Demande de réinitialisation du mot de passe pour $email',
      );

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

      final updatedUser = await _authService.updateProfile(
        currentUser.value!.id!,
        userData,
      );
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
      isLoading.value = true;
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
      // Mettre à jour la session stockée
      if (user != null) {
        await _storageService.saveUserSession(user.toJson());
      }
    } catch (e) {
      print('Error refreshing user profile: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de rafraîchir le profil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
