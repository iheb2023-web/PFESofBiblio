import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Obx(() {
        final user = controller.currentUser.value;
        final isLoading = controller.isLoading.value;

        print('ProfilePage - État de chargement: $isLoading');
        print('ProfilePage - Utilisateur: $user');
        if (user != null) {
          print('ProfilePage - ID utilisateur: ${user.id}');
          print(
            'ProfilePage - Données utilisateur complètes: ${user.toJson()}',
          );
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          print('ProfilePage - Redirection vers la page de connexion');
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    user.firstname.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bonjour, ${user.firstname} ${user.lastname}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${user.email}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controller.logout();
                    },
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
              ],
            ),
          ),
        );
      }),
    );
  }
}
