import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app/views/NavigationMenu.dart';
import 'package:app/views/Authentification/Step/Préférences.dart';
import 'package:app/views/Authentification/login/forgot_password_screen.dart';
import 'package:app/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
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
      print("Authentification réussie !");
      Get.off(() => const NavigationMenu());
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              const SizedBox(height: 20),
              const Text(
                "Connectez-vous",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),

              // Section Email/Mot de passe
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(140, 99, 125, 255),
                      blurRadius: 3,
                      spreadRadius: 0.01,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Email",
                        icon: Icon(Icons.person, color: Colors.grey),
                        border: UnderlineInputBorder(),
                      ),
                      controller: emailController,
                      style: const TextStyle(fontFamily: "Sora", fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: _isHidden,
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: "Mot de Passe",
                        icon: const Icon(Icons.lock, color: Colors.grey),
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                          icon: Icon(
                            !_isHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.7,
                          50,
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          Get.snackbar(
                            'Erreur',
                            'Veuillez remplir tous les champs',
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
                          Get.to(() => const PreferencesPage());
                        } catch (e) {
                          Get.snackbar(
                            'Erreur',
                            'Identifiants incorrects',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Text(
                        "Se Connecter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Get.to(() => const ForgotPasswordScreen());
                },
                child: const Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    fontFamily: "Sora",
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "ou",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),

              const Text(
                "Utiliser votre empreinte pour vous connecter\nà votre compte",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                    onPressed: _canCheckBiometrics ? _authenticate : null,
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
