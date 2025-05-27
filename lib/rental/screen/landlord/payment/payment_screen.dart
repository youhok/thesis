import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/widgets/custom_search_field.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;
  final Map<String, String> _tenantNames = {};
  final _dateFmt = DateFormat('MMM dd, yyyy hh:mm a');

  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  StreamSubscription? _tenantSub;
  StreamSubscription? _paymentSub;

  @override
  void initState() {
    super.initState();
    _listenTenants();
    _listenPayments();

    _searchController.addListener(() {
      _searchQuery.value = _searchController.text.toLowerCase();
    });
  }

  void _listenTenants() {
    getCollectionQuery(
      collectionName: 'tenants',
      useSnapshot: true,
      callback: (List<Map<String, dynamic>> rawTenants) {
        _tenantNames.clear();
        for (var tenant in rawTenants) {
          final id = tenant['id'] as String?;
          final name = tenant['name'] as String? ?? 'Unknown';
          if (id != null) _tenantNames[id] = name;
        }
        _applyTenantNames();
      },
    ).then((sub) {
      _tenantSub = sub;
    });
  }

  void _listenPayments() {
    getCollectionQuery(
      collectionName: 'payments',
      useSnapshot: true,
      callback: (List<Map<String, dynamic>> rawPayments) {
        final formatted = rawPayments.map((doc) {
          final ts = doc['date'] as Timestamp?;
          return {
            'id': doc['id'],
            'amount': doc['amount'],
            'currency': doc['currency'] ?? 'USD',
            'date': ts != null ? _dateFmt.format(ts.toDate()) : '',
            'tenantId': doc['tenantId'] as String,
            'status': doc['status'] ?? '',
          };
        }).toList();

        payments.assignAll(formatted);
        _applyTenantNames();
      },
    ).then((sub) {
      _paymentSub = sub;
    });
  }

  void _applyTenantNames() {
    final withNames = payments.map((p) {
      final tid = p['tenantId'] as String;
      return {
        ...p,
        'tenantName': _tenantNames[tid] ?? 'Unknown',
      };
    }).toList();
    payments.assignAll(withNames);
  }

  List<Map<String, dynamic>> get _filteredPayments {
    if (_searchQuery.value.isEmpty) {
      return payments;
    }
    return payments.where((payment) {
      final name = (payment['tenantName'] as String).toLowerCase();
      return name.contains(_searchQuery.value);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tenantSub?.cancel();
    _paymentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "transaction.title".tr,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 15),
            CustomSearchField(
              hintText: 'transaction.placeholder'.tr,
              controller: _searchController,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Obx(() {
                if (_filteredPayments.isEmpty) {
                  return _buildNoDataPlaceholder();
                }
                return _buildPaymentList(_filteredPayments);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataPlaceholder() {
    return Center(
      child: Image.asset(
        "images/undraw_no-data_ig65-removebg-preview.png",
        height: 240,
      ),
    );
  }

  Widget _buildPaymentList(List<Map<String, dynamic>> paymentList) {
    return ListView.separated(
      itemCount: paymentList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payment = paymentList[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${payment['amount']} ${payment['currency']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tenant: ${payment['tenantName']}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                // Right Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      payment['date'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment['status'],
                      style: TextStyle(
                        fontSize: 14,
                        color: payment['status'] == 'paid'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
