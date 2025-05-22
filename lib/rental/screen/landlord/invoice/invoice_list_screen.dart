import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/screen/landlord/invoice/invoice_details.dart';
import 'package:sankaestay/rental/screen/landlord/invoice/generate_invoice_screen.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/receiptCard.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/composables/useDocumetn.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  StreamSubscription? _invoiceSubscription;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchInvoices();
  }

  @override
  void dispose() {
    _invoiceSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    _invoiceSubscription = await getCollectionQuery(
      collectionName: 'invoices',
      useSnapshot: true,
      callback: (List<Map<String, dynamic>> invoices) async {
        List<Map<String, dynamic>> enriched = [];
        for (var inv in invoices) {
          try {
            final tSnap = await FirebaseFirestore.instance
                .collection('tenants')
                .doc(inv['tenantID'])
                .get();
            if (tSnap.exists) {
              inv['tenantName'] = tSnap.data()?['name'] ?? 'Unknown';
              enriched.add(inv);
            }
          } catch (_) {
            // ignore errors
          }
        }
        setState(() {
          _invoices = enriched;
          _applyFilter(_searchController.text);
        });
      },
    );
  }

  void _onSearchChanged() {
    _applyFilter(_searchController.text);
  }

  void _applyFilter(String query) {
    if (query.isEmpty) {
      _filteredInvoices = List.from(_invoices);
    } else {
      final lower = query.toLowerCase();
      _filteredInvoices = _invoices.where((inv) {
        final name = (inv['tenantName'] as String).toLowerCase();
        final id = (inv['id'] as String? ?? '').toLowerCase();
        final date = inv['payDate'] is Timestamp
            ? DateFormat('yyyy-MM-dd')
                .format((inv['payDate'] as Timestamp).toDate())
                .toLowerCase()
            : (inv['payDate'] as String? ?? '').toLowerCase();
        return name.contains(lower) ||
            id.contains(lower) ||
            date.contains(lower);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredInvoices;
    return BaseScreen(
      title: "invoice_list.title".tr,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGrey,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Search field
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'invoice_list.placeholders'.tr,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // No-data or list
                      if (displayList.isEmpty)
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              "images/undraw_no-data_ig65-removebg-preview.png",
                              height: 250,
                              errorBuilder: (_, __, ___) => Text(
                                "Image not found",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: displayList.length,
                            itemBuilder: (ctx, i) {
                              final invoice = displayList[i];

                              String date = 'No Date';
                              if (invoice['payDate'] is Timestamp) {
                                date = DateFormat('yyyy-MM-dd').format(
                                    (invoice['payDate'] as Timestamp).toDate());
                              } else if (invoice['payDate'] is String) {
                                date = invoice['payDate'];
                              }

                              return Padding(
                                padding: EdgeInsets.all(5),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => InvoiceDetails(
                                          invoiceData: invoice,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ReceiptCard(
                                    name: invoice['tenantName'] ??
                                        'Unknown Tenant',
                                    date: date,
                                    onEdit: () async {
                                      final didUpdate =
                                          await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GenerateInvoiceScreen(
                                            existingInvoice: invoice,
                                          ),
                                        ),
                                      );
                                      if (didUpdate == true) {
                                        _fetchInvoices();
                                      }
                                    },
                                    onDelete: () async {
                                      final id = invoice['id'] as String?;
                                      if (id == null) return;
                                      final ok =
                                          await FirestoreService('invoices')
                                              .removeDocument(id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(ok
                                              ? 'Invoice deleted'
                                              : 'Delete failed'),
                                        ),
                                      );
                                    },
                                    onView: () {
                                      // implement additional view if needed
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // New invoice button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final didCreate = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenerateInvoiceScreen(),
                  ),
                );
                if (didCreate == true) {
                  _fetchInvoices();
                }
              },
              backgroundColor: Color(0xFF0A2658),
              child: Icon(AppIcons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
