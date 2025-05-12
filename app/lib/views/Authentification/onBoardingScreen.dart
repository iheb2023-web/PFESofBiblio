import 'package:app/controllers/auth_controller.dart';
import 'package:app/themeData.dart';
import 'package:app/views/Authentification/pageDesign.dart';
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
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController
          .tryAutoLogin(); // Appel de l'auto-login après le rendu initial
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Contenu principal (PageView)
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
              ),
            ),
            // Navigation et boutons dans un Expanded
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicateurs et boutons Next/Back
                    Row(
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
                              fontSize: isTablet ? 16 : screenWidth * 0.035,
                              fontFamily: "Sora",
                              fontWeight: FontWeight.w400,
                              color:
                                  index == 0
                                      ? Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor
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
                            dotHeight: isTablet ? 12 : screenWidth * 0.025,
                            dotWidth: isTablet ? 12 : screenWidth * 0.025,
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
                              fontSize: isTablet ? 16 : screenWidth * 0.035,
                              fontFamily: "Sora",
                              fontWeight: FontWeight.w700,
                              color:
                                  index == 2
                                      ? Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor
                                      : blueColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Bouton Sign In
                    MyButton(
                      onTap: () {
                        Get.to(
                          () => LoginPage(),
                          transition: Transition.rightToLeft,
                        );
                      },
                      label: 'sign_in'.tr,
                      width: isTablet ? screenWidth * 0.5 : screenWidth * 0.85,
                      height: 38,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
