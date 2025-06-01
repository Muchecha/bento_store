import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/calculate_list_total_sale.dart';
import 'package:bento_store/core/utils/format_utils.dart';
import 'package:bento_store/core/utils/ui_error_helper.dart';
import 'package:bento_store/features/admin/service/cubit/admin_sale_cubit.dart';
import 'package:bento_store/features/admin/widgets/sale_card.dart';
import 'package:bento_store/features/admin/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminSalePage extends StatefulWidget {
  const AdminSalePage({super.key});

  @override
  State<AdminSalePage> createState() => _AdminSalePageState();
}

class _AdminSalePageState extends State<AdminSalePage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminSaleCubit>().loadSales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID da venda',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[400]),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
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
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<AdminSaleCubit, AdminSaleState>(
        listener: (context, state) {
          if (state is AdminSaleError) {
            UIErrorHelper.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminSaleLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Carregando vendas...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                  ),
                ],
              ),
            );
          }

          if (state is AdminSaleError) {
            final isNetworkError =
                state.message.contains('conexão') ||
                state.message.contains('internet') ||
                state.message.contains('servidor');

            if (isNetworkError) {
              return NetworkErrorWidget(
                message: state.message,
                onRetry: () => context.read<AdminSaleCubit>().loadSales(),
              );
            } else {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<AdminSaleCubit>().loadSales(),
              );
            }
          }

          if (state is AdminSaleLoaded) {
            final filteredSales =
                state.sales.where((sale) {
                  if (_searchQuery.isEmpty) return true;
                  return sale.id.toString().contains(_searchQuery) ||
                      sale.userId.toString().contains(_searchQuery);
                }).toList();

            return RefreshIndicator(
              onRefresh: () => context.read<AdminSaleCubit>().loadSales(),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondaryColor,
                          AppTheme.secondaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total de Vendas',
                            value: '${filteredSales.length}',
                            icon: Icons.shopping_cart_rounded,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: StatCard(
                            title: 'Valor Total',
                            value: SaleCalculator.calculateListTotalValue(
                              filteredSales,
                            ).toStringAsFixed(2),
                            icon: Icons.monetization_on_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: filteredSales.length,
                      itemBuilder: (context, index) {
                        final sale = filteredSales[index];
                        return SaleCard(
                          sale: sale,
                          index: index,
                          onTap: () => _showSaleDetails(context, sale),
                          onCancel: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Venda #${sale.id} cancelada'),
                              ),
                            );
                            context.read<AdminSaleCubit>().loadSales();
                          },
                        );
                        // return _buildSaleCard(context, sale, index);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showSaleDetails(BuildContext context, dynamic sale) {
    final total = SaleCalculator.calculateSingleSaleValue(sale);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Detalhes da Venda #${sale.id}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: sale.products.length,
                    itemBuilder: (context, index) {
                      final product = sale.products[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                product.image,
                                width: 50.w,
                                height: 50.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50.w,
                                    height: 50.w,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'R\$ ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
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
                ),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total da Venda:',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        FormatUtils.formatCurrencyWithSymbol(total),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
