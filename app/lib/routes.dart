import 'package:get/get.dart';
import 'package:app/views/NavigationMenu.dart';
import 'package:app/views/Authentification/onBoardingScreen.dart';
import 'package:app/views/Ma_Biblio/mes_demandes.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: '/home', page: () => const NavigationMenu()),
    GetPage(name: '/onboarding', page: () => const Onboardingscreen()),
    GetPage(
      name: '/mes-demandes',
      page: () => MesDemandesPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
