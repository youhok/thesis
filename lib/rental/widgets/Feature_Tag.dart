import 'package:flutter/material.dart';

import 'package:sankaestay/util/constants.dart';
 // Update with your actual AppColors import

class FeatureTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureTag({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.black54),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.opacityBlue,
    );
  }
}
