import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePicker({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          widget.selectedDate != null ? _formatDate(widget.selectedDate!) : '',
    );
  }

  @override
  void didUpdateWidget(covariant CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _controller.text =
          widget.selectedDate != null ? _formatDate(widget.selectedDate!) : '';
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Select date",
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2.0,
              ),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today,
                  color: AppColors.primaryBlue),
              onPressed: () async {
                DateTime initialDate = widget.selectedDate ?? DateTime.now();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primaryBlue,
                          onPrimary: Colors.white,
                          onSurface: AppColors.primaryBlue,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  _controller.text = _formatDate(pickedDate);
                  widget.onDateSelected(pickedDate);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
