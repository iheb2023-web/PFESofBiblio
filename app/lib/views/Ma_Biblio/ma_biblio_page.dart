import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mes_livres.dart';
import 'mes_emprunts.dart';
import '../Ajouter_livre/ajouter_livre.dart';
import 'package:app/controllers/theme_controller.dart';
import 'package:app/theme/app_theme.dart';

class MaBiblioPage extends StatefulWidget {
  const MaBiblioPage({super.key});

  @override
  State<MaBiblioPage> createState() => _MaBiblioPageState();
}

class _MaBiblioPageState extends State<MaBiblioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Theme(
            data:
                themeController.isDarkMode
                    ? AppTheme.darkTheme
                    : AppTheme.lightTheme,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,

                title: Text(
                  'my_library'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => Get.to(() => const AddBookScreen()),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      indicatorColor: Theme.of(context).primaryColor,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        // fontFamily: "Sora",  // Commenté temporairement
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        // fontFamily: "Sora",  // Commenté temporairement
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: 'my_books'.tr),
                        Tab(text: 'borrowed'.tr),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [MesLivresPage(), MesEmpruntsPage()],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
