import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';
// Update with your actual AppColors import

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }
}
