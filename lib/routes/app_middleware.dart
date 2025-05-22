import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    bool isAuthenticated = false;

    if (!isAuthenticated && route != '/login') {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class SuperAdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null;
  }
}
