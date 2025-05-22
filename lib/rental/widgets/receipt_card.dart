import 'package:flutter/material.dart';
import 'package:sankaestay/rental/util/icon_util.dart';

@immutable
class ReceiptCard extends StatelessWidget {
  final Map<String, dynamic> receiptData;

  const ReceiptCard({super.key, required this.receiptData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (Month & Action Icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  receiptData['month'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Icon(AppIcons.share, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Icon(AppIcons.morevert, size: 20, color: Colors.black54),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Receipt No: ${receiptData['receiptNo']}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),

            // First Row (Electricity & Internet)
            Row(
              children: [
                const Expanded(child: Text('Electricity:', style: TextStyle(fontSize: 14))),
                Text(receiptData['electricity'], style: const TextStyle(fontSize: 14)),
                const Spacer(),
                const Expanded(child: Text('Internet:', style: TextStyle(fontSize: 14))),
                Text(receiptData['internet'], style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),

            // Second Row (Water & Garbage)
            Row(
              children: [
                const Expanded(child: Text('Water:', style: TextStyle(fontSize: 14))),
                Text(receiptData['water'], style: const TextStyle(fontSize: 14)),
                const Spacer(),
                const Expanded(child: Text('Garbage:', style: TextStyle(fontSize: 14))),
                Text(receiptData['garbage'], style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),

            // Paid Row
            Row(
              children: [
                const Text('Paid:', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  receiptData['paid'] ? 'Yes' : 'No',
                  style: TextStyle(
                    fontSize: 14,
                    color: receiptData['paid'] ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const Divider(),

            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(receiptData['total'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
