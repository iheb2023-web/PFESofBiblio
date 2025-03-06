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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.2,
          left: 30,
          right: 30,
        ),
        child: PageView(
          controller: controller,
          onPageChanged: (value) {
            setState(() {
              index = value;
            });
          },
          children: const [
            BuildPage(
              title: "Trouvez votre lecture en un clic !",
              description:
                  "À la recherche d'un livre ? Découvrez et partagez facilement des ouvrages pour enrichir votre bibliothèque en un seul clic.",
              path: "assets/lottie/livres.json",
            ),

            BuildPage(
              title: "Plongez dans un univers de lecture !",
              description:
                  "Laissez-vous inspirer par une collection de livres variée et trouvez celui qui vous transportera dans une nouvelle aventure.",
              path: "assets/lottie/lecture1.json",
            ),
            BuildPage(
              title: "Réservez votre livre en un instant !",
              description:
                  "Trouvez le livre qui vous passionne et réservez-le en toute simplicité pour en profiter sans attendre.",
              path: "assets/lottie/réservation.json",
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.3,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
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
                      "Back",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Sora",
                        fontWeight: FontWeight.w400,
                        color:
                            index == 0
                                ? Theme.of(context).scaffoldBackgroundColor
                                : blueColor,
                      ),
                    ),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: const WormEffect(
                        activeDotColor: blueColor,
                        dotColor: Colors.grey,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
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
                      "Next",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Sora",
                        fontWeight: FontWeight.w700,
                        color:
                            index == 2
                                ? Theme.of(context).scaffoldBackgroundColor
                                : blueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: MyButton(
                onTap: () {
                  Get.to(() => LoginPage(), transition: Transition.rightToLeft);
                },
                label: "Se Connecter",
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.06,
              ),
            ),
            // Supprimez ou commentez tout le TextButton, pas seulement une partie
            /*TextButton(
                onPressed: () {
                  Get.to(() => LoginPage(),
                      transition: Transition.rightToLeft);
                },
                child: const Text(
                  "Pas de compte? Créer Un",
                  style: TextStyle(
                      fontFamily: "Sora",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: blueColor),
                )),*/
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
