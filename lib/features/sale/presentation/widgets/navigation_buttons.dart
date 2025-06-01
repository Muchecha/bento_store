import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/shared/widgets/scale_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onNewSalePressed;
  final VoidCallback? onHomePressed;
  final String? newSaleButtonText;
  final String? homeButtonText;

  const NavigationButtons({
    super.key,
    this.onNewSalePressed,
    this.onHomePressed,
    this.newSaleButtonText,
    this.homeButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ScaleButton(
              text: newSaleButtonText ?? 'Iniciar Nova Venda',
              onPressed:
                  onNewSalePressed ??
                  () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.seller, (route) => false),
              backgroundColor: Colors.green.shade600,
              textColor: Colors.white,
              borderRadius: 8.r,
              fontSize: 16.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(color: Colors.grey[300]!, width: 1.2),
                ),
              ),
              onPressed:
                  onHomePressed ??
                  () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false),
              child: Text(
                homeButtonText ?? 'Voltar para a Tela Inicial',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
