import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/format_utils.dart';
import 'package:bento_store/features/sale/domain/entities/sale.dart';
import 'package:bento_store/features/sale/presentation/widgets/animated_change_display.dart';
import 'package:bento_store/features/sale/presentation/widgets/quick_amount_buttons.dart';
import 'package:bento_store/features/sale/service/cubit/sale_cubit.dart';
import 'package:bento_store/features/seller/service/cubit/seller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CashPaymentPage extends StatefulWidget {
  final double total;
  final Sale sale;

  const CashPaymentPage({super.key, required this.total, required this.sale});

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  double _change = 0.0;
  double _amountPaid = 0.0;
  bool _isProcessing = false;
  late AnimationController _processAnimController;

  @override
  void initState() {
    super.initState();
    _change = 0 - widget.total;
    _processAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _processAnimController.dispose();
    super.dispose();
  }

  void _setAmountPaid(double amount) {
    setState(() {
      _amountPaid = amount;
      _change = amount - widget.total;
      _amountController.text = FormatUtils.formatCurrency(amount);
    });
  }

  void _startProcessingAnimation() {
    setState(() {
      _isProcessing = true;
    });
    _processAnimController.repeat();
  }

  void _finalizeSale() {
    _startProcessingAnimation();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.read<SaleCubit>().finalizeSale();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleCubit, SaleState>(
      listener: (context, state) {
        if (state is SaleSuccess) {
          _processAnimController.stop();
          context.read<SellerCubit>().clearSelectedSeller();

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.paymentSuccess,
            (route) => false,
            arguments: {
              'totalAmount': widget.total,
              'amountPaid': _amountPaid,
              'change': _change,
              'sale': state.sale,
            },
          );
        } else if (state is SaleError) {
          _processAnimController.stop();
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
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
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    'Pagamento em Dinheiro',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Column(
                    children: [
                      Text(
                        'Valor Total',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        FormatUtils.formatCurrencyWithSymbol(widget.total),
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  MultiSelectQuickAmountButtons(
                    onTotalChanged: (double amount) {
                      _setAmountPaid(amount);
                    },
                    onAmountSelected: (double amount, int quantity) {},
                  ),
                  SizedBox(height: 12.h),
                  AnimatedChangeDisplay(change: _change),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: SizedBox(
                      height: 48.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isProcessing || _change <= 0
                                ? null
                                : _finalizeSale,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child:
                            _isProcessing
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Processando...',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  'Finalizar Pagamento',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
