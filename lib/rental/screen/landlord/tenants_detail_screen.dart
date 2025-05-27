import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sankaestay/rental/screen/landlord/addtenants_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Custom_Icon_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';

class TenantsDetailScreen extends StatefulWidget {
  final String tenantId;

  TenantsDetailScreen({required this.tenantId, Key? key}) : super(key: key);

  @override
  State<TenantsDetailScreen> createState() => _TenantsDetailScreenState();
}

class _TenantsDetailScreenState extends State<TenantsDetailScreen> {
  Stream<DocumentSnapshot> get _tenantStream => FirebaseFirestore.instance
      .collection('tenants')
      .doc(widget.tenantId)
      .snapshots();

  Future<Map<String, String>> _fetchRoomAndProperty(String roomId) async {
    String roomName = 'N/A', propertyName = 'N/A';
    final roomDoc =
        await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
    if (roomDoc.exists) {
      roomName = roomDoc['name'] ?? 'N/A';
      final propId = roomDoc['propertyID'];
      final propDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propId)
          .get();
      if (propDoc.exists) propertyName = propDoc['name'] ?? 'N/A';
    }
    return {'roomName': roomName, 'propertyName': propertyName};
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "tenant_detail.title".tr,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _tenantStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists)
            return Center(child: Text("Tenant not found".tr));

          final tenant = snap.data!.data()! as Map<String, dynamic>;

          // parse dates as string or Timestamp
          String moveInStr = '';
          final moveInRaw = tenant['moveInDate'] ?? tenant['move_in_date'];
          if (moveInRaw is Timestamp) {
            moveInStr = DateFormat('yyyy-MM-dd').format(moveInRaw.toDate());
          } else if (moveInRaw is String && moveInRaw.isNotEmpty) {
            moveInStr = moveInRaw;
          }

          String dobStr = '';
          final dobRaw = tenant['dob'];
          if (dobRaw is Timestamp) {
            dobStr = DateFormat('yyyy-MM-dd').format(dobRaw.toDate());
          } else if (dobRaw is String && dobRaw.isNotEmpty) {
            dobStr = dobRaw;
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header: profile image, name, phone, dates
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: tenant['profileImage'] != null &&
                                tenant['profileImage'].toString().isNotEmpty
                            ? Image.network(
                                tenant['profileImage'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'images/sangkaestay.ico',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tenant['phoneNumber'] ?? '',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          if (moveInStr.isNotEmpty)
                            Text(
                              'Move In: $moveInStr',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // room & property & other fields
                  FutureBuilder<Map<String, String>>(
                    future: _fetchRoomAndProperty(tenant['roomID']),
                    builder: (context, rp) {
                      if (!rp.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final roomName = rp.data!['roomName']!;
                      final propertyName = rp.data!['propertyName']!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              'tenant_detail.room_name'.tr, ':  $roomName'),
                          _buildInfoRow('tenant_detail.property_name'.tr,
                              ':  $propertyName'),
                          _buildInfoRow('tenant_detail.address'.tr,
                              ':  ${tenant['address'] ?? '—'}'),
                          if (dobStr.isNotEmpty)
                            _buildInfoRow(
                                'tenant_detail.date_of_birth'.tr, ':  $dobStr'),
                          _buildInfoRow('tenant_detail.profession'.tr,
                              ':  ${tenant['profession'] ?? '—'}'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // ID Card image
                  if (tenant['idCardImage'] != null &&
                      tenant['idCardImage'].toString().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID Card:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tenant['idCardImage'],
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Move Out',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CustomIconButton(icon: AppIcons.phone, onPressed: () {}),
                      const SizedBox(width: 20),
                      CustomIconButton(icon: AppIcons.badge, onPressed: () {}),
                      const SizedBox(width: 20),
                      CustomIconButton(
                          icon: AppIcons.edit,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddTenantsScreen(tenantId: widget.tenantId),
                              ),
                            );
                          }),
                      const SizedBox(width: 20),
                      CustomIconButton(
                          icon: AppIcons.payments, onPressed: () {}),
                    ],
                  ),

                  const SizedBox(height: 400),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildInfoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
