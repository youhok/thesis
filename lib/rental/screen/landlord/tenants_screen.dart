import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/getCollectin.dart'; // your custom function
import 'package:sankaestay/rental/screen/landlord/addtenants_screen.dart';
import 'package:sankaestay/rental/screen/landlord/tenants_detail_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';

class TenantsScreen extends StatefulWidget {
  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  //–– your property filters (if you need them later) ––
  var selectedProperty = Rx<String?>(null);
  var propertyOptions = <String>[].obs;
  var propertyIDs = <String>[].obs;

  //–– tenants data & subscription ––
  final RxList<Map<String, dynamic>> tenants = <Map<String, dynamic>>[].obs;
  StreamSubscription? tenantsSubscription;

  @override
  void initState() {
    super.initState();
    loadTenantsRealtime();
  }

  @override
  void dispose() {
    tenantsSubscription?.cancel();
    super.dispose();
  }

  /// Uses your generic getCollectionQuery to listen to 'tenants'
  void loadTenantsRealtime() async {
    tenantsSubscription = await getCollectionQuery(
      collectionName: 'tenants',
      useSnapshot: true,
      callback: (List<Map<String, dynamic>> data) {
        tenants.assignAll(data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "tenant.title".tr,
      child: Stack(
        children: [
          Column(
            children: [
              // optional search/filter field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'tenant.placeholders'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.secondaryBlue,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),

              // tenant list
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() {
                    if (tenants.isEmpty) {
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

                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: tenants.length,
                      itemBuilder: (context, index) {
                        final tenant = tenants[index];

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // profile image
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        tenant['profileImage'] ?? '',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.person,
                                              size: 60, color: Colors.grey);
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  // name, phone, room & duration
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tenant['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tenant['phoneNumber'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // room name fetch
                                            Expanded(
                                              child: FutureBuilder<
                                                  DocumentSnapshot>(
                                                future: FirebaseFirestore
                                                    .instance
                                                    .collection('rooms')
                                                    .doc(tenant['roomID'])
                                                    .get(),
                                                builder:
                                                    (context, roomSnapshot) {
                                                  if (roomSnapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading room...",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    );
                                                  }
                                                  if (!roomSnapshot.hasData ||
                                                      !roomSnapshot
                                                          .data!.exists) {
                                                    return const Text(
                                                      "Room: N/A",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    );
                                                  }
                                                  final roomData = roomSnapshot
                                                          .data!
                                                          .data()
                                                      as Map<String, dynamic>?;
                                                  final roomName =
                                                      roomData?['name'] ??
                                                          'Unnamed Room';
                                                  return Text(
                                                    "Room: $roomName",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[700]),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // detail button
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TenantsDetailScreen(
                                            tenantId: tenant['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),

          // add tenant button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddTenantsScreen()));
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(AppIcons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
