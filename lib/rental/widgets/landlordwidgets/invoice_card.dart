import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Dashed_Line_Painter.dart';

// The main reusable CustomCard widget
class InvoiceCard extends StatelessWidget {
  final String avatarText;
  final String name;
  final String amount;
  final String roomName;
  final String propertyName;
  final String receiptId;
  final String receiptDate;
  final String waterUsage;
  final String electricityUsage;
  final String garbage;
  final String internet;
  final String paymentStatus;
  final String rentType;
  final String payDate;
  final String landlordContact;
  final String companyName;
  final String companyTagline;
  final String logoPath;

  const InvoiceCard({
    Key? key,
    required this.avatarText,
    required this.name,
    required this.amount,
    required this.roomName,
    required this.propertyName,
    required this.receiptId,
    required this.receiptDate,
    required this.waterUsage,
    required this.electricityUsage,
    required this.garbage,
    required this.internet,
    required this.paymentStatus,
    required this.rentType,
    required this.payDate,
    required this.landlordContact,
    required this.companyName,
    required this.companyTagline,
    required this.logoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.red,
                  child:
                      Text(avatarText, style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(amount,
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DashedLine(),
            const SizedBox(height: 10),
            _InfoRow(
              roomName: roomName,
              propertyName: propertyName,
              receiptId: receiptId,
              receiptDate: receiptDate,
            ),
            const SizedBox(height: 10),
            _DashedLine(),
            const SizedBox(height: 10),
            _UsageInfoRow(
              waterUsage: waterUsage,
              electricityUsage: electricityUsage,
              garbage: garbage,
              internet: internet,
            ),
            const SizedBox(height: 10),
            _DashedLine(),
            const SizedBox(height: 10),
            _PaymentStatusRow(
              paymentStatus: paymentStatus,
              rentType: rentType,
              payDate: payDate,
            ),
            const SizedBox(height: 10),
            _DashedLine(),
            const SizedBox(height: 10),
            _ContactRow(
              landlordContact: landlordContact,
              companyName: companyName,
              companyTagline: companyTagline,
              logoPath: logoPath,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Dashed line widget
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CustomPaint(
        painter: DashedLinePainter(),
        child: SizedBox(width: double.infinity, height: 1),
      ),
    );
  }
}

// Row showing room and property information
class _InfoRow extends StatelessWidget {
  final String roomName;
  final String propertyName;
  final String receiptId;
  final String receiptDate;

  const _InfoRow({
    required this.roomName,
    required this.propertyName,
    required this.receiptId,
    required this.receiptDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room Name'),
            Text('Property Name'),
            Text('Receipt ID'),
            Text('Receipt Date'),
          ],
        ),
        const SizedBox(width: 50),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(':$roomName'),
            Text(':$propertyName'),
            Text(':$receiptId'),
            Text(':$receiptDate'),
          ],
        ),
      ],
    );
  }
}

// Row showing usage details
class _UsageInfoRow extends StatelessWidget {
  final String waterUsage;
  final String electricityUsage;
  final String garbage;
  final String internet;

  const _UsageInfoRow({
    required this.waterUsage,
    required this.electricityUsage,
    required this.garbage,
    required this.internet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Usage'),
            Text('Electricity Usage'),
            Text('Garbage'),
            Text('Internet'),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(':$waterUsage m³'),
            Text(':$electricityUsage kWh'),
            Text(':$garbage \$/month'),
            Text(':$internet \$/month'),
          ],
        ),
      ],
    );
  }
}

// Row showing payment status
class _PaymentStatusRow extends StatelessWidget {
  final String paymentStatus;
  final String rentType;
  final String payDate;

  const _PaymentStatusRow({
    required this.paymentStatus,
    required this.rentType,
    required this.payDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Status'),
            Text('Rent Type'),
            Text('Pay Date'),
          ],
        ),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(':$paymentStatus'),
            Text(':$rentType'),
            Text(':$payDate'),
          ],
        ),
      ],
    );
  }
}

// Row showing contact details
class _ContactRow extends StatelessWidget {
  final String landlordContact;
  final String companyName;
  final String companyTagline;
  final String logoPath;

  const _ContactRow({
    required this.landlordContact,
    required this.companyName,
    required this.companyTagline,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Landlord Contact Number',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(landlordContact),
          ],
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                      fontSize: 16),
                ),
                Text(companyTagline, style: TextStyle(fontSize: 10)),
              ],
            ),
            const SizedBox(width: 5),
            SvgPicture.asset(logoPath, height: 40),
          ],
        ),
      ],
    );
  }
}
