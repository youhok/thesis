import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Custom_Icon_button.dart';
import 'package:sankaestay/util/constants.dart';

class ContactOwnerCard extends StatelessWidget {
  final String ownerName;
  final String phoneNumber;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onBookNow;
  final String imagePath;

  const ContactOwnerCard({
    Key? key,
    required this.ownerName,
    required this.phoneNumber,
    required this.onCall,
    required this.onMessage,
    required this.onBookNow,
    this.imagePath = 'images/sangkaestay.ico',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "location_preview.contactOwner".tr,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  CustomIconButton(
                    icon: AppIcons.phone,
                    onPressed: onCall,
                    backgroundColor: AppColors.opacityBlue,
                  ),
                  const SizedBox(width: 10),
                  CustomIconButton(
                    icon: Icons.telegram,
                    onPressed: onMessage,
                    backgroundColor: AppColors.opacityBlue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onBookNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "location_preview.book".tr,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
