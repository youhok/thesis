import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/widgets/custom_search_field.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});

  final List<Map<String, dynamic>> _payments = [
    // Sample data, replace with real data
    {
      "amount": 65.37,
      "currency": "USD",
      "date": "11/01/2025 01:00 PM",
      "fromAccount": "rieu_dhqj_1984@devb"
    }
  ]; // Replace with real data source

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "transaction.title".tr,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [   
                const SizedBox(height: 15),
                // Search Bar
                CustomSearchField(hintText: 'transaction.placeholder'.tr),
                const SizedBox(height: 15),
                // Conditional UI for No Data / Data List
                _payments.isEmpty
                    ? _buildNoDataPlaceholder()
                    : _buildPaymentList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display if no data is found
  Widget _buildNoDataPlaceholder() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("images/undraw_no-data_ig65-removebg-preview.png",
                height: 240), // Use an appropriate asset
          ],
        ),
      ),
    );
  }
  // Widget to display payment list
  Widget _buildPaymentList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side (Amount & Account Info)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${payment['amount']} ${payment['currency']}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          SizedBox(width: 130,),
                          Text(
                            payment['date'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "From Account : ${payment['fromAccount']}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
