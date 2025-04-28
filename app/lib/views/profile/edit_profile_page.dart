import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController jobController;
  late TextEditingController birthdayController;
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstname);
    lastNameController = TextEditingController(text: widget.user.lastname);
    emailController = TextEditingController(text: widget.user.email);
    print('Numéro de téléphone ****** ${widget.user.phone}');
    phoneController = TextEditingController(text: widget.user.phone);
    jobController = TextEditingController(text: widget.user.job);
    birthdayController = TextEditingController(
      text:
          widget.user.birthday != null
              ? DateFormat('yyyy-MM-dd').format(widget.user.birthday!)
              : '',
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    jobController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final userData = {
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'email': emailController.text,
        'number': phoneController.text.isNotEmpty ? phoneController.text : null,
        'job': jobController.text,
        'birthday': birthdayController.text,
      };

      await authController.updateUserProfile(userData);

      final updatedUser = User(
        id: widget.user.id,
        firstname: userData['firstname'] as String,
        lastname: userData['lastname'] as String,
        email: userData['email'] as String,
        phone: userData['number'] as String?,
        job: userData['job'] as String,
        birthday:
            userData['birthday'] is String &&
                    (userData['birthday'] as String).isNotEmpty
                ? DateFormat('yyyy-MM-dd').parse(userData['birthday'] as String)
                : null,
        image: widget.user.image,
        role: widget.user.role,
      );
      authController.currentUser.value = updatedUser;

      Get.back();
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Impossible de mettre à jour le profil: $e',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Éditer le profil')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileImageSection(),
              const SizedBox(height: 30),
              _buildTextField(
                controller: firstNameController,
                label: 'Prénom',
                icon: Icons.person_outline,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Veuillez entrer votre prénom' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: lastNameController,
                label: 'Nom',
                icon: Icons.person_outline,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Veuillez entrer votre nom' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // L'email est souvent en lecture seule
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: 'Numéro de téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Veuillez entrer un numéro valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: jobController,
                label: 'Profession',
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: birthdayController,
                label: 'Date de naissance',
                icon: Icons.cake_outlined,
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    birthdayController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  }
                },
                validator: (value) {
                  if (value!.isNotEmpty) {
                    try {
                      DateFormat('yyyy-MM-dd').parse(value);
                    } catch (e) {
                      return 'Format de date invalide (yyyy-MM-dd)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              backgroundImage:
                  user?.image != null
                      ? NetworkImage(
                        '${user!.image}?t=${DateTime.now().millisecondsSinceEpoch}',
                      )
                      : null,
              child:
                  user?.image == null
                      ? Text(
                        widget.user.firstname.isNotEmpty
                            ? widget.user.firstname
                                .substring(0, 1)
                                .toUpperCase()
                            : '',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                      : null,
            );
          }),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.blue),
              onPressed: isLoading ? null : _pickAndUploadImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Text(
                  'Enregistrer',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
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
        final String? imageUrl = await authController.uploadProfileImage(
          // Remplacez controller par authController
          File(image.path),
        );
        if (imageUrl != null) {
          // Update local user state immediately
          final updatedUser = User(
            id: authController.currentUser.value!.id,
            firstname: authController.currentUser.value!.firstname,
            lastname: authController.currentUser.value!.lastname,
            email: authController.currentUser.value!.email,
            phone: authController.currentUser.value!.phone,
            job: authController.currentUser.value!.job,
            birthday: authController.currentUser.value!.birthday,
            image: imageUrl,
            role: authController.currentUser.value!.role,
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
        } else {
          Get.showSnackbar(
            const GetSnackBar(
              message: 'Échec de l\'upload de l\'image',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
        }
      } catch (e) {
        print('Error uploading image: $e');
        Get.showSnackbar(
          GetSnackBar(
            message: 'Erreur lors de l\'upload: $e',
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }
}
