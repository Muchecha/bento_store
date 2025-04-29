import 'package:bento_store/features/auth/presentarion/page/login_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String seller = '/seller';
  static const String product = '/product';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('Route not found ${settings.name}'))));
    }
  }
}