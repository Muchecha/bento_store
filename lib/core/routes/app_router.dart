import 'package:bento_store/features/auth/presentarion/page/login_page.dart';
import 'package:bento_store/features/home/presentation/pages/home_page.dart';
import 'package:bento_store/features/seller/presentation/pages/seller_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String seller = '/seller';
  static const String product = '/product';

  static const String adminHome = '/admin-home';
  static const String adminSales = '/admin-sales';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case seller:
        return MaterialPageRoute(builder: (_) => const SellerPage());
      case adminHome:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case adminSales:
        return MaterialPageRoute(builder: (context) => const LoginPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('Route not found ${settings.name}'))),
        );
    }
  }
}
