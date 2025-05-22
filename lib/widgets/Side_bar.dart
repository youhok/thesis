import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/widgets/Triangle_Painter.dart';

class Sidebar extends StatelessWidget {
  final Function(int) onItemSelected;

  const Sidebar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo and Title
        Column(
          children: [
            Image.asset(
              "images/10.png",
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
        // Menu Items
        Expanded(
          child: Column(
            children: [
              DrawerItem(
                icon: Icons.dashboard,
                text: "Dashboard",
                onTap: () => onItemSelected(0),
                isSelected: true,
              ),
              DrawerItem(
                icon: Icons.people,
                text: "Users",
                onTap: () => onItemSelected(1),
              ),
              DrawerItem(
                icon: Icons.notifications,
                text: "Push Notification",
                onTap: () => onItemSelected(2),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 150,
                  height: 300,
                  child: CustomPaint(
                    painter: TrianglePainter(
                        direction: TriangleDirection.right),
                  ),
                ),
              ),
              DrawerItem(
                icon: Icons.logout,
                text: "LogOut",
                onTap: () {
                  final auth = AuthService();
                  auth.signOut();
                  Get.offAllNamed('/login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final Function() onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.text,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the width is always consistent
      color: isSelected ? Colors.indigo[700] : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
      ),
    );
  }
}
