import 'package:app/views/ChangerMdp/password_fields.dart';
import 'package:app/views/ChangerMdp/password_strength_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    Get.snackbar(
      'success'.tr,
      'password_changed_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color:
                  Get.find<ThemeController>().isDarkMode
                      ? AppTheme.darkSurfaceColor
                      : AppTheme.lightSurfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.lock_outline,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'update_your_password'.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'password_requirements'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'update_password'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Naviguer vers la page de réinitialisation
        },
        child: Text(
          'forgot_password'.tr,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            appBar: AppBar(
              title: Text(
                'change_password'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor:
                  themeController.isDarkMode
                      ? Colors.white
                      : AppTheme.lightTextColor,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      CurrentPasswordField(
                        controller: _currentPasswordController,
                        themeController: themeController,
                      ),
                      const SizedBox(height: 24),
                      NewPasswordField(
                        controller: _newPasswordController,
                        themeController: themeController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      ConfirmPasswordField(
                        controller: _confirmPasswordController,
                        password: _newPasswordController.text,
                        themeController: themeController,
                      ),
                      if (_newPasswordController.text.isNotEmpty) ...[
                        const SizedBox(height: 40),
                        PasswordStrengthIndicator(
                          password: _newPasswordController.text,
                        ),
                      ],
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                      _buildForgotPasswordLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
