import 'package:flutter/material.dart';
import '../util/constants.dart';
import 'package:sankaestay/widgets/Edit_User_Dialog.dart';
import 'package:sankaestay/widgets/Table_Widget.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final List<Map<String, dynamic>> users = List.generate(10, (index) {
    return {
      "no": index + 1,
      "id": "ID1234",
      "name": "John Doe",
      "email": "johndoe@example.com",
      "phone": "092716312",
      "role": index % 2 == 0 ? "tenant" : "landlord",
      "createdAt": "27/02/2025 09:34 AM",
      "updatedAt": index == 0 ? "02/03/2025 10:34 AM" : "Null",
      "status": index % 3 == 0 ? "Online" : "Offline",
    };
  });
  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
  showDialog(
    context: context,
    builder: (context) => EditUserDialog(
      user: user,
      onSave: (updatedUser) {
        setState(() {
          user["name"] = updatedUser["name"];
          user["email"] = updatedUser["email"];
          user["phone"] = updatedUser["phone"];
          user["role"] = updatedUser["role"];
        });
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // Added padding for better spacing
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the left
          children: [
            const SizedBox(height: 28),
            Container(
              margin: EdgeInsets.only(left: 36),
              child: const Text(
                "All Users",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 36),
                  child: SizedBox(
                    width: 500, // Adjust this width as needed
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue, // Dark blue background
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // Handle search action
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10), // Properly placed spacing
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Tablewidget(
                users: users,
                onEditUser: _showEditUserDialog, // Pass function here
              ),
            ),
          ],
        ),
      ),
    );
  }
}
