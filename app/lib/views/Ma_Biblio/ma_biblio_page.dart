import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mes_livres.dart';
import 'mes_emprunts.dart';
import '../Ajouter_livre/ajouter_livre.dart';
import 'package:app/theme/theme_controller.dart';

class MaBiblioPage extends StatefulWidget {
  const MaBiblioPage({super.key});

  @override
  State<MaBiblioPage> createState() => _MaBiblioPageState();
}

class _MaBiblioPageState extends State<MaBiblioPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'my_library'.tr,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onBackground),
            onPressed: () => Get.to(() => const AddBookScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: theme.hintColor,
              indicatorColor: colorScheme.primary,
              labelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: 'my_books'.tr),
                Tab(text: 'borrowed'.tr),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MesLivresPage(),
                MesEmpruntsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
