import 'package:flutter/material.dart';
import 'package:sankaestay/rental/util/icon_util.dart';

import 'package:sankaestay/util/constants.dart';

class Tablewidget extends StatelessWidget {
 final List<Map<String, dynamic>> users;
  final Function(BuildContext, Map<String, dynamic>) onEditUser; // Add this line

  const Tablewidget({super.key, required this.users, required this.onEditUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey), // Gray border around table
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8), // Corrected
                bottomLeft: Radius.circular(8), // Corrected
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColors.primaryBlue), // Dark Blue
                headingTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                columns: [
                  DataColumn(label: Text("No")),
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Phone")),
                  DataColumn(label: Text("Role")),
                  DataColumn(label: Text("Create At")),
                  DataColumn(label: Text("Update At")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Action")),
                ],
                rows: users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user["no"].toString())),
                      DataCell(Text(user["id"])),
                      DataCell(Text(user["name"])),
                      DataCell(Text(user["email"])),
                      DataCell(Text(user["phone"])),
                      DataCell(Text(user["role"])),
                      DataCell(Text(user["createdAt"])),
                      DataCell(Text(user["updatedAt"])),
                      DataCell(
                        Text(
                          user["status"],
                          style: TextStyle(
                            color: user["status"] == "Online"
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(AppIcons.edit, color: Colors.blue),
                            onPressed: () {
                               onEditUser(context, user);
                            },
                          ),
                          IconButton(
                            icon: Icon(AppIcons.delete, color: Colors.red),
                            onPressed: () {},
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Pagination Buttons Aligned to the Left
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align left
            children: [
              _paginationButton("Previous", Colors.grey[500]!),
              SizedBox(width: 4),
              _paginationButton("1", AppColors.primaryBlue, isSelected: true),
              SizedBox(width: 4),
              _paginationButton("2", Colors.grey[500]!),
              SizedBox(width: 4),
              _paginationButton("Next", Colors.grey[500]!),
            ],
          ),
        ],
      ),
    );
  }

  // Small Pagination Button Widget
  Widget _paginationButton(String text, Color color,
      {bool isSelected = false}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(40, 30), // Set small button size
        padding:
            EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white,
          fontSize: 12, // Reduce font size
        ),
      ),
    );
  }
}
