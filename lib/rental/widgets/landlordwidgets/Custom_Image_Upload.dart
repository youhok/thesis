import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sankaestay/util/constants.dart';

class CustomImageUpload extends StatelessWidget {
  final File? imageFile;
  final ValueChanged<File?> onImageChanged;

  const CustomImageUpload({
    super.key,
    required this.imageFile,
    required this.onImageChanged,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImageChanged(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tenant Profile (Optional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black12),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ],
        ),
        if (imageFile != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => onImageChanged(null),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Clear Image",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
