import 'package:bento_store/features/auth/presentarion/page/login_page.dart';
import 'package:bento_store/features/home/presentation/pages/home_page.dart';
import 'package:bento_store/features/product/presentation/pages/product_page.dart';
import 'package:bento_store/features/sale/domain/entities/sale.dart';
import 'package:bento_store/features/sale/presentation/pages/cash_payment_page.dart';
import 'package:bento_store/features/sale/presentation/pages/payment_success_page.dart';
import 'package:bento_store/features/sale/presentation/pages/sale_summary_page.dart';
import 'package:bento_store/features/seller/domain/entities/seller.dart';
import 'package:bento_store/features/seller/presentation/pages/seller_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String seller = '/seller';
  static const String product = '/product';
  static const String sale = '/sale';
  static const String cashPayment = '/cashPayment';
  static const String paymentSuccess = '/paymentSuccess';
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
      case product:
        return MaterialPageRoute(
          builder: (_) => ProductPage(seller: settings.arguments as Seller),
        );
      case sale:
        return MaterialPageRoute(
          builder:
              (context) => SaleSummaryPage(sale: settings.arguments as Sale),
        );
      case cashPayment:
        return MaterialPageRoute(
          builder:
              (context) => CashPaymentPage(
                total:
                    (settings.arguments as Map<String, dynamic>)['total']
                        as double,
                sale:
                    (settings.arguments as Map<String, dynamic>)['sale']
                        as Sale,
              ),
        );
      case paymentSuccess:
        return MaterialPageRoute(
          builder:
              (context) => PaymentSuccessPage(
                totalAmount:
                    (settings.arguments as Map<String, dynamic>)['totalAmount']
                        as double,
                amountPaid:
                    (settings.arguments as Map<String, dynamic>)['amountPaid']
                        as double,
                change:
                    (settings.arguments as Map<String, dynamic>)['change']
                        as double,
                sale:
                    (settings.arguments as Map<String, dynamic>)['sale']
                        as Sale,
              ),
        );
      case adminHome:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case adminSales:
        return MaterialPageRoute(builder: (context) => const LoginPage());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('Route not found ${settings.name}')),
              ),
        );
    }
  }
}
