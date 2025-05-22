import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? suffixText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final bool isMultiline;
  final Function(String)? onChanged;
  final bool obscureText;

  // Optional font size parameters
  final double? labelFontSize;
  final double? textFontSize;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.suffixText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.isMultiline = false,
    this.onChanged,
    this.obscureText = false,
    this.labelFontSize,
    this.textFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize ?? 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText || isPassword,
          keyboardType: keyboardType,
          maxLines: isMultiline ? null : 1,
          onChanged: onChanged,
          style: TextStyle(fontSize: textFontSize ?? 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: textFontSize ?? 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.secondaryBlue,
                width: 2.0,
              ),
            ),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // You may implement a callback to toggle visibility
                    },
                  )
                : suffixIcon != null
                    ? Icon(suffixIcon, color: Colors.grey)
                    : null,
          ),
        ),
      ],
    );
  }
}
