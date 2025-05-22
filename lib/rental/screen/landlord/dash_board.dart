// lib/rental/screen/dashboard.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/screen/notification/notification_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/App_Drawer.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/build_Stat_Card.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int totalTenants = 0;
  int totalProperties = 0;
  int totalRooms = 0;

  List<Map<String, dynamic>> tenants = [];
  final Map<String, String> roomNames = {};
  final Map<String, String> propertyNames = {};

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    fetchAllData();
  }

  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      await prefs.setString('userName', data['name'] ?? '');
      await prefs.setString('userImageUrl', data['imageURL'] ?? '');
      await prefs.setString('userTelegram', data['telegram'] ?? '');
      await prefs.setString('userEmail', data['email'] ?? '');
      await prefs.setString('userPhoneNumber', data['phone'] ?? '');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(String name) {
    final completer = Completer<List<Map<String, dynamic>>>();
    getCollectionQuery(
      collectionName: name,
      callback: (List<Map<String, dynamic>> data) {
        completer.complete(data);
      },
    );
    return completer.future;
  }

  Future<void> fetchAllData() async {
    try {
      final tenantsData = await _fetchCollection('tenants');
      final roomsData = await _fetchCollection('rooms');
      final propsData = await _fetchCollection('properties');

      roomNames.clear();
      for (var r in roomsData) {
        final id = (r['id'] ?? r['roomID']) as String? ?? '';
        final name = r['name'] as String? ?? '(unnamed room)';
        roomNames[id] = name;
      }

      propertyNames.clear();
      for (var p in propsData) {
        final id = (p['id'] ?? p['propertyID']) as String? ?? '';
        final name = p['name'] as String? ??
            p['propertyTitle'] as String? ??
            '(unnamed property)';
        propertyNames[id] = name;
      }

      final merged = tenantsData.map((t) {
        final rid = t['roomID'] as String? ?? '';
        return {
          ...t,
          'roomName': roomNames[rid] ?? '(unknown room)',
        };
      }).toList();

      setState(() {
        tenants = merged;
        totalTenants = tenantsData.length;
        totalRooms = roomsData.length;
        totalProperties = propsData.length;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: AppDrawer(selectedItem: "Dashboard"),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leadingWidth: 180,
        leading: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(AppIcons.menu, color: Colors.white, size: 30),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'dashboardlandlord.title'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BuildStatCard(
                  label: 'dashboardlandlord.total_property'.tr,
                  color: Colors.blue,
                  icon: Icons.apartment,
                  total: totalProperties,
                ),
                BuildStatCard(
                  label: 'dashboardlandlord.total_tenants'.tr,
                  color: Colors.red,
                  icon: Icons.person_outline,
                  total: totalTenants,
                ),
                BuildStatCard(
                  label: 'dashboardlandlord.total_rooms'.tr,
                  color: Colors.green,
                  icon: Icons.home_outlined,
                  total: totalRooms,
                ),
              ],
            ),
          ),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'dashboardlandlord.recent_tenants'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'dashboardlandlord.view_all'.tr,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (tenants.isEmpty)
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            "images/undraw_no-data_ig65-removebg-preview.png",
                            height: 250,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: tenants.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (ctx, i) {
                            final t = tenants[i];
                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: InkWell(
                                onTap: () {
                                  // TODO: Navigate to tenant detail
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          t['profileImage'] ??
                                              'https://via.placeholder.com/60',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, _, __) =>
                                              const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t['name'] ?? 'No Name',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              t['phoneNumber'] ??
                                                  t['phone'] ??
                                                  '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  "Room: ${t['roomName']}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
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
          ),
        ],
      ),
    );
  }
}
