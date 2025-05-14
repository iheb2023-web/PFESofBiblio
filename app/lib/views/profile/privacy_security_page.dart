import 'package:app/imports.dart';
import 'package:app/controllers/theme_controller.dart'; // Importez votre ThemeController

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

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
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.blue),
            title: const Text('Changer le mot de passe'),
            subtitle: const Text('Mettre à jour votre mot de passe actuel'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(height: 1),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.blue),
              title: const Text('Mode sombre'),
              subtitle: Text(themeController.isDarkMode ? 'Actif' : 'Inactif'),
              trailing: Switch(
                value: themeController.isDarkMode,
                onChanged: (value) async {
                  await themeController.toggleTheme();
                },
                activeColor: Colors.blue,
              ),
              onTap: () async {
                await themeController.toggleTheme();
              },
            ),
          ),
        ],
      ),
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
