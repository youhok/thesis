import 'package:get/get.dart';
import 'package:sankaestay/screen/login_screen.dart';
import 'package:sankaestay/screen/start_screen.dart';
import 'package:sankaestay/screen/super_admin.dart';

class AdminRoutes {
  static String initialRoute = '/login';

  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: '/super-admin',
      page: () => const SuperAdminScreen(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const StartScreen(),
    ),
  ];
}
