import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  final _isDarkMode = false.obs;
  final _isSystemMode = true.obs;
  
  final String _themeKey = "theme_mode";
  final String _systemKey = "system_mode";
  
  bool get isDarkMode => _isDarkMode.value;
  bool get isSystemMode => _isSystemMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }
  
  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSystemMode.value = prefs.getBool(_systemKey) ?? true;
    _isDarkMode.value = prefs.getBool(_themeKey) ?? false;
    _updateTheme();
  }
  
  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode.value);
    await prefs.setBool(_systemKey, _isSystemMode.value);
  }
  
  void toggleDarkMode(bool value) {
    _isDarkMode.value = value;
    _isSystemMode.value = false;
    _saveThemeSettings();
    _updateTheme();
  }
  
  void toggleSystemMode(bool value) {
    _isSystemMode.value = value;
    _saveThemeSettings();
    _updateTheme();
  }
  
  void _updateTheme() {
    if (_isSystemMode.value) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      Get.changeThemeMode(ThemeMode.system);
      _isDarkMode.value = brightness == Brightness.dark;
    } else {
      Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    }
  }
} 