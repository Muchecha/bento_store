import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/features/home/presentation/widget/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {
        'title': 'Cancelar Vendas',
        'subtitle': 'Gerenciar vendas realizadas',
        'icon': Icons.cancel_rounded,
        'onTap': () => Navigator.pushNamed(context, AppRouter.adminSales),
        'isPrimary': false,
      },
      {
        'title': 'Iniciar Venda',
        'subtitle': 'Realizar nova\nTransação',
        'icon': Icons.shopping_cart_rounded,
        'onTap': () => Navigator.pushNamed(context, AppRouter.seller),
        'isPrimary': true,
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index];
        return MainButton(
          title: button['title'],
          subtitle: button['subtitle'],
          icon: button['icon'],
          onTap: button['onTap'],
          isPrimary: button['isPrimary'] ?? false,
        );
      },
    );
  }
}
