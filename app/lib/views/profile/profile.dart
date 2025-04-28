import 'package:app/views/profile/edit_preferences.dart';
import 'package:app/views/profile/profile_header.dart';
import 'package:app/views/profile/profile_option.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';
import 'package:app/views/profile/edit_profile_page.dart';
import 'package:app/views/profile/privacy_security_page.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        centerTitle: true,
        elevation: 2,
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        final isLoading = controller.isLoading.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!Get.isRegistered<AuthController>() ||
                controller.currentUser.value == null) {
              Get.offAll(() => const LoginPage());
            }
          });
          return const Center(
            child: Text('Redirection vers la page de connexion...'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(user: user),
              const SizedBox(height: 10),
              ProfileOption(
                icon: Icons.person_outline,
                title: 'Éditer le profil',
                subtitle: 'Modifier vos informations personnelles',
                onTap: () => Get.to(() => EditProfilePage(user: user)),
              ),
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              ProfileOption(
                icon: Icons.settings_outlined, // Choisis une icône qui te plaît
                title: 'Éditer les préférences',
                subtitle: 'Modifier vos préférences personnelles',
                onTap: () => Get.to(() => const EditPreferencePage()),
              ),
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

              ProfileOption(
                icon: Icons.lock_outline,
                title: 'Confidentialité et sécurité',
                subtitle: 'Gérer les paramètres de confidentialité',
                onTap: () => Get.to(() => const PrivacySecurityPage()),
              ),
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmation(),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      'deconnexion'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void _showLogoutConfirmation() {
    Get.defaultDialog(
      title: 'Confirmation',
      middleText: 'Êtes-vous sûr de vouloir vous déconnecter?',
      textConfirm: 'Déconnexion',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await controller.logout();
      },
    );
  }
}
