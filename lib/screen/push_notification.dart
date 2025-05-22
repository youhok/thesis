import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class PushNotification extends StatelessWidget {
  const PushNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            bool isMobile = screenWidth < 700; // Define mobile breakpoint
        
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SizedBox(
                  width: isMobile ? double.infinity : 800, // Adaptive width
                  child: isMobile
                      ? Column( // Mobile layout (stacked)
                          children: [
                            _buildUserList(context),
                            const SizedBox(height: 20),
                            _buildMessageBox(context),
                          ],
                        )
                      : Row( // Desktop/tablet layout (side by side)
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildUserList(context)),
                            const SizedBox(width: 20),
                            Expanded(flex: 4, child: _buildMessageBox(context)),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// **Users List Section**
  Widget _buildUserList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Users List",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
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
            const SizedBox(width: 8),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Allow horizontal scrolling
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.primaryBlue),
            columns: const [
              DataColumn(label: Text("Select", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("No", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("ID", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("Name", style: TextStyle(color: Colors.white))),
            ],
            rows: List.generate(
              5,
              (index) => DataRow(cells: [
                DataCell(Checkbox(value: false, onChanged: (value) {})),
                DataCell(Text("${index + 1}")),
                DataCell(Text("ID1234")),
                DataCell(Text("John Doe")),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _paginationButton("Previous", Colors.grey[500]!),
            const SizedBox(width: 4),
            _paginationButton("1", AppColors.primaryBlue, isSelected: true),
            const SizedBox(width: 4),
            _paginationButton("2", Colors.grey[500]!),
            const SizedBox(width: 4),
            _paginationButton("Next", Colors.grey[500]!),
          ],
        ),
      ],
    );
  }

  /// **Message Section**
  Widget _buildMessageBox(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Message",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Title",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          decoration: const InputDecoration(
            hintText: "Enter Title",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Message",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Your message",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2658),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Send",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// **Pagination Button Widget**
  Widget _paginationButton(String text, Color color, {bool isSelected = false}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(40, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
