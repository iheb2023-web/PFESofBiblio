import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';

class MesLivresPage extends GetView<ThemeController> {
  const MesLivresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBookCard(
              context,
              title: 'Le Petit Prince',
              author: 'Antoine de Saint-Exupéry',
              isAvailable: true,
              coverImage: 'assets/images/couverture1.png',
            ),
            const SizedBox(height: 12),
            _buildBookCard(
              context,
              title: '1984',
              author: 'George Orwell',
              isAvailable: false,
              borrowedBy: 'Marie D.',
              coverImage: 'assets/images/couverture2.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context, {
    required String title,
    required String author,
    required bool isAvailable,
    String? borrowedBy,
    required String coverImage,
  }) {
    final theme = Theme.of(context);
    final isDark = controller.isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to book details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Book cover
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(coverImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.darkSecondaryTextColor : AppTheme.lightSecondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAvailable ? 'disponible'.tr : 'emprunté'.tr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isAvailable ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (borrowedBy != null) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              borrowedBy[0],
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'emprunté_par'.trParams({'name': borrowedBy}),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppTheme.darkSecondaryTextColor : AppTheme.lightSecondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: isDark ? AppTheme.darkSecondaryTextColor : AppTheme.lightSecondaryTextColor,
                    ),
                    onPressed: () {
                      // TODO: Edit book
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: isDark ? AppTheme.darkSecondaryTextColor : AppTheme.lightSecondaryTextColor,
                    ),
                    onPressed: () {
                      // TODO: Delete book
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}