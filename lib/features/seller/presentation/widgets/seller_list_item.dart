import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/seller.dart';

class SellerListItem extends StatelessWidget {
  final Seller seller;
  final bool isSelected;
  final VoidCallback onTap;

  const SellerListItem({
    super.key,
    required this.seller,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
              color: isSelected ? AppTheme.primaryColor.withAlpha(26) : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      seller.name[0].toUpperCase() + seller.name.split(' ')[1][0].toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        seller.name.split(' ').map((word) =>
                        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
                        ).join(' '),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'ID: ${seller.id}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected ? AppTheme.secondaryColor : Colors.grey[600]
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            seller.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected ? AppTheme.secondaryColor : Colors.grey[600]
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                    child: Icon(Icons.check, color: Colors.white, size: 16.w),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
