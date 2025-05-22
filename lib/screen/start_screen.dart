import 'package:flutter/material.dart';
import 'package:sankaestay/screen/dashboard_screen.dart';
import 'package:sankaestay/screen/push_notification.dart';
import 'package:sankaestay/screen/user_screen.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Side_bar.dart';
import 'package:sankaestay/widgets/nav_bar.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    UserScreen(),
    PushNotification(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar without Drawer wrapper
                SizedBox(
                  width: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      // Remove rounded corners on the right
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Sidebar(onItemSelected: _onItemSelected),
                  ),
                ),
                // Main content area
                Expanded(
                  child: Column(
                    children: [
                      // Navbar at the top
                      PreferredSize(
                        preferredSize: Size.fromHeight(60),
                        child: Navbar(),
                      ),
                      // Page content
                      Expanded(
                        child: _pages[_selectedIndex],
                      ),
                      // Footer can be added here in the future
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}