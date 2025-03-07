import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mes_livres.dart';
import 'mes_emprunts.dart';
import '../Ajouter_livre/ajouter_livre.dart';
import 'package:app/themeData.dart';

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
    
    return Scaffold(
      backgroundColor: whiteSmokeColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'my_library'.tr,
          style: theme.textTheme.titleLarge?.copyWith(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: blackColor),
            onPressed: () {
              Get.to(() => const AddBookScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: whiteColor,
            child: TabBar(
              controller: _tabController,
              labelColor: blueColor,
              unselectedLabelColor: grayColor,
              indicatorColor: blueColor,
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
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