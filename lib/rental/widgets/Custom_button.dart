import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width; // New optional width parameter

  const Custombutton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width, // Accept width
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width ?? double.infinity, // Use custom width or fallback
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A2658),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
