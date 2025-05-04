import 'package:app/imports.dart';
import 'package:app/views/chatbot/chatbot.dart';
import 'package:lottie/lottie.dart';

class ChatbotButton extends StatelessWidget {
  final AnimationController animationController;

  const ChatbotButton({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animationController.value * 5),
          child: FloatingActionButton(
            onPressed: () {
              Get.to(() => ChatScreen());
            }, // Chat action
            elevation: 4,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 150,
              width: 150,
              child: Lottie.asset(
                'assets/lottie/chatbot.json',
                fit: BoxFit.cover,
                frameRate: FrameRate(60),
                repeat: true,
                options: LottieOptions(enableMergePaths: true),
              ),
            ),
          ),
        );
      },
    );
  }
}
