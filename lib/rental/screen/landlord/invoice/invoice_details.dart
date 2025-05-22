import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/invoice_card.dart';
import 'package:sankaestay/util/constants.dart';

class InvoiceDetails extends StatefulWidget {
  final Map<String, dynamic> invoiceData;
  const InvoiceDetails({Key? key, required this.invoiceData}) : super(key: key);

  @override
  State<InvoiceDetails> createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
  String landlordContact = '—';
  String propertyName = '—';
  String roomName = '—';

  final GlobalKey _invoiceKey = GlobalKey();

  Future<void> fetchTenantPhone() async {
    final tenantId = widget.invoiceData['tenantID'] as String?;
    if (tenantId == null) return;
    await getCollectionQuery(
      collectionName: 'tenants',
      docID: tenantId,
      callback: (Map<String, dynamic> tenant) {
        setState(() {
          landlordContact = tenant['phoneNumber']?.toString() ?? '—';
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTenantPhone();

    final propertyId = widget.invoiceData['propertyID'] as String?;
    if (propertyId != null) {
      fetchRoomNameByPropertyId(propertyId);
      fetchPropertyName(propertyId);
    }
  }

  Future<void> fetchRoomNameByPropertyId(String propertyId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('propertyID', isEqualTo: propertyId)
        .where('isAvailable', isEqualTo: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final roomData = querySnapshot.docs.first.data();
      setState(() {
        roomName = roomData['name'] ?? 'Unnamed Room';
      });
    } else {
      setState(() {
        roomName = 'No room found';
      });
    }
  }

  Future<void> fetchPropertyName(String propertyId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        propertyName =
            docSnapshot.data()?['propertyTitle'] ?? 'Unknown Property';
      });
    }
  }

  Future<void> _captureAndShareInvoice() async {
    try {
      RenderRepaintBoundary boundary = _invoiceKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;

      // ignore: unnecessary_null_comparison
      if (boundary == null) return;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/invoice.png').create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(imagePath.path)], text: 'Invoice Detail');
    } catch (e) {
      print('Error capturing invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoiceData;
    final tenantName = inv['tenantName'] as String? ?? '—';
    final receiptId = inv['id'] as String? ?? '—';
    final rawPayDate = inv['payDate'];
    final payDate = rawPayDate is Timestamp
        ? DateFormat('yyyy-MM-dd').format(rawPayDate.toDate())
        : rawPayDate?.toString() ?? '—';
    final waterUsage = inv['waterUsage']?.toString() ?? '0';
    final electricityUsage = inv['electricityUsage']?.toString() ?? '0';
    final garbageCost = inv['garbageCost']?.toString() ?? '0';
    final internetCost = inv['internetCost']?.toString() ?? '0';
    final rentType = inv['rentType'] as String? ?? '—';
    final totalCost = inv['totalCost']?.toString() ?? '0';
    final isPaid = inv['isPaid'] == true;

    return BaseScreen(
      title: "invoice_detail.title".tr,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryGrey,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            RepaintBoundary(
              key: _invoiceKey,
              child: InvoiceCard(
                avatarText: tenantName.isNotEmpty ? tenantName[0] : '–',
                name: tenantName,
                amount: 'KHR $totalCost ៛',
                roomName: roomName,
                propertyName: propertyName,
                receiptId: receiptId,
                receiptDate: payDate,
                waterUsage: waterUsage,
                electricityUsage: electricityUsage,
                garbage: garbageCost,
                internet: internetCost,
                paymentStatus: isPaid ? 'Paid' : 'Unpaid',
                rentType: rentType,
                payDate: payDate,
                landlordContact: landlordContact,
                companyName: 'SangkaeStay',
                companyTagline: 'Find rent & manage',
                logoPath: 'images/logo_blue.svg',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(AppIcons.share, size: 30, color: Colors.grey),
                  onPressed: _captureAndShareInvoice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
