import 'package:app/imports.dart';
import 'package:app/views/ChangerMdp/changerMdp.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:app/views/Authentification/Step/Préférences.dart';
import 'package:app/views/Authentification/login/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  final StorageService _storageService = StorageService();
  String? email;
  bool _isHidden = true;
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  String _authorizedOrNot = "Non autorisé";
  // Vérifier si l'appareil supporte la biométrie
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  void _loadToken() {
    final user = authController.currentUser.value;
    if (user != null) {
      setState(() {
        email = user.email;
      });
    } else {
      print("Aucun utilisateur connecté");
    }
  }

  // Authentifier avec la biométrie
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scannez votre empreinte pour vous connecter',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) return;

    setState(() {
      _authorizedOrNot = authenticated ? "Autorisé" : "Non autorisé";
    });

    if (authenticated) {
      // Naviguer vers la page suivante ou effectuer l'action souhaitée
      Get.off(() => const NavigationMenu());
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/images/logo.png', height: 150),
              const SizedBox(height: 20),
              Text(
                'login'.tr,
                style: const TextStyle(
                  fontFamily: "Sora",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(140, 99, 125, 255),
                      blurRadius: 3,
                      spreadRadius: 0.01,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 0, color: Colors.transparent),
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'email'.tr,
                    icon: const Icon(Icons.person, color: Colors.grey),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  style: const TextStyle(fontFamily: "Sora", fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(140, 99, 125, 255),
                      blurRadius: 3,
                      spreadRadius: 0.01,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 0, color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        obscureText: _isHidden,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'password'.tr,
                          icon: const Icon(Icons.lock, color: Colors.grey),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        style: const TextStyle(
                          fontFamily: "Sora",
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isHidden = !_isHidden;
                        });
                      },
                      icon: Icon(
                        !_isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.9,
                    50,
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    Get.snackbar(
                      'error'.tr,
                      'fill_all_fields'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    await authController.login(
                      emailController.text,
                      passwordController.text,
                    );

                    if (authController.currentUser.value != null) {
                      final currentUser =
                          authController
                              .currentUser
                              .value!; // Utilisation de '!' pour accéder à l'objet non nul
                      if (currentUser.hasSetPassword != null &&
                          currentUser.hasSetPassword!) {
                        if (currentUser.hasPreference != null &&
                            currentUser.hasPreference!) {
                          // Si 'hasPreference' est true, redirige vers le menu de navigation
                          Get.offAll(() => const NavigationMenu());
                        } else {
                          // Si 'hasPreference' est false, redirige vers la page de préférences

                          Get.offAll(() => const PreferencesPage());
                        }
                      } else {
                        Get.offAll(() => ChangePasswordPage(email: email));
                      }
                    }
                  } catch (e) {
                    print("probleme");
                  }
                },
                child: Text(
                  'sign_in'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Sora",
                  ),
                ),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Get.to(() => const ForgotPasswordScreen());
                },
                child: Text(
                  'forgot_password'.tr,
                  style: const TextStyle(
                    fontFamily: "Sora",
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Divider(color: Colors.grey, height: 1, thickness: 1),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Text(
                        'or'.tr,
                        style: const TextStyle(
                          fontFamily: "Sora",
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                'sign_in_with_fingerprint'.tr,
                style: const TextStyle(
                  fontFamily: "Sora",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),
              if (_canCheckBiometrics)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.fingerprint,
                        size: 40,
                        color: Colors.blue,
                      ),
                      onPressed: _authenticate,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
