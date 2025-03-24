import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/models/user_model.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';

class ProfilePage extends GetView<ThemeController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        appBar: AppBar(
          title: Text('profile'.tr),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to settings
              },
            ),
          ],
        ),
        body: Obx(() {
          final user = authController.currentUser.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => authController.refreshUserProfile(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: user.image != null && user.image!.isNotEmpty
                                  ? NetworkImage(user.image!)
                                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user.firstname ?? ''} ${user.lastname ?? ''}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          user.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat(context, '${user.borrowedBooks?.length ?? 0}', 'emprunts'.tr),
                            _buildStat(context, '${user.myBooks?.length ?? 0}', 'mes_livres'.tr),
                            _buildStat(context, '${user.toReadBooks?.length ?? 0}', 'a_lire'.tr),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'informations_personnelles'.tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(context, Icons.email, user.email ?? ''),
                        if (user.phone != null && user.phone!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(context, Icons.phone, user.phone!),
                        ],
                        if (user.address != null && user.address!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(context, Icons.location_on, user.address!),
                        ],
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'apparence'.tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Icon(
                            themeController.themeMode == ThemeMode.system
                                ? Icons.brightness_auto
                                : themeController.themeMode == ThemeMode.dark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                          ),
                          title: Text('theme'.tr),
                          subtitle: Text(
                            themeController.themeMode == ThemeMode.system
                                ? 'theme_system'.tr
                                : themeController.themeMode == ThemeMode.dark
                                    ? 'theme_dark'.tr
                                    : 'theme_light'.tr,
                          ),
                          onTap: themeController.toggleTheme,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          authController.logout();
                          Get.offAll(() => const LoginPage());
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'deconnexion'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}