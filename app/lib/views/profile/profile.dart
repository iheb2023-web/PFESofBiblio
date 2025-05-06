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
    final authController = AuthController();

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
              ProfileHeader(
                user: user,
                borrowsCount: authController.numberOfBorrowsByUser(
                  user.email,
                ), // Future<int?>
                booksCount: authController.numberOfBooksByUser(user.email),
                toReadCount: 4,
              ),
              const SizedBox(height: 10),
              ProfileOption(
                icon: Icons.person_outline,
                title: 'Éditer le profil',
                subtitle: 'Modifier vos informations personnelles',
                onTap: () => Get.to(() => EditProfilePage()),
              ),
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              ProfileOption(
                icon: Icons.settings_outlined,
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

              // Section "À lire plus tard"
              _buildToReadLaterSection(),

              // Bouton de déconnexion
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

  Widget _buildToReadLaterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'À lire plus tard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Couverture du livre
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://books.google.com/books/content?id=8tAn3HYf898C&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Titre et auteur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Les Misérables',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Victor Hugo',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Icône d'enregistrement
                IconButton(
                  icon: const Icon(Icons.bookmark, color: Colors.blue),
                  onPressed: () {
                    // Action pour retirer de la liste "À lire plus tard"
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
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
