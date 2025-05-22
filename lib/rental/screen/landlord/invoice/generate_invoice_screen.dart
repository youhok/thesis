import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/composables/useDocumetn.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Date_Picker.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:sankaestay/widgets/Dashed_Line_Painter.dart';
import 'package:sankaestay/util/constants.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic>? existingInvoice;
  const GenerateInvoiceScreen({Key? key, this.existingInvoice})
      : super(key: key);

  @override
  _GenerateInvoiceScreenState createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> tenantOptions = [];
  String? selectedTenantId;
  String? selectedRenttype;
  final isPaid = false.obs;
  DateTime? payDate = DateTime.now();
  double? total = 0;

  // property/room fields
  String? selectedPropertyId;
  double roomCost = 0;
  String internetPrice = '0';
  String garbagePrice = '0';

  // controllers
  final newWaterUsageController = TextEditingController();
  final newElectricityUsageController = TextEditingController();
  final previousWaterUsageController = TextEditingController();
  final previousElectricityUsageController = TextEditingController();

  // unit price constants
  static const kWaterUnitPrice = 460.0;
  static const kElectricityUnitPrice = 1600.0;

  @override
  void initState() {
    super.initState();
    _loadTenantOptions();
    _prepopulateIfEditing();
  }

  void _prepopulateIfEditing() {
    final inv = widget.existingInvoice;
    if (inv == null) return;

    // Tenant & rent type & paid flag
    selectedTenantId = inv['tenantID'] as String?;
    selectedRenttype = inv['rentType'] as String?;
    isPaid.value = inv['isPaid'] as bool? ?? false;

    // —— fix payDate casting ——
    final rawDate = inv['payDate'];
    if (rawDate is Timestamp) {
      payDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      payDate = rawDate;
    } else if (rawDate is String) {
      payDate = DateTime.tryParse(rawDate) ?? payDate;
    }
    // — end fix —

    // Room & property fields
    roomCost = (inv['roomCost'] as num?)?.toDouble() ?? 0;
    internetPrice = inv['internetCost']?.toString() ?? '0';
    garbagePrice = inv['garbageCost']?.toString() ?? '0';

    // Usage controllers
    previousWaterUsageController.text = inv['oldWaterUsage']?.toString() ?? '';
    previousElectricityUsageController.text =
        inv['oldElectricityUsage']?.toString() ?? '';
    newWaterUsageController.text = inv['newWaterUsage']?.toString() ?? '';
    newElectricityUsageController.text =
        inv['newElectricityUsage']?.toString() ?? '';

    total = (inv['totalCost'] as num?)?.toDouble() ?? 0;
  }

  Future<void> _loadTenantOptions() async {
    await getCollectionQuery(
      collectionName: 'tenants',
      filters: [
        (q) => q.where('isActive', isEqualTo: true),
        (q) => q.where('movedOut', isEqualTo: false),
      ],
      useSnapshot: true,
      callback: (data) async {
        final opts = <Map<String, String>>[];
        for (var t in data) {
          final name = t['name'] ?? '';
          final roomID = t['roomID'] as String?;
          final tid = t['id'] as String?;
          var roomName = 'Unknown Room';
          if (roomID?.isNotEmpty == true) {
            final doc = await FirebaseFirestore.instance
                .collection('rooms')
                .doc(roomID)
                .get();
            if (doc.exists) {
              roomName = doc.data()?['name'] ?? roomName;
            }
          }
          opts.add({'label': '$name ($roomName)', 'id': tid!});
        }
        setState(() => tenantOptions = opts);
      },
    );
  }

  Future<void> _onTenantSelected(String label) async {
    final match = tenantOptions.firstWhereOrNull((e) => e['label'] == label);
    if (match == null) return;

    final tenantId = match['id']!;
    final tenantDoc = await FirebaseFirestore.instance
        .collection('tenants')
        .doc(tenantId)
        .get();
    if (!tenantDoc.exists) return;

    final roomId = tenantDoc.data()?['roomID'] as String?;
    double fetchedRoomCost = 0;
    String? fetchedPropertyId;

    if (roomId?.isNotEmpty == true) {
      final r = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();
      if (r.exists) {
        fetchedRoomCost = (r.data()?['price'] ?? 0).toDouble();
        fetchedPropertyId = r.data()?['propertyID'] as String?;
      }
    }

    // load property prices
    String iP = '0', wP = '0', eP = '0', gP = '0';
    if (fetchedPropertyId?.isNotEmpty == true) {
      final p = await FirebaseFirestore.instance
          .collection('properties')
          .doc(fetchedPropertyId)
          .get();
      if (p.exists) {
        final d = p.data()!;
        iP = (d['internetPrice'] ?? '0').toString();
        wP = (d['waterPrice'] ?? '0').toString();
        eP = (d['electricityPrice'] ?? '0').toString();
        gP = (d['garbagePrice'] ?? '0').toString();

        // put the _per‑unit_ rates into your “previous” fields so the user sees them
        previousWaterUsageController.text = wP;
        previousElectricityUsageController.text = eP;
      }
    }

    setState(() {
      selectedTenantId = tenantId;
      selectedPropertyId = fetchedPropertyId;
      roomCost = fetchedRoomCost;
      internetPrice = iP;
      garbagePrice = gP;
    });
  }

  Map<String, double> calculateInvoiceNumbers() {
    final oldW = double.tryParse(previousWaterUsageController.text) ?? 0;
    final newW = double.tryParse(newWaterUsageController.text) ?? 0;
    final oldE = double.tryParse(previousElectricityUsageController.text) ?? 0;
    final newE = double.tryParse(newElectricityUsageController.text) ?? 0;

    final waterUsage = (newW - oldW).clamp(0, double.infinity);
    final electricityUsage = (newE - oldE).clamp(0, double.infinity);

    final waterCost = waterUsage * kWaterUnitPrice;
    final electricityCost = electricityUsage * kElectricityUnitPrice;
    final internetCost = double.tryParse(internetPrice) ?? 0;
    final garbageCost = double.tryParse(garbagePrice) ?? 0;

    final rentMult =
        selectedRenttype == 'generate_invoice.year'.tr ? 12.0 : 1.0;
    final roomCharge = roomCost * rentMult;

    final totalCost =
        waterCost + electricityCost + internetCost + garbageCost + roomCharge;

    return {
      'waterUsage': waterUsage.toDouble(),
      'electricityUsage': electricityUsage.toDouble(),
      'waterCost': waterCost.toDouble(),
      'electricityCost': electricityCost.toDouble(),
      'roomCharge': roomCharge.toDouble(),
      'totalCost': totalCost.toDouble(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingInvoice != null;
    return BaseScreen(
      title: isEditing
          ? "generate_invoice.edit_invoice".tr
          : "generate_invoice.title".tr,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    CustomDropdownField(
                      hintText: "generate_invoice.choose_tenant".tr,
                      label: "generate_invoice.tenants".tr,
                      options: tenantOptions.map((e) => e['label']!).toList(),
                      selectedValue: tenantOptions.firstWhereOrNull(
                          (e) => e['id'] == selectedTenantId)?['label'],
                      onChanged: (value) {
                        if (value != null) {
                          _onTenantSelected(value);
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    CustomDropdownField(
                      hintText: "generate_invoice.rent_type".tr,
                      label: "generate_invoice.rent_type".tr,
                      options: [
                        'generate_invoice.monthly'.tr,
                        'generate_invoice.year'.tr
                      ],
                      selectedValue: selectedRenttype,
                      onChanged: (v) => setState(() => selectedRenttype = v),
                    ),
                    SizedBox(height: 20),
                    CustomDatePicker(
                      label: "generate_invoice.pay_date".tr,
                      selectedDate: payDate,
                      onDateSelected: (d) => setState(() => payDate = d),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "generate_invoice.new_water.label".tr,
                            hintText:
                                "generate_invoice.new_water.placeholder".tr,
                            controller: newWaterUsageController,
                            suffixText: 'm³',
                            labelFontSize: 13,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: "generate_invoice.new_electricity.label".tr,
                            hintText:
                                "generate_invoice.new_electricity.placeholder"
                                    .tr,
                            controller: newElectricityUsageController,
                            suffixText: 'kwh',
                            labelFontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "generate_invoice.old_electricity.label".tr,
                            hintText:
                                "generate_invoice.old_electricity.placeholder"
                                    .tr,
                            controller: previousElectricityUsageController,
                            suffixText: 'kwh',
                            labelFontSize: 13,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: "generate_invoice.old_water.label".tr,
                            hintText:
                                "generate_invoice.old_water.placeholder".tr,
                            controller: previousWaterUsageController,
                            suffixText: 'm³',
                            labelFontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Obx(() => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text("generate_invoice.ispaid".tr),
                          value: isPaid.value,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (v) => isPaid.value = v ?? false,
                        )),
                    SizedBox(height: 10),
                    CustomPaint(
                      painter: DashedLinePainter(),
                      child: SizedBox(width: double.infinity, height: 1),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("generate_invoice.total".tr,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'KHR ${total?.toStringAsFixed(0) ?? 0} ៛',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Custombutton(
                      text: isEditing
                          ? "generate_invoice.update".tr
                          : "generate_invoice.generate".tr,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate() ||
                            selectedTenantId == null ||
                            selectedRenttype == null) {
                          Get.snackbar(
                              "Error", "Please fill all required fields");
                          return;
                        }
                        final nums = calculateInvoiceNumbers();
                        final data = {
                          'tenantID': selectedTenantId,
                          'propertyID': selectedPropertyId,
                          'roomCost': roomCost,
                          'rentType': selectedRenttype,
                          'payDate': payDate,
                          'internetCost': double.tryParse(internetPrice) ?? 0,
                          'garbageCost': double.tryParse(garbagePrice) ?? 0,
                          'oldWaterUsage': double.tryParse(
                                  previousWaterUsageController.text) ??
                              0,
                          'newWaterUsage':
                              double.tryParse(newWaterUsageController.text) ??
                                  0,
                          'waterUsage': nums['waterUsage'],
                          'waterCost': nums['waterCost'],
                          'oldElectricityUsage': double.tryParse(
                                  previousElectricityUsageController.text) ??
                              0,
                          'newElectricityUsage': double.tryParse(
                                  newElectricityUsageController.text) ??
                              0,
                          'electricityUsage': nums['electricityUsage'],
                          'electricityCost': nums['electricityCost'],
                          'totalCost': nums['totalCost'],
                          'isPaid': isPaid.value,
                          'status': false,
                          'updatedAt': FieldValue.serverTimestamp(),
                          'updatedBy': null,
                        };

                        final svc = FirestoreService('invoices');
                        bool ok;
                        if (isEditing) {
                          final id = widget.existingInvoice!['id'] as String;
                          ok = await svc.updateDocument(id, data);
                        } else {
                          data['createdAt'] = FieldValue.serverTimestamp();
                          data['createdBy'] = null;
                          ok = await svc.addDocument(data);
                        }

                        if (ok) {
                          setState(() => total = nums['totalCost']);
                          Get.snackbar(
                            "Success",
                            isEditing
                                ? "Invoice updated successfully!"
                                : "Invoice generated successfully!",
                          );
                          if (isEditing) {
                            Navigator.pop(context, true);
                          }
                        } else {
                          Get.snackbar("Error",
                              isEditing ? "Update failed" : "Create failed");
                        }
                      },
                    ),
                    SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
