import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/features/sale/domain/entities/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../widgets/navigation_buttons.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/success_icon.dart';

class PaymentSuccessPage extends StatelessWidget {
  final double totalAmount;
  final double amountPaid;
  final double change;
  final Sale sale;

  const PaymentSuccessPage({
    super.key,
    required this.totalAmount,
    required this.amountPaid,
    required this.change,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Bento Store',
          style: TextStyle(color: AppTheme.primaryColor, fontSize: 24.sp),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SuccessIcon(),
                      SizedBox(height: 24.h),
                      Text(
                        'Pagamento Realizado\ncom Sucesso!',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(height: 30.h),
                      PaymentSummaryCard(
                        sale: sale.id.toString(),
                        saller: sale.userId.toString(),
                        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        totalAmount: totalAmount,
                        amountPaid: amountPaid,
                        change: change,
                      ),
                    ],
                  ),
                ),
              ),

              NavigationButtons(),
            ],
          ),
        ],
      ),
    );
  }
}
