import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  int _calculateStrength() {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  Widget _buildRule(String rule, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle : Icons.circle_outlined,
            color: isSatisfied ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            rule,
            style: TextStyle(
              color: isSatisfied ? Colors.green : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final Color strengthColor =
        strength <= 2
            ? Colors.red
            : strength <= 4
            ? Colors.orange
            : Colors.green;
    final String strengthText =
        strength <= 2
            ? 'weak'.tr
            : strength <= 4
            ? 'medium'.tr
            : 'strong'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'password_strength'.tr,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength / 6,
                  backgroundColor: Colors.grey[300],
                  color: strengthColor,
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: TextStyle(
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRule('min_8_characters'.tr, password.length >= 8),
        _buildRule(
          'contains_uppercase'.tr,
          RegExp(r'[A-Z]').hasMatch(password),
        ),
        _buildRule(
          'contains_lowercase'.tr,
          RegExp(r'[a-z]').hasMatch(password),
        ),
        _buildRule('contains_number'.tr, RegExp(r'[0-9]').hasMatch(password)),
        _buildRule(
          'contains_special_char'.tr,
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
        ),
      ],
    );
  }
}
