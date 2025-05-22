import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final List<String> options;
  final String? hintText;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String Function(String)? itemLabelBuilder;
  final double? menuMaxHeight; // 👈 New optional parameter

  const CustomDropdownField({
    this.label,
    required this.options,
    this.hintText,
    this.selectedValue,
    required this.onChanged,
    this.itemLabelBuilder,
    this.menuMaxHeight, // 👈 Include in constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        if (label != null) const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: selectedValue,
          onChanged: onChanged,
          menuMaxHeight: menuMaxHeight ?? 250, // 👈 Use provided or default
          items: [
            if (hintText != null && selectedValue == null)
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  hintText ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ...options.map((option) {
              final displayText =
                  itemLabelBuilder != null ? itemLabelBuilder!(option) : option;
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  displayText,
                  style:
                      const TextStyle(fontSize: 14), // 👈 Optional smaller text
                ),
              );
            }).toList(),
          ],
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.secondaryBlue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
