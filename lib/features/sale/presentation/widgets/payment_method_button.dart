import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback onTap;

  const PaymentMethodButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isEnabled ? AppTheme.secondaryColor : Colors.grey[300]!,
                isEnabled
                    ? AppTheme.secondaryColor.withValues(alpha: 0.8)
                    : Colors.grey[300]!,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isEnabled ? AppTheme.primaryColor : Colors.grey[400],
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isEnabled ? AppTheme.surfaceColor : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
