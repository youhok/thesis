import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class ProfileUser extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isNetworkImage;
  final Color borderColor;
  final double radius;

  const ProfileUser({
    super.key,
    required this.imagePath,
    required this.name,
    this.isNetworkImage = false,
    this.borderColor = AppColors.primaryBlue,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: (radius * 2) + 25,
          height: (radius * 2) + 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: isNetworkImage
                ? NetworkImage(imagePath)
                : AssetImage(imagePath) as ImageProvider,
            backgroundColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
