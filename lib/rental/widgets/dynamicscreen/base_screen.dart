import 'package:flutter/material.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/util/constants.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Widget? actionButton;
  final Color? bodyBackgroundColor;   // Optional parameter for action button

  const BaseScreen({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.actionButton,
    this.bodyBackgroundColor,  // Pass the action button
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(AppIcons.arrowback, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 5), // Adjust spacing between icon and text
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leadingWidth: 290, // Set enough width to accommodate both icon and text
        actions: [
          if (actionButton != null) actionButton!,  // Conditionally show action button
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: bodyBackgroundColor ?? AppColors.secondaryGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: child, // Dynamic content
      ),
    );
  }
}
