import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/format_utils.dart';
import 'package:bento_store/features/admin/widgets/cancel_sale_dialog.dart';
import 'package:bento_store/features/sale/domain/entities/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SaleCard extends StatelessWidget {
  final Sale sale;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final Function(double)? calculateTotal;

  const SaleCard({
    super.key,
    required this.sale,
    required this.index,
    this.onTap,
    this.onCancel,
    this.calculateTotal,
  });

  @override
  Widget build(BuildContext context) {
    final total = calculateTotal?.call(_getSaleTotal()) ?? _getSaleTotal();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 16.h),
                _buildSaleInfo(),
                SizedBox(height: 16.h),
                _buildTotalSection(total),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            'Venda #${sale.id}',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () => _handleCancel(context),
          icon: Icon(Icons.cancel_outlined, color: Colors.red[400], size: 24.w),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red[50],
            padding: EdgeInsets.all(8.w),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.person_2_rounded,
          text: 'Vendedor: ID - ${sale.userId}',
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          icon: Icons.shopping_bag_rounded,
          text: '${sale.products?.length ?? 0} produto(s)',
        ),
      ],
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 16.w),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildTotalSection(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total:',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
        ),
        Text(
          FormatUtils.formatCurrencyWithSymbol(total),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  void _handleCancel(BuildContext context) {
    CancelSaleDialog.show(context, sale, onConfirm: onCancel);
  }

  double _getSaleTotal() {
    double total = 0.0;

    try {
      if (sale.products != null && sale.products is List) {
        for (var product in sale.products) {
          if (product != null && product.price != null) {
            var price = product.price;
            if (price is int) {
              price = price.toDouble();
            }
            total += price;
          }
        }
      }
    } catch (e) {
      print('Erro ao calcular valor total: $e');
    }

    return total;
  }
}
