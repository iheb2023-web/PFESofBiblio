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
    // Obtenir les dimensions de l'écran
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation Lottie adaptative
              Lottie.asset(
                path,
                height: isPortrait 
                    ? screenWidth * 0.7  // En mode portrait
                    : screenHeight * 0.5, // En mode paysage
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.04),
              // Titre adaptatif
              SizedBox(
                width: screenWidth * 0.8,
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Sora",
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: blueColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Description adaptative
              SizedBox(
                width: screenWidth * 0.8,
                child: Text(
                  description,
                  style: TextStyle(
                    fontFamily: "Sora",
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isPortrait ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        );
      },
    );
  }
}
