import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app/themeData.dart';

class BuildPage extends StatelessWidget {
  final String title;
  final String description;
  final String path;
  const BuildPage({
    super.key,
    required this.title,
    required this.description,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(path, height: MediaQuery.of(context).size.width * 0.8),
          const SizedBox(height: 50),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "Sora",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: blueColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: "Sora",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
