import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class MainButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const MainButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0.5,
        padding: EdgeInsets.all(12.w),
        backgroundColor: isPrimary ? AppTheme.secondaryColor : Colors.white,
        foregroundColor: isPrimary ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: isPrimary ? AppTheme.secondaryColor : Colors.grey[300]!,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Icon(icon, color: AppTheme.primaryColor, size: 32.w)],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isPrimary ? Colors.white : AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color:
                        isPrimary
                            ? AppTheme.surfaceColor
                            : AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
