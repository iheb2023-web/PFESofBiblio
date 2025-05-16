import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;
  final _themeModeKey = 'themeMode';

  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();

    // Écouter les changements de thème système
    SchedulerBinding
        .instance
        .platformDispatcher
        .onPlatformBrightnessChanged = () {
      if (_themeMode.value == ThemeMode.system) {
        update();
      }
    };
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex =
        prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode.value = ThemeMode.values[themeModeIndex];
    Get.changeThemeMode(_themeMode.value);
    update();
  }

  Future<void> toggleTheme() async {
    ThemeMode newMode;

    switch (_themeMode.value) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
    }

    _themeMode.value = newMode;
    Get.changeThemeMode(newMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, newMode.index);
    update();
  }
}
