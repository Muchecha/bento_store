import 'package:bento_store/core/utils/format_utils.dart';
import 'package:bento_store/features/sale/service/cubit/sale_cubit.dart';
import 'package:bento_store/features/seller/domain/entities/seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final Seller seller;
  final bool isDisabled;

  String _getFirstFourWords(String text) {
    final words = text.split(' ');
    return words.length <= 4 ? text : words.take(4).join(' ');
  }

  const ProductListItem({
    super.key,
    required this.product,
    required this.seller,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleCubit, SaleState>(
      builder: (context, state) {
        final saleCubit = context.read<SaleCubit>();
        final quantity = saleCubit.getProductQuantity(product.id);
        final isSelected = saleCubit.isProductInCart(product.id);

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Material(
            color: isDisabled ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12.r),

            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Stack(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: product.image,
                            width: 50.w,
                            height: 50.w,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                              width: 80.w,
                              height: 80.w,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget:
                                (context, url, error) => Container(
                              width: 50.w,
                              height: 50.w,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getFirstFourWords(product.title),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDisabled ? Colors.grey[500] : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Cod.:${product.id}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                isDisabled
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              FormatUtils.formatCurrencyWithSymbol(product.price),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                isDisabled
                                    ? Colors.grey[400]
                                    : AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isDisabled && !isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.white.withAlpha(128),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(204),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Limite atingido',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child:
                    Container(
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: isDisabled ? Colors.grey[200] : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isDisabled ? null : () => saleCubit.toggleRemoveProduct(seller, product, context: context),
                              borderRadius: BorderRadius.circular(14.r),
                              child: Container(
                                width: 28.w,
                                height: 28.h,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.remove,
                                  color: isDisabled ? Colors.grey[400] : AppTheme.primaryColor,
                                  size: 16.w,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(minWidth: 24.w),
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Text(
                                '$quantity',
                                key: ValueKey<int>(quantity),
                                style: TextStyle(
                                  color: isDisabled ? Colors.grey[600] : AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isDisabled ? null : () => saleCubit.toggleProduct(seller, product, context: context),
                              borderRadius: BorderRadius.circular(14.r),
                              child: Container(
                                width: 28.w,
                                height: 28.h,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add,
                                  color: isDisabled ? Colors.grey[400] : AppTheme.primaryColor,
                                  size: 16.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}