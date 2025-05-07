import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';
import 'package:app/views/ChangerMdp/password_fields.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  final String? email; // Si vous utilisez un token pour la réinitialisation
  const ChangePasswordPage({super.key, this.email});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Appel au AuthController pour réinitialiser le mot de passe
      await Get.find<AuthController>().resetPassword(
        _newPasswordController.text,
      );
      // Rediriger vers la page de connexion
      Get.offAll(() => const LoginPage());
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Widgets simplifiés (suppression du champ currentPassword)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('reset_password'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              NewPasswordField(
                controller: _newPasswordController,
                onChanged: (_) => setState(() {}), // Pour rafraîchir l'UI
                themeController: Get.find<ThemeController>(),
              ),

              ConfirmPasswordField(
                controller: _confirmPasswordController,
                password: _newPasswordController.text, // Pour la validation
                themeController: Get.find<ThemeController>(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text('reset_password'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
