import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class TenantCard extends StatelessWidget {
  final int? roomId;
  final String? tenantName;
  final String? tenantAddress;
  final double? roomPrice;
  final bool isAvailable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TenantCard({
    super.key,
    this.roomId,
    this.tenantName,
    this.tenantAddress,
    this.roomPrice,
    this.isAvailable = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Room title and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tenantName ?? "Tenant",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.secondaryBlue,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${roomPrice?.toStringAsFixed(0) ?? '0'}KHR',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Address row
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tenantAddress ?? 'No Address',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Status and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Availability status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green[200] : Colors.red[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: isAvailable ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                /// Edit & delete buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 20, color: Colors.black),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
