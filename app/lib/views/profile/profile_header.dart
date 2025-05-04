import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/user_model.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final User user;
  final int borrowsCount;
  final int booksCount;
  final int toReadCount;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.borrowsCount,
    required this.booksCount,
    required this.toReadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                backgroundImage:
                    user.image != null
                        ? NetworkImage(
                          '${user.image}?t=${DateTime.now().millisecondsSinceEpoch}',
                        )
                        : null,
                child:
                    user.image == null
                        ? Text(
                          user.firstname.isNotEmpty
                              ? user.firstname.substring(0, 1).toUpperCase()
                              : '',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.blue,
                          ),
                        )
                        : null,
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.blue,
                  ),
                  onPressed: () => _pickAndUploadImage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${user.firstname} ${user.lastname}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.email}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Emprunts', borrowsCount.toString()),
              _buildStatItem('Mes Livres', booksCount.toString()),
              _buildStatItem('À lire', toReadCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await Get.bottomSheet<XFile?>(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Prendre une photo'),
              onTap: () async {
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                );
                Get.back(result: picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                Get.back(result: picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Annuler'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );

    if (image != null) {
      try {
        final AuthController authController = Get.find<AuthController>();
        final String? imageUrl = await authController.uploadProfileImage(
          File(image.path),
        );

        if (imageUrl != null) {
          final updatedUser = User(
            id: user.id,
            firstname: user.firstname,
            lastname: user.lastname,
            email: user.email,
            phone: user.phone,
            job: user.job,
            birthday: user.birthday,
            image: imageUrl,
            role: user.role,
          );
          authController.currentUser.value = updatedUser;

          Get.showSnackbar(
            const GetSnackBar(
              message: 'Photo de profil mise à jour',
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
        }
      } catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Erreur lors de l\'upload: $e',
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      }
    }
  }
}
