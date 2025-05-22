import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor; // Add backgroundColor parameter

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white, // Default background color is white
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: backgroundColor, // Use the backgroundColor here
          constraints: const BoxConstraints(
            minWidth: 10,
            minHeight: 10,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
