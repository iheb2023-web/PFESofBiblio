import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';

class ProfilePage extends GetView<ThemeController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de profil et statistiques
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Photo de profil
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: const AssetImage('assets/images/default_profile.png'),
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
                    // Nom et username
                    Text(
                      'Marie Dupont',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '@mariedupont',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    // Statistiques
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(context, '12', 'emprunts'.tr),
                        _buildStat(context, '8', 'mes_livres'.tr),
                        _buildStat(context, '4', 'a_lire'.tr),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Informations personnelles
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
                    _buildInfoRow(context, Icons.email, 'marie.dupont@email.com'),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, Icons.phone, '+33 6 12 34 56 78'),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, Icons.location_on, 'Paris, France'),
                  ],
                ),
              ),
              const Divider(),
              // Thème
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
              // Centres d'intérêt
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'centres_interet'.tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInterestChip(context, 'Roman'),
                        _buildInterestChip(context, 'Science-Fiction'),
                        _buildInterestChip(context, 'Histoire'),
                        _buildInterestChip(context, 'Philosophie'),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // À lire plus tard
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'a_lire_plus_tard'.tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildBookToRead(
                      context,
                      'Les Misérables',
                      'Victor Hugo',
                      'assets/images/les_miserables.jpg',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildInterestChip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: AppTheme.primaryColor),
    );
  }

  Widget _buildBookToRead(
    BuildContext context,
    String title,
    String author,
    String coverImage,
  ) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            coverImage,
            width: 40,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(title),
        subtitle: Text(author),
        trailing: const Icon(Icons.bookmark),
      ),
    );
  }
}