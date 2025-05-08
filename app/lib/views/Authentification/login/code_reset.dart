// import 'package:app/controllers/auth_controller.dart';
// import 'package:app/views/ChangerMdp/changerMdp.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ResetCodePage extends StatefulWidget {
//   final String email;

//   const ResetCodePage({Key? key, required this.email}) : super(key: key);

//   @override
//   _ResetCodePageState createState() => _ResetCodePageState();
// }

// class _ResetCodePageState extends State<ResetCodePage> {
//   final List<TextEditingController> _controllers = List.generate(
//     4,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
//   final AuthController authController = Get.find<AuthController>();
//   int? _verificationCode;
//   bool _isLoading = false;
//   bool _isError = false;

//   @override
//   void initState() {
//     super.initState();
//     // Retarde l'appel après la fin du build initial
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadVerificationCode();
//     });
//   }

//   Future<void> _loadVerificationCode() async {
//     setState(() {
//       _isLoading = true;
//       _isError = false;
//     });

//     try {
//       print("voici email ${widget.email}");
//       // Appel à votre fonction verifyResetCode
//       _verificationCode = await authController.verifyResetCode(widget.email);
//       print("verfification code $_verificationCode");
//     } catch (e) {
//       setState(() {
//         _isError = true;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _onChanged(int index, String value) {
//     if (value.isNotEmpty && index < 3) {
//       _focusNodes[index + 1].requestFocus();
//     }

//     _checkCode();
//   }

//   void _checkCode() {
//     final enteredCode = _controllers.map((c) => c.text).join();
//     if (enteredCode.length == 4 && _verificationCode != null) {
//       if (enteredCode == _verificationCode.toString()) {
//         Get.offAll(() => ChangePasswordPage(email: widget.email));
//       } else {
//         setState(() {
//           _isError = true;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Vérification du code')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Entrez le code de vérification envoyé à votre email',
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (_isError)
//               const Text(
//                 'Erreur lors de la vérification du code',
//                 style: TextStyle(color: Colors.red),
//               )
//             else
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(4, (index) {
//                   return SizedBox(
//                     width: 50,
//                     child: TextField(
//                       controller: _controllers[index],
//                       focusNode: _focusNodes[index],
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       decoration: const InputDecoration(
//                         counterText: '',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => _onChanged(index, value),
//                     ),
//                   );
//                 }),
//               ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadVerificationCode,
//               child: const Text('Renvoyer le code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/ChangerMdp/changerMdp.dart';
import 'package:app/views/resetMdp/changerMdp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetCodePage extends StatefulWidget {
  final String email;

  const ResetCodePage({Key? key, required this.email}) : super(key: key);

  @override
  _ResetCodePageState createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final AuthController authController = Get.find<AuthController>();
  int? _verificationCode;
  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVerificationCode();
    });
  }

  Future<void> _loadVerificationCode() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      print("voici email ${widget.email}");
      _verificationCode = await authController.verifyResetCode(widget.email);
      print("verfification code $_verificationCode");
    } catch (e) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    _checkCode();
  }

  void _checkCode() {
    final enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode.length == 4 && _verificationCode != null) {
      if (enteredCode == _verificationCode.toString()) {
        Get.offAll(() => ResetPasswordPage(email: widget.email));
      } else {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du code')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Entrez le code de vérification envoyé à votre email',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_isError)
                const Text(
                  'Erreur lors de la vérification du code',
                  style: TextStyle(color: Colors.red),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _onChanged(index, value),
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadVerificationCode,
                child: const Text('Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
