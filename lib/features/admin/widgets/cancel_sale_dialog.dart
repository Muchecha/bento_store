import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/features/admin/service/cubit/admin_sale_cubit.dart';
import 'package:bento_store/features/sale/domain/entities/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelSaleDialog extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CancelSaleDialog({
    super.key,
    required this.sale,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.w),
          SizedBox(width: 12.w),
          Text(
            'Cancelar Venda',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        'Tem certeza que deseja cancelar a venda #${sale.id}?\n\nEsta ação não pode ser desfeita.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.secondaryColor,
          fontWeight: FontWeight.normal,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AdminSaleCubit>().cancelSale(sale.id!);
            Navigator.pop(context);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context,
    dynamic sale, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => CancelSaleDialog(
            sale: sale,
            onConfirm: onConfirm,
            onCancel: onCancel,
          ),
    );
  }
}
