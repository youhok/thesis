import 'package:flutter/material.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Info_Row.dart';
import 'package:sankaestay/rental/widgets/receipt_card.dart';
import 'package:sankaestay/util/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> receipts = [
      {
        'month': 'August 2024',
        'receiptNo': '5812',
        'electricity': '27 kwh',
        'water': '3 m3',
        'internet': '0 \$',
        'garbage': '0 \$',
        'paid': false,
        'total': '65.0\$'
      },
      {
        'month': 'September 2024',
        'receiptNo': '5812',
        'electricity': '27 kwh',
        'water': '3 m3',
        'internet': '0 \$',
        'garbage': '0 \$',
        'paid': true,
        'total': '65.0\$'
      }
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'images/sangkaestay.ico', // Replace with actual image URL
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Room Rental Battambang',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        AppIcons.location,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '# 105 Group 04 Commune, City',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        AppIcons.home,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Property ID :BTB1241',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                "50.0 \$",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              Text(
                                "/ month",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 20),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _buildUtilityInfo(),
                           SizedBox(
                            height: 20,
                          ),
                          // Contact Card Section
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.opacityBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                // Profile Image
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                      "https://randomuser.me/api/portraits/men/1.jpg"), // Replace with actual image
                                ),
                                const SizedBox(width: 10),

                                // Name & Phone Number
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Heng Youhok",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text("091 247 124",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),

                                Spacer(),

                                // Call & Message Buttons
                                Row(
                                  children: [
                                    _buildIconButton(Icons.call_outlined),
                                    const SizedBox(width: 6),
                                    _buildIconButton(Icons.telegram_outlined),
                                  ],
                                ),
                              ],
                            ),
                          ),
                           SizedBox(
                            height: 20,
                          ),
                          //Receipt card
                           Column(
                            children: receipts
                                .map((receipt) =>
                                    ReceiptCard(receiptData: receipt))
                                .toList(),
                          ),

                        ],
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.opacityBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 25, color: Colors.black),
    );
  }
}

Widget _buildUtilityInfo() {
  return Column(
    children: [
      InfoRow(icon:AppIcons.electricity, label: "Electricity", value: ":0.35     \$ / kWh"),
      InfoRow(icon:AppIcons.water, label:  "Water", value:  "       :0.35     \$ / m³"),
      InfoRow(icon:AppIcons.delete, label: "Garbage", value: "  :0           \$ / month"),
      InfoRow(icon:AppIcons.internet,label:  "Internet", value: "   :0           \$ / month"),
    ],
  );
}

