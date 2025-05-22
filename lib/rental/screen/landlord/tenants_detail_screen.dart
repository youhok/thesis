import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Custom_Icon_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/receipt_card.dart';
import 'package:sankaestay/util/constants.dart';

class TenantsDetailScreen extends StatefulWidget {
  final String tenantId;

  TenantsDetailScreen({required this.tenantId, Key? key}) : super(key: key);

  @override
  State<TenantsDetailScreen> createState() => _TenantsDetailScreenState();
}

class _TenantsDetailScreenState extends State<TenantsDetailScreen> {
  // final List<Map<String, dynamic>> receipts = [
  //   {
  //     'month': 'August 2024',
  //     'receiptNo': '5812',
  //     'electricity': '27 kwh',
  //     'water': '3 m3',
  //     'internet': '0 \$',
  //     'garbage': '0 \$',
  //     'paid': false,
  //     'total': '65.0\$'
  //   },
  //   {
  //     'month': 'September 2024',
  //     'receiptNo': '5812',
  //     'electricity': '27 kwh',
  //     'water': '3 m3',
  //     'internet': '0 \$',
  //     'garbage': '0 \$',
  //     'paid': true,
  //     'total': '65.0\$'
  //   }
  // ];

  Future<List<Map<String, dynamic>>> fetchReceipts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('receipts')
        // .where('tenantID', isEqualTo: "H7kdQnyyU7Hf0XtcJGbc")
        .orderBy('payDate', descending: true)
        .get();

    final receipts = querySnapshot.docs.map((doc) {
      final data = doc.data();

      // Format month as 'August 2024'
      String formattedMonth = '';
      if (data['payDate'] != null && data['payDate'] is Timestamp) {
        final date = (data['payDate'] as Timestamp).toDate();
        formattedMonth = DateFormat('MMMM yyyy').format(date); // August 2024
      }

      return {
        'month': formattedMonth,
        'receiptNo': data['receiptNo'] ?? '',
        'electricity': '${data['electricityUsage'] ?? 0} kwh',
        'water': '${data['waterUsage'] ?? 0} m3',
        'internet': '0 \$',
        'garbage': '0 \$',
        'paid': data['isPaid'] ?? false,
        'total': '${data['totalCost'] ?? 0}\$',
      };
    }).toList();

    return receipts;
  }

  Future<Map<String, String>> _fetchRoomAndProperty(String roomId) async {
    String roomName = 'N/A';
    String propertyName = 'N/A';

    final roomDoc =
        await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
    if (roomDoc.exists) {
      roomName = roomDoc['name'] ?? 'N/A';
      final propertyId = roomDoc['propertyID'];
      final propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();
      if (propertyDoc.exists) {
        propertyName = propertyDoc['name'] ?? 'N/A';
      }
    }

    return {'roomName': roomName, 'propertyName': propertyName};
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "tenant_detail.title".tr,
      child: Stack(
        children: [
          Column(
            children: [
              // Text(widget.tenantId),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tenants')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Image.asset(
                                "images/undraw_no-data_ig65-removebg-preview.png",
                                height: 250,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text("Image not found",
                                      style: TextStyle(color: Colors.grey));
                                },
                              ),
                            );
                          }

                          final tenants = snapshot.data!.docs;
                          final tenant = tenants[int.parse(widget.tenantId)]
                              .data() as Map<String, dynamic>;
                          final String roomId = tenant['roomID'];

                          return FutureBuilder<Map<String, String>>(
                            future: _fetchRoomAndProperty(roomId),
                            builder: (context, roomSnapshot) {
                              if (!roomSnapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final roomName = roomSnapshot.data!['roomName']!;
                              final propertyName =
                                  roomSnapshot.data!['propertyName']!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          'images/sangkaestay.ico',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tenant['name'] ?? '',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tenant['phoneNumber'] ?? '',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Move In: ${tenant['move_in_date'] is Timestamp ? DateFormat('yyyy-MM-dd').format((tenant['move_in_date'] as Timestamp).toDate()) : ''}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('tenant_detail.room_id'.tr,
                                      ':  $roomName'),
                                  _buildInfoRow('tenant_detail.property_id'.tr,
                                      ':  $propertyName'),
                                  _buildInfoRow('tenant_detail.address'.tr,
                                      ':  Battambang'),
                                  _buildInfoRow(
                                      'tenant_detail.date_of_birth'.tr,
                                      ': ${tenant['dob'] is Timestamp ? DateFormat('yyyy-MM-dd').format((tenant['dob'] as Timestamp).toDate()) : ''}'),
                                  _buildInfoRow('tenant_detail.profession'.tr,
                                      ':  ${tenant['profession'] ?? ''}'),
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Move Out",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      CustomIconButton(
                                          icon: AppIcons.phone,
                                          onPressed: () {}),
                                      SizedBox(width: 20),
                                      CustomIconButton(
                                          icon: AppIcons.telegram,
                                          onPressed: () {}),
                                      SizedBox(width: 20),
                                      CustomIconButton(
                                          icon: AppIcons.badge,
                                          onPressed: () {}),
                                      SizedBox(width: 20),
                                      CustomIconButton(
                                          icon: AppIcons.edit,
                                          onPressed: () {}),
                                      SizedBox(width: 20),
                                      CustomIconButton(
                                          icon: AppIcons.payments,
                                          onPressed: () {}),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: fetchReceipts(),
                                    builder: (context, receiptSnapshot) {
                                      if (receiptSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (!receiptSnapshot.hasData ||
                                          receiptSnapshot.data!.isEmpty) {
                                        return const Center(
                                            child:
                                                Text('No receipts available'));
                                      }

                                      final receipts = receiptSnapshot.data!;

                                      return Column(
                                        children: receipts
                                            .map((receipt) => ReceiptCard(
                                                receiptData: receipt))
                                            .toList(),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildInfoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
