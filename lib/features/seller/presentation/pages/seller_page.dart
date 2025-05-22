import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/ui_error_helper.dart';
import 'package:bento_store/features/seller/presentation/widgets/seller_list_item.dart';
import 'package:bento_store/features/seller/service/cubit/seller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.textColor,
          onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.home),
        ),
        title: Text('Deep Store', style: TextStyle(color: AppTheme.primaryColor, fontSize: 18.sp)),
      ),
      body: BlocBuilder<SellerCubit, SellerState>(
        builder: (context, state) {
          if (state is SellerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SellerError) {
            final isNetworkError =
                state.error.contains('conexão') ||
                state.error.contains('internet') ||
                state.error.contains('servidor');

            if (isNetworkError) {
              return NetworkErrorWidget(
                message: state.error,
                onRetry: () {
                  context.read<SellerCubit>().loadSellers();
                },
              );
            } else {
              return AppErrorWidget(
                message: state.error,
                onRetry: () {
                  context.read<SellerCubit>().loadSellers();
                },
              );
            }
          } else if (state is SellerLoaded) {
            return Column(
              children: [
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    'Selecione o Vendedor',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.textColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 0,
                      childAspectRatio: 4,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    itemCount: state.sellers.length,
                    itemBuilder: (context, index) {
                      final seller = state.sellers[index];
                      return SellerListItem(
                        seller: seller,
                        isSelected: state.selectedSeller?.id == seller.id,
                        onTap: () {
                          context.read<SellerCubit>().selectSeller(seller);
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
      bottomNavigationBar: BlocBuilder<SellerCubit, SellerState>(
        builder: (context, state) {
          if (state is SellerLoaded) {
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
              child: ElevatedButton(
                onPressed:
                    state.selectedSeller != null
                        ? () => Navigator.pushNamed(
                          context,
                          AppRouter.product,
                          arguments: state.selectedSeller,
                        )
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  disabledBackgroundColor: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
