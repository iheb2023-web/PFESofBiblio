import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/imports.dart';

class ActiveMembersSection extends StatefulWidget {
  const ActiveMembersSection({Key? key}) : super(key: key);

  @override
  State<ActiveMembersSection> createState() => _ActiveMembersSectionState();
}

class _ActiveMembersSectionState extends State<ActiveMembersSection> {
  final AuthController authController = Get.find<AuthController>();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!_isDisposed) {
        authController.fetchTop10Borrowers();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'active_members'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          final isLoading = authController.isLoading.value;
          final errorMessage = authController.errorMessage.value;
          final borrowers = authController.topBorrowers;

          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (borrowers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Aucun emprunteur trouvé'.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return SizedBox(
            height: 100, // Augmenté de 60 à 100 pour contenir tous les éléments
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: borrowers.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final member = borrowers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28, // Retour à la taille originale
                        backgroundImage: AssetImage(
                          'assets/images/profile.jpg',
                        ),
                        backgroundColor: Colors.grey,
                        onBackgroundImageError:
                            (_, __) => const Icon(Icons.person),
                      ),
                      const SizedBox(
                        height: 4,
                      ), // Retour à l'espacement original
                      SizedBox(
                        width: 90,
                        child: Text(
                          '${member.firstname} ${member.lastname}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12, // Retour à la taille originale
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 12, // Retour à la taille originale
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${member.nbEmprunts}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12, // Retour à la taille originale
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
