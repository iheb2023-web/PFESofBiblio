import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/controllers/theme_controller.dart';

class NewPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ThemeController themeController;

  const NewPasswordField({
    super.key,
    required this.controller,
    this.onChanged,
    required this.themeController,
  });

  @override
  State<NewPasswordField> createState() => _NewPasswordFieldState();
}

class _NewPasswordFieldState extends State<NewPasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'new_password'.tr,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: !_isVisible,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'enter_new_password'.tr,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _isVisible = !_isVisible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    widget.themeController.isDarkMode
                        ? Colors.white24
                        : Colors.grey[300]!,
              ),
            ),
            filled: true,
            fillColor:
                widget.themeController.isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_new_password'.tr;
            }
            if (value.length < 8) {
              return 'password_too_short'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }
}

class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String password;
  final ThemeController themeController;

  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.password,
    required this.themeController,
  });

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'confirm_password'.tr,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: !_isVisible,
          decoration: InputDecoration(
            hintText: 'confirm_new_password'.tr,
            prefixIcon: const Icon(Icons.lock_reset),
            suffixIcon: IconButton(
              icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _isVisible = !_isVisible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    widget.themeController.isDarkMode
                        ? Colors.white24
                        : Colors.grey[300]!,
              ),
            ),
            filled: true,
            fillColor:
                widget.themeController.isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_confirm_password'.tr;
            }
            if (value != widget.password) {
              return 'passwords_do_not_match'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }
}
