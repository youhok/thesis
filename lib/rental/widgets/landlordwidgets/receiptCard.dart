import 'package:sankaestay/widgets/Dashed_Line_Painter.dart';
import 'package:flutter/material.dart';

class ReceiptCard extends StatelessWidget {
  final String name;
  final String date;
  final VoidCallback? onDelete; // ← new

  final VoidCallback? onEdit;
  final VoidCallback? onView;
  const ReceiptCard({
    super.key,
    required this.name,
    required this.date,
    this.onEdit,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Number and Menu Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Name",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.black54, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.white, // White background
                  elevation: 2, // Light shadow for subtle effect
                  onSelected: (value) {
                    if (value == 'share') {
                    } else if (value == 'delete') {
                      if (onDelete != null) onDelete!();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'share',
                      height: 30, // Smaller height
                      child: Row(
                        children: const [
                          Icon(Icons.share, color: Colors.black, size: 18),
                          SizedBox(width: 8),
                          Text('Share', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      height: 30, // Smaller height
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Delete',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Dashed Divider
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: CustomPaint(
                painter: DashedLinePainter(),
                child: SizedBox(
                  width: double.infinity,
                  height: 1,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Name and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 20, color: Colors.black54),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code,
                          size: 20, color: Colors.green),
                      onPressed: onView,
                    ),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
