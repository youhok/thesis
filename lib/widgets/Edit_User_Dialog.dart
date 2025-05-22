import 'package:flutter/material.dart';
import 'Custom_Text_Field.dart';
import '../util/constants.dart';

class EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(Map<String, dynamic>) onSave;

  const EditUserDialog({super.key, required this.user, required this.onSave});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user["name"]);
    emailController = TextEditingController(text: widget.user["email"]);
    phoneController = TextEditingController(text: widget.user["phone"]);
    roleController = TextEditingController(text: widget.user["role"]);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(label: "Name", hintText: "Name", controller: nameController),
              const SizedBox(height: 8),
              CustomTextField(label: "Email", hintText: "Email", controller: emailController),
              const SizedBox(height: 8),
              CustomTextField(label: "Phone", hintText: "Phone", controller: phoneController),
              const SizedBox(height: 8),
              CustomTextField(label: "Role", hintText: "Role", controller: roleController),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic> updatedUser = {
                        "name": nameController.text,
                        "email": emailController.text,
                        "phone": phoneController.text,
                        "role": roleController.text,
                      };
                      widget.onSave(updatedUser);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
