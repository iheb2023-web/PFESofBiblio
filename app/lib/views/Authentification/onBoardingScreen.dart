import 'package:app/themeData.dart';
import 'package:app/views/Authentification/pageDesign.dart';
//import 'package:softbiblio/views/Authentification/singnup/SignupPage.dart';
import 'package:app/widgets/Button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/views/Authentification/login/LoginPage.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.only(
              // Padding adaptatif
              bottom: screenHeight * (isPortrait ? 0.2 : 0.1),
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            child: PageView(
              controller: controller,
              onPageChanged: (value) {
                setState(() {
                  index = value;
                });
              },
              children: [
                BuildPage(
                  title: 'find_book'.tr,
                  description: 'find_book_desc'.tr,
                  path: "assets/lottie/livres.json",
                ),
                BuildPage(
                  title: 'dive_reading'.tr,
                  description: 'dive_reading_desc'.tr,
                  path: "assets/lottie/lecture1.json",
                ),
                BuildPage(
                  title: 'reserve_instant'.tr,
                  description: 'reserve_instant_desc'.tr,
                  path: "assets/lottie/réservation.json",
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        height: screenHeight * (isPortrait ? 0.25 : 0.35),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'back'.tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontFamily: "Sora",
                        fontWeight: FontWeight.w400,
                        color: index == 0
                            ? Theme.of(context).scaffoldBackgroundColor
                            : blueColor,
                      ),
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: WormEffect(
                      activeDotColor: blueColor,
                      dotColor: Colors.grey,
                      dotHeight: screenWidth * 0.025,
                      dotWidth: screenWidth * 0.025,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'next'.tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontFamily: "Sora",
                        fontWeight: FontWeight.w700,
                        color: index == 2
                            ? Theme.of(context).scaffoldBackgroundColor
                            : blueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MyButton(
              onTap: () {
                Get.to(() => LoginPage(), transition: Transition.rightToLeft);
              },
              label: 'sign_in'.tr,
              width: screenWidth * 0.85,
              height: screenHeight * (isPortrait ? 0.06 : 0.08),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
