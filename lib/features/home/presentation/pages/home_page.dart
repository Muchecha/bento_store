import 'package:bento_store/core/config/env_config.dart';
import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/core/utils/calculateRespoonsive.dart';
import 'package:bento_store/features/auth/service/cubit/auth_cubit.dart';
import 'package:bento_store/features/auth/service/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/main_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final titleSize = CalculateResponsive.fontSize(screenWidth, 0.05, 30, 36);
    final subtitleSize = CalculateResponsive.fontSize(screenWidth, 0.02, 14, 18);
    final inputTextSize = CalculateResponsive.fontSize(screenWidth, 0.02, 14, 18);
    final buttonTextSize = CalculateResponsive.fontSize(screenWidth, 0.018, 12, 18);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              color: AppTheme.primaryColor,
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/app_icon.png',
                        width: screenWidth * 0.5,
                        height: screenWidth * 0.5,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                      Column(
                        children: [
                          Text(
                            EnvConfig.appName,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Sistema de Vendas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: subtitleSize,
                              color: AppTheme.secondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MainButton(
                        title: 'Iniciar Venda',
                        subtitle: 'Realizar nova transação',
                        icon: Icons.shopping_cart_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.seller),
                        isPrimary: true,
                      ),
                      SizedBox(height: 16.h),
                      MainButton(
                        title: 'Cancelar Vendas',
                        subtitle: 'Gerenciar vendas realizadas',
                        icon: Icons.cancel_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.adminSales),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
