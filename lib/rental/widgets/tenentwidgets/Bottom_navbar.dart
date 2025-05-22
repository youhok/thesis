import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sankaestay/rental/screen/tenants/bookmark_screen.dart';
import 'package:sankaestay/rental/screen/tenants/dashboard_screen.dart';
import 'package:sankaestay/rental/screen/tenants/home_screen.dart';
import 'package:sankaestay/rental/screen/tenants/map_screen.dart';
import 'package:sankaestay/rental/screen/tenants/setting_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/util/constants.dart';


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentTabIndex = 0;

  // List of pages
  final List<Widget> pages = [
    const HomeScreen(),
    const MapScreen(),
    const DashboardScreen(),
    const BookmarkScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryGrey, // Keep background color consistent
      body: Column(
        children: [
          // Common AppBar
          Container(
            padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
            height: 90,
            color: AppColors.primaryBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('images/sangkaestay.ico', height: 40),
                    const SizedBox(width: 10),
                    const Text(
                      'SangkaeStay',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications, color: Colors.white),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Text('5', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main Content Area - Switch between screens
          Expanded(
            child: IndexedStack(
              index: currentTabIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.grey[200]!, // Matches body background
        color: AppColors.primaryBlue, // Active tab background
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(AppIcons.home, color: Colors.white, size: 25),
          Icon(AppIcons.maps, color: Colors.white, size: 25),
          Icon(AppIcons.dashboard, color: Colors.white, size: 25),
          Icon(AppIcons.bookmark, color: Colors.white, size: 25),
          Icon(AppIcons.settings, color: Colors.white, size: 25),
        ],
      ),
    );
  }
}
