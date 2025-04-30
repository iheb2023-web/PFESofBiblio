import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final List<String> categories = [
    'all'.tr,
    'fiction'.tr,
    'business'.tr,
    'science'.tr,
    'history'.tr,
  ];

  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (controller) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children:
                  categories
                      .map((category) => _buildChip(category, controller))
                      .toList(),
            ),
          ),
    );
  }

  Widget _buildChip(String category, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => setState(() {
                selectedCategory =
                    selectedCategory == category ? null : category;
              }),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color:
                  selectedCategory == category
                      ? AppTheme.primaryColor
                      : (themeController.isDarkMode
                          ? AppTheme.darkSurfaceColor
                          : AppTheme.lightSurfaceColor),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color:
                    selectedCategory == category
                        ? AppTheme.primaryColor
                        : themeController.isDarkMode
                        ? Colors.white24
                        : Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                if (selectedCategory == category)
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              category,
              style: TextStyle(
                color:
                    selectedCategory == category
                        ? Colors.white
                        : (themeController.isDarkMode
                            ? Colors.white70
                            : AppTheme.lightTextColor),
                fontWeight:
                    selectedCategory == category
                        ? FontWeight.bold
                        : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
