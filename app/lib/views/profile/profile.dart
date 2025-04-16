// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:app/controllers/auth_controller.dart';
// import 'package:app/views/Authentification/login/LoginPage.dart';

// class ProfilePage extends GetView<AuthController> {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('profile'.tr)),
//       body: Obx(() {
//         final user = controller.currentUser.value;
//         final isLoading = controller.isLoading.value;

//         print('ProfilePage - État de chargement: $isLoading');
//         print('ProfilePage - Utilisateur: $user');
//         if (user != null) {
//           print('ProfilePage - ID utilisateur: ${user.id}');
//           print(
//             'ProfilePage - Données utilisateur complètes: ${user.toJson()}',
//           );
//         }

//         if (isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (user == null) {
//           print('ProfilePage - Redirection vers la page de connexion');
//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (!Get.isRegistered<AuthController>() ||
//                 controller.currentUser.value == null) {
//               Get.offAll(() => const LoginPage());
//             }
//           });
//           return const Center(
//             child: Text('Redirection vers la page de connexion...'),
//           );
//         }

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.blueAccent,
//                   child: Text(
//                     user.firstname.substring(0, 1).toUpperCase(),
//                     style: const TextStyle(fontSize: 40, color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Bonjour, ${user.firstname} ${user.lastname}',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Email: ${user.email}',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () async {
//                       await controller.logout();
//                     },
//                     icon: const Icon(Icons.logout, color: Colors.white),
//                     label: Text(
//                       'deconnexion'.tr,
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';

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
              // Section profil
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
                          child: Text(
                            user.firstname.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
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
                            onPressed: () {
                              // Logique pour changer la photo de profil
                              Get.snackbar(
                                'Photo de profil',
                                'Fonctionnalité de changement de photo à implémenter',
                                snackPosition: SnackPosition.BOTTOM,
                              );
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

              // Options du profil
              const SizedBox(height: 10),
              _buildProfileOption(
                context,
                icon: Icons.person_outline,
                title: 'Éditer le profil',
                subtitle: 'Modifier vos informations personnelles',
                onTap: () {
                  _navigateToEditProfile(context, user);
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                context,
                icon: Icons.lock_outline,
                title: 'Confidentialité et sécurité',
                subtitle: 'Gérer les paramètres de confidentialité',
                onTap: () {
                  _navigateToPrivacySecurity(context);
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                context,
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Gérer vos préférences de notifications',
                onTap: () {
                  _navigateToNotifications(context);
                },
              ),
              _buildDivider(),
              const SizedBox(height: 20),

              // Bouton de déconnexion
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Confirmation de déconnexion
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

  void _navigateToEditProfile(BuildContext context, dynamic user) {
    Get.to(() => EditProfilePage(user: user));
  }

  void _navigateToPrivacySecurity(BuildContext context) {
    Get.to(() => const PrivacySecurityPage());
  }

  void _navigateToNotifications(BuildContext context) {
    Get.to(() => const NotificationsPage());
  }
}

// Page d'édition de profil
class EditProfilePage extends StatefulWidget {
  final dynamic user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  final AuthController authController = Get.find<AuthController>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstname);
    lastNameController = TextEditingController(text: widget.user.lastname);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Implémentation à faire pour mettre à jour le profil
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      // Remplacer par votre logique réelle d'update
      // await authController.updateUserProfile({
      //   'firstname': firstNameController.text,
      //   'lastname': lastNameController.text,
      //   'email': emailController.text,
      //   'phone': phoneController.text,
      // });

      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Éditer le profil'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _updateProfile,
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
                      style: TextStyle(color: Colors.white),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      widget.user.firstname.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
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
                      onPressed: () {
                        Get.snackbar(
                          'Photo de profil',
                          'Fonctionnalité de changement de photo à implémenter',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
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
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: lastNameController,
              label: 'Nom',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              readOnly: true, // On ne permet pas de modifier l'email
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Téléphone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
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

// Page de confidentialité et sécurité
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
              Get.snackbar(
                'Changement de mot de passe',
                'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildSettingTile(
            'Authentification à deux facteurs',
            'Ajouter une couche de sécurité supplémentaire',
            Icons.security,
            onTap: () {
              Get.snackbar(
                '2FA',
                'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Paramètres de confidentialité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildSwitchTile(
            'Visibilité du profil',
            'Votre profil est visible pour les autres utilisateurs',
            Icons.visibility,
            true,
          ),
          _buildSwitchTile(
            'Partage des données',
            'Autoriser le partage anonyme des données d\'utilisation',
            Icons.data_usage,
            false,
          ),
          const Divider(),
          _buildSettingTile(
            'Supprimer le compte',
            'Supprimer définitivement votre compte et vos données',
            Icons.delete_outline,
            textColor: Colors.red,
            onTap: () {
              Get.defaultDialog(
                title: 'Attention',
                middleText:
                    'Cette action est irréversible. Voulez-vous vraiment supprimer votre compte?',
                textConfirm: 'Supprimer',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                textCancel: 'Annuler',
                onConfirm: () {
                  Get.snackbar(
                    'Suppression de compte',
                    'Fonctionnalité à implémenter',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.back();
                },
              );
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool initialValue,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                value = newValue;
              });
              Get.snackbar(
                'Paramètre mis à jour',
                '$title ${newValue ? 'activé' : 'désactivé'}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            activeColor: Colors.blue,
          ),
        );
      },
    );
  }
}

// Page des notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool activityUpdates = true;
  bool promotionalEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Paramètres de notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildNotificationSwitch(
            'Notifications push',
            'Recevoir des notifications sur votre appareil',
            Icons.notifications_active,
            pushNotifications,
            (value) {
              setState(() {
                pushNotifications = value;
              });
            },
          ),
          _buildNotificationSwitch(
            'Notifications par email',
            'Recevoir des notifications par email',
            Icons.email_outlined,
            emailNotifications,
            (value) {
              setState(() {
                emailNotifications = value;
              });
            },
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Types de notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          _buildNotificationSwitch(
            'Mises à jour d\'activité',
            'Notifications concernant votre activité sur l\'application',
            Icons.update,
            activityUpdates,
            (value) {
              setState(() {
                activityUpdates = value;
              });
            },
          ),
          _buildNotificationSwitch(
            'Emails promotionnels',
            'Recevoir des offres et nouvelles fonctionnalités',
            Icons.local_offer_outlined,
            promotionalEmails,
            (value) {
              setState(() {
                promotionalEmails = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          onChanged(newValue);
          Get.snackbar(
            'Paramètre mis à jour',
            '$title ${newValue ? 'activé' : 'désactivé'}',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        activeColor: Colors.blue,
      ),
    );
  }
}
