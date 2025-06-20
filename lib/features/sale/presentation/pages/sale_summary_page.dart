import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/format_utils.dart';
import 'package:bento_store/features/sale/domain/entities/sale.dart';
import 'package:bento_store/features/sale/presentation/widgets/payment_method_button.dart';
import 'package:bento_store/features/sale/presentation/widgets/sale_summary_item.dart';
import 'package:bento_store/features/sale/service/cubit/sale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SaleSummaryPage extends StatelessWidget {
  final Sale sale;

  const SaleSummaryPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final List<PaymentMethodData> paymentMethods = [
      PaymentMethodData(
        icon: Icons.attach_money_rounded,
        label: 'Dinheiro',
        isEnabled: true,
        onTap: () {
          context.read<SaleCubit>().canProceedToPayment();
        },
      ),
      PaymentMethodData(
        icon: Icons.qr_code_rounded,
        label: 'Pix',
        isEnabled: false,
        onTap: () {},
      ),
      PaymentMethodData(
        icon: Icons.credit_card_rounded,
        label: 'Crédito',
        isEnabled: false,
        onTap: () {},
      ),
      PaymentMethodData(
        icon: Icons.credit_card_rounded,
        label: 'Débito',
        isEnabled: false,
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppTheme.textColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bento Store',
          style: TextStyle(color: AppTheme.primaryColor, fontSize: 24.sp),
        ),
      ),
      body: BlocBuilder<SaleCubit, SaleState>(
        builder: (context, state) {
          if (state is SaleLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.sale.products.length,
                    itemBuilder: (context, index) {
                      final product = state.sale.products[index];
                      return SaleSummaryItem(product: product);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        // padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Total da Venda',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              FormatUtils.formatCurrencyWithSymbol(state.total),
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      Text(
                        'Selecione a forma de pagamento',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4.h),
                      BlocListener<SaleCubit, SaleState>(
                        listener: (context, state) {
                          if (state is SaleCanProceedToPayment) {
                            Navigator.pushNamed(
                              context,
                              AppRouter.cashPayment,
                              arguments: {"total": state.total, "sale": sale},
                            );
                          }
                          if (state is SaleCanNotProceedToPaymentError) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.message,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.amber.shade700,
                                duration: Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                              ),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            return PaymentMethodButton(
                              icon: method.icon,
                              label: method.label,
                              isEnabled: method.isEnabled,
                              onTap: method.onTap,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PaymentMethodData {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback onTap;

  PaymentMethodData({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.onTap,
  });
}
