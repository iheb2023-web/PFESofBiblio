import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/models/user_model.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';
import 'dart:io';

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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent,
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
                                        ? user.firstname
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
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
                            onPressed: () async {
                              await _pickAndUploadImage();
                            },
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
                      user.email,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildProfileOption(
                context,
                icon: Icons.person_outline,
                title: 'Éditer le profil',
                subtitle: 'Modifier vos informations personnelles',
                onTap: () {
                  Get.to(() => EditProfilePage(user: user));
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                context,
                icon: Icons.lock_outline,
                title: 'Confidentialité et sécurité',
                subtitle: 'Gérer les paramètres de confidentialité',
                onTap: () {
                  Get.to(() => const PrivacySecurityPage());
                },
              ),
              _buildDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.defaultDialog(
                        title: 'Confirmation',
                        middleText:
                            'Êtes-vous sûr de vouloir vous déconnecter?',
                        textConfirm: 'Déconnexion',
                        textCancel: 'Annuler',
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () async {
                          await controller.logout();
                        },
                      );
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
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
        final String? imageUrl = await controller.uploadProfileImage(
          File(image.path),
        );
        if (imageUrl != null) {
          // Update local user state immediately
          final updatedUser = User(
            id: controller.currentUser.value!.id,
            firstname: controller.currentUser.value!.firstname,
            lastname: controller.currentUser.value!.lastname,
            email: controller.currentUser.value!.email,
            phone: controller.currentUser.value!.phone,
            job: controller.currentUser.value!.job,
            birthday: controller.currentUser.value!.birthday,
            image: imageUrl,
            role: controller.currentUser.value!.role,
          );
          controller.currentUser.value = updatedUser;

          Get.showSnackbar(
            const GetSnackBar(
              message: 'Photo de profil mise à jour',
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
          await Future.delayed(const Duration(seconds: 3));
        } else {
          Get.showSnackbar(
            const GetSnackBar(
              message: 'Échec de l\'upload de l\'image',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
          await Future.delayed(const Duration(seconds: 3));
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

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

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
    phoneController = TextEditingController(text: widget.user.phone ?? '');
    jobController = TextEditingController(text: widget.user.job ?? '');
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userData = {
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'email': emailController.text,
        'number': phoneController.text.isNotEmpty ? phoneController.text : null,
        'job': jobController.text,
        'birthday': birthdayController.text,
      };

      print('Updating profile with userData: $userData');
      await authController.updateUserProfile(userData);

      // Update local user state immediately
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

      await Future.delayed(const Duration(seconds: 3));
      Get.back();
    } catch (e) {
      print('Error updating profile: $e');
      Get.showSnackbar(
        GetSnackBar(
          message: 'Impossible de mettre à jour le profil: $e',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
      setState(() {
        isLoading = true;
      });
      try {
        print('Uploading image: ${image.path}');
        final String? imageUrl = await authController.uploadProfileImage(
          File(image.path),
        );
        print('Image upload result: $imageUrl');
        if (imageUrl != null) {
          // Update local user state immediately
          final updatedUser = User(
            id: widget.user.id,
            firstname: widget.user.firstname,
            lastname: widget.user.lastname,
            email: widget.user.email,
            phone: widget.user.phone,
            job: widget.user.job,
            birthday: widget.user.birthday,
            image: imageUrl,
            role: widget.user.role,
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
          await Future.delayed(const Duration(seconds: 3));
        } else {
          Get.showSnackbar(
            const GetSnackBar(
              message: 'Échec de l\'upload de l\'image',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
          await Future.delayed(const Duration(seconds: 3));
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
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
              Center(
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
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.blue,
                        ),
                        onPressed: isLoading ? null : _pickAndUploadImage,
                      ),
                    ),
                  ],
                ),
              ),
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
                readOnly: true,
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
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Veuillez entrer votre profession'
                            : null,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              ),
            ],
          ),
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
}

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confidentialité et sécurité')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Paramètres de sécurité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildSettingTile(
            'Changer le mot de passe',
            'Mettre à jour votre mot de passe actuel',
            Icons.lock_outline,
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.blue),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _currentPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;
    bool _isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _changePassword() async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              setState(() {
                _isLoading = true;
              });

              try {
                // TODO: Implement actual password change logic
                await Future.delayed(const Duration(seconds: 1)); // Simulation
                Get.back();
                Get.showSnackbar(
                  const GetSnackBar(
                    message: 'Mot de passe modifié avec succès',
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                );
              } catch (e) {
                Get.showSnackbar(
                  GetSnackBar(
                    message: 'Impossible de modifier le mot de passe: $e',
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Changer le mot de passe'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe actuel',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe actuel';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nouveau mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
