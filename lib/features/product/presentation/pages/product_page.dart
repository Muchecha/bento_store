import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/format_utils.dart';
import 'package:bento_store/features/product/presentation/widgets/product_list_item.dart';
import 'package:bento_store/features/product/presentation/widgets/product_loading_shimmer.dart';
import 'package:bento_store/features/product/service/cubit/product_cubit.dart';
import 'package:bento_store/features/sale/service/cubit/sale_cubit.dart';
import 'package:bento_store/features/seller/domain/entities/seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductPage extends StatelessWidget {
  final Seller seller;

  const ProductPage({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          color: AppTheme.textColor,
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed:
              () => Navigator.pushReplacementNamed(context, AppRouter.seller),
        ),
        title: Text(
          'Bento Store',
          style: TextStyle(color: AppTheme.primaryColor, fontSize: 24.sp),
        ),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const ProductLoadingShimmer();
          } else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductCubit>().loadProducts();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          } else if (state is ProductLoaded) {
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (query) {
                          context.read<ProductCubit>().searchProducts(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar produto',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return BlocBuilder<SaleCubit, SaleState>(
                        builder: (context, saleState) {
                          final isSelected =
                              saleState is SaleLoaded &&
                              saleState.sale.products.contains(product);
                          final isAtMaxLimit =
                              saleState is SaleLoaded &&
                              saleState.sale.products.length >=
                                  SaleCubit.maxProducts;

                          return ProductListItem(
                            key: ValueKey(product.id),
                            product: product,
                            seller: seller,
                            isDisabled: !isSelected && isAtMaxLimit,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<SaleCubit, SaleState>(
        builder: (context, state) {
          if (state is SaleLoaded) {
            return Container(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de ${state.sale.products.length > 1 ? 'Itens' : 'Item'}: ${state.sale.products.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        FormatUtils.formatCurrencyWithSymbol(state.total),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      state.sale.products.isNotEmpty
                          ? Navigator.pushNamed(
                            context,
                            AppRouter.sale,
                            arguments: state.sale,
                          )
                          : null;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          state.sale.products.isNotEmpty
                              ? AppTheme.secondaryColor
                              : Colors.grey[400],
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_rounded,
                          color: Colors.white,
                          size: 24.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Ver Carrinho',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppTheme.surfaceColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total de item: 0',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      FormatUtils.formatCurrencyWithSymbol(0),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Ver Carrinho',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.surfaceColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
