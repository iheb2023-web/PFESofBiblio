import 'package:app/themeData.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final double width;
  final double height;
  final Widget? leadingIcon;
  final Color? backgroundColor;
  const MyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 0.9,
    this.height = 0.06,
    this.leadingIcon,
    this.backgroundColor = blueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,

      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leadingIcon ?? const SizedBox(),
            leadingIcon != null ? const SizedBox(width: 20) : const SizedBox(),
            Text(
              label,
              style: const TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontFamily: 'Sora',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
