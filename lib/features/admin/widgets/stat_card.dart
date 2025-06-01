import 'package:bento_store/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;
  final Color? titleColor;
  final double? iconSize;
  final double? valueSize;
  final double? titleSize;
  final VoidCallback? onTap;
  final bool showBackground;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
    this.titleColor,
    this.iconSize,
    this.valueSize,
    this.titleSize,
    this.onTap,
    this.showBackground = false,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.primaryColor,
              size: iconSize ?? 24.w,
            ),
            SizedBox(width: 8.w),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: valueSize ?? 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white.withValues(alpha: 0.9),
            fontSize: titleSize ?? 12.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (showBackground) {
      content = Container(
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              backgroundColor ?? AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
