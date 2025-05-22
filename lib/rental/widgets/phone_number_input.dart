import 'package:flutter/material.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hintText;
  final String flagImage;
  final String countryCode;

  const PhoneNumberInput({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.hintText = '968225617',
    this.flagImage = 'images/cambodiaflag.png',
    this.countryCode = 'KH (+855)',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    flagImage,
                    width: 30,
                  ),
                  const SizedBox(width: 5),
                  Text(countryCode),
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
