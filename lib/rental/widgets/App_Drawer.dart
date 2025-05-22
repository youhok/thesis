import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/role/role_screen.dart';
import 'package:sankaestay/rental/screen/landlord/booking/booking.dart';
import 'package:sankaestay/rental/screen/landlord/dash_board.dart';
import 'package:sankaestay/rental/screen/landlord/invoice/invoice_list_screen.dart';
import 'package:sankaestay/rental/screen/landlord/payment/payment_screen.dart';
import 'package:sankaestay/rental/screen/landlord/properties/property_screen.dart';
import 'package:sankaestay/rental/screen/landlord/properties/rooms/rooms_with_property.dart';
import 'package:sankaestay/rental/screen/landlord/settings/setting.dart';
import 'package:sankaestay/rental/screen/landlord/tenants_screen.dart';

import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/composables/useAuth.dart';

// Import your actual screens below:

class AppDrawer extends StatelessWidget {
  final String selectedItem;

  const AppDrawer({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.primaryBlue,
        child: Column(
          children: [
            // Logo and title
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  Image.asset(
                    "images/sangkaestay.ico",
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "SangkaeStay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    AppIcons.dashboard,
                    "drawerlandlord.dashboard".tr,
                    selectedItem == "Dashboard",
                    onTap: () {
                      Get.to(() => Dashboard());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.home,
                    "drawerlandlord.properties".tr,
                    selectedItem == "Properties",
                    onTap: () {
                      Get.to(() => PropertyScreen());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.home,
                    "drawerlandlord.room".tr,
                    selectedItem == "Rooms",
                    onTap: () {
                      Get.to(() => RoomsWithProperty());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.people,
                    "drawerlandlord.tenants".tr,
                    selectedItem == "Tenants",
                    onTap: () {
                      Get.to(() => TenantsScreen());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.booking,
                    "drawerlandlord.bookings".tr,
                    selectedItem == "Receipt",
                    onTap: () {
                      Get.to(() => Booking());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.payments,
                    "drawerlandlord.payments".tr,
                    selectedItem == "Premium",
                    onTap: () {
                      Get.to(() => PaymentScreen());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.invoice,
                    "drawerlandlord.invoices".tr,
                    selectedItem == "Premium",
                    onTap: () {
                      Get.to(() => InvoiceListScreen());
                    },
                  ),
                  _buildDrawerItem(
                    AppIcons.settings,
                    "drawerlandlord.settings".tr,
                    selectedItem == "Settings",
                    onTap: () {
                      Get.to(() => Setting());
                    },
                  ),
                ],
              ),
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildDrawerItem(
                Icons.logout,
                "drawerlandlord.logout".tr,
                false,
                color: Colors.red,
                onTap: () async {
                  final auth = AuthService();
                  await auth.signOut();
                  Get.offAll(() => const RoleScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isSelected, {
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
