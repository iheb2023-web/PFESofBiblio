import 'package:app/initializer.dart';

import 'imports.dart';

void main() async {
  await AppInitializer.initializeCriticalServices();
  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppInitializer.initializeNonCriticalServices();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final socketService = Get.find<SocketService>();

    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(socketService));

    return GetMaterialApp(
      title: 'SoftBiblio',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBinding(),
      defaultTransition: Transition.fade,
      initialRoute: '/onboarding',
      getPages: [
        GetPage(name: '/home', page: () => const NavigationMenu()),
        GetPage(name: '/onboarding', page: () => const Onboardingscreen()),
        GetPage(
          name: '/mes-demandes',
          page: () => MesDemandesPage(),
          transition: Transition.rightToLeft,
        ),
      ],
      home: Obx(
        () =>
            authController.currentUser.value != null
                ? const NavigationMenu()
                : const Onboardingscreen(),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final SocketService socketService;

  _AppLifecycleObserver(this.socketService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      socketService.disconnect();
    }
  }
}
