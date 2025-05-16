import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Contrôleurs pour les champs du formulaire
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Utiliser un délai pour éviter le build
    Future.delayed(Duration.zero, _loadUserData);
  }

  Future<void> _loadUserData() async {
    if (mounted) setState(() => isLoading = true);

    try {
      final userId = authController.currentUser.value?.id;
      if (userId == null) {
        _showErrorAndGoBack('Aucun utilisateur connecté');
        return;
      }

      _user = await authController
          .getUserById(userId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (_user == null) {
        _showErrorAndGoBack('Données utilisateur non disponibles');
        return;
      }

      // Mettre à jour les contrôleurs
      firstNameController.text = _user!.firstname;
      lastNameController.text = _user!.lastname;
      emailController.text = _user!.email;
      phoneController.text = _user!.phone?.toString() ?? '';
      jobController.text = _user!.job ?? '';
      if (_user!.birthday != null) {
        birthdayController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(_user!.birthday!);
      }
    } catch (e) {
      _showErrorAndGoBack('Erreur: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Affiche une erreur et retourne à l'écran précédent
  void _showErrorAndGoBack(String message) {
    // Ne pas appeler setState ici
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.back();
      Get.snackbar(
        'Erreur',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    });
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
    if (!_formKey.currentState!.validate() || _user == null) return;

    setState(() => isLoading = true);
    try {
      final userData = {
        'firstname': firstNameController.text.trim(),
        'lastname': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'number':
            phoneController.text.isNotEmpty
                ? int.tryParse(phoneController.text)
                : null,
        'job': jobController.text.trim(),
        'birthday':
            birthdayController.text.isNotEmpty ? birthdayController.text : null,
      };

      await authController.updateUserProfile(userData);
      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Éditer le profil')),
      body:
          isLoading || _user == null
              ? const Center(child: CircularProgressIndicator())
              : Form(
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
                                value!.trim().isEmpty
                                    ? 'Veuillez entrer votre prénom'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: lastNameController,
                        label: 'Nom',
                        icon: Icons.person_outline,
                        validator:
                            (value) =>
                                value!.trim().isEmpty
                                    ? 'Veuillez entrer votre nom'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        validator:
                            (value) =>
                                value!.isEmail
                                    ? null
                                    : 'Veuillez entrer un email valide',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: phoneController,
                        label: 'Numéro de téléphone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isNotEmpty &&
                              !RegExp(r'^\+?\d{8,8}$').hasMatch(value)) {
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
                              DateFormat('yyyy-MM-dd').parseStrict(value);
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

  /// Construit la section de l'image de profil
  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueAccent,
            backgroundImage:
                _user?.image != null
                    ? NetworkImage(
                      '${_user!.image}?t=${DateTime.now().millisecondsSinceEpoch}',
                    )
                    : null,
            child:
                _user?.image == null
                    ? Text(
                      _user!.firstname.isNotEmpty
                          ? _user!.firstname[0].toUpperCase()
                          : '',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    )
                    : null,
          ),
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

  /// Construit le bouton de sauvegarde
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

  /// Construit un champ de texte avec validation
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

  /// Permet de sélectionner et uploader une image de profil
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );

    if (image == null) return;

    setState(() => isLoading = true);
    try {
      final String? imageUrl = await authController
          .uploadProfileImage(File(image.path))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Délai d\'attente dépassé pour l\'upload de l\'image',
              );
            },
          );

      if (imageUrl != null) {
        final updatedUser = await authController.getUserById(
          authController.currentUser.value!.id!,
        );

        if (updatedUser != null) {
          authController.currentUser.value = updatedUser.copyWith(
            image: imageUrl,
          );
          Get.snackbar(
            'Succès',
            'Photo de profil mise à jour',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception('Impossible de récupérer les données mises à jour');
        }
      } else {
        throw Exception('Échec de l\'upload de l\'image');
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'upload: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
