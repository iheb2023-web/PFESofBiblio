import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Member {
  final String name;
  final int loans;

  Member(this.name, this.loans);
}

class ActiveMembersSection extends StatelessWidget {
  const ActiveMembersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final members = List.generate(
      10,
      (index) => Member('Membre ${index + 1}', (10 - index) * 5),
    )..sort((a, b) => b.loans.compareTo(a.loans));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'active_members'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final member = members[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/images/profile.jpg',
                      ),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.book_outlined,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${member.loans}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
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
        ),
      ],
    );
  }
}
